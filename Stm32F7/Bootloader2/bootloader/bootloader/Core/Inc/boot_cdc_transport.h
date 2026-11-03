#ifndef BOOT_CDC_TRANSPORT_H
#define BOOT_CDC_TRANSPORT_H

#include <stdbool.h>
#include <stdint.h>

bool boot_cdc_rx_enqueue(const uint8_t *data, uint32_t length);
bool boot_cdc_rx_dequeue(uint8_t *byte);
bool boot_cdc_rx_overflowed(void);
void boot_cdc_rx_clear_overflow(void);
bool boot_cdc_transmit(const uint8_t *data, uint16_t length);
bool boot_cdc_tx_idle(void);

#endif
