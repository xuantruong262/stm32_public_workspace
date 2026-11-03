#include "boot_manager.h"

#include "boot_image.h"
#include "boot_flash.h"
#include "boot_flash_layout.h"
#include "boot_swap.h"
#include "main.h"

#ifdef BOOT_SIL
extern void boot_sil_record_jump(uint32_t msp, uint32_t reset_handler);
#endif

#ifndef BOOT_SIL
static void boot_disable_interrupts(void)
{
    __disable_irq();
    SysTick->CTRL = 0U;
    SysTick->LOAD = 0U;
    SysTick->VAL = 0U;
    for (uint32_t i = 0U; i < 8U; ++i) {
        NVIC->ICER[i] = 0xFFFFFFFFUL;
        NVIC->ICPR[i] = 0xFFFFFFFFUL;
    }
}
#endif

void boot_jump_to_primary(void)
{
    const uint32_t *vector = (const uint32_t *)boot_flash_read_ptr(BOOT_APP_VECTOR_ADDRESS);
    const uint32_t app_msp = vector[0];
    const uint32_t app_reset = vector[1];

#ifdef BOOT_SIL
    boot_sil_record_jump(app_msp, app_reset);
    return;
#else
    boot_disable_interrupts();
    /* Do not call HAL_RCC_DeInit() here. On STM32H7 it changes the active
     * RCC/PLL tree before the application has established its own clock and
     * time base; this caused an imprecise bus fault in the S1 hardware test.
     * The hand-off contract requires each application to initialize all clocks
     * and peripherals it owns after Reset_Handler. */
    /* Do not perform set/way cache maintenance during the basic hand-off.
     * S1 has no shared DMA buffer or cacheable RAM ownership to transfer, and
     * SCB->DCCISW caused a bus fault on the target before VTOR/MSP changed.
     * Cache/DMA ownership will be introduced only with an explicit contract. */
    SCB->VTOR = BOOT_APP_VECTOR_ADDRESS;
    __DSB();
    __ISB();
    __set_CONTROL(0U);
    __set_MSP(app_msp);
    __DSB();
    __ISB();
    /* The application owns its interrupts (including SysTick used by HAL_Delay).
     * They were disabled only to make the hand-off atomic. */
    __enable_irq();
    ((void (*)(void))(uintptr_t)app_reset)();
    while (1) {
    }
#endif
}

#if !defined(BOOT_S1_DIRECT_HANDOFF) && !defined(BOOT_S2_PRIMARY_VALIDATION)
static bool boot_record_matches_image(boot_slot_t slot, const boot_trailer_record_t *record)
{
    return record->image_crc32 == boot_image_header(slot)->payload_crc32;
}
#endif

bool boot_manager_run(void)
{
#ifdef BOOT_S1_DIRECT_HANDOFF
    /* S1 proves only vector hand-off. This profile is built in a separate
     * directory and is never the production boot decision. */
    boot_jump_to_primary();
    return true;
#elif defined(BOOT_S2_PRIMARY_VALIDATION)
    /* S2 intentionally isolates image validation from trailer/swap policy.
     * A valid Primary may hand off; every invalid Primary stays in recovery. */
    if (!boot_image_validate(BOOT_SLOT_PRIMARY)) {
        return false;
    }
    boot_jump_to_primary();
    return true;
#else
    boot_trailer_record_t primary_record;
    boot_trailer_record_t secondary_record;
    const bool primary_was_valid = boot_image_validate(BOOT_SLOT_PRIMARY);

    /* A first installation has no valid Primary image yet.  Process a fully
     * downloaded Secondary image before applying normal Primary boot checks. */
    if (boot_trailer_latest(BOOT_SLOT_SECONDARY, &secondary_record) &&
        (secondary_record.state == BOOT_STATE_PENDING)) {
        if (!boot_image_validate(BOOT_SLOT_SECONDARY) ||
            !boot_record_matches_image(BOOT_SLOT_SECONDARY, &secondary_record) ||
            !(primary_was_valid ? boot_swap_slots() : boot_install_secondary_to_primary()) ||
            !boot_image_validate(BOOT_SLOT_PRIMARY) ||
            !boot_trailer_append(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST, 0U, 0xFFU,
                                 secondary_record.image_crc32) ||
            !boot_trailer_latest(BOOT_SLOT_PRIMARY, &primary_record) ||
            (!primary_was_valid &&
             !boot_trailer_append(BOOT_SLOT_SECONDARY, BOOT_STATE_CONFIRMED, 0U, 0xFFU,
                                  secondary_record.image_crc32))) {
            return false;
        }
    }

    if (!boot_image_validate(BOOT_SLOT_PRIMARY)) {
        return false; /* Recovery transport owns this path. */
    }

    if (!boot_trailer_latest(BOOT_SLOT_PRIMARY, &primary_record)) {
        return false; /* A valid image is bootable only after explicit state. */
    }
    if (!boot_record_matches_image(BOOT_SLOT_PRIMARY, &primary_record)) {
        return false; /* Do not boot from a stale trailer state record. */
    }

    if (primary_record.state == BOOT_STATE_CONFIRMED) {
        boot_jump_to_primary();
        return true; /* Hardware never returns; SIL records the hand-off. */
    }

    if (primary_record.state == BOOT_STATE_TEST) {
        if (primary_record.boot_attempts >= 3U) {
            /* A first install has no previous confirmed image to restore. */
            if (!boot_trailer_latest(BOOT_SLOT_SECONDARY, &secondary_record) ||
                (secondary_record.state != BOOT_STATE_CONFIRMED) ||
                !boot_record_matches_image(BOOT_SLOT_SECONDARY, &secondary_record) ||
                (secondary_record.image_crc32 == primary_record.image_crc32)) {
                return false;
            }
            if (!boot_trailer_append(BOOT_SLOT_PRIMARY, BOOT_STATE_REVERT,
                                     primary_record.boot_attempts, 0xFFU,
                                     primary_record.image_crc32) ||
                !boot_image_validate(BOOT_SLOT_SECONDARY) || !boot_swap_slots() ||
                !boot_image_validate(BOOT_SLOT_PRIMARY) ||
                !boot_trailer_latest(BOOT_SLOT_PRIMARY, &primary_record) ||
                (primary_record.state != BOOT_STATE_CONFIRMED)) {
                return false;
            }
            boot_jump_to_primary();
            return true;
        }
        if (!boot_trailer_append(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST,
                                 primary_record.boot_attempts + 1U,
                                 primary_record.swap_sector,
                                 primary_record.image_crc32)) {
            return false;
        }
        boot_jump_to_primary();
        return true;
    }

    return false;
#endif
}
