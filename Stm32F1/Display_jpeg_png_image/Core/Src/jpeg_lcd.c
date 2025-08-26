#include "jpeg_lcd.h"
#include "main.h"

UINT Height_Of_Jpeg = 0;

BYTE Buff[8192] __attribute__ ((aligned(4))); //8192  16384  32768   76800


UINT STM32_in_func(
	JDEC* jd,
	BYTE* buff,
	UINT nd
){
	UINT rb;
	FIL * dev = (FIL *)jd->device;
	
	if (buff){
		f_read(dev, buff, nd, &rb);
		return rb;
	}else{
		return (f_lseek(dev, f_tell(dev) + nd) == FR_OK) ? nd : 0;
	}
}

UINT STM32_out_func(

	JDEC* jd,
	void* bitmap,
	JRECT* rect
){
	jd = jd;

	uint16_t w = rect->right - rect->left + 1;
	uint16_t h = rect->bottom - rect->top + 1;
	ST7735_Draw_PixData(rect->left,rect->top,w, h,(uint16_t *)bitmap);
	//drawRGBBitmap(rect->top,rect->left , (uint16_t *)bitmap, w, h);
	return 1;
}

uint32_t  STM32_JPEG_DISPLAY(FIL* f_Jpeg,const char* filename){
	
	FRESULT	Res_FatFs;		//FATFSϵͳ��������ֵ
	JDEC jd;				/* ������Ķ������Ϣ��¼�� */
	JRESULT	Res_TjpgDec;	// TjpgDecϵͳ��������ֵ
	BYTE scale;				//ͼ���������
	

	//Res_FatFs = f_open(f_Jpeg,filename,FA_READ);
	

//	if(Res_FatFs!= FR_OK){
//		HAL_Delay(1);
//		f_close(f_Jpeg);
//		return Res_FatFs;
//	}

	Res_TjpgDec = jd_prepare(&jd,STM32_in_func,Buff,sizeof(Buff),f_Jpeg);

	Height_Of_Jpeg=jd.height;
	
	if (Res_TjpgDec == JDR_OK) {
		

		for (scale = 0; scale < 3; scale++){
			if ((jd.width >> scale) <= 160 && (jd.height >> scale) <= 128){
				break;
			}
		}

		if(scale)
			scale--;
		

		Res_TjpgDec = jd_decomp(&jd, STM32_out_func, scale);

	}else{
//		HAL_Delay(1);
		f_close(f_Jpeg);
		return Res_TjpgDec;
	}
	

	f_close(f_Jpeg);
	
	return 0;
}

