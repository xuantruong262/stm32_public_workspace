#include "boot_sil.h"

#include "boot_flash.h"
#include "boot_flash_layout.h"

#include <string.h>

#define SIL_FLASH_SIZE (BOOT_FLASH_END - BOOT_FLASH_BASE)
#define SIL_FLASH_PGSERR (1UL << 18U)
#define SIL_FLASH_OPERR  (1UL << 22U)

static uint8_t g_flash[SIL_FLASH_SIZE];
static uint32_t g_last_status;
static int g_fail_after = -1;
static unsigned g_operations;

static bool address_in_flash(uint32_t address, size_t length)
{
    return address >= BOOT_FLASH_BASE && length <= (size_t)(BOOT_FLASH_END - address);
}

static bool address_writable(uint32_t address)
{
    return (address >= BOOT_PRIMARY_BASE && address < BOOT_FLASH_END);
}

static bool should_fail(void)
{
    const bool fail = g_fail_after >= 0 && g_operations == (unsigned)g_fail_after;
    ++g_operations;
    if (fail) {
        g_last_status = SIL_FLASH_OPERR;
    }
    return fail;
}

void boot_sil_flash_reset(void)
{
    memset(g_flash, 0xFF, sizeof(g_flash));
    g_last_status = 0U;
    g_fail_after = -1;
    g_operations = 0U;
}

void boot_sil_flash_seed(uint32_t address, const void *data, size_t length)
{
    if (address_in_flash(address, length)) {
        memcpy(&g_flash[address - BOOT_FLASH_BASE], data, length);
    }
}

uint8_t *boot_sil_flash_mut(uint32_t address)
{
    return address_in_flash(address, 1U) ? &g_flash[address - BOOT_FLASH_BASE] : NULL;
}

void boot_sil_flash_fail_after(int operation_index)
{
    g_fail_after = operation_index;
}

unsigned boot_sil_flash_operation_count(void)
{
    return g_operations;
}

const void *boot_flash_read_ptr(uint32_t address)
{
    return boot_sil_flash_mut(address);
}

uint32_t boot_flash_last_status(void)
{
    return g_last_status;
}

bool boot_flash_program_word(uint32_t address, const void *source)
{
    if (!address_writable(address) || !address_in_flash(address, BOOT_FLASH_WORD_SIZE) ||
        (address & (BOOT_FLASH_WORD_SIZE - 1U)) != 0U || source == NULL) {
        g_last_status = 0U;
        return false;
    }
    if (should_fail()) {
        return false;
    }

    uint8_t *destination = boot_sil_flash_mut(address);
    const uint8_t *input = source;
    for (uint32_t index = 0U; index < BOOT_FLASH_WORD_SIZE; ++index) {
        if ((destination[index] & input[index]) != input[index]) {
            g_last_status = SIL_FLASH_PGSERR;
            return false;
        }
    }
    for (uint32_t index = 0U; index < BOOT_FLASH_WORD_SIZE; ++index) {
        destination[index] &= input[index];
    }
    g_last_status = 0U;
    return true;
}

bool boot_flash_erase_sector(uint32_t sector)
{
    if (sector < BOOT_PRIMARY_SECTOR || sector > BOOT_SCRATCH_SECTOR || should_fail()) {
        return false;
    }
    memset(boot_sil_flash_mut(BOOT_FLASH_BASE + sector * BOOT_FLASH_SECTOR_SIZE), 0xFF,
           BOOT_FLASH_SECTOR_SIZE);
    g_last_status = 0U;
    return true;
}

bool boot_flash_erase_secondary_slot(void)
{
    for (uint32_t sector = BOOT_SECONDARY_SECTOR; sector < BOOT_SECONDARY_SECTOR + 3U; ++sector) {
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

bool boot_flash_copy_sector(uint32_t source, uint32_t destination, uint32_t destination_sector)
{
    if (((source | destination) & (BOOT_FLASH_SECTOR_SIZE - 1U)) != 0U ||
        !address_in_flash(source, BOOT_FLASH_SECTOR_SIZE) || !boot_flash_erase_sector(destination_sector)) {
        return false;
    }
    for (uint32_t offset = 0U; offset < BOOT_FLASH_SECTOR_SIZE; offset += BOOT_FLASH_WORD_SIZE) {
        uint8_t word[BOOT_FLASH_WORD_SIZE];
        memcpy(word, boot_flash_read_ptr(source + offset), sizeof(word));
        if (!boot_flash_program_word(destination + offset, word)) {
            return false;
        }
    }
    return true;
}
