#include "itr.h"
#include "main.h"
extern SPI_HandleTypeDef hspi1;
extern SPI_HandleTypeDef hspi2;
extern int dma_tx_done_spi2;
extern int dma_rx_done_spi2;
extern int dma_tx_done_spi1;
extern int dma_rx_done_spi1;

void (*I2S_TXHalfFunc)(void);
void (*I2S_TXCpltFunc)(void);
void (*SPI_TXCpltFunc)(void);
void (*SPI_RXCpltFunc)(void);

void Itr_InitI2SCBFunc( void (*TX_HalfF)(void), void (*TX_CpltF)(void)){
	I2S_TXHalfFunc = TX_HalfF;
	I2S_TXCpltFunc = TX_CpltF;
}
void Itr_InitSPICBFunc( void (*TX_CpltF)(void), void (*RX_CpltF)(void)){
	SPI_TXCpltFunc = TX_CpltF;
	SPI_RXCpltFunc = RX_CpltF;
}


//From audio library
void HAL_I2S_TxHalfCpltCallback(I2S_HandleTypeDef *hi2s)
{
	I2S_TXHalfFunc();

}

/* Transfer complete: refill second half */
void HAL_I2S_TxCpltCallback(I2S_HandleTypeDef *hi2s)
{
	I2S_TXCpltFunc();
}

/* Error callback */
void HAL_I2S_ErrorCallback(I2S_HandleTypeDef *hi2s)
{
    // handle error (reset DMA, stop playback)
    //wav_stop_play();
}

//From audio library
extern uint8_t num_trunk;
extern uint32_t SizePerTrunk;
extern uint16_t frame_buffer[240][320];
///////SPI//////////////////
void HAL_SPI_TxCpltCallback(SPI_HandleTypeDef *hspi) {
    if (hspi == &hspi1)
    {
    	dma_tx_done_spi1 = 1;
    }
   else if(hspi == &hspi2){
	   SPI_TXCpltFunc();
   }
}

void HAL_SPI_TxRxCpltCallback(SPI_HandleTypeDef *hspi) {
    if (hspi == &hspi1)
    {
    	dma_rx_done_spi1 = 1;
    }
   else if (hspi == &hspi2)
   {
	   SPI_RXCpltFunc();
   }
}
