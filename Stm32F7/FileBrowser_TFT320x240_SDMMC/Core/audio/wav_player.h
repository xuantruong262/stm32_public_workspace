#ifndef WAV_PLAYER_H
#define WAV_PLAYER_H

#include "ff.h"
#include "stm32h7xx_hal.h" // đổi theo family (stm32h7xx_hal.h nếu H7)
#include <stdint.h>

#define WAV_BUF_SIZE 4096   // bytes per buffer half (nên là multiple of frame size)
typedef enum { WAV_OK=0, WAV_ERR } WAV_Status;

WAV_Status wav_init(I2S_HandleTypeDef *hi2s, char *filename, uint8_t *Audio_Playing_Ctrl);
void wav_start_play(void);
void wav_stop_play(void);
void wav_deinit(void);

#endif
