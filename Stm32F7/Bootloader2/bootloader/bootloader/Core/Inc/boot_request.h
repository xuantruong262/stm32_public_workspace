#ifndef BOOT_REQUEST_H
#define BOOT_REQUEST_H

#include <stdbool.h>

/* Returns true once for a valid app-requested USB update boot and clears it. */
bool boot_request_consume_update(void);

#endif
