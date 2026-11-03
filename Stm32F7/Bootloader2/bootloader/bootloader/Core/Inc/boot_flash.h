#ifndef BOOT_FLASH_H
#define BOOT_FLASH_H

#include <stdbool.h>
#include <stdint.h>

/* Source and destination must both be 32-byte aligned. */
bool boot_flash_program_word(uint32_t address, const void *source);
/* FLASH_SR1 captured after the latest flash operation; zero means no HW flag. */
uint32_t boot_flash_last_status(void);
/* STM32: direct memory-map read. SIL: mapped in-memory Flash read. */
const void *boot_flash_read_ptr(uint32_t address);
bool boot_flash_erase_secondary_slot(void);
bool boot_flash_erase_scratch(void);

/* Privileged operations: used only by the swap engine. */
bool boot_flash_erase_sector(uint32_t sector);
bool boot_flash_copy_sector(uint32_t source, uint32_t destination, uint32_t destination_sector);

#endif
