#include "boot_cdc_transport.h"

#include "usbd_cdc_if.h"
#include "usb_device.h"
#include "usbd_cdc.h"

extern USBD_HandleTypeDef hUsbDeviceHS;

#define BOOT_CDC_RX_RING_SIZE 4096U

static uint8_t g_rx_ring[BOOT_CDC_RX_RING_SIZE];
static volatile uint32_t g_rx_head;
static volatile uint32_t g_rx_tail;
static volatile bool g_rx_overflow;

bool boot_cdc_rx_enqueue(const uint8_t *data, uint32_t length)
{
    bool accepted = true;
    while (length-- != 0U) {
        const uint32_t next = (g_rx_head + 1U) % BOOT_CDC_RX_RING_SIZE;
        if (next == g_rx_tail) {
            g_rx_overflow = true;
            accepted = false;
            break;
        }
        g_rx_ring[g_rx_head] = *data++;
        g_rx_head = next;
    }
    return accepted;
}

bool boot_cdc_rx_dequeue(uint8_t *byte)
{
    if (g_rx_tail == g_rx_head) {
        return false;
    }
    *byte = g_rx_ring[g_rx_tail];
    g_rx_tail = (g_rx_tail + 1U) % BOOT_CDC_RX_RING_SIZE;
    return true;
}

bool boot_cdc_rx_overflowed(void)
{
    return g_rx_overflow;
}

void boot_cdc_rx_clear_overflow(void)
{
    g_rx_overflow = false;
}

bool boot_cdc_transmit(const uint8_t *data, uint16_t length)
{
    return CDC_Transmit_HS((uint8_t *)data, length) == USBD_OK;
}

bool boot_cdc_tx_idle(void)
{
    if (hUsbDeviceHS.pClassData == NULL) {
        return false;
    }
    return ((USBD_CDC_HandleTypeDef *)hUsbDeviceHS.pClassData)->TxState == 0U;
}
