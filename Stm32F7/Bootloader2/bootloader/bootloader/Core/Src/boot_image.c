#include "boot_image.h"
#include "boot_flash.h"

#include <string.h>

#define BOOT_TRAILER_RECORD_COUNT (BOOT_IMAGE_TRAILER_SIZE / BOOT_FLASH_WORD_SIZE)

uint32_t boot_crc32(const void *data, uint32_t length)
{
    const uint8_t *bytes = (const uint8_t *)data;
    uint32_t crc = 0xFFFFFFFFUL;

    while (length-- != 0U) {
        crc ^= *bytes++;
        for (uint32_t bit = 0U; bit < 8U; ++bit) {
            crc = (crc >> 1U) ^ ((crc & 1U) != 0U ? 0xEDB88320UL : 0U);
        }
    }
    return ~crc;
}

const boot_image_header_t *boot_image_header(boot_slot_t slot)
{
    return (const boot_image_header_t *)boot_flash_read_ptr(
        slot == BOOT_SLOT_PRIMARY ? BOOT_PRIMARY_BASE : BOOT_SECONDARY_BASE);
}

uint32_t boot_slot_payload_base(boot_slot_t slot)
{
    return slot == BOOT_SLOT_PRIMARY ? BOOT_PRIMARY_PAYLOAD_BASE : BOOT_SECONDARY_PAYLOAD_BASE;
}

uint32_t boot_slot_trailer_base(boot_slot_t slot)
{
    return slot == BOOT_SLOT_PRIMARY ? BOOT_PRIMARY_TRAILER_BASE : BOOT_SECONDARY_TRAILER_BASE;
}

static bool boot_is_valid_stack(uint32_t msp)
{
    return ((msp >= 0x20000000UL) && (msp <= 0x20020000UL)) ||
           ((msp >= 0x24000000UL) && (msp <= 0x24050000UL)) ||
           ((msp >= 0x30000000UL) && (msp <= 0x30008000UL)) ||
           ((msp >= 0x38000000UL) && (msp <= 0x38004000UL));
}

bool boot_image_validate(boot_slot_t slot)
{
    const boot_image_header_t *header = boot_image_header(slot);
    const uint32_t payload_base = boot_slot_payload_base(slot);
    const uint32_t *vector = (const uint32_t *)boot_flash_read_ptr(payload_base);
    const uint32_t reset_handler = vector[1] & ~1UL;

    if ((header->magic != BOOT_IMAGE_MAGIC) ||
        (header->format_version != BOOT_IMAGE_FORMAT_VERSION) ||
        (header->header_size != sizeof(*header)) ||
        (header->board_id != BOOT_BOARD_ID) ||
        (header->minimum_boot_version > BOOT_VERSION) ||
        (header->payload_size == 0U) || (header->payload_size > BOOT_PAYLOAD_SIZE) ||
        (header->load_address != BOOT_PRIMARY_PAYLOAD_BASE) ||
        (header->vector_offset != BOOT_IMAGE_HEADER_SIZE) ||
        (header->header_crc32 != boot_crc32(header, sizeof(*header) - sizeof(header->header_crc32))) ||
        !boot_is_valid_stack(vector[0]) || ((vector[1] & 1U) == 0U) ||
        (reset_handler < BOOT_PRIMARY_PAYLOAD_BASE) ||
        (reset_handler >= (BOOT_PRIMARY_PAYLOAD_BASE + header->payload_size)) ||
        (header->entry_point != vector[1])) {
        return false;
    }

    return header->payload_crc32 == boot_crc32(boot_flash_read_ptr(payload_base), header->payload_size);
}

static bool boot_record_is_valid(const boot_trailer_record_t *record)
{
    return (record->magic == BOOT_TRAILER_MAGIC) &&
           (record->state >= BOOT_STATE_DOWNLOADED) && (record->state <= BOOT_STATE_REVERT) &&
           (record->record_crc32 == boot_crc32(record, sizeof(*record) - sizeof(record->record_crc32)));
}

bool boot_trailer_latest(boot_slot_t slot, boot_trailer_record_t *record)
{
    const boot_trailer_record_t *records =
        (const boot_trailer_record_t *)boot_flash_read_ptr(boot_slot_trailer_base(slot));
    bool found = false;
    uint32_t best_sequence = 0U;

    for (uint32_t i = 0U; i < BOOT_TRAILER_RECORD_COUNT; ++i) {
        if (boot_record_is_valid(&records[i]) && (!found || records[i].sequence > best_sequence)) {
            *record = records[i];
            best_sequence = records[i].sequence;
            found = true;
        }
    }
    return found;
}

bool boot_trailer_append(boot_slot_t slot, boot_state_t state, uint8_t attempts, uint8_t swap_sector, uint32_t image_crc32)
{
    const uint32_t trailer_base = boot_slot_trailer_base(slot);
    const boot_trailer_record_t *records =
        (const boot_trailer_record_t *)boot_flash_read_ptr(trailer_base);
    boot_trailer_record_t latest;
    boot_trailer_record_t next;

    for (uint32_t i = 0U; i < BOOT_TRAILER_RECORD_COUNT; ++i) {
        if (records[i].magic == 0xFFFFFFFFUL) {
            memset(&next, 0xFF, sizeof(next));
            next.magic = BOOT_TRAILER_MAGIC;
            next.sequence = boot_trailer_latest(slot, &latest) ? latest.sequence + 1U : 1U;
            next.state = (uint8_t)state;
            next.boot_attempts = attempts;
            next.swap_sector = swap_sector;
            next.flags = 0xFFU;
            next.image_crc32 = image_crc32;
            next.record_crc32 = boot_crc32(&next, sizeof(next) - sizeof(next.record_crc32));
            return boot_flash_program_word(trailer_base + (i * BOOT_FLASH_WORD_SIZE), &next);
        }
    }
    return false;
}
