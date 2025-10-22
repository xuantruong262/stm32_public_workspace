#include "wav_player.h"
#include <string.h>
#include "mp3dec.h"

#define aLIST 0x5453494c
#define aMovi 0x69766f6d
#define aJunk 0x4b4e554a
#define a00dc 0x63643030
#define a00dc 0x63643030
#define a01wb 0x62773130
#define astrl  0x6c727473
#define aMJPEG 0x47504a4d
#define aAuds  0x73647561
#define aStrf  0x66727473
// FatFS objects
static FATFS fs;
FIL *myFile;

// I2S handle (from main)
static I2S_HandleTypeDef *hI2S = NULL;
static volatile uint32_t DEFAULT_SAMPLERATE = 0;

// WAV format info
static uint16_t bitsPerSample = 16;
static uint16_t numChannels = 2;
static uint32_t sampleRate = 44100;
static volatile uint32_t dataChunkSize = 0;
static volatile uint32_t bufFillPos = 0;
static volatile uint8_t *playRunning = 0;
uint32_t DataRemain = 0;

// Local double buffer
__attribute__((section(".RAM_D3"), aligned(4)))
volatile uint8_t buffer[4700]; // Use this for I2S6(BDMA)
__attribute__((section(".RAM_D1"), aligned(4)))
static volatile uint8_t D1Buffer[WAV_BUF_SIZE* 2];

// For Mp3
#define MP3_READBUF_SIZE  1024*2   // buffer đọc từ SD
#define PCM_OUTBUF_SIZE   1152*2*2 // 1152 sample, stereo, 16-bit
static uint8_t mp3_readBuf[18632];
//__attribute__((section(".RAM_D3"), aligned(4)))
static uint8_t pcm_outBuf[4608];
HMP3Decoder hMP3Decoder;
UINT bytesRead;
static volatile int MP3_offset = 0;
static volatile int MP3_err = 0;
static volatile int MP3_outSamples = 0;
uint32_t MP3_bytesLeft = 0;
static volatile uint8_t *readPtr = mp3_readBuf;
volatile uint8_t mp3_flag = 0;
// Other
static volatile uint8_t remainDataBuf[4096];
// For video AVI
static uint8_t IsAVI = 5;
static volatile uint8_t *video_frame;
uint32_t AVIFPS;
uint8_t AudioVideoSync = 0;
void (*Vid_Func)(void);

// file read position
static volatile uint32_t bytesRemaining = 0;
static volatile uint32_t audio_cnt = 0;
// Define Local Func
static int parse_wav_header(FIL *f);
static uint32_t AVI_DataOffset(FIL *f_Jpeg);
static void start_dma_transfer(uint32_t length);

// Local Function
void wav_stop_play(void) {
	HAL_I2S_DMAStop(hI2S);
	f_close(myFile);
	*playRunning = 0;
}
static int parse_wav_header(FIL *f) {
	BYTE hdr[44];
	UINT br;
	if (f_read(f, hdr, 12, &br) != FR_OK)
		return -1;
	if (br < 12)
		return -1;
	// check "RIFF" and "WAVE"
	if (memcmp(hdr, "RIFF", 4) != 0)
		return -1;
	if (memcmp(hdr + 8, "WAVE", 4) != 0)
		return -1;

	// read chunks until fmt and data found
	while (1) {
		if (f_read(f, hdr, 8, &br) != FR_OK)
			return -1;
		if (br < 8)
			return -1;
		uint32_t chunkID = *((uint32_t*) hdr);
		uint32_t chunkSize = hdr[4] | (hdr[5] << 8) | (hdr[6] << 16)
				| (hdr[7] << 24);

		if (memcmp(hdr, "fmt ", 4) == 0) {
			// read fmt chunk
			if (chunkSize > 100)
				return -1;
			if (f_read(f, hdr, chunkSize, &br) != FR_OK)
				return -1;
			// parse: audio format at offset 0 (little-endian)
			uint16_t audioFormat = hdr[0] | (hdr[1] << 8); // 1 = PCM
			numChannels = hdr[2] | (hdr[3] << 8);
			sampleRate = hdr[4] | (hdr[5] << 8) | (hdr[6] << 16)
					| (hdr[7] << 24);
			bitsPerSample = hdr[14] | (hdr[15] << 8);
			if (audioFormat != 1)
				return -1; // only PCM supported in this simple example
			// skip padding if chunkSize odd
		} else if (memcmp(hdr, "data", 4) == 0) {
			dataChunkSize = chunkSize;
			// data chunk starts immediately — file pointer already after chunk header
			return 0; // success
		} else {
			// skip unknown chunk
			// move file pointer forward chunkSize bytes
			if (f_lseek(f, f_tell(f) + chunkSize) != FR_OK)
				return -1;
		}
	}
	return -1;
}
static void start_dma_transfer(uint32_t length) {
	hI2S->Init.AudioFreq = sampleRate;
	printf("sampleRate: %d\n",sampleRate);
	HAL_I2S_Init(hI2S);
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
	while (1) {
		if (*playRunning == 0) {
			hI2S->Init.AudioFreq = DEFAULT_SAMPLERATE;
			HAL_I2S_Init(hI2S);
			wav_stop_play();
			break;
		}
	}
}
static uint32_t AVI_DataOffset(FIL *f_Jpeg) {
	UINT br = 0;
	uint32_t buf = 0;
	uint32_t Junk_size = 0;
	uint32_t List_size = 0;
	uint32_t tmp_offset = 0;
	f_lseek(f_Jpeg, 0x20);
	f_read(f_Jpeg, &AVIFPS, 4, &br);
	AVIFPS = 1000000 / AVIFPS;

	f_lseek(f_Jpeg, 0x38);
	f_read(f_Jpeg, &buf, 4, &br);
	do {
		// Find chunk
		f_read(f_Jpeg, &buf, 4, &br);
		// Check Video Type

		if (buf == aJunk) { // found JUNK
			f_read(f_Jpeg, &buf, 4, &br);
			Junk_size = buf; // JUNK size
			f_lseek(f_Jpeg, f_tell(f_Jpeg) + Junk_size);
			Junk_size = 0;
		}

		if (buf == aLIST) { // found LIST
			f_read(f_Jpeg, &buf, 4, &br);
			List_size = buf;
			tmp_offset = f_tell(f_Jpeg);
			f_read(f_Jpeg, &buf, 4, &br);
			if (buf == aMovi) { // found Movi
				return List_size;
			}
			else if(buf == astrl){
				uint32_t dt = 0;
				while(1){
					f_read(f_Jpeg, &dt, 4, &br);
					if(dt == aMJPEG){
						f_lseek(f_Jpeg, tmp_offset);
						f_lseek(f_Jpeg, f_tell(f_Jpeg) + List_size);
						break;
					}
					else if(dt == aAuds){
						while(1){
							f_read(f_Jpeg, &dt, 4, &br);
							if(dt == aStrf){
								f_lseek(f_Jpeg, f_tell(f_Jpeg) + 8);
								f_read(f_Jpeg, &sampleRate, 4, &br);
								f_lseek(f_Jpeg, tmp_offset);
								f_lseek(f_Jpeg, f_tell(f_Jpeg) + List_size);
								break;
							}
							else if(dt == aJunk || dt == a01wb){
								f_lseek(f_Jpeg, tmp_offset);
								f_lseek(f_Jpeg, f_tell(f_Jpeg) + List_size);
								break;
							}
						}
						break;
					}
				}
			}
			else {
				f_lseek(f_Jpeg, f_tell(f_Jpeg) + List_size - 4);
			}
			List_size = 0;
		}

		if (br < 4) {
			break;
		}
	} while (br);
	return 0x0;
}
/***********************************API functions for Audio Play****************************/
WAV_Status Audio_Init(I2S_HandleTypeDef *hi2s_ptr, uint8_t *Playing_Ctrl) {
	hI2S = hi2s_ptr;
	DEFAULT_SAMPLERATE = hI2S->Init.AudioFreq;
	playRunning = Playing_Ctrl;
	return WAV_OK;
}
/* AVI Play */
void AVIaudioLoadFile(FIL *f, uint8_t *vid_frBuf, void (*VideoSteam_Func)(void)) {
	Vid_Func = VideoSteam_Func;
	video_frame = vid_frBuf;
	IsAVI = 1;
	myFile = f;
	if (!AVI_DataOffset(myFile))
		return 0;
	AudioVideoSync = AVIFPS / 20 + 1;
	start_dma_transfer(WAV_BUF_SIZE * 2);
}
/* Wav Play */
uint8_t wav_start_play(char *filename) {
	UINT br;
	IsAVI = 0;
	// Audio File  open
	myFile = malloc(sizeof(FIL));
	if (f_open(myFile, filename, FA_READ) != FR_OK)
		return 0;
	// Audio Get file info
	if (parse_wav_header(myFile) != 0) {
		f_close(myFile);
		return 0;
	}
	bytesRemaining = dataChunkSize;
	memset(buffer, 0, sizeof(buffer));
	bufFillPos = 0;
	start_dma_transfer(WAV_BUF_SIZE * 2);
}
/* MP3 Play */
uint8_t mp3_start_play(char *filename) {
	printf("Start Convert Mp3 to Wav!!!\n");
	helix_processing(filename);
	printf("Finished Convert Mp3 to Wav!!!\n");
	wav_start_play("rec.wav");
	sdio_delete_file("rec.wav");

}

// CallBack Function
void Audio_I2S_TxHalfCb() {
	UINT br;
	uint32_t blockSize = 0;
	uint32_t chunk_type = 0;
	uint32_t limit_size = WAV_BUF_SIZE;
	uint32_t offset = 0;
	uint8_t hafBuffer[WAV_BUF_SIZE];
	if (IsAVI == 1) { // AVI
		while (*playRunning) {
			if ( f_tell(myFile) & 0x1) {
				f_lseek(myFile, f_tell(myFile) + 1);
			}
			// Get type
			f_read(myFile, &chunk_type, 4, &br);
			if (br < 4) {
				break;
			}
			// Get Size
			f_read(myFile, &blockSize, 4, &br);
			if (br < 4) {
				break;
			}
			if (chunk_type == a01wb) { // Audio
				if (DataRemain) {
					memcpy(hafBuffer, remainDataBuf, DataRemain);
					offset += DataRemain;
					DataRemain = 0;
				}
				if ((offset + blockSize) > limit_size) {
					f_read(myFile, remainDataBuf, blockSize, &br);
					DataRemain = (offset + blockSize) - limit_size;
					blockSize = limit_size - offset;
					memcpy(hafBuffer + offset, remainDataBuf, blockSize);
					memcpy(remainDataBuf, remainDataBuf + blockSize,
							DataRemain);
					break;
				}
				f_read(myFile, hafBuffer + offset, blockSize, &br);
				offset += blockSize;
			} else if (chunk_type == a00dc) {
				if (audio_cnt % AudioVideoSync == 0) {
					f_read(myFile, video_frame, blockSize, &br); // read data input
					Vid_Func();
				} else {
					f_lseek(myFile, f_tell(myFile) + blockSize);
				}
				audio_cnt++;
			} else {
				f_lseek(myFile, f_tell(myFile) + blockSize);
			}
		}
		memcpy(buffer, hafBuffer, WAV_BUF_SIZE);
	} else if (IsAVI == 0) { // Wav
		// fill first half of buffer
		UINT br;
		uint8_t *dst = buffer;
		uint32_t toRead = (WAV_BUF_SIZE < bytesRemaining) ? WAV_BUF_SIZE : bytesRemaining;
		if (toRead > 0) {
			if (f_read(myFile, dst, toRead, &br) == FR_OK) {
				bytesRemaining -= br;
				if (br < WAV_BUF_SIZE) {
					memset(dst + br, 0, WAV_BUF_SIZE - br);
					// Read new sub file
				}
			} else {
				*playRunning = 0;
			}
		} else {
			*playRunning = 0;
		}
	}
#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)buffer, WAV_BUF_SIZE*2);
			__DSB();
			asm volatile("" ::: "memory");
#endif
}
void Audio_I2S_TxCpltCb() {
	UINT br;
	uint32_t blockSize = 0;
	uint32_t chunk_type = 0;
	uint32_t limit_size = WAV_BUF_SIZE;
	uint32_t offset = 0;
	uint8_t hafBuffer[WAV_BUF_SIZE];
	if (IsAVI == 1) { // AVI
		while (*playRunning) {
			if ( f_tell(myFile) & 0x1) {
				f_lseek(myFile, f_tell(myFile) + 1);
			}
			// Get type
			f_read(myFile, &chunk_type, 4, &br);
			if (br < 4) {
				break;
			}
			// Get Size
			f_read(myFile, &blockSize, 4, &br);
			if (br < 4) {
				break;
			}
			if (chunk_type == a01wb) { // Audio
				if (DataRemain) {
					memcpy(hafBuffer, remainDataBuf, DataRemain);
					offset += DataRemain;
					DataRemain = 0;
				}
				if ((offset + blockSize) > limit_size) {
					f_read(myFile, remainDataBuf, blockSize, &br);
					DataRemain = (offset + blockSize) - limit_size;
					blockSize = limit_size - offset;
					memcpy(hafBuffer + offset, remainDataBuf, blockSize);
					memcpy(remainDataBuf, remainDataBuf + blockSize,
							DataRemain);
					break;
				}
				f_read(myFile, hafBuffer + offset, blockSize, &br);
				offset += blockSize;
			} else if (chunk_type == a00dc) {
				if (audio_cnt % AudioVideoSync == 0) {
					f_read(myFile, video_frame, blockSize, &br); // read data input
					Vid_Func();
				} else {
					f_lseek(myFile, f_tell(myFile) + blockSize);
				}
				audio_cnt++;
			} else {
				f_lseek(myFile, f_tell(myFile) + blockSize);
			}
		}
		memcpy(buffer + WAV_BUF_SIZE, hafBuffer, WAV_BUF_SIZE);
	} else if (IsAVI == 0) { // Wav
		UINT br;
		uint8_t *dst = buffer + WAV_BUF_SIZE;
		uint32_t toRead = (WAV_BUF_SIZE < bytesRemaining) ? WAV_BUF_SIZE : bytesRemaining;
		if (toRead > 0) {
			if (f_read(myFile, dst, toRead, &br) == FR_OK) {
				bytesRemaining -= br;
				if (br < WAV_BUF_SIZE) {
					memset(dst + br, 0, WAV_BUF_SIZE - br);

				}
			} else {
				*playRunning = 0;
			}
		} else {
			*playRunning = 0;
		}
	}
#ifdef USING_CACHE
            // Clean D Cache Transmiss
    		SCB_CleanDCache_by_Addr((uint32_t*)buffer, WAV_BUF_SIZE*2);
			__DSB();
			asm volatile("" ::: "memory");
#endif

}


