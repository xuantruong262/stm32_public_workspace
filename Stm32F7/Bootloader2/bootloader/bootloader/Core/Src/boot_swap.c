#include "boot_swap.h"

#include "boot_flash.h"
#include "boot_flash_layout.h"

bool boot_swap_slots(void)
{
    for (uint32_t index = 0U; index < 3U; ++index) {
        const uint32_t primary = BOOT_PRIMARY_BASE + (index * BOOT_FLASH_SECTOR_SIZE);
        const uint32_t secondary = BOOT_SECONDARY_BASE + (index * BOOT_FLASH_SECTOR_SIZE);

        if (!boot_flash_copy_sector(primary, BOOT_SCRATCH_BASE, BOOT_SCRATCH_SECTOR) ||
            !boot_flash_copy_sector(secondary, primary, BOOT_PRIMARY_SECTOR + index) ||
            !boot_flash_copy_sector(BOOT_SCRATCH_BASE, secondary, BOOT_SECONDARY_SECTOR + index)) {
            return false;
        }
    }
    return true;
}

bool boot_install_secondary_to_primary(void)
{
    for (uint32_t index = 0U; index < 3U; ++index) {
        const uint32_t primary = BOOT_PRIMARY_BASE + (index * BOOT_FLASH_SECTOR_SIZE);
        const uint32_t secondary = BOOT_SECONDARY_BASE + (index * BOOT_FLASH_SECTOR_SIZE);

        if (!boot_flash_copy_sector(secondary, primary, BOOT_PRIMARY_SECTOR + index)) {
            return false;
        }
    }
    return true;
}
