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


typedef struct obj_status
{
  uint8_t pos_x;
  uint8_t pos_y;
  uint8_t width;
  uint8_t height;
} obj_status;

typedef struct bmp_info
{
  uint32_t bmp_size;
  uint32_t width;
  uint32_t height;
  uint16_t bpp; // byte per pixel
} bmp_info;



void ST7735_SendCommand(uint8_t cmd);

void ST7735_SendData(uint8_t *data, uint16_t size);

void ST7735_Reset(void);

void ST7735_Init(uint8_t Is160x128);

void ST7735_FillScreen(uint16_t color, uint8_t end_x,uint8_t end_y );

void ST7735_Draw_ChunkOfColor(uint8_t pos_x, uint8_t pos_y, uint8_t width, uint8_t height, uint16_t color);

void extract_BMP_Info(uint8_t *Frame_header_Buffer, bmp_info *bmp);

uint8_t Display_BMP_picture(const char * file_name);

void ST7735_video_display(obj_status obj, uint16_t *buf);

uint8_t play_video(FIL *f, uint32_t *frame_num);

void Allocate_video_buffer(uint16_t **FrA,uint16_t **FrB);

void Deallocate_video_buffer(uint16_t *FrA,uint16_t *FrB);
#endif // __SD_SPI_H__
