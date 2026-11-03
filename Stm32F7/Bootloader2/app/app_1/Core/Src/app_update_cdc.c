#include "app_update_cdc.h"

#include "app_bootloader.h"
#include "main.h"
#include "usbd_cdc_if.h"

#include <stdbool.h>
#include <stddef.h>

/* App CDC protocol: host sends the byte stream "ENTER_UPDATE\\n"; app replies "OK\\n". */
static const uint8_t g_enter_update_command[] = "ENTER_UPDATE\n";
static uint8_t g_command_index;
static volatile bool g_update_requested;
static volatile bool g_ack_in_flight;
static volatile bool g_ack_complete;
static volatile uint32_t g_ack_complete_tick;

/* Do not reset in the USB IN-complete callback's next foreground iteration.
 * The host CDC stack needs a small, deterministic window to deliver "OK\\n"
 * to the flashing utility before the device disconnects for bootloader mode. */
#define APP_UPDATE_ACK_HOLD_MS 1000U

void app_update_cdc_receive(const uint8_t *data, uint32_t length)
{
    if ((data == NULL) || g_update_requested) {
        return;
    }

    for (uint32_t i = 0U; i < length; ++i) {
        if (data[i] == g_enter_update_command[g_command_index]) {
            ++g_command_index;
            if (g_command_index == (sizeof(g_enter_update_command) - 1U)) {
                g_update_requested = true;
                g_command_index = 0U;
                return;
            }
        } else {
            g_command_index = (data[i] == g_enter_update_command[0]) ? 1U : 0U;
        }
    }
}

void app_update_cdc_tx_complete(void)
{
    if (g_ack_in_flight) {
        g_ack_complete = true;
        g_ack_complete_tick = HAL_GetTick();
    }
}

void app_update_cdc_poll(void)
{
    static uint8_t ack[] = "OK\n";

    if (!g_update_requested) {
        return;
    }
    if (g_ack_in_flight) {
        if ((HAL_GetTick() - g_ack_complete_tick) >= APP_UPDATE_ACK_HOLD_MS) {
            (void)app_bootloader_request_update();
        }
        return;
    }
    if (CDC_Transmit_HS(ack, sizeof(ack) - 1U) == USBD_OK) {
        g_ack_in_flight = true;
        /* Some Cube USB-device versions do not invoke the optional
         * TransmitCplt interface callback.  USBD_OK means the class driver
         * accepted the packet; retain the device link for a bounded window so
         * the host can consume it, without relying on that optional callback. */
        g_ack_complete_tick = HAL_GetTick();
    }
}
