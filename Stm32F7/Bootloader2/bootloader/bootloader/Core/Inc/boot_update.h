#ifndef BOOT_UPDATE_H
#define BOOT_UPDATE_H

#include <stdbool.h>
#include <stdint.h>
#include "boot_image.h"

/* Transport-independent, stop-and-wait update engine.
 * Blocks are 32-byte multiples; the final block is padded with 0xFF by the host. */
bool boot_update_begin(const boot_image_header_t *metadata);
bool boot_update_write_block(uint32_t offset, const uint8_t *data, uint32_t length);
bool boot_update_finalize(void);
void boot_update_abort(void);
bool boot_update_is_active(void);

#endif
