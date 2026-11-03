#ifndef APP_BOOTLOADER_H
#define APP_BOOTLOADER_H

#include <stdbool.h>

/* Call after application-specific self-test. This API never erases flash. */
bool app_bootloader_confirm(void);

/* Request one boot into bootloader USB update mode, then reset the MCU.
 * Returns false only if the RTC backup domain cannot be made writable. */
bool app_bootloader_request_update(void);

#endif
