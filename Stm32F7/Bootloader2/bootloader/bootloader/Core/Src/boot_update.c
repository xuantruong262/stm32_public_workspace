#include "boot_update.h"

#include "boot_flash.h"
#include "boot_flash_layout.h"

#include <string.h>

typedef struct {
    bool active;
    uint32_t next_offset;
    uint32_t crc_state;
    boot_image_header_t header;
} boot_update_session_t;

static boot_update_session_t g_session;

static uint32_t crc32_update(uint32_t crc, const uint8_t *data, uint32_t length)
{
    while (length-- != 0U) {
        crc ^= *data++;
        for (uint32_t bit = 0U; bit < 8U; ++bit) {
            crc = (crc >> 1U) ^ ((crc & 1U) != 0U ? 0xEDB88320UL : 0U);
        }
    }
    return crc;
}

static bool boot_update_metadata_is_valid(const boot_image_header_t *header)
{
    return (header->magic == BOOT_IMAGE_MAGIC) &&
           (header->format_version == BOOT_IMAGE_FORMAT_VERSION) &&
           (header->header_size == sizeof(*header)) &&
           (header->board_id == BOOT_BOARD_ID) &&
           (header->minimum_boot_version <= BOOT_VERSION) &&
           (header->payload_size != 0U) && (header->payload_size <= BOOT_PAYLOAD_SIZE) &&
           (header->load_address == BOOT_PRIMARY_PAYLOAD_BASE) &&
           (header->vector_offset == BOOT_IMAGE_HEADER_SIZE);
}

bool boot_update_begin(const boot_image_header_t *metadata)
{
    if (g_session.active || !boot_update_metadata_is_valid(metadata)) {
        return false;
    }
    if (!boot_flash_erase_secondary_slot()) {
        return false;
    }

    memset(&g_session, 0, sizeof(g_session));
    g_session.header = *metadata;
    g_session.next_offset = 0U;
    g_session.crc_state = 0xFFFFFFFFUL;
    g_session.active = true;
    return true;
}

bool boot_update_write_block(uint32_t offset, const uint8_t *data, uint32_t length)
{
    const uint32_t padded_size = (g_session.header.payload_size + BOOT_FLASH_WORD_SIZE - 1U) &
                                 ~(BOOT_FLASH_WORD_SIZE - 1U);
    if (!g_session.active || (data == NULL) || (offset != g_session.next_offset) ||
        (offset > padded_size) ||
        (length == 0U) || ((length % BOOT_FLASH_WORD_SIZE) != 0U) ||
        (length > (padded_size - offset))) {
        return false;
    }

    for (uint32_t block = 0U; block < length; block += BOOT_FLASH_WORD_SIZE) {
        if (!boot_flash_program_word(BOOT_SECONDARY_PAYLOAD_BASE + offset + block, data + block)) {
            return false;
        }
    }

    const uint32_t remaining_payload = g_session.header.payload_size - offset;
    const uint32_t crc_length = length < remaining_payload ? length : remaining_payload;
    g_session.crc_state = crc32_update(g_session.crc_state, data, crc_length);
    g_session.next_offset += length;
    return true;
}

bool boot_update_finalize(void)
{
    const uint32_t padded_size = (g_session.header.payload_size + BOOT_FLASH_WORD_SIZE - 1U) &
                                 ~(BOOT_FLASH_WORD_SIZE - 1U);
    if (!g_session.active || (g_session.next_offset != padded_size) ||
        ((~g_session.crc_state) != g_session.header.payload_crc32)) {
        return false;
    }

    g_session.header.header_crc32 = boot_crc32(&g_session.header,
                                                sizeof(g_session.header) - sizeof(g_session.header.header_crc32));
    for (uint32_t offset = 0U; offset < sizeof(g_session.header); offset += BOOT_FLASH_WORD_SIZE) {
        if (!boot_flash_program_word(BOOT_SECONDARY_BASE + offset, ((const uint8_t *)&g_session.header) + offset)) {
            return false;
        }
    }

    if (!boot_image_validate(BOOT_SLOT_SECONDARY) ||
        !boot_trailer_append(BOOT_SLOT_SECONDARY, BOOT_STATE_DOWNLOADED, 0U, 0U, g_session.header.payload_crc32) ||
        !boot_trailer_append(BOOT_SLOT_SECONDARY, BOOT_STATE_PENDING, 0U, 0U, g_session.header.payload_crc32)) {
        return false;
    }
    g_session.active = false;
    return true;
}

void boot_update_abort(void)
{
    memset(&g_session, 0, sizeof(g_session));
}

bool boot_update_is_active(void)
{
    return g_session.active;
}
