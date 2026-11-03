#ifndef BOOT_SWAP_H
#define BOOT_SWAP_H

#include <stdbool.h>

/* Exchanges the three primary and secondary sectors through scratch.
 * This implementation is intentionally NOT power-fail-safe. */
bool boot_swap_slots(void);

/* First-install path: Primary has no bootable image, so there is no fallback
 * worth preserving. Copy Secondary into Primary without a reverse swap. */
bool boot_install_secondary_to_primary(void);

#endif
