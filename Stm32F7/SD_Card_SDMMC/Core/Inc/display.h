/******************************************************************************
 *  File        : sd_spi.h (SDSC/SDHC support)
 *  Author      : ControllersTech
 *  Website     : https://controllerstech.com
 *  Date        : June 26, 2025
 *
 *  Description :
 *    This file is part of a custom STM32/Embedded tutorial series.
 *    For documentation, updates, and more examples, visit the website above.
 *
 *  Note :
 *    This code is written and maintained by ControllersTech.
 *    You are free to use and modify it for learning and development.
 ******************************************************************************/

#ifndef __ST7735_DISPLAY_H__
#define __ST7735_DISPLAY_H__

#include <stdint.h>
#include <stdlib.h>
#include "main.h"
#include "fatfs.h"
#include "sd_functions.h"

#define ILI9341_NOP     0x00
#define ILI9341_SWRESET 0x01
#define ILI9341_RDDID   0x04
#define ILI9341_RDDST   0x09

#define ILI9341_SLPIN   0x10
#define ILI9341_SLPOUT  0x11
#define ILI9341_PTLON   0x12
#define ILI9341_NORON   0x13

#define ILI9341_RDMODE  0x0A
#define ILI9341_RDMADCTL  0x0B
#define ILI9341_RDPIXFMT  0x0C
#define ILI9341_RDIMGFMT  0x0A
#define ILI9341_RDSELFDIAG  0x0F

#define ILI9341_INVOFF  0x20
#define ILI9341_INVON   0x21
#define ILI9341_GAMMASET 0x26
#define ILI9341_DISPOFF 0x28
#define ILI9341_DISPON  0x29

#define ILI9341_CASET   0x2A
#define ILI9341_PASET   0x2B
#define ILI9341_RAMWR   0x2C
#define ILI9341_RAMRD   0x2E

#define ILI9341_PTLAR   0x30
#define ILI9341_VSCRDEF 0x33
#define ILI9341_MADCTL  0x36
#define ILI9341_VSCRSADD 0x37
#define ILI9341_PIXFMT  0x3A

#define ILI9341_WRDISBV  0x51
#define ILI9341_RDDISBV  0x52
#define ILI9341_WRCTRLD  0x53

#define ILI9341_FRMCTR1 0xB1
#define ILI9341_FRMCTR2 0xB2
#define ILI9341_FRMCTR3 0xB3
#define ILI9341_INVCTR  0xB4
#define ILI9341_DFUNCTR 0xB6

#define ILI9341_PWCTR1  0xC0
#define ILI9341_PWCTR2  0xC1
#define ILI9341_PWCTR3  0xC2
#define ILI9341_PWCTR4  0xC3
#define ILI9341_PWCTR5  0xC4
#define ILI9341_VMCTR1  0xC5
#define ILI9341_VMCTR2  0xC7

#define ILI9341_RDID4   0xD3
#define ILI9341_RDINDEX 0xD9
#define ILI9341_RDID1   0xDA
#define ILI9341_RDID2   0xDB
#define ILI9341_RDID3   0xDC
#define ILI9341_RDIDX   0xDD // TBC

#define ILI9341_GMCTRP1 0xE0
#define ILI9341_GMCTRN1 0xE1

#define ILI9341_MADCTL_MY  0x80
#define ILI9341_MADCTL_MX  0x40
#define ILI9341_MADCTL_MV  0x20
#define ILI9341_MADCTL_ML  0x10
#define ILI9341_MADCTL_RGB 0x00
#define ILI9341_MADCTL_BGR 0x08
#define ILI9341_MADCTL_MH  0x04

#define TFT_MADCTL  0x36
#define TFT_MAD_MY  0x80
#define TFT_MAD_MX  0x40
#define TFT_MAD_MV  0x20
#define TFT_MAD_ML  0x10
#define TFT_MAD_BGR 0x08
#define TFT_MAD_MH  0x04
#define TFT_MAD_RGB 0x00

#ifdef TFT_RGB_ORDER
  #if (TFT_RGB_ORDER == 1)
    #define TFT_MAD_COLOR_ORDER TFT_MAD_RGB
  #else
    #define TFT_MAD_COLOR_ORDER TFT_MAD_BGR
  #endif
#else
  #define TFT_MAD_COLOR_ORDER TFT_MAD_BGR
#endif
typedef struct obj_status
{
  uint32_t pos_x;
  uint32_t pos_y;
  uint32_t width;
  uint32_t height;
} obj_status;

typedef struct bmp_info
{
  uint32_t bmp_size;
  uint32_t width;
  uint32_t height;
  uint16_t bpp; // byte per pixel
} bmp_info;



void SendCommand(uint8_t cmd);

void SendData(uint8_t *data, uint16_t size);

void Reset(void);

void LCD_Init(uint8_t Is160x128);

void FillScreen(uint16_t color,uint16_t end_x,uint16_t end_y );

void TFT_AdjustGamma(void);

void Draw_ChunkOfColor(uint8_t pos_x, uint8_t pos_y, uint8_t width, uint8_t height, uint16_t color);

void extract_BMP_Info(uint8_t *Frame_header_Buffer, bmp_info *bmp);

uint8_t Display_BMP_picture(const char * file_name);

void video_display(obj_status obj, uint16_t *buf);

uint8_t play_video(FIL *f, uint32_t *frame_num);

void Allocate_video_buffer(uint16_t **FrA,uint16_t **FrB);

void Deallocate_video_buffer(uint16_t *FrA,uint16_t *FrB);

#endif // __SD_SPI_H__
