/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
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

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32h7xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */
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


typedef enum eIR_Button{
  emIR_NONE = 0,
  emIR_CH_Minus,
  emIR_CH,
  emIR_CH_Plus,
  emIR_Prev,
  emIR_Next,
  emIR_Play_Pause,
  emIR_Plus,
  emIR_Minus,
  emIR_EQ,
  emIR_0,
  emIR_100_Plus,
  emIR_200_Plus,
  emIR_1,
  emIR_2,
  emIR_3,
  emIR_4,
  emIR_5,
  emIR_6,
  emIR_7,
  emIR_8,
  emIR_9
} eIR_Button;
/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define TFT_SDA_Pin GPIO_PIN_1
#define TFT_SDA_GPIO_Port GPIOC
#define TFT_SDI_Pin GPIO_PIN_2
#define TFT_SDI_GPIO_Port GPIOC
#define CAMERAPWDN_Pin GPIO_PIN_13
#define CAMERAPWDN_GPIO_Port GPIOF
#define TFT_TransMode_Pin GPIO_PIN_13
#define TFT_TransMode_GPIO_Port GPIOE
#define TFT_RS_Pin GPIO_PIN_14
#define TFT_RS_GPIO_Port GPIOE
#define TFT_CS_Pin GPIO_PIN_15
#define TFT_CS_GPIO_Port GPIOE
#define TFT_SCK_Pin GPIO_PIN_10
#define TFT_SCK_GPIO_Port GPIOB
#define RST_CAM_Pin GPIO_PIN_10
#define RST_CAM_GPIO_Port GPIOD
#define IR_Remote_Pin GPIO_PIN_14
#define IR_Remote_GPIO_Port GPIOD
#define IR_Remote_EXTI_IRQn EXTI15_10_IRQn
#define Debug_Led_Pin GPIO_PIN_7
#define Debug_Led_GPIO_Port GPIOG

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
