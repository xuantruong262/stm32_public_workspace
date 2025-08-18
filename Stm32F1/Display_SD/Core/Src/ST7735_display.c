#include "ST7735_display.h"


extern SPI_HandleTypeDef hspi2;

volatile int dma_tx_done_spi2 = 1;
volatile int dma_rx_done_spi2 = 0;

#if IWDGG
extern IWDG_HandleTypeDef hiwdg;
#endif

//This define for video
#define display_w 160
#define display_h 128
#define w_numchunk_in_frame 8
#define byte_per_pix 2
#define line_per_chunk display_h/w_numchunk_in_frame
#define total_pix_per_chunk  line_per_chunk * display_w

//This define for image
#define w_per_chunk 8




uint8_t X_Y_Coordinate = 0x60;

void ST7735_SendCommand(uint8_t cmd)
{
  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_RESET); // Command mode
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  HAL_SPI_Transmit(&hspi2, &cmd, 1,HAL_MAX_DELAY);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_SendData(uint8_t *data, uint16_t size)
{
  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET); // Data mode
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  HAL_SPI_Transmit(&hspi2, data, size,HAL_MAX_DELAY);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_Reset(void)
{
  HAL_GPIO_WritePin(TFT_RS_GPIO_Port, TFT_RS_Pin, GPIO_PIN_RESET);
  HAL_Delay(10);
  HAL_GPIO_WritePin(TFT_RS_GPIO_Port, TFT_RS_Pin, GPIO_PIN_SET);
  HAL_Delay(10);
}

void ST7735_Init(uint8_t Is160x128)
{
  ST7735_Reset();

  ST7735_SendCommand(0x01); // Software reset
  HAL_Delay(150);

  ST7735_SendCommand(0x11); // Sleep out
  HAL_Delay(150);

  ST7735_SendCommand(0x3A); // Interface Pixel Format
  uint8_t data = 0x05;      // 16-bit color
  ST7735_SendData(&data, 1);
  if (Is160x128 == 1)
  {
    ST7735_SendCommand(0x36);
    // uint8_t ctl = 0x20;
    uint8_t ctl = X_Y_Coordinate;
    ST7735_SendData(&ctl, 1);
  }
  ST7735_SendCommand(0x29); // Display ON
  HAL_Delay(10);
}

// Fill entire screen by 1 color
void ST7735_FillScreen(uint16_t color,uint8_t end_x,uint8_t end_y )
{
  uint8_t data[2] = {color >> 8,color & 0xFF };
  ST7735_SendCommand(0x2A);                // Column addr set
  uint8_t col[] = {0x00, 0x00, 0x00, end_x}; // x0 to x127
  ST7735_SendData(col, 4);

  ST7735_SendCommand(0x2B);                // Row addr set
  uint8_t row[] = {0x00, 0x00 , 0x00, end_y}; // y0 to y159
  ST7735_SendData(row, 4);

  ST7735_SendCommand(0x2C); // Memory write

  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  for (int i = 0; i < 128 * 160; i++)
  {
    HAL_SPI_Transmit(&hspi2, data, 2,HAL_MAX_DELAY);
  }
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_Draw_Simple_Pix(uint8_t pos_x, uint8_t pos_y, uint8_t width, uint8_t height, uint16_t color)
{
    uint8_t data[2]= {color >> 8, color & 0xFF};
    ST7735_SendCommand(0x2A);                             // Column addr set
    uint8_t col[] = {0x00, 0x0, 0x00, pos_x + width - 1}; // x0 to x127
    ST7735_SendData(col, 4);

    ST7735_SendCommand(0x2B);                                // Row addr set
    uint8_t row[] = {0x00, pos_y, 0x00, pos_y + height - 1}; // y0 to y159
    ST7735_SendData(row, 4);

    ST7735_SendCommand(0x2C); // Memory write

    HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);

    // With Little Endian
    for (int i = 0; i < width * height; i++)
    {
        HAL_SPI_Transmit(&hspi2, data, 2,HAL_MAX_DELAY);
    }
    HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_Display_BMPImage(uint8_t pos_x, uint8_t pos_y, uint8_t width, uint8_t height, uint8_t *data_frame, uint8_t bpp)
{
    ST7735_SendCommand(0x2A);                             // Column addr set
    uint8_t col[] = {0x00, 0x0, 0x00, pos_x + width - 1}; // x0 to x127
    ST7735_SendData(col, 4);

    ST7735_SendCommand(0x2B);                                // Row addr set
    uint8_t row[] = {0x00, pos_y, 0x00, pos_y + height - 1}; // y0 to y159
    ST7735_SendData(row, 4);

    ST7735_SendCommand(0x2C); // Memory write

    HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);

    // Convert to Big Endian

    if(bpp == 2){     // RGB565
        uint16_t *byte_fr565 = (uint16_t*)data_frame;
        for (uint32_t i = 0; i < width * height; i++)
        {
            byte_fr565[i] = (byte_fr565[i] >> 8) | (byte_fr565[i] << 8);
        }
        HAL_SPI_Transmit(&hspi2, byte_fr565, width * height * sizeof(uint16_t), HAL_MAX_DELAY);
    }
    else if(bpp == 3){     // RGB888
        uint8_t *byte_fr = (uint8_t*)data_frame;
        uint8_t R_565 = 0;
        uint8_t G_565 = 0;
        uint8_t B_565 = 0;
        uint16_t RGB_565 = 0;
        for(int i = 0; i < width * height; i++){
            B_565 = (data_frame[3*i + 0] >> 3) & 0x1F;
            G_565 = (data_frame[3*i + 1] >> 2) & 0x3F;
            R_565 = (data_frame[3*i + 2] >> 3) & 0x1F;
            RGB_565 = (R_565 << 11) | (G_565 << 5) | B_565;
            RGB_565 = (RGB_565 >> 8) | (RGB_565 << 8);
            HAL_SPI_Transmit(&hspi2, &RGB_565,sizeof(uint16_t), HAL_MAX_DELAY);
        }

    }
    HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}


void extract_BMP_Info(uint8_t *Frame_header_Buffer, bmp_info *bmp){
   memcpy(&bmp->bmp_size,Frame_header_Buffer + 2, 4);
   memcpy(&bmp->width,Frame_header_Buffer + 0x12, 4);
   memcpy(&bmp->height,Frame_header_Buffer + 0x16, 4);
   memcpy(&bmp->bpp,Frame_header_Buffer + 0x1c, 2);
   bmp->bpp = bmp->bpp / 8;
}

uint8_t Display_BMP_picture(const char *file_name)
{
    uint8_t header[36];
    bmp_info bmp;
    FIL file;
    UINT br;
    uint32_t Offset = 0;
    uint32_t SizeOfFrameBuff = 0;
    // if (Is160x128 == 1)
    // {
        ST7735_SendCommand(0x36);
        uint8_t ctl = 0x20;
        ST7735_SendData(&ctl, 1);
    // }
    // open file
    while (1)
    {
        if (f_open(&file, file_name, FA_READ) == FR_OK)
        {
#if IWDGG
            HAL_IWDG_Refresh(&hiwdg);
#endif
            break;
        }
    }
    // read header file
    while (1)
    {
        f_lseek(&file, 0x0);
        if (f_read(&file, header, sizeof(header), &br) == FR_OK)
        {
#if IWDGG
            HAL_IWDG_Refresh(&hiwdg);
#endif
            break;
        }
    }
    // extract BMP info
    extract_BMP_Info(header, &bmp);
    uint32_t total_pix = bmp.width * bmp.height;
    uint8_t pos_x = 0;
    uint8_t pos_y = 0;
    SizeOfFrameBuff = w_per_chunk * bmp.width * bmp.bpp;
    uint8_t Frame_buf[SizeOfFrameBuff];

    br = 0;
    int i = 0;
    if (bmp.bpp == 2)
    { // RGB565
        Offset = 0x42;
        // read data
        while (((total_pix * bmp.bpp ) - SizeOfFrameBuff*i) > 0)
        {
            f_lseek(&file, Offset);
            while (1)
            {
                if (f_read(&file, Frame_buf, SizeOfFrameBuff, &br) == FR_OK)
                {
#if IWDGG
                    HAL_IWDG_Refresh(&hiwdg);
#endif
                    break;
                }
            }
            ST7735_Display_BMPImage(pos_x, pos_y, bmp.width, w_per_chunk, Frame_buf, bmp.bpp);
            pos_y += w_per_chunk;
            i++;
            Offset = Offset + SizeOfFrameBuff;
        }
    }
    else if (bmp.bpp == 3)
    { // RGB888
        if(Frame_buf == NULL){
            return 0;
        }
        Offset = 0x36;
        while (((total_pix * bmp.bpp ) - SizeOfFrameBuff * i) > 0)
        {
            f_lseek(&file, Offset);
            while (1)
            {
                if (f_read(&file, Frame_buf, SizeOfFrameBuff, &br) == FR_OK)
                {
#if IWDGG
                    HAL_IWDG_Refresh(&hiwdg);
#endif
                    break;
                }
            }
            ST7735_Display_BMPImage(pos_x, pos_y, bmp.width, w_per_chunk, Frame_buf, bmp.bpp);
            pos_y += w_per_chunk;
            i++;
            Offset = Offset + SizeOfFrameBuff;
        }
    }
    else
    {
        ST7735_SendCommand(0x36);
        uint8_t ctl = 0x20;
        ST7735_SendData(&ctl, 1);
        return 0;
    }
    ST7735_SendCommand(0x36);
    ctl = 0x60;
    ST7735_SendData(&ctl, 1);
    return 1;
}

void ST7735_video_display(obj_status obj, uint16_t *buf)
{
  // Disable SD_Card_CS
  // HAL_GPIO_WritePin(SD_CS_GPIO_Port, SD_CS_Pin, GPIO_PIN_SET);
  ST7735_SendCommand(0x2A);                // Column addr set
  uint8_t col[] = {0x00, obj.pos_x, 0x00, obj.pos_x + obj.width-1}; // x0 to x127
  ST7735_SendData(col, 4);

  ST7735_SendCommand(0x2B);
  uint8_t row[] = {0x00, obj.pos_y , 0x00, obj.pos_y + obj.height-1 }; // y0 to y159
  ST7735_SendData(row, 4);


  ST7735_SendCommand(0x2C); // Memory write
  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);

  dma_tx_done_spi2 = 0;
  HAL_SPI_Transmit_DMA(&hspi2, buf, total_pix_per_chunk * byte_per_pix);
  // while (!dma_tx_done_spi2)
  //   ;
  // HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}


// Need open video file before call this function
uint8_t play_video(FIL *f, uint32_t *frame_num)
{
  UINT br;
  uint16_t FrameA[total_pix_per_chunk];
  uint16_t FrameB[total_pix_per_chunk];
  uint16_t Size_Per_Chunk = total_pix_per_chunk * byte_per_pix;
  uint32_t base_offset = *frame_num * w_numchunk_in_frame * Size_Per_Chunk;
  uint32_t offset = base_offset;
  obj_status object2 = {0, 0, display_w, line_per_chunk};
  int i = 0;
  while (1)
  {
    while (1)
    {
      f_lseek(f, offset);
      if (f_read(f, FrameA, Size_Per_Chunk - 1, &br) == FR_OK)
      {
#if IWDGG
        HAL_IWDG_Refresh(&hiwdg);
#endif
        break;
      }
    }
    // Check EOF
    if(br < (Size_Per_Chunk - 1)){
        return 0;
    }

    while (!dma_tx_done_spi2)
      ;
    ST7735_video_display(object2, FrameA);

    object2.pos_y += line_per_chunk;
    i++;
    offset = base_offset + i * Size_Per_Chunk;
    f_lseek(f, offset);
    while (1)
    {
      if (f_read(f, FrameB, Size_Per_Chunk - 1, &br) == FR_OK)
      {
#if IWDGG
        HAL_IWDG_Refresh(&hiwdg);
#endif
        break;
      }
    }
    // Check EOF
    if(br < (Size_Per_Chunk - 1)){
        return 0;
    }
    while (!dma_tx_done_spi2)
      ;
    ST7735_video_display(object2, FrameB);
    object2.pos_y += line_per_chunk;
    i++;
    offset = base_offset + i * Size_Per_Chunk;
    if (!(i % w_numchunk_in_frame))
    {
      break;
    }
  }
  *frame_num += 1;
  return 1;
}

void Allocate_video_buffer(uint16_t **FrA,uint16_t **FrB){
  *FrA = (uint16_t*)malloc(5120);
  *FrB = (uint16_t*)malloc(5120);
//   memset(*FrA,0,sizeof(uint16_t) * total_pix_per_chunk);
//   memset(*FrB,0,sizeof(uint16_t) * total_pix_per_chunk);
}
void Deallocate_video_buffer(uint16_t *FrA,uint16_t *FrB){
  free(FrA);
  free(FrB);
}
