#ifndef __ITR_H__
#define __ITR_H__
#include "stm32h7xx_hal.h"

///////////I2S/////////////////////

void HAL_I2S_TxCpltCallback(I2S_HandleTypeDef *hi2s);
void HAL_I2S_TxHalfCpltCallback(I2S_HandleTypeDef *hi2s);
void HAL_I2S_ErrorCallback(I2S_HandleTypeDef *hi2s);
///////////SPI/////////////////////

void HAL_SPI_TxCpltCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_TxRxCpltCallback(SPI_HandleTypeDef *hspi);


void Itr_InitI2SCBFunc( void (*TX_HalfF)(void), void (*TX_CpltF)(void));
void Itr_InitSPICBFunc( void (*TX_CpltF)(void), void (*RX_CpltF)(void));
#endif
