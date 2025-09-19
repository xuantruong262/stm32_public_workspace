/* ***** BEGIN LICENSE BLOCK ***** 
 * Version: RCSL 1.0/RPSL 1.0 
 *  
 * Portions Copyright (c) 1995-2002 RealNetworks, Inc. All Rights Reserved. 
 *      
 * The contents of this file, and the files included with this file, are 
 * subject to the current version of the RealNetworks Public Source License 
 * Version 1.0 (the "RPSL") available at 
 * http://www.helixcommunity.org/content/rpsl unless you have licensed 
 * the file under the RealNetworks Community Source License Version 1.0 
 * (the "RCSL") available at http://www.helixcommunity.org/content/rcsl, 
 * in which case the RCSL will apply. You may also obtain the license terms 
 * directly from RealNetworks.  You may not use this file except in 
 * compliance with the RPSL or, if you have a valid RCSL with RealNetworks 
 * applicable to this file, the RCSL.  Please see the applicable RPSL or 
 * RCSL for the rights, obligations and limitations governing use of the 
 * contents of the file.  
 *  
 * This file is part of the Helix DNA Technology. RealNetworks is the 
 * developer of the Original Code and owns the copyrights in the portions 
 * it created. 
 *  
 * This file, and the files included with this file, is distributed and made 
 * available on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER 
 * EXPRESS OR IMPLIED, AND REALNETWORKS HEREBY DISCLAIMS ALL SUCH WARRANTIES, 
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS 
 * FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. 
 * 
 * Technology Compatibility Kit Test Suite(s) Location: 
 *    http://www.helixcommunity.org/content/tck 
 * 
 * Contributor(s): 
 *  
 * ***** END LICENSE BLOCK ***** */ 

/**************************************************************************************
 * Fixed-point MP3 decoder
 * Jon Recker (jrecker@real.com), Ken Cooke (kenc@real.com)
 * June 2003
 *
 * main.c - command-line test app that uses C interface to MP3 decoder
 **************************************************************************************/

#include <stdlib.h>
#include <string.h>
#include "mp3dec.h"
#include "debug.h"
#include "timing.h"
#include "ff.h"  // Include FatFs library
#include "main.h"
#include "waverecorder.h"
#define READBUF_SIZE (1024*16)
#define DEFAULT_AUDIO_IN_FREQ 48000
#define ALIGN32(x)   (((x) + 31) & ~31U)
#define USING_CACHE
extern uint8_t buffer[4700];
extern I2S_HandleTypeDef hi2s6;
static int FillReadBuffer(unsigned char *readBuf, unsigned char *readPtr, int bufSize, int bytesLeft, FIL *infile)
{
    UINT nRead;

    memmove(readBuf, readPtr, bytesLeft);
    f_read(infile, readBuf + bytesLeft, bufSize - bytesLeft, &nRead);

    if (nRead < (UINT)(bufSize - bytesLeft))
        memset(readBuf + bytesLeft + nRead, 0, bufSize - bytesLeft - nRead);

    return nRead;
}
int helix_processing(const char *file_name)
{
    int bytesLeft, nRead, err, offset, outOfData, eofReached;
    unsigned char readBuf[READBUF_SIZE], *readPtr;
    short outBuf[MAX_NCHAN * MAX_NGRAN * MAX_NSAMP];
    MP3FrameInfo mp3FrameInfo;
    FIL mp3File, pcmFile; // File handlers for FatFs
    HMP3Decoder hMP3Decoder;

    if (f_open(&mp3File, file_name, FA_READ) != FR_OK)
    {
        // Handle error
        return -1;
    }

    if (f_open(&pcmFile, "rec.wav", FA_WRITE | FA_CREATE_ALWAYS) != FR_OK)
    {
        // Handle error
        return -1;
    }


	#define WAV_HEADER_SIZE	sizeof(WAVE_FormatTypeDef)
	uint8_t wavHeader[WAV_HEADER_SIZE];

	// Initialize the WAV header
	if (WavProcess_EncInit(DEFAULT_AUDIO_IN_FREQ, wavHeader) != 0) {
		printf("Error initializing WAV header\n");
		return -1;
	}

	// Write the initialized header to the output file
	f_write(&pcmFile, wavHeader, WAV_HEADER_SIZE, NULL);

    if ((hMP3Decoder = MP3InitDecoder()) == 0)
        return -2;

    bytesLeft = 0;
    outOfData = 0;
    eofReached = 0;
    readPtr = readBuf;
    nRead = 0;

    do {
        if (bytesLeft < 2*MAINBUF_SIZE && !eofReached) {
            nRead = FillReadBuffer(readBuf, readPtr, READBUF_SIZE, bytesLeft, &mp3File);
            bytesLeft += nRead;
            readPtr = readBuf;
            if (nRead == 0)
                eofReached = 1;
        }

        offset = MP3FindSyncWord(readPtr, bytesLeft);
        if (offset < 0) {
            outOfData = 1;
            break;
        }
        readPtr += offset;
        bytesLeft -= offset;

        err = MP3Decode(hMP3Decoder, &readPtr, &bytesLeft, outBuf, 0);

        if (err) {
            switch (err) {
                case ERR_MP3_INDATA_UNDERFLOW:
                    outOfData = 1;
                    break;
                case ERR_MP3_MAINDATA_UNDERFLOW:
                    break;
                case ERR_MP3_FREE_BITRATE_SYNC:
                default:
                    outOfData = 1;
                    break;
            }
        } else {
            MP3GetLastFrameInfo(hMP3Decoder, &mp3FrameInfo);
#ifdef USING_CACHE
        // Clean D Cache Transmiss
		SCB_CleanDCache_by_Addr((uint32_t*)outBuf, ALIGN32((mp3FrameInfo.bitsPerSample / 8) * mp3FrameInfo.outputSamps));
		__DSB();
		asm volatile("" ::: "memory");
#endif
            f_write(&pcmFile, outBuf, (mp3FrameInfo.bitsPerSample / 8) * mp3FrameInfo.outputSamps, NULL);
        }
    } while (!outOfData);

    f_lseek(&pcmFile, 0x1c);
    f_write(&pcmFile, &mp3FrameInfo.samprate, 4 , NULL);
    uint32_t SizeOfFile = f_tell(&pcmFile) - 0x2c;
    f_lseek(&pcmFile, 0x28);
    f_write(&pcmFile, &SizeOfFile, 4 , NULL);
    MP3FreeDecoder(hMP3Decoder);

    f_close(&mp3File);
    f_close(&pcmFile);

    return 0;
}

