#ifndef APP_UPDATE_CDC_H
#define APP_UPDATE_CDC_H

#include <stdint.h>

/* Called by the CubeMX USB CDC callbacks and from the application main loop. */
void app_update_cdc_receive(const uint8_t *data, uint32_t length);
void app_update_cdc_tx_complete(void);
void app_update_cdc_poll(void);

#endif
