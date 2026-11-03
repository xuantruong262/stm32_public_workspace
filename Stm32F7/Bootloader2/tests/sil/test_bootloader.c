#include "boot_sil.h"

#include "boot_flash.h"
#include "boot_flash_layout.h"
#include "boot_image.h"
#include "boot_manager.h"
#include "boot_protocol.h"
#include "boot_update.h"

#include <stdio.h>
#include <string.h>

static unsigned g_tests;
static unsigned g_failures;

#define CHECK(condition) do { \
    if (!(condition)) { \
        printf("  FAIL %s:%d: %s\n", __func__, __LINE__, #condition); \
        ++g_failures; \
        return; \
    } \
} while (0)

#define RUN(test) do { \
    const unsigned failures_before = g_failures; \
    ++g_tests; \
    printf("[RUN ] %s\n", #test); \
    fflush(stdout); \
    test(); \
    printf("[%s] %s\n", g_failures == failures_before ? "PASS" : "FAIL", #test); \
    fflush(stdout); \
} while (0)

enum {
    CMD_GET_INFO = 0x01U,
    CMD_BEGIN_UPDATE = 0x02U,
    CMD_WRITE_BLOCK = 0x03U,
    CMD_FINALIZE = 0x04U,
    CMD_ABORT = 0x05U,
    CMD_RESET = 0x06U,
    STATUS_OK = 0U,
    STATUS_BAD_FRAME = 1U,
    STATUS_BAD_COMMAND = 2U,
    STATUS_BAD_ARGUMENT = 3U
};

static void reset_fixture(void)
{
    boot_sil_flash_reset();
    boot_sil_runtime_reset();
    boot_update_abort();
    boot_protocol_init();
}

static uint32_t slot_base(boot_slot_t slot)
{
    return slot == BOOT_SLOT_PRIMARY ? BOOT_PRIMARY_BASE : BOOT_SECONDARY_BASE;
}

static void write_u32(uint8_t *bytes, uint32_t value)
{
    bytes[0] = (uint8_t)value;
    bytes[1] = (uint8_t)(value >> 8U);
    bytes[2] = (uint8_t)(value >> 16U);
    bytes[3] = (uint8_t)(value >> 24U);
}

static void make_payload(uint8_t *payload, uint32_t size, uint32_t marker)
{
    for (uint32_t index = 0U; index < size; ++index) {
        payload[index] = (uint8_t)(marker + index * 13U);
    }
    write_u32(&payload[0], 0x20020000UL);
    write_u32(&payload[4], BOOT_PRIMARY_PAYLOAD_BASE + 0x21U);
}

static boot_image_header_t make_header(const uint8_t *payload, uint32_t payload_size, uint32_t marker)
{
    boot_image_header_t header;
    memset(&header, 0, sizeof(header));
    header.magic = BOOT_IMAGE_MAGIC;
    header.format_version = BOOT_IMAGE_FORMAT_VERSION;
    header.header_size = sizeof(header);
    header.board_id = BOOT_BOARD_ID;
    header.minimum_boot_version = 0x00010000UL;
    header.firmware_version = marker;
    header.build_number = marker + 1U;
    header.payload_size = payload_size;
    header.payload_crc32 = boot_crc32(payload, payload_size);
    header.load_address = BOOT_PRIMARY_PAYLOAD_BASE;
    header.vector_offset = BOOT_IMAGE_HEADER_SIZE;
    header.entry_point = BOOT_PRIMARY_PAYLOAD_BASE + 0x21U;
    header.timestamp = 0x1122334400000000ULL | marker;
    header.header_crc32 = boot_crc32(&header, sizeof(header) - sizeof(header.header_crc32));
    return header;
}

static boot_image_header_t seed_image(boot_slot_t slot, uint32_t marker)
{
    uint8_t payload[64];
    make_payload(payload, sizeof(payload), marker);
    const boot_image_header_t header = make_header(payload, sizeof(payload), marker);
    boot_sil_flash_seed(slot_base(slot), &header, sizeof(header));
    boot_sil_flash_seed(boot_slot_payload_base(slot), payload, sizeof(payload));
    return header;
}

static void seed_state(boot_slot_t slot, boot_state_t state, uint8_t attempts, uint32_t crc)
{
    CHECK(boot_trailer_append(slot, state, attempts, 0xFFU, crc));
}

static void test_flash_model_rules(void)
{
    reset_fixture();
    uint8_t first[BOOT_FLASH_WORD_SIZE];
    uint8_t invalid_rewrite[BOOT_FLASH_WORD_SIZE];
    memset(first, 0xF0, sizeof(first));
    memset(invalid_rewrite, 0xFF, sizeof(invalid_rewrite));

    CHECK(!boot_flash_program_word(BOOTLOADER_BASE, first));
    CHECK(!boot_flash_program_word(BOOT_PRIMARY_BASE + 1U, first));
    CHECK(boot_flash_program_word(BOOT_PRIMARY_BASE, first));
    CHECK(!boot_flash_program_word(BOOT_PRIMARY_BASE, invalid_rewrite));
    CHECK(boot_flash_last_status() != 0U);
    CHECK(boot_flash_erase_sector(BOOT_PRIMARY_SECTOR));
    for (uint32_t index = 0U; index < BOOT_FLASH_WORD_SIZE; ++index) {
        CHECK(boot_sil_flash_mut(BOOT_PRIMARY_BASE)[index] == 0xFFU);
    }
}

static void test_image_validation_rejects_tampering(void)
{
    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x31U);
    CHECK(boot_image_validate(BOOT_SLOT_PRIMARY));

    boot_sil_flash_mut(BOOT_PRIMARY_BASE)[0] ^= 1U;
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));

    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x32U);
    write_u32(boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE), 0x10000000UL);
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));

    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x33U);
    write_u32(boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE + 4U), BOOT_PRIMARY_PAYLOAD_BASE + 0x20U);
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));

    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x34U);
    boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE + 31U)[0] ^= 1U;
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));
}

static void test_image_validation_rejects_all_s2_metadata_variants(void)
{
    boot_image_header_t *header;

    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x35U);
    header = (boot_image_header_t *)boot_sil_flash_mut(BOOT_PRIMARY_BASE);
    header->board_id ^= 1U;
    header->header_crc32 = boot_crc32(header, sizeof(*header) - sizeof(header->header_crc32));
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));

    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x36U);
    header = (boot_image_header_t *)boot_sil_flash_mut(BOOT_PRIMARY_BASE);
    header->payload_size = 0U;
    header->header_crc32 = boot_crc32(header, sizeof(*header) - sizeof(header->header_crc32));
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));

    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x37U);
    write_u32(boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE), 0x10000000UL);
    header = (boot_image_header_t *)boot_sil_flash_mut(BOOT_PRIMARY_BASE);
    header->payload_crc32 = boot_crc32(boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE), header->payload_size);
    header->header_crc32 = boot_crc32(header, sizeof(*header) - sizeof(header->header_crc32));
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));

    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x38U);
    write_u32(boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE + 4U), BOOT_PRIMARY_PAYLOAD_BASE + 0x101U);
    header = (boot_image_header_t *)boot_sil_flash_mut(BOOT_PRIMARY_BASE);
    header->payload_crc32 = boot_crc32(boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE), header->payload_size);
    header->header_crc32 = boot_crc32(header, sizeof(*header) - sizeof(header->header_crc32));
    CHECK(!boot_image_validate(BOOT_SLOT_PRIMARY));
}

static void test_trailer_journal_latest_and_partial_record(void)
{
    boot_trailer_record_t record;
    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x41U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_DOWNLOADED, 0U, 0x11111111UL);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST, 2U, 0x22222222UL);
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.sequence == 2U);
    CHECK(record.state == BOOT_STATE_TEST);
    CHECK(record.boot_attempts == 2U);

    boot_sil_flash_mut(BOOT_PRIMARY_TRAILER_BASE + BOOT_FLASH_WORD_SIZE)[28] ^= 1U;
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.sequence == 1U);
}

static void test_update_engine_end_to_end_and_rejections(void)
{
    uint8_t payload[64];
    make_payload(payload, sizeof(payload), 0x51U);
    boot_image_header_t header = make_header(payload, sizeof(payload), 0x51U);
    boot_trailer_record_t trailer;

    reset_fixture();
    header.board_id ^= 1U;
    CHECK(!boot_update_begin(&header));
    header.board_id = BOOT_BOARD_ID;
    CHECK(boot_update_begin(&header));
    CHECK(boot_update_is_active());
    CHECK(!boot_update_write_block(BOOT_FLASH_WORD_SIZE, payload, sizeof(payload)));
    CHECK(!boot_update_write_block(0U, payload, 31U));
    CHECK(boot_update_write_block(0U, payload, sizeof(payload)));
    CHECK(boot_update_finalize());
    CHECK(!boot_update_is_active());
    CHECK(boot_image_validate(BOOT_SLOT_SECONDARY));
    CHECK(boot_trailer_latest(BOOT_SLOT_SECONDARY, &trailer));
    CHECK(trailer.state == BOOT_STATE_PENDING);
    CHECK(trailer.sequence == 2U);
}

static void test_update_engine_crc_failure_does_not_commit(void)
{
    uint8_t payload[64];
    make_payload(payload, sizeof(payload), 0x52U);
    boot_image_header_t header = make_header(payload, sizeof(payload), 0x52U);
    header.payload_crc32 ^= 1U;

    reset_fixture();
    CHECK(boot_update_begin(&header));
    CHECK(boot_update_write_block(0U, payload, sizeof(payload)));
    CHECK(!boot_update_finalize());
    CHECK(boot_update_is_active());
    boot_update_abort();
    CHECK(!boot_update_is_active());
}

/* Sprint 7 boundary: receiving a candidate is strictly a Secondary-slot
 * operation.  A confirmed running image must survive both an aborted and a
 * successfully-finalized download unchanged. */
static void test_secondary_download_preserves_confirmed_primary(void)
{
    uint8_t payload[64];
    boot_trailer_record_t primary_before;
    boot_trailer_record_t primary_after;
    boot_trailer_record_t secondary;

    reset_fixture();
    const boot_image_header_t running = seed_image(BOOT_SLOT_PRIMARY, 0x5AU);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, running.payload_crc32);
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &primary_before));

    make_payload(payload, sizeof(payload), 0x5BU);
    const boot_image_header_t candidate = make_header(payload, sizeof(payload), 0x5BU);

    CHECK(boot_update_begin(&candidate));
    CHECK(!boot_update_write_block(BOOT_FLASH_WORD_SIZE, payload, sizeof(payload)));
    CHECK(!boot_update_write_block(0U, payload, 31U));
    boot_update_abort();
    CHECK(!boot_update_is_active());
    CHECK(!boot_trailer_latest(BOOT_SLOT_SECONDARY, &secondary));
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &primary_after));
    CHECK(memcmp(&primary_before, &primary_after, sizeof(primary_before)) == 0);
    CHECK(boot_image_header(BOOT_SLOT_PRIMARY)->firmware_version == running.firmware_version);

    CHECK(boot_update_begin(&candidate));
    CHECK(boot_update_write_block(0U, payload, sizeof(payload)));
    CHECK(boot_update_finalize());
    CHECK(boot_image_validate(BOOT_SLOT_SECONDARY));
    CHECK(boot_trailer_latest(BOOT_SLOT_SECONDARY, &secondary));
    CHECK(secondary.state == BOOT_STATE_PENDING && secondary.sequence == 2U);
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &primary_after));
    CHECK(memcmp(&primary_before, &primary_after, sizeof(primary_before)) == 0);
    CHECK(boot_image_header(BOOT_SLOT_PRIMARY)->firmware_version == running.firmware_version);
}

static void test_first_install_from_empty_primary(void)
{
    boot_trailer_record_t record;
    reset_fixture();
    const boot_image_header_t candidate = seed_image(BOOT_SLOT_SECONDARY, 0x61U);
    seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_DOWNLOADED, 0U, candidate.payload_crc32);
    seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_PENDING, 0U, candidate.payload_crc32);

    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    CHECK(boot_sil_jump_msp() == 0x20020000UL);
    CHECK(boot_sil_jump_reset_handler() == BOOT_PRIMARY_PAYLOAD_BASE + 0x21U);
    CHECK(boot_image_validate(BOOT_SLOT_PRIMARY));
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.state == BOOT_STATE_TEST);
    CHECK(record.boot_attempts == 1U);
    CHECK(boot_trailer_latest(BOOT_SLOT_SECONDARY, &record));
    CHECK(record.state == BOOT_STATE_CONFIRMED);
}

static void test_confirmed_primary_swaps_pending_secondary(void)
{
    boot_trailer_record_t record;
    reset_fixture();
    const boot_image_header_t old_image = seed_image(BOOT_SLOT_PRIMARY, 0x71U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, old_image.payload_crc32);
    const boot_image_header_t candidate = seed_image(BOOT_SLOT_SECONDARY, 0x72U);
    seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_DOWNLOADED, 0U, candidate.payload_crc32);
    seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_PENDING, 0U, candidate.payload_crc32);

    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    CHECK(boot_image_header(BOOT_SLOT_PRIMARY)->firmware_version == 0x72U);
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.state == BOOT_STATE_TEST && record.boot_attempts == 1U);
    CHECK(boot_image_header(BOOT_SLOT_SECONDARY)->firmware_version == 0x71U);
    CHECK(boot_trailer_latest(BOOT_SLOT_SECONDARY, &record));
    CHECK(record.state == BOOT_STATE_CONFIRMED);
}

static void test_confirmed_primary_jumps_without_mutation(void)
{
    boot_trailer_record_t before;
    boot_trailer_record_t after;
    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0x81U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, image.payload_crc32);
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &before));

    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &after));
    CHECK(memcmp(&before, &after, sizeof(before)) == 0);
}

static void test_confirmed_primary_is_stable_over_ten_boots(void)
{
    boot_trailer_record_t before;
    boot_trailer_record_t after;
    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0x82U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, image.payload_crc32);
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &before));

    for (uint32_t boot = 0U; boot < 10U; ++boot) {
        boot_sil_runtime_reset();
        CHECK(boot_manager_run());
        CHECK(boot_sil_jump_occurred());
        CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &after));
        CHECK(memcmp(&before, &after, sizeof(before)) == 0);
    }
}

/* Models the contract of app_bootloader_confirm(): the bootloader has already
 * appended TEST(1), then the healthy application appends CONFIRMED(0). */
static void test_healthy_test_image_becomes_confirmed(void)
{
    boot_trailer_record_t record;
    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0x85U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST, 0U, image.payload_crc32);

    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.state == BOOT_STATE_TEST && record.boot_attempts == 1U);

    /* This append is what the application-side API performs after its health
     * checks.  It must be a new journal record, never an in-place rewrite. */
    CHECK(boot_trailer_append(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U,
                              0xFFU, image.payload_crc32));
    boot_sil_runtime_reset();
    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.state == BOOT_STATE_CONFIRMED && record.boot_attempts == 0U);
}

static void test_unhealthy_test_image_remains_test(void)
{
    boot_trailer_record_t record;
    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0x86U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST, 0U, image.payload_crc32);

    /* No application confirmation is injected between boots. */
    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    boot_sil_runtime_reset();
    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.state == BOOT_STATE_TEST && record.boot_attempts == 2U);
}

static void test_missing_or_corrupt_primary_trailer_enters_recovery(void)
{
    reset_fixture();
    (void)seed_image(BOOT_SLOT_PRIMARY, 0x83U);
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());

    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0x84U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, image.payload_crc32);
    boot_sil_flash_mut(BOOT_PRIMARY_TRAILER_BASE)[28] ^= 1U;
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());
}

/* Sprint 5 recovery gate: every malformed Primary variant must return to the
 * caller without recording a hand-off.  main.c then owns USB recovery. */
static void test_invalid_primary_variants_never_jump(void)
{
    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0x87U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, image.payload_crc32);
    boot_sil_flash_mut(BOOT_PRIMARY_BASE)[0] ^= 1U; /* Header magic. */
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());

    reset_fixture();
    const boot_image_header_t payload_image = seed_image(BOOT_SLOT_PRIMARY, 0x88U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, payload_image.payload_crc32);
    boot_sil_flash_mut(BOOT_PRIMARY_PAYLOAD_BASE)[16] ^= 1U; /* Payload CRC. */
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());

    reset_fixture();
    const boot_image_header_t stale = seed_image(BOOT_SLOT_PRIMARY, 0x89U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, stale.payload_crc32 ^ 1U);
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());
}

static void test_test_image_rolls_back_to_previous_confirmed(void)
{
    boot_trailer_record_t record;
    reset_fixture();
    const boot_image_header_t candidate = seed_image(BOOT_SLOT_PRIMARY, 0x91U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST, 3U, candidate.payload_crc32);
    const boot_image_header_t old_image = seed_image(BOOT_SLOT_SECONDARY, 0x92U);
    seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_CONFIRMED, 0U, old_image.payload_crc32);

    CHECK(boot_manager_run());
    CHECK(boot_sil_jump_occurred());
    CHECK(boot_image_header(BOOT_SLOT_PRIMARY)->firmware_version == 0x92U);
    CHECK(boot_trailer_latest(BOOT_SLOT_PRIMARY, &record));
    CHECK(record.state == BOOT_STATE_CONFIRMED);
}

static void test_unconfirmed_first_install_enters_recovery(void)
{
    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0xA1U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST, 3U, image.payload_crc32);
    const boot_image_header_t mirror = seed_image(BOOT_SLOT_SECONDARY, 0xA1U);
    seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_CONFIRMED, 0U, mirror.payload_crc32);

    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());
}

static void test_empty_device_enters_recovery(void)
{
    reset_fixture();
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());
}

static void test_stale_trailer_crc_cannot_boot_or_install(void)
{
    reset_fixture();
    const boot_image_header_t primary = seed_image(BOOT_SLOT_PRIMARY, 0xB1U);
    seed_state(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U, primary.payload_crc32 ^ 1U);
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());

    reset_fixture();
    const boot_image_header_t secondary = seed_image(BOOT_SLOT_SECONDARY, 0xB2U);
    seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_PENDING, 0U, secondary.payload_crc32 ^ 1U);
    CHECK(!boot_manager_run());
    CHECK(!boot_sil_jump_occurred());
}

static void test_trailer_capacity_is_append_only(void)
{
    reset_fixture();
    const boot_image_header_t image = seed_image(BOOT_SLOT_PRIMARY, 0xB3U);
    const uint32_t capacity = BOOT_IMAGE_TRAILER_SIZE / BOOT_FLASH_WORD_SIZE;
    for (uint32_t index = 0U; index < capacity; ++index) {
        CHECK(boot_trailer_append(BOOT_SLOT_PRIMARY, BOOT_STATE_TEST, (uint8_t)index,
                                  0xFFU, image.payload_crc32));
    }
    CHECK(!boot_trailer_append(BOOT_SLOT_PRIMARY, BOOT_STATE_CONFIRMED, 0U,
                               0xFFU, image.payload_crc32));
}

static void test_first_install_fault_injection_never_jumps(void)
{
    const unsigned cut_points[] = {0U, 1U, 6U, 128U};
    for (size_t index = 0U; index < sizeof(cut_points) / sizeof(cut_points[0]); ++index) {
        reset_fixture();
        const boot_image_header_t candidate = seed_image(BOOT_SLOT_SECONDARY, 0xC0U + (uint32_t)index);
        seed_state(BOOT_SLOT_SECONDARY, BOOT_STATE_PENDING, 0U, candidate.payload_crc32);
        boot_sil_flash_fail_after((int)(boot_sil_flash_operation_count() + cut_points[index]));
        CHECK(!boot_manager_run());
        CHECK(!boot_sil_jump_occurred());
    }
}

static size_t make_frame(uint8_t *frame, uint8_t command, uint16_t sequence,
                         const uint8_t *payload, uint16_t payload_length)
{
    frame[0] = 0xA5U;
    frame[1] = 0x5AU;
    frame[2] = 1U;
    frame[3] = command;
    frame[4] = (uint8_t)sequence;
    frame[5] = (uint8_t)(sequence >> 8U);
    frame[6] = (uint8_t)payload_length;
    frame[7] = (uint8_t)(payload_length >> 8U);
    if (payload_length != 0U) {
        memcpy(&frame[8], payload, payload_length);
    }
    const uint32_t crc = boot_crc32(&frame[2], 6U + payload_length);
    write_u32(&frame[8U + payload_length], crc);
    return 12U + payload_length;
}

static uint8_t protocol_request(uint8_t command, const uint8_t *payload, uint16_t payload_length,
                                bool corrupt_crc)
{
    uint8_t request[1200];
    uint8_t response[1200];
    const size_t request_length = make_frame(request, command, 0x1234U, payload, payload_length);
    if (corrupt_crc) {
        request[request_length - 1U] ^= 1U;
    }
    boot_sil_cdc_feed(request, request_length);
    boot_protocol_poll();
    boot_protocol_poll();
    const size_t response_length = boot_sil_cdc_take_tx(response, sizeof(response));
    if (response_length < 13U || response[0] != 0xA5U || response[1] != 0x5AU ||
        response[3] != (uint8_t)(command | 0x80U) ||
        response[4] != 0x34U || response[5] != 0x12U) {
        printf("  FAIL %s: malformed response\n", __func__);
        ++g_failures;
        return 0xFFU;
    }
    return response[8];
}

static void test_protocol_get_info_and_error_responses(void)
{
    reset_fixture();
    CHECK(protocol_request(CMD_GET_INFO, NULL, 0U, false) == STATUS_OK);
    CHECK(protocol_request(0x7EU, NULL, 0U, false) == STATUS_BAD_COMMAND);
    CHECK(protocol_request(CMD_GET_INFO, NULL, 0U, true) == STATUS_BAD_FRAME);
    CHECK(protocol_request(CMD_WRITE_BLOCK, NULL, 0U, false) == STATUS_BAD_ARGUMENT);
    CHECK(protocol_request(CMD_RESET, NULL, 0U, false) == STATUS_OK);
    CHECK(boot_sil_reset_count() == 1U);
}

static void test_protocol_incomplete_frame_times_out_and_abort_is_idempotent(void)
{
    uint8_t partial[] = {0xA5U, 0x5AU, 1U, CMD_GET_INFO, 0x44U, 0x33U, 4U, 0U, 0xAAU};
    reset_fixture();
    boot_sil_cdc_feed(partial, sizeof(partial));
    boot_protocol_poll();
    boot_sil_tick_advance(1000U);
    boot_protocol_poll();
    CHECK(protocol_request(CMD_GET_INFO, NULL, 0U, false) == STATUS_OK);
    CHECK(protocol_request(CMD_ABORT, NULL, 0U, false) == STATUS_OK);
    CHECK(protocol_request(CMD_WRITE_BLOCK, NULL, 0U, false) == STATUS_BAD_ARGUMENT);
}

static void test_protocol_update_end_to_end(void)
{
    uint8_t payload[64];
    uint8_t write_payload[sizeof(payload) + 4U];
    const uint8_t malformed_begin_payload = 0U;
    boot_trailer_record_t trailer;
    make_payload(payload, sizeof(payload), 0xD1U);
    const boot_image_header_t header = make_header(payload, sizeof(payload), 0xD1U);

    reset_fixture();
    CHECK(protocol_request(CMD_BEGIN_UPDATE, (const uint8_t *)&header, sizeof(header), false) == STATUS_OK);
    write_u32(write_payload, 0U);
    memcpy(&write_payload[4], payload, sizeof(payload));
    CHECK(protocol_request(CMD_WRITE_BLOCK, write_payload, sizeof(write_payload), false) == STATUS_OK);
    CHECK(protocol_request(CMD_FINALIZE, NULL, 0U, false) == STATUS_OK);
    CHECK(boot_image_validate(BOOT_SLOT_SECONDARY));
    CHECK(boot_trailer_latest(BOOT_SLOT_SECONDARY, &trailer));
    CHECK(trailer.state == BOOT_STATE_PENDING);
    CHECK(protocol_request(CMD_BEGIN_UPDATE, &malformed_begin_payload, 1U, false) == STATUS_BAD_ARGUMENT);
    CHECK(protocol_request(CMD_ABORT, NULL, 0U, false) == STATUS_OK);
}

int main(void)
{
    RUN(test_flash_model_rules);
    RUN(test_image_validation_rejects_tampering);
    RUN(test_image_validation_rejects_all_s2_metadata_variants);
    RUN(test_trailer_journal_latest_and_partial_record);
    RUN(test_update_engine_end_to_end_and_rejections);
    RUN(test_update_engine_crc_failure_does_not_commit);
    RUN(test_secondary_download_preserves_confirmed_primary);
    RUN(test_first_install_from_empty_primary);
    RUN(test_confirmed_primary_swaps_pending_secondary);
    RUN(test_confirmed_primary_jumps_without_mutation);
    RUN(test_confirmed_primary_is_stable_over_ten_boots);
    RUN(test_healthy_test_image_becomes_confirmed);
    RUN(test_unhealthy_test_image_remains_test);
    RUN(test_missing_or_corrupt_primary_trailer_enters_recovery);
    RUN(test_invalid_primary_variants_never_jump);
    RUN(test_test_image_rolls_back_to_previous_confirmed);
    RUN(test_unconfirmed_first_install_enters_recovery);
    RUN(test_empty_device_enters_recovery);
    RUN(test_stale_trailer_crc_cannot_boot_or_install);
    RUN(test_trailer_capacity_is_append_only);
    RUN(test_first_install_fault_injection_never_jumps);
    RUN(test_protocol_get_info_and_error_responses);
    RUN(test_protocol_incomplete_frame_times_out_and_abort_is_idempotent);
    RUN(test_protocol_update_end_to_end);

    printf("SIL result: %u tests, %u failures\n", g_tests, g_failures);
    return g_failures == 0U ? 0 : 1;
}
