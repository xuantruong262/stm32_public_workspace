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
#include <stdio.h>
#include <string.h>
#include "main.h"
#include "fatfs.h"
#include "fonts.h"
// ST7735
// ILI9341
#define ILI9341
#define SDBrower_ptr_color 0xe682
// This define for type of TFT display
#ifdef ILI9341
#define display_w 320
#define display_h 240
#elif ST7735
#define display_w 160
#define display_h 128
#endif


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

#define IR_None 0x0
#define IR_CH_Minus 0x00FFA25D
#define IR_CH 0x00FF629D
#define IR_CH_Plus  0x00FFE21D
#define IR_Prev 0x00FF22DD
#define IR_Next 0x00FF02FD
#define IR_Play_Pause 0x00FFC23D
#define IR_Minus 0x00FFE01F
#define IR_Plus 0x00FFA857
#define IR_EQ 0x00FF906F
#define IR_0  0x00FF6897
#define IR_100_Plus 0x00FF9867
#define IR_200_Plus 0x00FFB04F
#define IR_1  0x00FF30CF
#define IR_2  0x00FF18E7
#define IR_3  0x00FF7A85
#define IR_4  0x00FF10EF
#define IR_5  0x00FF38C7
#define IR_6  0x00FF5AA5
#define IR_7  0x00FF42BD
#define IR_8  0x00FF4AB5
#define IR_9  0x00FF52AD

#define aLIST 0x5453494c
#define aMovi 0x69766f6d
#define aJunk 0x4b4e554a
// For RAW video display
#define w_numchunk_in_frame 4
#define byte_per_pix 2
#define line_per_chunk display_h / w_numchunk_in_frame
#define total_pix_per_chunk line_per_chunk* display_w
// For image display
#define w_per_chunk 32
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

typedef enum Browser_FileFormat
{
    emJPG,
    emBMP,
    emWAV,
    emRGB,
	emAVI,
    emDAT,
    emNone
} Browser_FileFormat;

typedef struct Browser_FileInfo
{
    char name[50];
    Browser_FileFormat format;
    uint32_t size;
} Browser_FileInfo;


// function prototypes
void SendCommand(uint8_t cmd);

void SendData(uint8_t *data, uint16_t size);

void Reset(void);

void LCD_Init(SPI_HandleTypeDef *hspi_ptr ,uint8_t *LCD_Playing_Ctrl, uint8_t IsHorizol);

void LCD_FillScreen(uint16_t color,uint16_t end_x,uint16_t end_y );

void LCD_AdjustGamma(void);

void Draw_ChunkOfColor(uint16_t pos_x, uint16_t pos_y, uint16_t width, uint16_t height, uint16_t color);

// Image display
uint8_t LCD_DisplayBMP(const char * file_name);
uint32_t LCD_DisplayJPEG(const char* filename);

// Text display
void LCD_WriteChar(uint16_t x, uint16_t y, char ch, FontDef font, uint16_t color, uint16_t bgcolor);
void LCD_WriteString(uint16_t x, uint16_t y, const char* str, FontDef font, uint16_t color, uint16_t bgcolor);
// AVI_MPJEG video
uint8_t LCD_PlayAVIVideo(FIL* f_AVI);
uint8_t LCD_PlayRawVideo(const char *file_name ,uint32_t *frame_num);

// SD file browser
void Browser_Init(Browser_FileInfo *FileList);
void Browser_MenuBackGround();
void Browser_FillCtrlPtr(uint8_t row, uint16_t color);
void Browser_WriteFile2Menu(uint8_t N_o, const char *str);
void Browser_Page_Update(uint8_t ptr_location);
void Browser_FileCtrl(uint32_t button_code, uint8_t Sel_N_o);

#endif // __SD_SPI_H__
