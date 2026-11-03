#ifndef BOOT_REQUEST_CONTRACT_H
#define BOOT_REQUEST_CONTRACT_H

#include <stdint.h>

/* One-shot request stored in RTC backup registers BKP0R..BKP2R. */
#define BOOT_REQUEST_MAGIC          (0x42525153UL) /* "BRQS" */
#define BOOT_REQUEST_UPDATE_MODE    (0x55504454UL) /* "UPDT" */
#define BOOT_REQUEST_GUARD          (BOOT_REQUEST_MAGIC ^ BOOT_REQUEST_UPDATE_MODE ^ 0xFFFFFFFFUL)

#endif
