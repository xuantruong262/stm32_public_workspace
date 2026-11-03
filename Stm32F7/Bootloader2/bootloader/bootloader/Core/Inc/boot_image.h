#ifndef BOOT_IMAGE_H
#define BOOT_IMAGE_H

#include <stdbool.h>
#include <stdint.h>
#include "boot_flash_layout.h"

#define BOOT_IMAGE_MAGIC                0x4837424CUL /* H7BL */
#define BOOT_TRAILER_MAGIC              0x48375452UL /* H7WR */
#define BOOT_IMAGE_FORMAT_VERSION       1U

typedef enum {
    BOOT_STATE_NONE = 0xFFU,
    BOOT_STATE_DOWNLOADED = 1U,
    BOOT_STATE_PENDING = 2U,
    BOOT_STATE_TEST = 3U,
    BOOT_STATE_CONFIRMED = 4U,
    BOOT_STATE_REVERT = 5U
} boot_state_t;

typedef enum {
    BOOT_SLOT_PRIMARY,
    BOOT_SLOT_SECONDARY
} boot_slot_t;

#if defined(_MSC_VER)
#pragma pack(push, 1)
#define BOOT_PACKED
#else
#define BOOT_PACKED __attribute__((packed))
#endif

typedef struct BOOT_PACKED {
    uint32_t magic;
    uint16_t format_version;
    uint16_t header_size;
    uint32_t board_id;
    uint32_t minimum_boot_version;
    uint32_t firmware_version;
    uint32_t build_number;
    uint32_t payload_size;
    uint32_t payload_crc32;
    uint32_t load_address;
    uint32_t vector_offset;
    uint32_t entry_point;
    uint64_t timestamp;
    uint8_t uuid[16];
    uint8_t reserved[56];
    uint32_t header_crc32;
} boot_image_header_t;

typedef struct BOOT_PACKED {
    uint32_t magic;
    uint32_t sequence;
    uint8_t state;
    uint8_t boot_attempts;
    uint8_t swap_sector;
    uint8_t flags;
    uint32_t image_crc32;
    uint8_t reserved[12];
    uint32_t record_crc32;
} boot_trailer_record_t;

#if defined(_MSC_VER)
#pragma pack(pop)
#endif
#undef BOOT_PACKED

_Static_assert(sizeof(boot_image_header_t) == 128U, "header must be 128 bytes");
_Static_assert(sizeof(boot_trailer_record_t) == BOOT_FLASH_WORD_SIZE, "trailer record must be one flash word");

uint32_t boot_crc32(const void *data, uint32_t length);
const boot_image_header_t *boot_image_header(boot_slot_t slot);
uint32_t boot_slot_payload_base(boot_slot_t slot);
uint32_t boot_slot_trailer_base(boot_slot_t slot);
bool boot_image_validate(boot_slot_t slot);
bool boot_trailer_latest(boot_slot_t slot, boot_trailer_record_t *record);
bool boot_trailer_append(boot_slot_t slot, boot_state_t state, uint8_t attempts, uint8_t swap_sector, uint32_t image_crc32);

#endif
