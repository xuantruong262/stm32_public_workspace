#ifndef BOOT_SIL_H
#define BOOT_SIL_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

void boot_sil_flash_reset(void);
void boot_sil_flash_seed(uint32_t address, const void *data, size_t length);
uint8_t *boot_sil_flash_mut(uint32_t address);
void boot_sil_flash_fail_after(int operation_index);
unsigned boot_sil_flash_operation_count(void);

void boot_sil_runtime_reset(void);
void boot_sil_record_jump(uint32_t msp, uint32_t reset_handler);
bool boot_sil_jump_occurred(void);
uint32_t boot_sil_jump_msp(void);
uint32_t boot_sil_jump_reset_handler(void);

void boot_sil_cdc_feed(const uint8_t *data, size_t length);
size_t boot_sil_cdc_take_tx(uint8_t *data, size_t capacity);
unsigned boot_sil_reset_count(void);
void boot_sil_tick_advance(uint32_t milliseconds);

#endif
