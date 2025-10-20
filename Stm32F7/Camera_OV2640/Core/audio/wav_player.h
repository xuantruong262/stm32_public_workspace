#ifndef WAV_PLAYER_H
#define WAV_PLAYER_H

#include "ff.h"
#include "stm32h7xx_hal.h" // đổi theo family (stm32h7xx_hal.h nếu H7)
#include <stdint.h>

#define NUSING_CACHE
#define DEVELOPING
#define WAV_BUF_SIZE 2048   // bytes per buffer half (nên là multiple of frame size)
#define ALIGN32(x)   (((x) + 31) & ~31U)

typedef enum { WAV_ERR, WAV_OK=1} WAV_Status;

void Audio_I2S_TxHalfCb();
void Audio_I2S_TxCpltCb();
// For audio
void AVIaudioLoadFile(FIL *f , uint8_t *vid_frBuf, void (*VideoStream_Func)(void) );
WAV_Status Audio_Init(I2S_HandleTypeDef *hi2s_ptr, uint8_t *Playing_Ctrl);

/* Start playback: read initial double buffers then start DMA */

uint8_t wav_start_play(char *filename);
void wav_stop_play(void);

// Mp3
uint8_t mp3_start_play(char *filename);

// Itr func

#endif
