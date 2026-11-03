#include "app_bootloader.h"

#include "boot_request_contract.h"

#include "stm32h7xx.h"

#include <stdint.h>
#include <string.h>

#define APP_BOOTLOADER_PRIMARY_TRAILER_BASE  0x0807F000UL
#define APP_BOOTLOADER_TRAILER_SIZE           0x1000UL
#define APP_BOOTLOADER_FLASH_WORD_SIZE        32UL
#define APP_BOOTLOADER_TRAILER_MAGIC          0x48375452UL
#define APP_BOOTLOADER_STATE_TEST             3U
#define APP_BOOTLOADER_STATE_CONFIRMED        4U
#define APP_BOOTLOADER_RAMFUNC __attribute__((section(".RamFunc"), noinline))
#define APP_BOOTLOADER_FLASH_ERROR_FLAGS (FLASH_SR_WRPERR | FLASH_SR_PGSERR | FLASH_SR_STRBERR | \
                                          FLASH_SR_INCERR | FLASH_SR_OPERR | FLASH_SR_RDPERR)

typedef struct __attribute__((packed)) {
    uint32_t magic;
    uint32_t sequence;
    uint8_t state;
    uint8_t boot_attempts;
    uint8_t swap_sector;
    uint8_t flags;
    uint32_t image_crc32;
    uint8_t reserved[12];
    uint32_t record_crc32;
} app_bootloader_trailer_record_t;

_Static_assert(sizeof(app_bootloader_trailer_record_t) == APP_BOOTLOADER_FLASH_WORD_SIZE,
               "trailer record must be one flash word");

static uint32_t g_flash_word[APP_BOOTLOADER_FLASH_WORD_SIZE / sizeof(uint32_t)] __attribute__((aligned(32)));

static uint32_t app_bootloader_crc32(const void *data, uint32_t length)
{
    const uint8_t *bytes = data;
    uint32_t crc = 0xFFFFFFFFUL;
    while (length-- != 0U) {
        crc ^= *bytes++;
        for (uint32_t bit = 0U; bit < 8U; ++bit) {
            crc = (crc >> 1U) ^ ((crc & 1U) != 0U ? 0xEDB88320UL : 0U);
        }
    }
    return ~crc;
}

static bool app_bootloader_backup_access_enable(void)
{
    HAL_PWR_EnableBkUpAccess();

    if ((RCC->BDCR & RCC_BDCR_RTCSEL) == 0U) {
        SET_BIT(RCC->CSR, RCC_CSR_LSION);
        uint32_t timeout = 1000000U;
        while (((RCC->CSR & RCC_CSR_LSIRDY) == 0U) && (timeout-- != 0U)) {
        }
        if ((RCC->CSR & RCC_CSR_LSIRDY) == 0U) {
            return false;
        }
        MODIFY_REG(RCC->BDCR, RCC_BDCR_RTCSEL, RCC_RTCCLKSOURCE_LSI);
    }
    __HAL_RCC_RTC_ENABLE();
    return true;
}

bool app_bootloader_request_update(void)
{
    if (!app_bootloader_backup_access_enable()) {
        return false;
    }

    RTC->BKP0R = BOOT_REQUEST_MAGIC;
    RTC->BKP1R = BOOT_REQUEST_UPDATE_MODE;
    RTC->BKP2R = BOOT_REQUEST_GUARD;
    __DSB();
    NVIC_SystemReset();

    /* NVIC_SystemReset() should not return. */
    for (;;) {
        __NOP();
    }
}

static bool app_bootloader_record_valid(const app_bootloader_trailer_record_t *record)
{
    return (record->magic == APP_BOOTLOADER_TRAILER_MAGIC) &&
           (record->state >= 1U) && (record->state <= 5U) &&
           (record->record_crc32 == app_bootloader_crc32(record,
                                                         sizeof(*record) - sizeof(record->record_crc32)));
}

static APP_BOOTLOADER_RAMFUNC bool app_bootloader_program_word_ram(uint32_t address, const uint32_t *word)
{
    if ((FLASH->CR1 & FLASH_CR_LOCK) != 0U) {
        FLASH->KEYR1 = FLASH_KEY1;
        FLASH->KEYR1 = FLASH_KEY2;
    }
    FLASH->SR1 = FLASH_SR_EOP | APP_BOOTLOADER_FLASH_ERROR_FLAGS;
    FLASH->CR1 |= FLASH_CR_PG;
    __ISB();
    __DSB();
    for (uint32_t i = 0U; i < (APP_BOOTLOADER_FLASH_WORD_SIZE / sizeof(uint32_t)); ++i) {
        *(volatile uint32_t *)(uintptr_t)(address + (i * sizeof(uint32_t))) = word[i];
    }
    __ISB();
    __DSB();
    /* The H723 flash write queue remains active while QW is set. */
    while ((FLASH->SR1 & FLASH_SR_QW) != 0U) {
    }
    const bool ok = (FLASH->SR1 & APP_BOOTLOADER_FLASH_ERROR_FLAGS) == 0U;
    FLASH->CR1 &= ~FLASH_CR_PG;
    FLASH->CR1 |= FLASH_CR_LOCK;
    return ok;
}

bool app_bootloader_confirm(void)
{
    const app_bootloader_trailer_record_t *records =
        (const app_bootloader_trailer_record_t *)(uintptr_t)APP_BOOTLOADER_PRIMARY_TRAILER_BASE;
    const app_bootloader_trailer_record_t *latest = NULL;
    const uint32_t record_count = APP_BOOTLOADER_TRAILER_SIZE / APP_BOOTLOADER_FLASH_WORD_SIZE;
    uint32_t free_index = record_count;

    for (uint32_t i = 0U; i < record_count; ++i) {
        if (records[i].magic == 0xFFFFFFFFUL) {
            free_index = i;
            break;
        }
        if (app_bootloader_record_valid(&records[i]) &&
            ((latest == NULL) || (records[i].sequence > latest->sequence))) {
            latest = &records[i];
        }
    }
    if ((latest == NULL) || (latest->state != APP_BOOTLOADER_STATE_TEST) || (free_index == record_count)) {
        return false;
    }

    app_bootloader_trailer_record_t next;
    memset(&next, 0xFF, sizeof(next));
    next.magic = APP_BOOTLOADER_TRAILER_MAGIC;
    next.sequence = latest->sequence + 1U;
    next.state = APP_BOOTLOADER_STATE_CONFIRMED;
    /* A confirmed image is no longer in its trial-boot window. */
    next.boot_attempts = 0U;
    next.swap_sector = 0xFFU;
    next.flags = 0xFFU;
    next.image_crc32 = latest->image_crc32;
    next.record_crc32 = app_bootloader_crc32(&next, sizeof(next) - sizeof(next.record_crc32));

    memcpy(g_flash_word, &next, sizeof(next));
    const uint32_t primask = __get_PRIMASK();
    __disable_irq();
    const bool ok = app_bootloader_program_word_ram(
        APP_BOOTLOADER_PRIMARY_TRAILER_BASE + (free_index * APP_BOOTLOADER_FLASH_WORD_SIZE), g_flash_word);
    if (primask == 0U) {
        __enable_irq();
    }
    return ok;
}
