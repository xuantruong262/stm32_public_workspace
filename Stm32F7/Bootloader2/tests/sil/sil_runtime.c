#include "boot_sil.h"

#include "boot_cdc_transport.h"

#include <string.h>

#define SIL_CDC_CAPACITY 8192U

static uint8_t g_rx[SIL_CDC_CAPACITY];
static size_t g_rx_read;
static size_t g_rx_write;
static uint8_t g_tx[SIL_CDC_CAPACITY];
static size_t g_tx_length;
static bool g_rx_overflow;
static bool g_jumped;
static uint32_t g_jump_msp;
static uint32_t g_jump_reset;
static unsigned g_reset_count;
static uint32_t g_tick;

void boot_sil_runtime_reset(void)
{
    g_rx_read = 0U;
    g_rx_write = 0U;
    g_tx_length = 0U;
    g_rx_overflow = false;
    g_jumped = false;
    g_jump_msp = 0U;
    g_jump_reset = 0U;
    g_reset_count = 0U;
    g_tick = 0U;
}

void boot_sil_record_jump(uint32_t msp, uint32_t reset_handler)
{
    g_jumped = true;
    g_jump_msp = msp;
    g_jump_reset = reset_handler;
}

bool boot_sil_jump_occurred(void) { return g_jumped; }
uint32_t boot_sil_jump_msp(void) { return g_jump_msp; }
uint32_t boot_sil_jump_reset_handler(void) { return g_jump_reset; }
unsigned boot_sil_reset_count(void) { return g_reset_count; }
void boot_sil_tick_advance(uint32_t milliseconds) { g_tick += milliseconds; }
uint32_t HAL_GetTick(void) { return g_tick; }

void boot_sil_cdc_feed(const uint8_t *data, size_t length)
{
    if (length > SIL_CDC_CAPACITY - g_rx_write) {
        g_rx_overflow = true;
        return;
    }
    memcpy(&g_rx[g_rx_write], data, length);
    g_rx_write += length;
}

size_t boot_sil_cdc_take_tx(uint8_t *data, size_t capacity)
{
    const size_t copied = g_tx_length < capacity ? g_tx_length : capacity;
    memcpy(data, g_tx, copied);
    g_tx_length = 0U;
    return copied;
}

bool boot_cdc_rx_enqueue(const uint8_t *data, uint32_t length)
{
    boot_sil_cdc_feed(data, length);
    return !g_rx_overflow;
}

bool boot_cdc_rx_dequeue(uint8_t *byte)
{
    if (g_rx_read == g_rx_write) {
        return false;
    }
    *byte = g_rx[g_rx_read++];
    return true;
}

bool boot_cdc_rx_overflowed(void) { return g_rx_overflow; }
void boot_cdc_rx_clear_overflow(void) { g_rx_overflow = false; }

bool boot_cdc_transmit(const uint8_t *data, uint16_t length)
{
    if (length > SIL_CDC_CAPACITY - g_tx_length) {
        return false;
    }
    memcpy(&g_tx[g_tx_length], data, length);
    g_tx_length += length;
    return true;
}

bool boot_cdc_tx_idle(void) { return true; }

void NVIC_SystemReset(void)
{
    ++g_reset_count;
}
