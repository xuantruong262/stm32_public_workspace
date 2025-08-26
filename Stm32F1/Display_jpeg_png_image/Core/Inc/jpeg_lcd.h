/********************COPYRIGHT (C)  2013 Creator Lab of embedded systems *******************************
 * �ļ���  ��main.c
 * ����    ��
 * ʵ��ƽ̨��MINI������
 * ��汾  ��ST3.5.0
 * ���Է�����
********************************************************************************************************/
#include <stdio.h>
#include "stm32f1xx_hal.h"
#include "ff.h"
#include "tjpgd.h"
#include "ST7735_display.h"
//#include "stm_pin_magic.h"
//#include "delay.h"

typedef struct {
    FIL *fp;      /*ָ�������ļ���ָ�루JPEG�ļ���*/  // 
    BYTE *fbuf;    /*ָ�������������ָ��*/// 
    UINT wfbuf;    /*����������Ŀ��[pix] */// 
} IODEV;

//�й�TFTLCD�ĳߴ�Ķ���
#define TFTLCD_WIDTH     160
#define TFTLCD_HEIGHT    128

static int Mask_Left  = 0;                  //TFTLCD����ߵ���ʼ��
static int Mask_Right = TFTLCD_WIDTH - 1;   //TFTLCD���ұߵĽ�����
static int Mask_Top   = 0;                  //TFTLCD���Ϸ�����ʼ��
static int Mask_Bottom= TFTLCD_HEIGHT - 1;  //TFTLCD���·��Ľ�����


//��������
UINT      STM32_in_func ( JDEC* jd,BYTE* buff,UINT nd) ;
UINT      STM32_out_func (JDEC* jd,void* bitmap,JRECT* rect); 
void      STM32_Display( int left,int right,int top,int bottom,const uint16_t * RGB_Data_Pointer); 
uint32_t  STM32_JPEG_DISPLAY(FIL* f_Jpeg,const char* filename);


/********************  COPYRIGHT (C) 2013 Creator Lab of embedded systems *******************************/




