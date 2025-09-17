#include "wav_player.h"
#include <string.h>

// FatFS objects
static FATFS fs;
FIL *myFile ;


// I2S handle (from main)
static I2S_HandleTypeDef *hI2S = NULL;

// WAV format info
static uint16_t bitsPerSample = 16;
static uint16_t numChannels = 2;
static uint32_t sampleRate = 44100;
static volatile uint32_t dataChunkSize = 0;
static uint8_t IsAVI = 1;
// double buffer
__attribute__((section(".RAM_D3"), aligned(4)))
static volatile uint8_t buffer[WAV_BUF_SIZE * 2]; // Use this for I2S6(BDMA)
__attribute__((section(".RAM_D1"), aligned(4)))
static volatile uint8_t D1Buffer[WAV_BUF_SIZE * 2];

static volatile uint32_t bufFillPos = 0;
static volatile uint8_t *playRunning = 0;
uint32_t DataRemain = 0;
static volatile uint8_t remainDataBuf[4096];
extern uint8_t Jpeg_frame[76800];


// file read position
static volatile uint32_t bytesRemaining = 0;
static volatile uint32_t audio_cnt = 0;
// forward
static int parse_wav_header(FIL *f);
void start_dma_transfer(uint32_t length);

// For AVI
WAV_Status AVIaudio_init(I2S_HandleTypeDef *hi2s_ptr, uint8_t *Playing_Ctrl)
{

    hI2S = hi2s_ptr;
    playRunning = Playing_Ctrl;
    return WAV_OK;
}

/* Start playback: read initial double buffers then start DMA */
void AVIaudioLoadFile(FIL *f){
	IsAVI = 1;
	myFile = f;
}

/* Initialize WAV player: mount FS, open file, parse header */

/* Start playback: read initial double buffers then start DMA */
void wav_start_play(char *filename)
{
	UINT br;
	IsAVI = 0;
	// Audio File  open
	myFile = malloc(sizeof(FIL));
    if (f_open(myFile, filename, FA_READ) != FR_OK) return WAV_ERR;
    // Audio Get file info
    if (parse_wav_header(myFile) != 0) {
        f_close(myFile);
        return WAV_ERR;
    }
    bytesRemaining = dataChunkSize;
    memset(buffer, 0, sizeof(buffer));
    bufFillPos = 0;
    start_dma_transfer(WAV_BUF_SIZE*2);
}

/* stop playback */
void wav_stop_play(void)
{
    //if(!(*playRunning)) return;
    HAL_I2S_DMAStop(hI2S);
    f_close(myFile);
    f_mount(NULL, "", 1);
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

void Audio_I2S_TxHalfCb(){
	UINT br;
	uint32_t blockSize = 0;
	uint32_t chunk_type = 0;
	uint32_t limit_size = WAV_BUF_SIZE;
	uint32_t offset = 0;
	uint8_t hafBuffer[WAV_BUF_SIZE];
	if(IsAVI){ // AVI
		while(*playRunning){
			if( f_tell(myFile) & 0x1 ) {
				f_lseek(myFile, f_tell(myFile) + 1);
			}
			// Get type
			f_read(myFile, &chunk_type, 4, &br);
			if(br < 4){
				break;
			}
			// Get Size
			f_read(myFile, &blockSize, 4, &br);
			if(br < 4){
				break;
			}
			if(chunk_type == 0x62773130){ // Audio
				if(DataRemain){
					memcpy(hafBuffer,remainDataBuf, DataRemain);
					offset += DataRemain;
					DataRemain = 0;
				}
				if( (offset + blockSize) > limit_size){
					f_read(myFile, remainDataBuf, blockSize, &br);
					DataRemain = (offset + blockSize) - limit_size;
					blockSize = limit_size - offset;
					memcpy(hafBuffer + offset, remainDataBuf ,blockSize);
					memcpy(remainDataBuf, remainDataBuf + blockSize , DataRemain);
					break;
				}
				f_read(myFile, hafBuffer + offset, blockSize, &br);
				offset += blockSize;
			}
			else if (chunk_type == 0x63643030) {
				if (audio_cnt % 1 == 0) {
					f_read(myFile, Jpeg_frame, blockSize, &br); // read data input
					JPEG();
				} else {
					f_lseek(myFile, f_tell(myFile) + blockSize);
				}
				audio_cnt++;
			}
			else{
				f_lseek(myFile, f_tell(myFile) + blockSize);
			}
		}
		memcpy(buffer,hafBuffer,WAV_BUF_SIZE);

	}
	else{ // Wav
	    if (!(*playRunning)){
	    	return;
	    }
	    // fill first half of buffer
	    UINT br;
	    uint8_t *dst = buffer;
	    uint32_t toRead = (WAV_BUF_SIZE < bytesRemaining) ? WAV_BUF_SIZE : bytesRemaining;
	    if (toRead > 0) {
	        if (f_read(myFile, dst, toRead, &br) == FR_OK) {
	            bytesRemaining -= br;
	            if (br < WAV_BUF_SIZE) {
	            	memset(dst + br, 0, WAV_BUF_SIZE - br);
	            }
	        } else {
	            wav_stop_play();
	        }
	    } else {
	        // no more data: fill zeros and stop after whole buffer has played
	        memset(dst, 0, WAV_BUF_SIZE);
	        wav_deinit();
	    }
	}
#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)buffer, WAV_BUF_SIZE*2);
			__DSB();
			asm volatile("" ::: "memory");
#endif
}
void Audio_I2S_TxCpltCb(){
	UINT br;
	uint32_t blockSize = 0;
	uint32_t chunk_type = 0;
	uint32_t limit_size = WAV_BUF_SIZE;
	uint32_t offset = 0;
	uint8_t hafBuffer[WAV_BUF_SIZE];
	if(IsAVI){ // AVI
		while(*playRunning){
			if( f_tell(myFile) & 0x1 ) {
				f_lseek(myFile, f_tell(myFile) + 1);
			}
			// Get type
			f_read(myFile, &chunk_type, 4, &br);
			if(br < 4){
				break;
			}
			// Get Size
			f_read(myFile, &blockSize, 4, &br);
			if(br < 4){
				break;
			}
			if(chunk_type == 0x62773130){ // Audio
				if(DataRemain){
					memcpy(hafBuffer,remainDataBuf, DataRemain);
					offset += DataRemain;
					DataRemain = 0;
				}
				if( (offset + blockSize) > limit_size){
					f_read(myFile, remainDataBuf, blockSize, &br);
					DataRemain = (offset + blockSize) - limit_size;
					blockSize = limit_size - offset;
					memcpy(hafBuffer + offset, remainDataBuf ,blockSize);
					memcpy(remainDataBuf, remainDataBuf + blockSize , DataRemain);
					break;
				}
				f_read(myFile, hafBuffer + offset, blockSize, &br);
				offset += blockSize;
			}
			else if (chunk_type == 0x63643030) {
				if (audio_cnt % 1 == 0) {
					f_read(myFile, Jpeg_frame, blockSize, &br); // read data input
					JPEG();
				} else {
					f_lseek(myFile, f_tell(myFile) + blockSize);
				}
				audio_cnt++;
			}
			else{
				f_lseek(myFile, f_tell(myFile) + blockSize);
			}
		}
		memcpy(buffer + WAV_BUF_SIZE,hafBuffer,WAV_BUF_SIZE);
	}
	else{ // WAV
	    if (!(*playRunning)) return;
	    UINT br;
	    uint8_t *dst = buffer + WAV_BUF_SIZE;
	    uint32_t toRead = (WAV_BUF_SIZE < bytesRemaining) ? WAV_BUF_SIZE : bytesRemaining;
	    if (toRead > 0) {
	        if (f_read(myFile, dst, toRead, &br) == FR_OK) {
	            bytesRemaining -= br;
	            if (br < WAV_BUF_SIZE) memset(dst + br, 0, WAV_BUF_SIZE - br);
	        } else {
	            wav_stop_play();
	        }
	    } else {
	        memset(dst, 0, WAV_BUF_SIZE);
	        wav_deinit();
	    }
	}

#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)buffer, WAV_BUF_SIZE*2);
			__DSB();
			asm volatile("" ::: "memory");
#endif
}

/* helper to start DMA */
void start_dma_transfer(uint32_t length)
{
	uint32_t halfWords = length / 2;
	Audio_I2S_TxHalfCb();
	Audio_I2S_TxCpltCb();
#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)buffer, WAV_BUF_SIZE*2);
			__DSB();
			asm volatile("" ::: "memory");
#endif
	HAL_I2S_Transmit_DMA(hI2S, buffer, halfWords);
}

/* DMA callbacks - called from HAL IRQ context -------------------------------------------------*/
/* Half complete: refill first half */

