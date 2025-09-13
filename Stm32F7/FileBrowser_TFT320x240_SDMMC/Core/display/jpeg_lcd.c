#include "jpeg_lcd.h"
#include "main.h"

UINT Height_Of_Jpeg = 0;
#define ALIGN32(x)   (((x) + 31) & ~31U)
//Store the frame buffer
#ifdef STM32H723xx_H
extern uint16_t frame_buffer[240][320];
extern uint32_t video_blockSize;
#endif
size_t mem_input(JDEC *jd, uint8_t *buff, size_t nbyte) {
    UINT rb;
    uint8_t* dev = (uint8_t*) jd->device;

    if (buff)
    {
    	memcpy(buff,dev,nbyte);
    	jd->device += nbyte;
    	video_blockSize = video_blockSize - nbyte;
        return nbyte;
    }
    else
    {
    	if( (video_blockSize - nbyte) > 0){
    		jd->device += nbyte;
    		return nbyte;
    	}
    	else{
    		return 0;
    	}

    }
}

UINT STM32_in_func(JDEC* jd, BYTE* buff, UINT nd)
{
    UINT rb;
    FIL* dev = (FIL*) jd->device;

    if (buff)
    {
        if (f_read(dev, buff, nd, &rb) == FR_OK) {
#ifdef USING_CACHE
        	SCB_InvalidateDCache_by_Addr((uint32_t*)buff, ALIGN32(nd));
#endif
        }
        return rb;
    }
    else
    {
    	return (f_lseek(dev, f_tell(dev) + nd) == FR_OK) ? nd : 0;
    }
}

UINT STM32_out_func(
    JDEC* jd, void* bitmap, JRECT* rect)
{

    jd = jd;
    uint16_t w = rect->right - rect->left + 1;
    uint16_t h = rect->bottom - rect->top + 1;
    uint8_t* src = (uint8_t*) bitmap;
    int j = 0;

#ifdef SWAP_PIX_BYTEORDER
    for (int i = rect->top; i < rect->bottom + 1; i++)
    {
        memcpy(&frame_buffer[i][rect->left], src + j * 32, w * 2);
        j++;
    }
#else
    uint8_t lo = 0;
    uint8_t hi = 0;
    for (int i = rect->top; i < rect->bottom + 1; i++)
    {
        memcpy(&frame_buffer[i][rect->left], src + j * 32, w * 2);
        for(int k = 0; k < w; k++){
        	hi = (frame_buffer[i][rect->left + k] & 0xff);
        	lo = (frame_buffer[i][rect->left + k] >> 8);
        	frame_buffer[i][rect->left + k] =  (hi << 8) | lo;
        }
        j++;
    }
#endif

#ifndef REALSE_FULL_SCREEN
    LCD_DrawPixData(rect->left,rect->top,w, h,(uint16_t *)bitmap);
#endif

    return 0;
}
