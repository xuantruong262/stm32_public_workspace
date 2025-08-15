/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "fatfs.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "sd_functions.h"
#include "string.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */
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
  uint32_t bpp;
} bmp_info;
/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define IWDGG 1
#define display_w 160
#define display_h 128
#define w_numchunk_in_frame 8
#define byte_per_pix 2

#define line_per_chunk display_h/w_numchunk_in_frame
#define total_pix_per_chunk  line_per_chunk * display_w

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
IWDG_HandleTypeDef hiwdg;

SPI_HandleTypeDef hspi1;
SPI_HandleTypeDef hspi2;
DMA_HandleTypeDef hdma_spi1_rx;
DMA_HandleTypeDef hdma_spi1_tx;
DMA_HandleTypeDef hdma_spi2_rx;
DMA_HandleTypeDef hdma_spi2_tx;

/* USER CODE BEGIN PV */
volatile int dma_tx_done_spi2 = 1;
volatile int dma_rx_done_spi2 = 0;

UINT br;
bmp_info header_info;

uint32_t cnt = 0;
uint8_t FPS = 0;
uint32_t my_time_TFT = 0;
uint32_t my_time_SD = 0;
uint16_t Frame_bufferA[total_pix_per_chunk];
uint16_t Frame_bufferB[total_pix_per_chunk];



/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_DMA_Init(void);
static void MX_IWDG_Init(void);
static void MX_SPI1_Init(void);
static void MX_SPI2_Init(void);
/* USER CODE BEGIN PFP */
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
    uint8_t ctl = 0x60;
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

void ST7735_Drawing(obj_status obj)
{
  uint8_t data[2];
  uint16_t tmp_buf[128];
  ST7735_SendCommand(0x2A);                // Column addr set
  uint8_t col[] = {0x00, 0x0, 0x00, obj.pos_x+obj.width-1}; // x0 to x127
  ST7735_SendData(col, 4);

  ST7735_SendCommand(0x2B);                // Row addr set
  uint8_t row[] = {0x00, obj.pos_y , 0x00, obj.pos_y+obj.height-1 }; // y0 to y159
  ST7735_SendData(row, 4);

  ST7735_SendCommand(0x2C); // Memory write

  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  //dma_tx_done_spi2 = 0;
  // for (int i = 0; i < 2048; i+=4) {
  //     Frame_buffer[i]   = (Frame_buffer[i] >> 8) | (Frame_buffer[i] << 8);
  //     Frame_buffer[i+1] = (Frame_buffer[i+1] >> 8) | (Frame_buffer[i+1] << 8);
  //     Frame_buffer[i+2] = (Frame_buffer[i+2] >> 8) | (Frame_buffer[i+2] << 8);
  //     Frame_buffer[i+3] = (Frame_buffer[i+3] >> 8) | (Frame_buffer[i+3] << 8);
  // }
    // HAL_SPI_Transmit_DMA(&hspi2, Frame_buffer, 2048 * 2);
    // while (!dma_tx_done_spi2)
    //   ;
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_video_display(obj_status obj, uint16_t *buf)
{
  // Disable SD_Card_CS
  // HAL_GPIO_WritePin(SD_CS_GPIO_Port, SD_CS_Pin, GPIO_PIN_SET);
  ST7735_SendCommand(0x2A);                // Column addr set
  uint8_t col[] = {0x00, obj.pos_x, 0x00, obj.pos_x + obj.width-1}; // x0 to x127
  ST7735_SendData(col, 4);

  ST7735_SendCommand(0x2B);
  uint8_t row[] = {0x00, obj.pos_y , 0x00, obj.pos_y+obj.height-1 }; // y0 to y159
  ST7735_SendData(row, 4);

  ST7735_SendCommand(0x36); 
  uint8_t ctl = 0x60;
  ST7735_SendData(&ctl, 1);

  ST7735_SendCommand(0x2C); // Memory write
  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);

  dma_tx_done_spi2 = 0;
  HAL_SPI_Transmit_DMA(&hspi2, buf, total_pix_per_chunk * byte_per_pix);
  // while (!dma_tx_done_spi2)
  //   ;
  // HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

  void processing(FIL * f, uint16_t *FrameA, uint16_t *FrameB, uint16_t byte_r, uint32_t *frame_num)
  {
    uint32_t base_offset = *frame_num * w_numchunk_in_frame * byte_r;
    uint32_t offset = base_offset;
    obj_status object2 = {0,0,display_w, line_per_chunk};
    int i = 0;
    while (1)
    {
      while (1)
      {
        f_lseek(f, offset);
        if (f_read(f, FrameA, byte_r - 1, &br) == FR_OK)
        {
#if IWDGG
          HAL_IWDG_Refresh(&hiwdg);
#endif
          break;
        }
      }
      while (!dma_tx_done_spi2)
        ;
      ST7735_video_display(object2, FrameA);

      object2.pos_y += line_per_chunk;
      i++;
      offset = base_offset + i * byte_r;
      f_lseek(f, offset);
      while (1)
      {
        if (f_read(f, FrameB, byte_r - 1, &br) == FR_OK)
        {
#if IWDGG
          HAL_IWDG_Refresh(&hiwdg);
#endif
          break;
        }
      }
      while (!dma_tx_done_spi2)
        ;
      ST7735_video_display(object2, FrameB);
      object2.pos_y += line_per_chunk;
      i++;
      offset = base_offset + i * byte_r;
      if (!(i % w_numchunk_in_frame))
      {
        break;
      }
    }
    *frame_num += 1;
  }

void extract_BMP_Info(uint8_t *Frame_header_Buffer, bmp_info *bmp){
   memcpy(&bmp->bmp_size,Frame_header_Buffer + 2, 4);
   memcpy(&bmp->width,Frame_header_Buffer + 0x12, 4);
   memcpy(&bmp->height,Frame_header_Buffer + 0x16, 4);
   memcpy(&bmp->bpp,Frame_header_Buffer + 0x1c, 2);
}

uint8_t Check_FPS(uint32_t time){
  if( ( cnt + time) > HAL_GetTick()){
     return 0;
  }
  else{
    cnt = HAL_GetTick();
    return 1;
  }
}

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */
  FIL f;

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_IWDG_Init();
  MX_SPI1_Init();
  MX_SPI2_Init();
  /* USER CODE BEGIN 2 */
 
  ST7735_Init(1);
  ST7735_FillScreen(0xf800,159,127);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
  int i = 0;
  int frame_num = 0;
  while (1)
  {
    if (sd_mount() == FR_OK)
    {
#if IWDGG
      HAL_IWDG_Refresh(&hiwdg);
#endif
      break;
    }
  }

  while (1)
  { 
    if (f_open(&f,"family_guy_ep1_rgb565_full_be_160x128.rgb",FA_READ) == FR_OK)
    {
#if IWDGG
      HAL_IWDG_Refresh(&hiwdg);
#endif
      break;
    }
  }
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    cnt = HAL_GetTick();
    processing(&f,Frame_bufferA,Frame_bufferB,total_pix_per_chunk*byte_per_pix,&frame_num);
    my_time_TFT = HAL_GetTick() - cnt;
    FPS = 1000 / my_time_TFT;
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_LSI|RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.LSIState = RCC_LSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief IWDG Initialization Function
  * @param None
  * @retval None
  */
static void MX_IWDG_Init(void)
{

  /* USER CODE BEGIN IWDG_Init 0 */

  /* USER CODE END IWDG_Init 0 */

  /* USER CODE BEGIN IWDG_Init 1 */

  /* USER CODE END IWDG_Init 1 */
  hiwdg.Instance = IWDG;
  hiwdg.Init.Prescaler = IWDG_PRESCALER_64;
  hiwdg.Init.Reload = 4095;
  if (HAL_IWDG_Init(&hiwdg) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN IWDG_Init 2 */

  /* USER CODE END IWDG_Init 2 */

}

/**
  * @brief SPI1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_SPI1_Init(void)
{

  /* USER CODE BEGIN SPI1_Init 0 */

  /* USER CODE END SPI1_Init 0 */

  /* USER CODE BEGIN SPI1_Init 1 */

  /* USER CODE END SPI1_Init 1 */
  /* SPI1 parameter configuration*/
  hspi1.Instance = SPI1;
  hspi1.Init.Mode = SPI_MODE_MASTER;
  hspi1.Init.Direction = SPI_DIRECTION_2LINES;
  hspi1.Init.DataSize = SPI_DATASIZE_8BIT;
  hspi1.Init.CLKPolarity = SPI_POLARITY_LOW;
  hspi1.Init.CLKPhase = SPI_PHASE_1EDGE;
  hspi1.Init.NSS = SPI_NSS_SOFT;
  hspi1.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_4;
  hspi1.Init.FirstBit = SPI_FIRSTBIT_MSB;
  hspi1.Init.TIMode = SPI_TIMODE_DISABLE;
  hspi1.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
  hspi1.Init.CRCPolynomial = 10;
  if (HAL_SPI_Init(&hspi1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN SPI1_Init 2 */

  /* USER CODE END SPI1_Init 2 */

}

/**
  * @brief SPI2 Initialization Function
  * @param None
  * @retval None
  */
static void MX_SPI2_Init(void)
{

  /* USER CODE BEGIN SPI2_Init 0 */

  /* USER CODE END SPI2_Init 0 */

  /* USER CODE BEGIN SPI2_Init 1 */

  /* USER CODE END SPI2_Init 1 */
  /* SPI2 parameter configuration*/
  hspi2.Instance = SPI2;
  hspi2.Init.Mode = SPI_MODE_MASTER;
  hspi2.Init.Direction = SPI_DIRECTION_2LINES;
  hspi2.Init.DataSize = SPI_DATASIZE_8BIT;
  hspi2.Init.CLKPolarity = SPI_POLARITY_LOW;
  hspi2.Init.CLKPhase = SPI_PHASE_1EDGE;
  hspi2.Init.NSS = SPI_NSS_SOFT;
  hspi2.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_2;
  hspi2.Init.FirstBit = SPI_FIRSTBIT_MSB;
  hspi2.Init.TIMode = SPI_TIMODE_DISABLE;
  hspi2.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
  hspi2.Init.CRCPolynomial = 10;
  if (HAL_SPI_Init(&hspi2) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN SPI2_Init 2 */

  /* USER CODE END SPI2_Init 2 */

}

/**
  * Enable DMA controller clock
  */
static void MX_DMA_Init(void)
{

  /* DMA controller clock enable */
  __HAL_RCC_DMA1_CLK_ENABLE();

  /* DMA interrupt init */
  /* DMA1_Channel2_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel2_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel2_IRQn);
  /* DMA1_Channel3_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel3_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel3_IRQn);
  /* DMA1_Channel4_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel4_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel4_IRQn);
  /* DMA1_Channel5_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel5_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel5_IRQn);

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(SD_CS_GPIO_Port, SD_CS_Pin, GPIO_PIN_SET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, TFT_CS_Pin|TFT_RS_Pin|TFT_TransMode_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : PC13 */
  GPIO_InitStruct.Pin = GPIO_PIN_13;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : SD_CS_Pin */
  GPIO_InitStruct.Pin = SD_CS_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(SD_CS_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : TFT_CS_Pin TFT_RS_Pin TFT_TransMode_Pin */
  GPIO_InitStruct.Pin = TFT_CS_Pin|TFT_RS_Pin|TFT_TransMode_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
