#include "jpeg_lcd.h"
#include "main.h"

UINT Height_Of_Jpeg = 0;
uint32_t OffsetInBuf = 0;
BYTE Buff[8192] __attribute__((aligned(4))); // 8192  16384  32768   76800
extern int frame_size;
extern uint16_t frame_buffer[240][320];
uint32_t out_time = 0;
UINT STM32_in_func(JDEC* jd, BYTE* buff, UINT nd)
{
    UINT rb;
    FIL* dev = (FIL*) jd->device;

    if (buff)
    {
        f_read(dev, buff, nd, &rb);
        //printf("\nOffset: %x, nd: %d, rb: %d",f_tell(dev),nd,rb);
        return rb;
    }
    else
    {
        //uint8_t tmp = f_lseek(dev, f_tell(dev) + nd);
        //printf("\n  Else => tmp: %d, nd: %d",tmp,nd);
        //return (tmp == FR_OK) ? nd : 0;
    	return (f_lseek(dev, f_tell(dev) + nd) == FR_OK) ? nd : 0;
    }
}

uint32_t cnt = 0;
UINT STM32_in_func_avi(JDEC** jd, BYTE* buff, UINT nd)
{
    uint8_t* dev = (uint8_t*) jd[0]->device;
    cnt++;
    if (buff)
    {
        frame_size -= nd;
		if (frame_size < 0) {
			nd = -1 * frame_size;
		}
    	memcpy(buff,dev,nd);
    	jd[0]->device += nd;
        return nd;
    }
    else{
    	jd[0]->device += nd;
        return nd;
    }
}


UINT STM32_out_func(

    JDEC* jd, void* bitmap, JRECT* rect)
{
	uint32_t start_time = HAL_GetTick();
    jd = jd;
    uint16_t w = rect->right - rect->left + 1;
    uint16_t h = rect->bottom - rect->top + 1;
    uint8_t* src = (uint8_t*) bitmap;
    int j = 0;
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
    uint32_t end_time = HAL_GetTick();
    out_time += end_time - start_time;
    // Draw_PixData(rect->left,rect->top,w, h,(uint16_t *)bitmap);
    return 1;
}

uint32_t STM32_JPEG_DISPLAY(FIL* f_Jpeg, const char* filename)
{

    FRESULT Res_FatFs;   // FATFSϵͳ��������ֵ
    JDEC jd;             /* ������Ķ������Ϣ��¼�� */
    JRESULT Res_TjpgDec; // TjpgDecϵͳ��������ֵ
    BYTE scale;          // ͼ���������

    Res_FatFs = f_open(f_Jpeg, filename, FA_READ);

    if (Res_FatFs != FR_OK)
    {
        HAL_Delay(1);
        f_close(f_Jpeg);
        return Res_FatFs;
    }

    Res_TjpgDec = jd_prepare(&jd, STM32_in_func, Buff, sizeof(Buff), f_Jpeg);

    Height_Of_Jpeg = jd.height;

    if (Res_TjpgDec == JDR_OK)
    {

        for (scale = 0; scale < 3; scale++)
        {
            if ((jd.width >> scale) <= 320 && (jd.height >> scale) <= 240)
            {
                break;
            }
        }

        if (scale)
            scale--;

        Res_TjpgDec = jd_decomp(&jd, STM32_out_func, scale);
        Draw_PixData(0, 0, 320, 240, &frame_buffer[0][0]);
    }
    else
    {
        //		HAL_Delay(1);
        f_close(f_Jpeg);
        return Res_TjpgDec;
    }

    f_close(f_Jpeg);

    return 0;
}
