#include "wav_player.h"
#include <string.h>

// FatFS objects
static FATFS fs;
static FIL fil;

// I2S handle (from main)
static I2S_HandleTypeDef *hI2S = NULL;

// WAV format info
static uint16_t bitsPerSample = 16;
static uint16_t numChannels = 2;
static uint32_t sampleRate = 44100;
static volatile uint32_t dataChunkSize = 0;

// double buffer
__attribute__((section(".RAM_D3"), aligned(4)))
static volatile uint8_t buffer[WAV_BUF_SIZE * 2]; // Use this for I2S6(BDMA)

static volatile uint32_t bufFillPos = 0;
static volatile uint8_t *playRunning = 0;

// file read position
static volatile uint32_t bytesRemaining = 0;

// forward
static int parse_wav_header(FIL *f);
static void start_dma_transfer(uint8_t *pData, uint32_t length);

// callbacks will be invoked by HAL (weak override in main.c usually)
void HAL_I2S_TxCpltCallback(I2S_HandleTypeDef *hi2s);
void HAL_I2S_TxHalfCpltCallback(I2S_HandleTypeDef *hi2s);
void HAL_I2S_ErrorCallback(I2S_HandleTypeDef *hi2s);

// For AVI
WAV_Status AVIaudio_init(I2S_HandleTypeDef *hi2s_ptr)
{
    hI2S = hi2s_ptr;
    return WAV_OK;
}

/* Start playback: read initial double buffers then start DMA */
void AVIaudio_play(uint32_t block_size, FIL *f){
	UINT br = 0;
    f_read(f, buffer, block_size, &br);
#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)buffer, ALIGN32(block_size));
			__DSB();
			asm volatile("" ::: "memory");
#endif
	HAL_I2S_Transmit(hI2S, (uint16_t*)buffer, block_size/2, HAL_MAX_DELAY);
}


/* Initialize WAV player: mount FS, open file, parse header */
WAV_Status wav_init(I2S_HandleTypeDef *hi2s_ptr, char *filename, uint8_t *Audio_Playing_Ctrl)
{
    hI2S = hi2s_ptr;

    //if (f_mount(&fs, "", 1) != FR_OK) return WAV_ERR;
    if (f_open(&fil, filename, FA_READ) != FR_OK) return WAV_ERR;

    if (parse_wav_header(&fil) != 0) {
        f_close(&fil);
        return WAV_ERR;
    }

    bytesRemaining = dataChunkSize;
    memset(buffer, 0, sizeof(buffer));
    bufFillPos = 0;
    playRunning = Audio_Playing_Ctrl;

    return WAV_OK;
}

/* Start playback: read initial double buffers then start DMA */
void wav_start_play(void)
{
    UINT br;

    // Fill both halves
    if(bytesRemaining == 0) return;
    UINT toRead = (WAV_BUF_SIZE*2 < bytesRemaining) ? WAV_BUF_SIZE*2 : bytesRemaining;
    if (f_read(&fil, buffer, toRead, &br) != FR_OK) return;
    bytesRemaining -= br;

    // If file smaller than full double buffer, zero the rest
    if (br < WAV_BUF_SIZE*2) {
        memset(buffer + br, 0, WAV_BUF_SIZE*2 - br);
    }

    *playRunning = 1;

    // Start DMA transmit (blocking start with DMA offload)
    // Note: HAL_I2S_Transmit_DMA expects a buffer of 16-bit samples for 16-bit PCM.
    start_dma_transfer(buffer, WAV_BUF_SIZE*2);
}

/* stop playback */
void wav_stop_play(void)
{
    if(!(*playRunning)) return;
    HAL_I2S_DMAStop(hI2S);
    f_close(&fil);
    //f_mount(NULL, "", 1);
    *playRunning = 0;
}

/* deinit if needed */
void wav_deinit(void)
{
    wav_stop_play();
}

/* parse WAV header (very basic, looks for "fmt " and "data" chunks) */
static int parse_wav_header(FIL *f)
{
    BYTE hdr[44];
    UINT br;
    if (f_read(f, hdr, 12, &br) != FR_OK) return -1;
    if (br < 12) return -1;
    // check "RIFF" and "WAVE"
    if (memcmp(hdr, "RIFF", 4) != 0) return -1;
    if (memcmp(hdr+8, "WAVE", 4) != 0) return -1;

    // read chunks until fmt and data found
    while(1) {
        if (f_read(f, hdr, 8, &br) != FR_OK) return -1;
        if (br < 8) return -1;
        uint32_t chunkID = *((uint32_t*)hdr);
        uint32_t chunkSize = hdr[4] | (hdr[5]<<8) | (hdr[6]<<16) | (hdr[7]<<24);

        if (memcmp(hdr, "fmt ", 4) == 0) {
            // read fmt chunk
            if (chunkSize > 100) return -1;
            if (f_read(f, hdr, chunkSize, &br) != FR_OK) return -1;
            // parse: audio format at offset 0 (little-endian)
            uint16_t audioFormat = hdr[0] | (hdr[1]<<8); // 1 = PCM
            numChannels = hdr[2] | (hdr[3]<<8);
            sampleRate = hdr[4] | (hdr[5]<<8) | (hdr[6]<<16) | (hdr[7]<<24);
            bitsPerSample = hdr[14] | (hdr[15]<<8);
            if (audioFormat != 1) return -1; // only PCM supported in this simple example
            // skip padding if chunkSize odd
        } else if (memcmp(hdr, "data",4) == 0) {
            dataChunkSize = chunkSize;
            // data chunk starts immediately — file pointer already after chunk header
            return 0; // success
        } else {
            // skip unknown chunk
            // move file pointer forward chunkSize bytes
            if (f_lseek(f, f_tell(f) + chunkSize) != FR_OK) return -1;
        }
    }
    return -1;
}

/* helper to start DMA */
static void start_dma_transfer(uint8_t *pData, uint32_t length)
{
    // For 16-bit PCM stereo, length is bytes; HAL_I2S expects 16-bit units count (length / 2)
    uint32_t halfWords = length / 2;
#ifdef USING_CACHE
		SCB_InvalidateDCache_by_Addr((uint32_t*)pData, ALIGN32(halfWords));
        __DSB();
        asm volatile("" ::: "memory");
#endif
    HAL_I2S_Transmit_DMA(hI2S, (uint16_t*)pData, halfWords);
}

/* DMA callbacks - called from HAL IRQ context -------------------------------------------------*/
/* Half complete: refill first half */
void HAL_I2S_TxHalfCpltCallback(I2S_HandleTypeDef *hi2s)
{
    if (!(*playRunning)) return;
    // fill first half of buffer
    UINT br;
    uint8_t *dst = buffer;
    uint32_t toRead = (WAV_BUF_SIZE < bytesRemaining) ? WAV_BUF_SIZE : bytesRemaining;
    if (toRead > 0) {
        if (f_read(&fil, dst, toRead, &br) == FR_OK) {
            bytesRemaining -= br;
#ifdef USING_CACHE
			// Clean D Cache Receive
//			SCB_InvalidateDCache_by_Addr((uint32_t*)dst, ALIGN32(toRead));
//	        __DSB();
//	        asm volatile("" ::: "memory");
#endif
            if (br < WAV_BUF_SIZE) memset(dst + br, 0, WAV_BUF_SIZE - br);
        } else {
            // read error -> stop
            wav_stop_play();
        }
    } else {
        // no more data: fill zeros and stop after whole buffer has played
        memset(dst, 0, WAV_BUF_SIZE);
        wav_deinit();
        // optional: signal end-of-playback flag here
    }
#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)dst, ALIGN32(toRead));
			__DSB();
			asm volatile("" ::: "memory");
#endif
}

/* Transfer complete: refill second half */
void HAL_I2S_TxCpltCallback(I2S_HandleTypeDef *hi2s)
{
#ifndef DEVELOPING
    if (!(*playRunning)) return;
    UINT br;
    uint8_t *dst = buffer + WAV_BUF_SIZE;
    uint32_t toRead = (WAV_BUF_SIZE < bytesRemaining) ? WAV_BUF_SIZE : bytesRemaining;
    if (toRead > 0) {
        if (f_read(&fil, dst, toRead, &br) == FR_OK) {
            bytesRemaining -= br;
#ifdef USING_CACHE
			// Clean D Cache Receive
//			SCB_InvalidateDCache_by_Addr((uint32_t*)dst, ALIGN32(toRead));
//	        __DSB();
//	        asm volatile("" ::: "memory");
#endif
            if (br < WAV_BUF_SIZE) memset(dst + br, 0, WAV_BUF_SIZE - br);
        } else {
            wav_stop_play();
        }
    } else {
        memset(dst, 0, WAV_BUF_SIZE);
        wav_deinit();
    }
#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)dst, ALIGN32(toRead));
			__DSB();
			asm volatile("" ::: "memory");
#endif
    // if bytesRemaining==0 and both halves zero -> stop
    if (bytesRemaining == 0) {
        // If you want to stop immediately after the last buffer played,
        // you could call wav_stop_play() from a safe context (e.g., set a flag and stop in main loop).
    }
#else
    // processing here
#endif
}

/* Error callback */
void HAL_I2S_ErrorCallback(I2S_HandleTypeDef *hi2s)
{
    // handle error (reset DMA, stop playback)
    wav_stop_play();
}
