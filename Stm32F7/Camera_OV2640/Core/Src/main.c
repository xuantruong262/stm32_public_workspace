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
#include "display.h"
//#include "jpeg_lcd.h"
#include "sdio_benchmark.h"
#include "sdio_functions.h"
#include "wav_player.h"
#include "itr.h"
#include "ov2640.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

DCMI_HandleTypeDef hdcmi;
DMA_HandleTypeDef hdma_dcmi;

I2C_HandleTypeDef hi2c4;

I2S_HandleTypeDef hi2s6;
DMA_HandleTypeDef hdma_spi6_tx;

SD_HandleTypeDef hsd1;

SPI_HandleTypeDef hspi2;
DMA_HandleTypeDef hdma_spi2_tx;

TIM_HandleTypeDef htim4;

UART_HandleTypeDef huart1;
DMA_HandleTypeDef hdma_usart1_rx;

/* USER CODE BEGIN PV */
//For File browser and UART
uint8_t firmware_data[1024];
volatile uint8_t FileSelection = 0;
SDFile_Info FileListTree;
SDFile_Info *Current_Page;
//For image display
UINT br;
uint8_t image_id = 0;
volatile uint8_t IsPlayingContent = 0;
char path[256];
char SDFullName[256];
//For IR Remote control
uint32_t tempCode;
uint8_t bitIndex;
uint8_t cmd;
uint8_t cmdli;
uint32_t code;

extern volatile uint16_t FrameBuff[240][320];
//extern uint16_t FrameBuffB[240][320];
extern uint8_t Jpeg_frame[32768];
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
void PeriphCommonClock_Config(void);
static void MPU_Config(void);
static void MX_GPIO_Init(void);
static void MX_DMA_Init(void);
static void MX_BDMA_Init(void);
static void MX_SPI2_Init(void);
static void MX_USART1_UART_Init(void);
static void MX_I2S6_Init(void);
static void MX_TIM4_Init(void);
static void MX_SDMMC1_SD_Init(void);
static void MX_DCMI_Init(void);
static void MX_I2C4_Init(void);
/* USER CODE BEGIN PFP */
static void IR_Control(uint32_t Ir_code);
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

int _write(int fd, unsigned char *buf, int len) {
	if (fd == 1 || fd == 2) {                              // stdout or stderr ?
		HAL_UART_Transmit(&huart1, buf, len, 999); // Print to the UART
	}
	return len;
}

// GPIO EXTI callbacks
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
	UNUSED(GPIO_Pin);
	if (GPIO_Pin == IR_Remote_Pin) {
		if (__HAL_TIM_GET_COUNTER(&htim4) > 8000) {
			tempCode = 0;
			bitIndex = 0;
		} else if (__HAL_TIM_GET_COUNTER(&htim4) > 1700) {
			tempCode |= (1UL << (31 - bitIndex)); // write 1
			bitIndex++;
		} else if (__HAL_TIM_GET_COUNTER(&htim4) > 1000) {
			tempCode &= ~(1UL << (31 - bitIndex)); // write 0
			bitIndex++;
		}
		if (bitIndex == 32) {
			cmdli = ~tempCode;   // Logical inverted last 8 bits
			cmd = tempCode >> 8; // Second last 8 bits
			if (cmdli == cmd)    // Check for errors
					{
				code = tempCode; // If no bit errors
				// Do your main work HERE
				IR_Control(code);
			}
			bitIndex = 0;
		}
		__HAL_TIM_SET_COUNTER(&htim4, 0);
	}
}
// UART callbacks
void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size) {
	memset(firmware_data, 0, 1024);
	HAL_UARTEx_ReceiveToIdle_IT(&huart1, firmware_data, 1024);
}
volatile uint8_t done_flag = 0 ;
uint32_t line_cnt = 0;
void HAL_DCMI_VsyncEventCallback(DCMI_HandleTypeDef *hdcmi)
{
    /* Disable DCMI Camera interface */
	printf("Frame captured in vsync!\n");
	done_flag = 1;
	//HAL_DCMI_Suspend(&hdcmi);
	//LCD_DrawPixData(0, 0, 320, 240, FrameBuff);
	//HAL_DCMI_Resume(&hdcmi);
//    HAL_DCMI_Stop(&hdcmi);
    //LCD_DrawPixData(0, 0, 320, 240, FrameBuff);
    //HAL_DCMI_Start_DMA(&hdcmi, DCMI_MODE_SNAPSHOT, FrameBuff, 320*(240)/2);
}
void HAL_DCMI_FrameEventCallback(DCMI_HandleTypeDef *hdcmi) {
    printf("Frame captured!\n");

//    HAL_DCMI_Stop(&hdcmi);
//    memcpy(FrameBuff,FrameBuffB,sizeof(FrameBuffB));
   // LCD_DrawPixData(0, 0, 320, 240, FrameBuff);


    //HAL_DCMI_Start_DMA(&hdcmi, DCMI_MODE_CONTINUOUS, FrameBuff, 320*(240)/2);
    line_cnt = 0;
}
void HAL_DCMI_LineEventCallback(DCMI_HandleTypeDef *hdcmi){
	line_cnt++;
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */
	FIL video_f;

  /* USER CODE END 1 */

  /* MPU Configuration--------------------------------------------------------*/
  MPU_Config();

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* Configure the peripherals common clocks */
  PeriphCommonClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_BDMA_Init();
  MX_FATFS_Init();
  MX_SPI2_Init();
  MX_USART1_UART_Init();
  MX_I2S6_Init();
  MX_TIM4_Init();
  MX_SDMMC1_SD_Init();
  MX_DCMI_Init();
  MX_I2C4_Init();
  /* USER CODE BEGIN 2 */
	// System peripheral
	for(int i = 0;i < 240;i++){
		memset(FrameBuff[i],0,320*2);
	}
//	HAL_TIM_Base_Start(&htim4);
//	__HAL_TIM_SET_COUNTER(&htim4, 0);
//	HAL_UARTEx_ReceiveToIdle_IT(&huart1, firmware_data, 1024);
	// User playground
	// For display
    uint16_t* p_lcdData = FrameBuff;


    HAL_Delay(3000);


	LCD_Init(&hspi2, &IsPlayingContent, 1);
	LCD_AdjustGamma();
	LCD_FillScreen(0x0000, 320, 240);
	Itr_InitSPICBFunc(LCD_SPI_TxCpltCb, LCD_SPI_TxRxCpltCb);

	HAL_StatusTypeDef sta;

//	HAL_DCMI_Start_DMA(&hdcmi, DCMI_MODE_CONTINUOUS, FrameBuff, 320*(240-12)/2);

	// Camera OV2640
    ov2640_Init(0x60, CAMERA_Monitor);
    HAL_DCMI_Start_DMA(&hdcmi, DCMI_MODE_SNAPSHOT, (uint32_t)FrameBuff, 320*240/2);
//	HAL_Delay(3000);

//	CAMERA_IO_Write(0x60, 0xFF, 0x01);
//	CAMERA_IO_Write(0x60, 0x15, 0x00); // Đảm bảo PCLK chạy liên tục

//	LCD_DrawPixData(0, 0, 320, 240, p_lcdData);
#define IDLEx
	// For SD card
//	while (1) {
//		if (sdio_mount() == FR_OK) {
//			break;
//		}
//	}
//	HAL_Delay(2000);
//	IsPlayingContent = 0;
//	sdio_list_files(&FileListTree);
	//print_directory(FileListTree.Directory_Ptr, 0, FileListTree.childCount);
//	Itr_InitI2SCBFunc(Audio_I2S_TxHalfCb, Audio_I2S_TxCpltCb);
//	LCD_DisplayBMP("0:/image/image2_rgb888_320x240.bmp");

#ifndef IDLEx
	Itr_InitI2SCBFunc(Audio_I2S_TxHalfCb, Audio_I2S_TxCpltCb);
	Itr_InitSPICBFunc(LCD_SPI_TxCpltCb, LCD_SPI_TxRxCpltCb);
//	 For File browser
	/*Point to root page*/

	memset(path,0,256);
	memset(SDFullName,0,256);
	strcat(path,"0:/");

	Current_Page = FileListTree.Directory_Ptr;
	Browser_Init(&Current_Page);

#endif
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
	while (1) {
		if(done_flag == 1){
			//HAL_Delay(1);
			HAL_DCMI_Stop(&hdcmi);
			LCD_DrawPixData(0, 0, 320, 240, FrameBuff);
			HAL_DCMI_Start_DMA(&hdcmi, DCMI_MODE_SNAPSHOT, FrameBuff, 320*240/2);
			done_flag = 0;
		}

		//LCD_DrawPixData(0, 0, 320, 240, FrameBuff);
//		  HAL_GPIO_WritePin(RST_CAM_GPIO_Port, RST_CAM_Pin, GPIO_PIN_RESET);  //hardware reset
//		  HAL_Delay(1000);
//		  HAL_GPIO_WritePin(RST_CAM_GPIO_Port, RST_CAM_Pin, GPIO_PIN_SET);
//		HAL_Delay(50);
//		LCD_DrawPixData(0, 0, 320, 240, FrameBuff);
//		for(int i = 0;i < 240;i++){
//			memset(FrameBuff[i],0,320*2);
//		}
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

  /** Supply configuration update enable
  */
  HAL_PWREx_ConfigSupply(PWR_LDO_SUPPLY);

  /** Configure the main internal regulator output voltage
  */
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE0);

  while(!__HAL_PWR_GET_FLAG(PWR_FLAG_VOSRDY)) {}

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_DIV1;
  RCC_OscInitStruct.HSICalibrationValue = 64;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 17;
  RCC_OscInitStruct.PLL.PLLP = 1;
  RCC_OscInitStruct.PLL.PLLQ = 2;
  RCC_OscInitStruct.PLL.PLLR = 2;
  RCC_OscInitStruct.PLL.PLLRGE = RCC_PLL1VCIRANGE_3;
  RCC_OscInitStruct.PLL.PLLVCOSEL = RCC_PLL1VCOWIDE;
  RCC_OscInitStruct.PLL.PLLFRACN = 1536;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2
                              |RCC_CLOCKTYPE_D3PCLK1|RCC_CLOCKTYPE_D1PCLK1;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.SYSCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB3CLKDivider = RCC_APB3_DIV2;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_APB1_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_APB2_DIV2;
  RCC_ClkInitStruct.APB4CLKDivider = RCC_APB4_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief Peripherals Common Clock Configuration
  * @retval None
  */
void PeriphCommonClock_Config(void)
{
  RCC_PeriphCLKInitTypeDef PeriphClkInitStruct = {0};

  /** Initializes the peripherals clock
  */
  PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_CKPER;
  PeriphClkInitStruct.CkperClockSelection = RCC_CLKPSOURCE_HSI;
  if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief DCMI Initialization Function
  * @param None
  * @retval None
  */
static void MX_DCMI_Init(void)
{

  /* USER CODE BEGIN DCMI_Init 0 */

  /* USER CODE END DCMI_Init 0 */

  /* USER CODE BEGIN DCMI_Init 1 */

  /* USER CODE END DCMI_Init 1 */
  hdcmi.Instance = DCMI;
  hdcmi.Init.SynchroMode = DCMI_SYNCHRO_HARDWARE;
  hdcmi.Init.PCKPolarity = DCMI_PCKPOLARITY_RISING;
  hdcmi.Init.VSPolarity = DCMI_VSPOLARITY_LOW;
  hdcmi.Init.HSPolarity = DCMI_HSPOLARITY_LOW;
  hdcmi.Init.CaptureRate = DCMI_CR_ALL_FRAME;
  hdcmi.Init.ExtendedDataMode = DCMI_EXTEND_DATA_8B;
  hdcmi.Init.JPEGMode = DCMI_JPEG_DISABLE;
  hdcmi.Init.ByteSelectMode = DCMI_BSM_ALL;
  hdcmi.Init.ByteSelectStart = DCMI_OEBS_ODD;
  hdcmi.Init.LineSelectMode = DCMI_LSM_ALL;
  hdcmi.Init.LineSelectStart = DCMI_OELS_ODD;
  if (HAL_DCMI_Init(&hdcmi) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN DCMI_Init 2 */

  /* USER CODE END DCMI_Init 2 */

}

/**
  * @brief I2C4 Initialization Function
  * @param None
  * @retval None
  */
static void MX_I2C4_Init(void)
{

  /* USER CODE BEGIN I2C4_Init 0 */

  /* USER CODE END I2C4_Init 0 */

  /* USER CODE BEGIN I2C4_Init 1 */

  /* USER CODE END I2C4_Init 1 */
  hi2c4.Instance = I2C4;
  hi2c4.Init.Timing = 0x20B0C4FE;
  hi2c4.Init.OwnAddress1 = 0;
  hi2c4.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
  hi2c4.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
  hi2c4.Init.OwnAddress2 = 0;
  hi2c4.Init.OwnAddress2Masks = I2C_OA2_NOMASK;
  hi2c4.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
  hi2c4.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
  if (HAL_I2C_Init(&hi2c4) != HAL_OK)
  {
    Error_Handler();
  }

  /** Configure Analogue filter
  */
  if (HAL_I2CEx_ConfigAnalogFilter(&hi2c4, I2C_ANALOGFILTER_ENABLE) != HAL_OK)
  {
    Error_Handler();
  }

  /** Configure Digital filter
  */
  if (HAL_I2CEx_ConfigDigitalFilter(&hi2c4, 0) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN I2C4_Init 2 */

  /* USER CODE END I2C4_Init 2 */

}

/**
  * @brief I2S6 Initialization Function
  * @param None
  * @retval None
  */
static void MX_I2S6_Init(void)
{

  /* USER CODE BEGIN I2S6_Init 0 */

  /* USER CODE END I2S6_Init 0 */

  /* USER CODE BEGIN I2S6_Init 1 */

  /* USER CODE END I2S6_Init 1 */
  hi2s6.Instance = SPI6;
  hi2s6.Init.Mode = I2S_MODE_MASTER_FULLDUPLEX;
  hi2s6.Init.Standard = I2S_STANDARD_PHILIPS;
  hi2s6.Init.DataFormat = I2S_DATAFORMAT_16B;
  hi2s6.Init.MCLKOutput = I2S_MCLKOUTPUT_ENABLE;
  hi2s6.Init.AudioFreq = I2S_AUDIOFREQ_16K;
  hi2s6.Init.CPOL = I2S_CPOL_LOW;
  hi2s6.Init.FirstBit = I2S_FIRSTBIT_MSB;
  hi2s6.Init.WSInversion = I2S_WS_INVERSION_DISABLE;
  hi2s6.Init.Data24BitAlignment = I2S_DATA_24BIT_ALIGNMENT_RIGHT;
  hi2s6.Init.MasterKeepIOState = I2S_MASTER_KEEP_IO_STATE_DISABLE;
  if (HAL_I2S_Init(&hi2s6) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN I2S6_Init 2 */

  /* USER CODE END I2S6_Init 2 */

}

/**
  * @brief SDMMC1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_SDMMC1_SD_Init(void)
{

  /* USER CODE BEGIN SDMMC1_Init 0 */

  /* USER CODE END SDMMC1_Init 0 */

  /* USER CODE BEGIN SDMMC1_Init 1 */

  /* USER CODE END SDMMC1_Init 1 */
  hsd1.Instance = SDMMC1;
  hsd1.Init.ClockEdge = SDMMC_CLOCK_EDGE_RISING;
  hsd1.Init.ClockPowerSave = SDMMC_CLOCK_POWER_SAVE_DISABLE;
  hsd1.Init.BusWide = SDMMC_BUS_WIDE_4B;
  hsd1.Init.HardwareFlowControl = SDMMC_HARDWARE_FLOW_CONTROL_ENABLE;
  hsd1.Init.ClockDiv = 2;
  if (HAL_SD_Init(&hsd1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN SDMMC1_Init 2 */

  /* USER CODE END SDMMC1_Init 2 */

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
  hspi2.Init.CRCPolynomial = 0x0;
  hspi2.Init.NSSPMode = SPI_NSS_PULSE_DISABLE;
  hspi2.Init.NSSPolarity = SPI_NSS_POLARITY_LOW;
  hspi2.Init.FifoThreshold = SPI_FIFO_THRESHOLD_01DATA;
  hspi2.Init.TxCRCInitializationPattern = SPI_CRC_INITIALIZATION_ALL_ZERO_PATTERN;
  hspi2.Init.RxCRCInitializationPattern = SPI_CRC_INITIALIZATION_ALL_ZERO_PATTERN;
  hspi2.Init.MasterSSIdleness = SPI_MASTER_SS_IDLENESS_00CYCLE;
  hspi2.Init.MasterInterDataIdleness = SPI_MASTER_INTERDATA_IDLENESS_00CYCLE;
  hspi2.Init.MasterReceiverAutoSusp = SPI_MASTER_RX_AUTOSUSP_DISABLE;
  hspi2.Init.MasterKeepIOState = SPI_MASTER_KEEP_IO_STATE_DISABLE;
  hspi2.Init.IOSwap = SPI_IO_SWAP_DISABLE;
  if (HAL_SPI_Init(&hspi2) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN SPI2_Init 2 */

  /* USER CODE END SPI2_Init 2 */

}

/**
  * @brief TIM4 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM4_Init(void)
{

  /* USER CODE BEGIN TIM4_Init 0 */

  /* USER CODE END TIM4_Init 0 */

  TIM_ClockConfigTypeDef sClockSourceConfig = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};

  /* USER CODE BEGIN TIM4_Init 1 */

  /* USER CODE END TIM4_Init 1 */
  htim4.Instance = TIM4;
  htim4.Init.Prescaler = 216;
  htim4.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim4.Init.Period = 65535;
  htim4.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  htim4.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  if (HAL_TIM_Base_Init(&htim4) != HAL_OK)
  {
    Error_Handler();
  }
  sClockSourceConfig.ClockSource = TIM_CLOCKSOURCE_INTERNAL;
  if (HAL_TIM_ConfigClockSource(&htim4, &sClockSourceConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim4, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM4_Init 2 */

  /* USER CODE END TIM4_Init 2 */

}

/**
  * @brief USART1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART1_UART_Init(void)
{

  /* USER CODE BEGIN USART1_Init 0 */

  /* USER CODE END USART1_Init 0 */

  /* USER CODE BEGIN USART1_Init 1 */

  /* USER CODE END USART1_Init 1 */
  huart1.Instance = USART1;
  huart1.Init.BaudRate = 9600;
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  huart1.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  huart1.Init.ClockPrescaler = UART_PRESCALER_DIV1;
  huart1.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
  if (HAL_UART_Init(&huart1) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetTxFifoThreshold(&huart1, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_SetRxFifoThreshold(&huart1, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_UARTEx_DisableFifoMode(&huart1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART1_Init 2 */

  /* USER CODE END USART1_Init 2 */

}

/**
  * Enable DMA controller clock
  */
static void MX_BDMA_Init(void)
{

  /* DMA controller clock enable */
  __HAL_RCC_BDMA_CLK_ENABLE();

  /* DMA interrupt init */
  /* BDMA_Channel0_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(BDMA_Channel0_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(BDMA_Channel0_IRQn);

}

/**
  * Enable DMA controller clock
  */
static void MX_DMA_Init(void)
{

  /* DMA controller clock enable */
  __HAL_RCC_DMA1_CLK_ENABLE();

  /* DMA interrupt init */
  /* DMA1_Stream0_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Stream0_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Stream0_IRQn);
  /* DMA1_Stream1_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Stream1_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Stream1_IRQn);
  /* DMA1_Stream3_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Stream3_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Stream3_IRQn);

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
  __HAL_RCC_GPIOE_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOF_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOG_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(CAMERAPWDN_GPIO_Port, CAMERAPWDN_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOE, TFT_TransMode_Pin|TFT_RS_Pin|TFT_CS_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(RST_CAM_GPIO_Port, RST_CAM_Pin, GPIO_PIN_SET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(Debug_Led_GPIO_Port, Debug_Led_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : CAMERAPWDN_Pin */
  GPIO_InitStruct.Pin = CAMERAPWDN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(CAMERAPWDN_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : TFT_TransMode_Pin TFT_RS_Pin TFT_CS_Pin */
  GPIO_InitStruct.Pin = TFT_TransMode_Pin|TFT_RS_Pin|TFT_CS_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /*Configure GPIO pin : RST_CAM_Pin */
  GPIO_InitStruct.Pin = RST_CAM_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(RST_CAM_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : IR_Remote_Pin */
  GPIO_InitStruct.Pin = IR_Remote_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(IR_Remote_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : Debug_Led_Pin */
  GPIO_InitStruct.Pin = Debug_Led_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(Debug_Led_GPIO_Port, &GPIO_InitStruct);

  /* EXTI interrupt init*/
  HAL_NVIC_SetPriority(IR_Remote_EXTI_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(IR_Remote_EXTI_IRQn);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */
void IR_Control(uint32_t Ir_code) {

	switch (Ir_code) {
	case IR_CH_Minus:
		break;
	case IR_CH:
		break;
	case IR_CH_Plus:
		break;
	case IR_Prev:
		break;
	case IR_Next:
		break;
	case IR_Play_Pause: //Enter
		Browser_FileCtrl(IR_Play_Pause, FileSelection);
		IsPlayingContent = 1;
		break;
	case IR_Plus:
		FileSelection++;
		Browser_FileCtrl(IR_Plus, FileSelection);
		break;
	case IR_Minus:
		if (FileSelection > 0) {
			FileSelection--;
			Browser_FileCtrl(IR_Minus, FileSelection);
		}
		break;
	case IR_EQ: //Back
		if (IsPlayingContent == 0) {
			Back2PrevFolder(&Current_Page, &FileListTree, path);
		}
		printf("Back: %s\n", Current_Page->name);
		IsPlayingContent = 0;
		Browser_FileCtrl(IR_EQ, FileSelection);
		break;
	case IR_0:
		break;
	case IR_100_Plus:
		FileSelection = 18;
		Browser_FileCtrl(IR_100_Plus, FileSelection);
		break;
	case IR_200_Plus:
		break;
	case IR_1:
		break;
	case IR_2:
		break;
	case IR_3:
		break;
	case IR_4:
		break;
	case IR_5:
		break;
	case IR_6:
		break;
	case IR_7:
		break;
	case IR_8:
		break;
	case IR_9:
		break;
	default:
		break;
	}
}
/* USER CODE END 4 */

 /* MPU Configuration */

void MPU_Config(void)
{
  MPU_Region_InitTypeDef MPU_InitStruct = {0};

  /* Disables the MPU */
  HAL_MPU_Disable();

  /** Initializes and configures the Region and the memory to be protected
  */
  MPU_InitStruct.Enable = MPU_REGION_ENABLE;
  MPU_InitStruct.Number = MPU_REGION_NUMBER0;
  MPU_InitStruct.BaseAddress = 0x0;
  MPU_InitStruct.Size = MPU_REGION_SIZE_4GB;
  MPU_InitStruct.SubRegionDisable = 0x87;
  MPU_InitStruct.TypeExtField = MPU_TEX_LEVEL0;
  MPU_InitStruct.AccessPermission = MPU_REGION_NO_ACCESS;
  MPU_InitStruct.DisableExec = MPU_INSTRUCTION_ACCESS_DISABLE;
  MPU_InitStruct.IsShareable = MPU_ACCESS_SHAREABLE;
  MPU_InitStruct.IsCacheable = MPU_ACCESS_NOT_CACHEABLE;
  MPU_InitStruct.IsBufferable = MPU_ACCESS_NOT_BUFFERABLE;

  HAL_MPU_ConfigRegion(&MPU_InitStruct);
  /* Enables the MPU */
  HAL_MPU_Enable(MPU_PRIVILEGED_DEFAULT);

}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
	/* User can add his own implementation to report the HAL error return state */
	__disable_irq();
	while (1) {
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
