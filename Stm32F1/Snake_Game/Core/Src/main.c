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

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>  // srand, rand
#include <time.h>    // time
#include "snake_game.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */


/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define X_START_PIX_POS_VALID 1
#define Y_START_PIX_POS_VALID 1
#define X_END_PIX_POS_VALID 126
#define Y_END_PIX_POS_VALID 158

#define Is_up_active 0
#define Is_right_active  1
#define Is_down_active  2
#define Is_left_active  3
#define LEN(x) x*Size_per_block
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
SPI_HandleTypeDef hspi2;
DMA_HandleTypeDef hdma_spi2_rx;
DMA_HandleTypeDef hdma_spi2_tx;

/* USER CODE BEGIN PV */
volatile int dma_tx_done = 0;
volatile int dma_rx_done = 0;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_DMA_Init(void);
static void MX_SPI2_Init(void);
/* USER CODE BEGIN PFP */
int key = 1;
void HAL_SPI_TxCpltCallback(SPI_HandleTypeDef *hspi) {
	if (hspi == &hspi2) dma_tx_done = 1;
}

void HAL_SPI_TxRxCpltCallback(SPI_HandleTypeDef *hspi) {
	if (hspi == &hspi2) dma_rx_done = 1;
}

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
  UNUSED(GPIO_Pin);
  if (Button_Up_Pin == GPIO_Pin)
  {
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, 1);
    key = 0;
  }
  else if (Button_Right_Pin == GPIO_Pin)
  {
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, 1);
    key = 1;
  }
  else if (Button_Left_Pin == GPIO_Pin)
  {
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, 0);
    key = 3;
  }
  else if (Button_Down_Pin == GPIO_Pin)
  {
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, 0);
    key = 2;
  }

}
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */


void ST7735_SendCommand(uint8_t cmd)
{
  dma_tx_done = 0;
  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_RESET); // Command mode
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  HAL_SPI_Transmit_DMA(&hspi2, &cmd, 1);
  while (!dma_tx_done)
    ;
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_SendData(uint8_t *data, uint16_t size)
{
  dma_tx_done = 0;
  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET); // Data mode
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  HAL_SPI_Transmit_DMA(&hspi2, data, size);
  while (!dma_tx_done)
    ;
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_Reset(void)
{
  HAL_GPIO_WritePin(TFT_RS_GPIO_Port, TFT_RS_Pin, GPIO_PIN_RESET);
  HAL_Delay(10);
  HAL_GPIO_WritePin(TFT_RS_GPIO_Port, TFT_RS_Pin, GPIO_PIN_SET);
  HAL_Delay(10);
}

void ST7735_Init(void)
{
  ST7735_Reset();

  ST7735_SendCommand(0x01); // Software reset
  HAL_Delay(150);

  ST7735_SendCommand(0x11); // Sleep out
  HAL_Delay(150);

  ST7735_SendCommand(0x3A); // Interface Pixel Format
  uint8_t data = 0x05;      // 16-bit color
  ST7735_SendData(&data, 1);

  ST7735_SendCommand(0x29); // Display ON
  HAL_Delay(10);
}

// Fill entire screen by 1 color
void ST7735_FillScreen(uint16_t color)
{
  uint8_t data[2] = { color >> 8 , color & 0xFF};
  ST7735_SendCommand(0x2A);                // Column addr set
  uint8_t col[] = {0x00, 0x00, 0x00, 127}; // x0 to x127
  ST7735_SendData(col, 4);

  ST7735_SendCommand(0x2B);                // Row addr set
  uint8_t row[] = {0x00, 0x00, 0x00, 159}; // y0 to y159
  ST7735_SendData(row, 4);

  ST7735_SendCommand(0x2C); // Memory write

  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  dma_tx_done = 0;
  for (int i = 0; i < 128 * 160; i++)
  {
    HAL_SPI_Transmit_DMA(&hspi2, data, 2);
    while (!dma_tx_done)
      ;
  }
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void ST7735_Drawing(uint16_t color, uint8_t pos_x, uint8_t pos_y, uint8_t width, uint8_t height)
{
  uint8_t data[2] = { color >> 8 , color & 0xFF};
  ST7735_SendCommand(0x2A);                // Column addr set
  uint8_t col[] = {0x00, pos_x, 0x00, pos_x + width-1}; // x0 to x127
  ST7735_SendData(col, 4);

  ST7735_SendCommand(0x2B);                // Row addr set
  uint8_t row[] = {0x00, pos_y, 0x00, pos_y+height-1}; // y0 to y159
  ST7735_SendData(row, 4);

  ST7735_SendCommand(0x2C); // Memory write

  HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
  dma_tx_done = 0;
  uint16_t total_pix =  (width) * (height);
  for (int i = 0; i < (total_pix) ; i++)
  {
    HAL_SPI_Transmit_DMA(&hspi2, data, 2);
    while (!dma_tx_done)
      ;
  }
  HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}
int Random(uint8_t max, uint8_t min) {
    return (rand() % (max - min + 1)) + min;  
}



uint32_t cnt = 0;
uint8_t Cnt2Delay(uint16_t time){
  if( (cnt + time) > HAL_GetTick()){
    return 0;
  }
  else{
    cnt = HAL_GetTick();
  }
}

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */
  // branch = (branch_info*)malloc(total_branch * sizeof(branch_info));
  // branch[0].branch_lenght = 7;
  // branch[0].dir = emD_Right;

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
  MX_SPI2_Init();
  /* USER CODE BEGIN 2 */
  ST7735_Init();
  ST7735_FillScreen(0x0000); // Fill black
  Snake My_Snake;
  Cherry cherry;
  cherry.pos_x = Random(108,4); //128 - 2* OBJECTS_THICKNESS - Cherry_Size <=> 128 - 2* 4 - OBJECTS_THICKNESS*3
  cherry.pos_y = Random(140,4); //160 - 2* OBJECTS_THICKNESS - Cherry_Size <=> 160 - 2* 4 - OBJECTS_THICKNESS*3
  cherry.color  = 0xf800;
  Init(&My_Snake);
  My_Snake.Init_border(&My_Snake);
  ST7735_Drawing(My_Snake.boder.color, My_Snake.boder.pos_x,My_Snake.boder.pos_y,My_Snake.boder.width,My_Snake.boder.height);
  My_Snake.Init_valid_space(&My_Snake);
  ST7735_Drawing(My_Snake.valid_space.color, My_Snake.valid_space.pos_x,My_Snake.valid_space.pos_y,My_Snake.valid_space.width,My_Snake.valid_space.height);
  My_Snake.Snake_Init_Shape(&My_Snake);
  ST7735_Drawing(My_Snake.snake.color, My_Snake.snake.pos_x,My_Snake.snake.pos_y,My_Snake.snake.width,My_Snake.snake.height);
  Cherry_Control(&cherry);
  ST7735_Drawing(cherry.color, cherry.pos_x,cherry.pos_y,cherry.width,cherry.height);

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    if (Cnt2Delay(100))
    {
      Snake_Control(&My_Snake,&key);
      if(My_Snake.IsDeath == emHit_the_Wall){
        ST7735_Drawing(My_Snake.boder.color, My_Snake.boder.pos_x,My_Snake.boder.pos_y,My_Snake.boder.width,My_Snake.boder.height);
        ST7735_Drawing(My_Snake.valid_space.color, My_Snake.valid_space.pos_x,My_Snake.valid_space.pos_y,My_Snake.valid_space.width,My_Snake.valid_space.height);
        ST7735_Drawing(My_Snake.snake.color, My_Snake.snake.pos_x,My_Snake.snake.pos_y,My_Snake.snake.width,My_Snake.snake.height);
        cherry.pos_x = Random(108,4);
        cherry.pos_y = Random(140,4);
        Cherry_Control(&cherry);
        ST7735_Drawing(cherry.color, cherry.pos_x,cherry.pos_y,cherry.width,cherry.height);
      }
      else if(My_Snake.IsDeath == emEat){
        Get_Cherry(&cherry);
        ST7735_Drawing(cherry.color, cherry.pos_x,cherry.pos_y,cherry.width,cherry.height);
        ST7735_Drawing(My_Snake.snake_head.color, My_Snake.snake_head.pos_x,My_Snake.snake_head.pos_y,My_Snake.snake_head.width,My_Snake.snake_head.height);
        ST7735_Drawing(My_Snake.snake_tail.color, My_Snake.snake_tail.pos_x,My_Snake.snake_tail.pos_y,My_Snake.snake_tail.width,My_Snake.snake_tail.height);
        ST7735_Drawing(My_Snake.snake_rmv.color, My_Snake.snake_rmv.pos_x,My_Snake.snake_rmv.pos_y,My_Snake.snake_rmv.width,My_Snake.snake_rmv.height);      
        cherry.pos_x = Random(108,4);
        cherry.pos_y = Random(140,4);
        Cherry_Control(&cherry);
        ST7735_Drawing(cherry.color, cherry.pos_x,cherry.pos_y,cherry.width,cherry.height);

      }
      else{
        ST7735_Drawing(My_Snake.snake_head.color, My_Snake.snake_head.pos_x,My_Snake.snake_head.pos_y,My_Snake.snake_head.width,My_Snake.snake_head.height);
        ST7735_Drawing(My_Snake.snake_tail.color, My_Snake.snake_tail.pos_x,My_Snake.snake_tail.pos_y,My_Snake.snake_tail.width,My_Snake.snake_tail.height);
        ST7735_Drawing(My_Snake.snake_rmv.color, My_Snake.snake_rmv.pos_x,My_Snake.snake_rmv.pos_y,My_Snake.snake_rmv.width,My_Snake.snake_rmv.height);
      }
    }

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
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
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
  hspi2.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_16;
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
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, TFT_CS_Pin|TFT_RS_Pin|TFT_TransMode_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : PC13 */
  GPIO_InitStruct.Pin = GPIO_PIN_13;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pins : TFT_CS_Pin TFT_RS_Pin TFT_TransMode_Pin */
  GPIO_InitStruct.Pin = TFT_CS_Pin|TFT_RS_Pin|TFT_TransMode_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : Button_Up_Pin Button_Right_Pin Button_Left_Pin Button_Down_Pin */
  GPIO_InitStruct.Pin = Button_Up_Pin|Button_Right_Pin|Button_Left_Pin|Button_Down_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /* EXTI interrupt init*/
  HAL_NVIC_SetPriority(EXTI3_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI3_IRQn);

  HAL_NVIC_SetPriority(EXTI4_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI4_IRQn);

  HAL_NVIC_SetPriority(EXTI9_5_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI9_5_IRQn);

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
