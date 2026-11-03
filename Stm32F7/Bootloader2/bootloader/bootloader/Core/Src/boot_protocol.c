#include "boot_protocol.h"

#include "boot_cdc_transport.h"
#include "boot_flash.h"
#include "boot_flash_layout.h"
#include "boot_image.h"
#include "boot_update.h"
#include "main.h"

#include <string.h>

#if defined(_MSC_VER)
#define BOOT_PROTOCOL_PACKED
#else
#define BOOT_PROTOCOL_PACKED __attribute__((packed))
#endif

#define BOOT_PROTOCOL_SOF0             0xA5U
#define BOOT_PROTOCOL_SOF1             0x5AU
#define BOOT_PROTOCOL_VERSION          1U
#define BOOT_PROTOCOL_MAX_PAYLOAD      1024U
#define BOOT_PROTOCOL_HEADER_SIZE      8U
#define BOOT_PROTOCOL_CRC_SIZE         4U
#define BOOT_PROTOCOL_RX_TIMEOUT_MS     1000U

enum {
    BOOT_CMD_GET_INFO = 0x01U,
    BOOT_CMD_BEGIN_UPDATE = 0x02U,
    BOOT_CMD_WRITE_BLOCK = 0x03U,
    BOOT_CMD_FINALIZE = 0x04U,
    BOOT_CMD_ABORT = 0x05U,
    BOOT_CMD_RESET = 0x06U
};

typedef enum {
    BOOT_STATUS_OK = 0U,
    BOOT_STATUS_BAD_FRAME = 1U,
    BOOT_STATUS_BAD_COMMAND = 2U,
    BOOT_STATUS_BAD_ARGUMENT = 3U,
    BOOT_STATUS_FLASH = 4U,
    BOOT_STATUS_BUSY = 5U
} boot_status_t;

typedef enum {
    RX_WAIT_SOF0,
    RX_WAIT_SOF1,
    RX_FRAME
} rx_state_t;

typedef struct BOOT_PROTOCOL_PACKED {
    uint32_t board_id;
    uint32_t boot_version;
    uint32_t payload_capacity;
    uint32_t flash_word_size;
} boot_info_t;

static rx_state_t g_rx_state;
static uint8_t g_frame[BOOT_PROTOCOL_HEADER_SIZE + BOOT_PROTOCOL_MAX_PAYLOAD + BOOT_PROTOCOL_CRC_SIZE];
static uint16_t g_frame_length;
static uint16_t g_frame_expected;
static uint8_t g_tx[BOOT_PROTOCOL_HEADER_SIZE + sizeof(boot_info_t) + 1U + BOOT_PROTOCOL_CRC_SIZE];
static uint16_t g_tx_length;
static bool g_tx_pending;
static bool g_reset_after_tx;
static uint32_t g_last_rx_tick;

static uint16_t read_u16(const uint8_t *data)
{
    return (uint16_t)data[0] | ((uint16_t)data[1] << 8U);
}

static uint32_t read_u32(const uint8_t *data)
{
    return (uint32_t)data[0] | ((uint32_t)data[1] << 8U) |
           ((uint32_t)data[2] << 16U) | ((uint32_t)data[3] << 24U);
}

static void write_u16(uint8_t *data, uint16_t value)
{
    data[0] = (uint8_t)value;
    data[1] = (uint8_t)(value >> 8U);
}

static void write_u32(uint8_t *data, uint32_t value)
{
    data[0] = (uint8_t)value;
    data[1] = (uint8_t)(value >> 8U);
    data[2] = (uint8_t)(value >> 16U);
    data[3] = (uint8_t)(value >> 24U);
}

static void queue_response(uint8_t command, uint16_t sequence, boot_status_t status,
                           const void *data, uint16_t data_length)
{
    uint8_t *frame = g_tx;
    const uint16_t payload_length = data_length + 1U;
    frame[0] = BOOT_PROTOCOL_SOF0;
    frame[1] = BOOT_PROTOCOL_SOF1;
    frame[2] = BOOT_PROTOCOL_VERSION;
    frame[3] = command | 0x80U;
    write_u16(&frame[4], sequence);
    write_u16(&frame[6], payload_length);
    frame[8] = (uint8_t)status;
    if ((data != NULL) && (data_length != 0U)) {
        memcpy(&frame[9], data, data_length);
    }
    write_u32(&frame[9U + data_length], boot_crc32(&frame[2], BOOT_PROTOCOL_HEADER_SIZE - 2U + payload_length));
    g_tx_length = (uint16_t)(2U + BOOT_PROTOCOL_HEADER_SIZE - 2U + payload_length + BOOT_PROTOCOL_CRC_SIZE);
    g_tx_pending = true;
}

static void handle_frame(void)
{
    const uint8_t version = g_frame[0];
    const uint8_t command = g_frame[1];
    const uint16_t sequence = read_u16(&g_frame[2]);
    const uint16_t payload_length = read_u16(&g_frame[4]);
    const uint8_t *payload = &g_frame[6];
    const uint32_t received_crc = read_u32(&payload[payload_length]);

    if ((version != BOOT_PROTOCOL_VERSION) ||
        (received_crc != boot_crc32(g_frame, BOOT_PROTOCOL_HEADER_SIZE - 2U + payload_length))) {
        queue_response(command, sequence, BOOT_STATUS_BAD_FRAME, NULL, 0U);
        return;
    }

    switch (command) {
    case BOOT_CMD_GET_INFO: {
        const boot_info_t info = {BOOT_BOARD_ID, BOOT_VERSION, BOOT_PAYLOAD_SIZE, BOOT_FLASH_WORD_SIZE};
        queue_response(command, sequence, BOOT_STATUS_OK, &info, sizeof(info));
        break;
    }
    case BOOT_CMD_BEGIN_UPDATE:
        if (payload_length != sizeof(boot_image_header_t)) {
            queue_response(command, sequence, BOOT_STATUS_BAD_ARGUMENT, NULL, 0U);
        } else if (!boot_update_begin((const boot_image_header_t *)payload)) {
            queue_response(command, sequence, BOOT_STATUS_FLASH, NULL, 0U);
        } else {
            queue_response(command, sequence, BOOT_STATUS_OK, NULL, 0U);
        }
        break;
    case BOOT_CMD_WRITE_BLOCK:
        if ((payload_length <= 4U) || !boot_update_is_active()) {
            queue_response(command, sequence, BOOT_STATUS_BAD_ARGUMENT, NULL, 0U);
        } else if (!boot_update_write_block(read_u32(payload), &payload[4], payload_length - 4U)) {
            const uint32_t flash_status = boot_flash_last_status();
            queue_response(command, sequence,
                           flash_status == 0U ? BOOT_STATUS_BAD_ARGUMENT : BOOT_STATUS_FLASH,
                           &flash_status, sizeof(flash_status));
        } else {
            queue_response(command, sequence, BOOT_STATUS_OK, NULL, 0U);
        }
        break;
    case BOOT_CMD_FINALIZE:
        if ((payload_length != 0U) || !boot_update_finalize()) {
            queue_response(command, sequence, BOOT_STATUS_FLASH, NULL, 0U);
        } else {
            queue_response(command, sequence, BOOT_STATUS_OK, NULL, 0U);
        }
        break;
    case BOOT_CMD_ABORT:
        boot_update_abort();
        queue_response(command, sequence, BOOT_STATUS_OK, NULL, 0U);
        break;
    case BOOT_CMD_RESET:
        if (payload_length != 0U) {
            queue_response(command, sequence, BOOT_STATUS_BAD_ARGUMENT, NULL, 0U);
        } else {
            g_reset_after_tx = true;
            queue_response(command, sequence, BOOT_STATUS_OK, NULL, 0U);
        }
        break;
    default:
        queue_response(command, sequence, BOOT_STATUS_BAD_COMMAND, NULL, 0U);
        break;
    }
}

void boot_protocol_init(void)
{
    g_rx_state = RX_WAIT_SOF0;
    g_frame_length = 0U;
    g_frame_expected = 0U;
    g_tx_pending = false;
    g_reset_after_tx = false;
    g_last_rx_tick = HAL_GetTick();
    boot_cdc_rx_clear_overflow();
}

void boot_protocol_poll(void)
{
    if (g_tx_pending && boot_cdc_transmit(g_tx, g_tx_length)) {
        g_tx_pending = false;
    }
    if (g_reset_after_tx && !g_tx_pending && boot_cdc_tx_idle()) {
        NVIC_SystemReset();
    }
    if (g_tx_pending || !boot_cdc_tx_idle()) {
        return; /* Strict stop-and-wait: do not consume another request yet. */
    }
    /* A disconnected host can leave a syntactically valid but incomplete
     * frame in the parser.  Discard it after a bounded idle interval so the
     * next SOF starts a fresh request rather than extending stale data. */
    if ((g_rx_state != RX_WAIT_SOF0) &&
        ((uint32_t)(HAL_GetTick() - g_last_rx_tick) >= BOOT_PROTOCOL_RX_TIMEOUT_MS)) {
        g_rx_state = RX_WAIT_SOF0;
        g_frame_length = 0U;
        g_frame_expected = 0U;
    }
    if (boot_cdc_rx_overflowed()) {
        g_rx_state = RX_WAIT_SOF0;
        g_frame_length = 0U;
        boot_cdc_rx_clear_overflow();
    }

    uint8_t byte;
    while (!g_tx_pending && boot_cdc_rx_dequeue(&byte)) {
        g_last_rx_tick = HAL_GetTick();
        if (g_rx_state == RX_WAIT_SOF0) {
            g_rx_state = byte == BOOT_PROTOCOL_SOF0 ? RX_WAIT_SOF1 : RX_WAIT_SOF0;
        } else if (g_rx_state == RX_WAIT_SOF1) {
            if (byte == BOOT_PROTOCOL_SOF1) {
                g_rx_state = RX_FRAME;
                g_frame_length = 0U;
                g_frame_expected = 0U;
            } else {
                g_rx_state = byte == BOOT_PROTOCOL_SOF0 ? RX_WAIT_SOF1 : RX_WAIT_SOF0;
            }
        } else {
            if (g_frame_length >= sizeof(g_frame)) {
                g_rx_state = RX_WAIT_SOF0;
                continue;
            }
            g_frame[g_frame_length++] = byte;
            if (g_frame_length == 6U) {
                const uint16_t payload_length = read_u16(&g_frame[4]);
                if (payload_length > BOOT_PROTOCOL_MAX_PAYLOAD) {
                    g_rx_state = RX_WAIT_SOF0;
                    continue;
                }
                g_frame_expected = (uint16_t)(6U + payload_length + BOOT_PROTOCOL_CRC_SIZE);
            }
            if ((g_frame_expected != 0U) && (g_frame_length == g_frame_expected)) {
                handle_frame();
                g_rx_state = RX_WAIT_SOF0;
                g_frame_length = 0U;
            }
        }
    }
}
