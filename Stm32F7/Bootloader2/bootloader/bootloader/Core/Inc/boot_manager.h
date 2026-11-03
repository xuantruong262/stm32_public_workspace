#ifndef BOOT_MANAGER_H
#define BOOT_MANAGER_H

#include <stdbool.h>

/* Returns only while recovery/update transport remains unimplemented. */
bool boot_manager_run(void);
#ifdef BOOT_SIL
void boot_jump_to_primary(void);
#else
void boot_jump_to_primary(void) __attribute__((noreturn));
#endif

#endif
