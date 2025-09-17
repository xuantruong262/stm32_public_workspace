/********************COPYRIGHT (C)  2013 Creator Lab of embedded systems *******************************
 * �ļ���  ��main.c
 * ����    ��
 * ʵ��ƽ̨��MINI������
 * ��汾  ��ST3.5.0
 * ���Է�����
********************************************************************************************************/
#include <stdio.h>
#include "stm32h7xx_hal.h"
#include "ff.h"
#include "tjpgd.h"
#include "display.h"


typedef struct {
    FIL *fp;      /*ָ�������ļ���ָ�루JPEG�ļ���*/  // 
    BYTE *fbuf;    /*ָ�������������ָ��*/// 
    UINT wfbuf;    /*����������Ŀ��[pix] */// 
} IODEV;

//�й�TFTLCD�ĳߴ�Ķ���
#define TFTLCD_WIDTH     320
#define TFTLCD_HEIGHT    240

typedef struct {
    const uint8_t *buf;
    uint32_t pos;
    uint32_t len;
} MEMSRC;

static int Mask_Left  = 0;                  //TFTLCD����ߵ���ʼ��
static int Mask_Right = TFTLCD_WIDTH - 1;   //TFTLCD���ұߵĽ�����
static int Mask_Top   = 0;                  //TFTLCD���Ϸ�����ʼ��
static int Mask_Bottom= TFTLCD_HEIGHT - 1;  //TFTLCD���·��Ľ�����


//��������
UINT      STM32_in_func ( JDEC* jd,BYTE* buff,UINT nd) ;
UINT      STM32_out_func (JDEC* jd,void* bitmap,JRECT* rect); 
void      STM32_Display( int left,int right,int top,int bottom,const uint16_t * RGB_Data_Pointer);
size_t    mem_input(JDEC *jd, uint8_t *buff, size_t nbyte);

/********************  COPYRIGHT (C) 2013 Creator Lab of embedded systems *******************************/




