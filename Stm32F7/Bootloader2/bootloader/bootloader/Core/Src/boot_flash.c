#include "boot_flash.h"
#include "boot_flash_layout.h"

#include "stm32h7xx.h"
#include <string.h>

#define BOOT_RAMFUNC __attribute__((section(".RamFunc"), noinline))
#define BOOT_FLASH_ERROR_FLAGS (FLASH_SR_WRPERR | FLASH_SR_PGSERR | FLASH_SR_STRBERR | \
                                FLASH_SR_INCERR | FLASH_SR_OPERR | FLASH_SR_RDPERR)

static uint32_t g_flash_word[BOOT_FLASH_WORD_SIZE / sizeof(uint32_t)] __attribute__((aligned(32)));
static volatile uint32_t g_flash_last_status;

static bool boot_flash_address_allowed(uint32_t address)
{
    const bool in_secondary = (address >= BOOT_SECONDARY_BASE) && (address < (BOOT_SECONDARY_BASE + BOOT_SLOT_SIZE));
    const bool in_scratch = (address >= BOOT_SCRATCH_BASE) && (address < (BOOT_SCRATCH_BASE + BOOT_SCRATCH_SIZE));
    const bool in_primary = (address >= BOOT_PRIMARY_BASE) && (address < (BOOT_PRIMARY_BASE + BOOT_SLOT_SIZE));
    return in_primary || in_secondary || in_scratch;
}

static BOOT_RAMFUNC bool boot_flash_wait_ready(void)
{
    /* H72x/H73x reports an active program/erase operation through QW.
     * BSY may already be clear while the 256-bit flash write queue is active. */
    while ((FLASH->SR1 & FLASH_SR_QW) != 0U) {
    }
    /* EOP is a successful-completion event, not a hardware error.  Preserve
     * only error flags so protocol callers can distinguish bad arguments from
     * a failed Flash transaction after a preceding successful erase/program. */
    g_flash_last_status = FLASH->SR1 & BOOT_FLASH_ERROR_FLAGS;
    return g_flash_last_status == 0U;
}

static BOOT_RAMFUNC void boot_flash_unlock_ram(void)
{
    if ((FLASH->CR1 & FLASH_CR_LOCK) != 0U) {
        FLASH->KEYR1 = FLASH_KEY1;
        FLASH->KEYR1 = FLASH_KEY2;
    }
}

static BOOT_RAMFUNC void boot_flash_lock_ram(void)
{
    FLASH->CR1 |= FLASH_CR_LOCK;
}

static BOOT_RAMFUNC bool boot_flash_program_word_ram(uint32_t address, const uint32_t *word)
{
    boot_flash_unlock_ram();
    FLASH->SR1 = FLASH_SR_EOP | BOOT_FLASH_ERROR_FLAGS;
    FLASH->CR1 |= FLASH_CR_PG;
    __ISB();
    __DSB();
    for (uint32_t i = 0U; i < (BOOT_FLASH_WORD_SIZE / sizeof(uint32_t)); ++i) {
        *(volatile uint32_t *)(uintptr_t)(address + (i * sizeof(uint32_t))) = word[i];
    }
    __ISB();
    __DSB();
    const bool ok = boot_flash_wait_ready();
    FLASH->CR1 &= ~FLASH_CR_PG;
    boot_flash_lock_ram();
    return ok;
}

static BOOT_RAMFUNC bool boot_flash_erase_sector_ram(uint32_t sector)
{
    boot_flash_unlock_ram();
    FLASH->SR1 = FLASH_SR_EOP | BOOT_FLASH_ERROR_FLAGS;
    FLASH->CR1 = (FLASH->CR1 & ~(FLASH_CR_SNB | FLASH_CR_SER)) |
                 FLASH_CR_SER | ((sector << FLASH_CR_SNB_Pos) & FLASH_CR_SNB);
    FLASH->CR1 |= FLASH_CR_START;
    __ISB();
    __DSB();
    const bool ok = boot_flash_wait_ready();
    FLASH->CR1 &= ~(FLASH_CR_SER | FLASH_CR_SNB);
    boot_flash_lock_ram();
    return ok;
}

bool boot_flash_program_word(uint32_t address, const void *source)
{
    if (!boot_flash_address_allowed(address) || ((address & (BOOT_FLASH_WORD_SIZE - 1U)) != 0U)) {
        g_flash_last_status = 0U;
        return false;
    }

    memcpy(g_flash_word, source, BOOT_FLASH_WORD_SIZE);
    __DSB();
    const uint32_t primask = __get_PRIMASK();
    __disable_irq();
    const bool ok = boot_flash_program_word_ram(address, g_flash_word);
    if (primask == 0U) {
        __enable_irq();
    }
    return ok;
}

uint32_t boot_flash_last_status(void)
{
    return g_flash_last_status;
}

const void *boot_flash_read_ptr(uint32_t address)
{
    return (const void *)(uintptr_t)address;
}

bool boot_flash_erase_sector(uint32_t sector)
{
    if ((sector < BOOT_PRIMARY_SECTOR) || (sector > BOOT_SCRATCH_SECTOR)) {
        return false;
    }
    const uint32_t primask = __get_PRIMASK();
    __disable_irq();
    const bool ok = boot_flash_erase_sector_ram(sector);
    if (primask == 0U) {
        __enable_irq();
    }
    return ok;
}

bool boot_flash_erase_secondary_slot(void)
{
    for (uint32_t sector = BOOT_SECONDARY_SECTOR; sector < (BOOT_SECONDARY_SECTOR + 3U); ++sector) {
        if (!boot_flash_erase_sector(sector)) {
            return false;
        }
    }
    return true;
}

bool boot_flash_erase_scratch(void)
{
    return boot_flash_erase_sector(BOOT_SCRATCH_SECTOR);
}

/*
 * This complete operation must execute from RAM.  STM32H723 has one internal
 * flash bank: executing the outer copy loop from Flash while it erases or
 * programs that bank works only until an instruction/literal fetch collides
 * with the active Flash operation.  In particular, an initial install copied
 * the image area but stalled before it could copy the trailer journal.
 *
 * Keep the source read and the 256-bit staging copy explicit here so the
 * compiler cannot emit a call to a Flash-resident memcpy routine.
 */
static BOOT_RAMFUNC bool boot_flash_copy_sector_ram(uint32_t source, uint32_t destination,
                                                    uint32_t destination_sector)
{
    if (!boot_flash_erase_sector_ram(destination_sector)) {
        return false;
    }
    for (uint32_t offset = 0U; offset < BOOT_FLASH_SECTOR_SIZE; offset += BOOT_FLASH_WORD_SIZE) {
        const volatile uint32_t *const source_word =
            (const volatile uint32_t *)(uintptr_t)(source + offset);
        for (uint32_t word = 0U; word < (BOOT_FLASH_WORD_SIZE / sizeof(uint32_t)); ++word) {
            g_flash_word[word] = source_word[word];
        }
        if (!boot_flash_program_word_ram(destination + offset, g_flash_word)) {
            return false;
        }
    }
    return true;
}

bool boot_flash_copy_sector(uint32_t source, uint32_t destination, uint32_t destination_sector)
{
    if (((source | destination) & (BOOT_FLASH_SECTOR_SIZE - 1U)) != 0U ||
        (destination_sector < BOOT_PRIMARY_SECTOR) || (destination_sector > BOOT_SCRATCH_SECTOR)) {
        return false;
    }
    const uint32_t primask = __get_PRIMASK();
    __disable_irq();
    const bool ok = boot_flash_copy_sector_ram(source, destination, destination_sector);
    if (primask == 0U) {
        __enable_irq();
    }
    return ok;
}
