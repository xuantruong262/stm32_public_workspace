#include "jpeg_lcd.h"
#include "display.h"
#include "main.h"

// variables
static SPI_HandleTypeDef *hSPI = NULL;
extern SPI_HandleTypeDef hspi1;

volatile int dma_tx_done_spi2 = 1;
volatile int dma_rx_done_spi2 = 0;


#define ALIGN32(x)   (((x) + 31) & ~31U)
// For decode JPEG
#ifdef STM32H723xx_H
__attribute__((section(".DTCMRAM"), aligned(4)))
 BYTE Buff[16384]; // 8192  16384  32768   76800
#else
BYTE Buff[8192]; // 8192  16384  32768   76800
#endif

#ifdef STM32H723xx_H
__attribute__((section(".RAM_D1"), aligned(4)))
volatile uint16_t FrameBuff[240][320];
__attribute__((section(".DTCMRAM"), aligned(4)))
volatile uint8_t Jpeg_frame[76800];
volatile audioInfo audio_data;
volatile uint32_t FrameSize_Remain = 0;
#endif
// For Watchdog
#if IWDGG
extern IWDG_HandleTypeDef hiwdg;
#endif
// For RAW video display
#ifdef STM32H723xx_H
__attribute__((section(".RAM_D1"), aligned(4)))
uint16_t *FrameA;
__attribute__((section(".RAM_D1"), aligned(4)))
uint16_t *FrameB;
#else
    uint16_t *FrameA;
    uint16_t *FrameB;
#endif

// SD File browser
uint16_t SD_Browser_BGColor[2] = { 0x10a6, 0x08cf };
int8_t prev_pointer = -1;
int8_t Cur_Page = 0;
int8_t Prev_Page = 0;
extern Browser_FileFormat fileFormat;
Browser_FileInfo *FileInMenuList;
volatile uint8_t *IsDisplayContent = NULL;
char SP_FileFormat[6][5] = { ".jpg", ".bmp", ".wav", ".rgb", ".avi", ".dat" };
uint8_t num_trunk = 0;
uint32_t SizePerTrunk = 0;
uint32_t Start = 0;
uint32_t End = 0;
volatile eAVI_type video_type = emAVI_OnlyVideo;



// For Interupt callback function
void LCD_SPI_TxCpltCb() {
	static uint8_t spi_cbTime = 1;
	num_trunk--;
	if (num_trunk > 0) {
#ifdef USING_CACHE
		SCB_CleanDCache_by_Addr(
				(uint32_t*) FrameBuff[spi_cbTime * (SizePerTrunk >> 1)
						/ display_w], ALIGN32(SizePerTrunk));
		__DSB();
		asm volatile("" ::: "memory");
#endif
		HAL_SPI_Transmit_DMA(hSPI,
				(uint8_t*) FrameBuff[spi_cbTime * (SizePerTrunk >> 1)
						/ display_w], SizePerTrunk);
		spi_cbTime++;
	} else {
		spi_cbTime = 1;
		num_trunk = 0;
		dma_tx_done_spi2 = 1;
		HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
	}
}


void LCD_SPI_TxRxCpltCb() {
	dma_rx_done_spi2 = 1;
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void SendCommand(uint8_t cmd) {
	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_RESET); // Command mode
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	HAL_SPI_Transmit(hSPI, &cmd, 1, HAL_MAX_DELAY);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void SendData(uint8_t *data, uint16_t size) {
	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET); // Data mode
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	HAL_SPI_Transmit(hSPI, data, size, HAL_MAX_DELAY);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void Reset(void) {
	HAL_GPIO_WritePin(TFT_RS_GPIO_Port, TFT_RS_Pin, GPIO_PIN_RESET);
	HAL_Delay(10);
	HAL_GPIO_WritePin(TFT_RS_GPIO_Port, TFT_RS_Pin, GPIO_PIN_SET);
	HAL_Delay(10);
}

void writedata(uint8_t dt) {
	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET); // Data mode
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	HAL_SPI_Transmit(hSPI, &dt, 1, HAL_MAX_DELAY);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

static void LCD_SetAddressWindow(uint16_t pos_x, uint16_t pos_y, uint16_t width,
		uint16_t height) {
	SendCommand(0x2A); // Column addr set
	uint8_t col[] = { pos_x >> 8, pos_x & 0xff, ((pos_x + width - 1) >> 8),
			((pos_x + width - 1) & 0xff) }; // x0 to 319
	SendData(col, 4);
	SendCommand(0x2B);
	uint8_t row[] = { pos_y >> 8, pos_y & 0xff, ((pos_y + height - 1) >> 8),
			((pos_y + height - 1) & 0xff) }; // y0 to 239
	SendData(row, 4);
}

static uint16_t RGB565_R_B_swap(uint16_t pix_data) {
	uint8_t B_565 = 0;
	uint8_t G_565 = 0;
	uint8_t R_565 = 0;
	B_565 = (pix_data) & 0x1F;
	G_565 = (pix_data >> 5) & 0x3F;
	R_565 = (pix_data >> 11) & 0x1F;
	return (B_565 << 11) | (G_565 << 5) | R_565;
}

void Display_BMPImage(uint16_t pos_x, uint16_t pos_y, uint16_t width,
		uint16_t height, uint8_t *data_frame, uint8_t bpp) {
	uint8_t width_hight = (width - 1) >> 8;
	uint8_t width_low = (width - 1) & 0xff;
	uint8_t height_hight = (height - 1) >> 8;
	uint8_t height_low = (height - 1) & 0xff;
	SendCommand(0x2A);                                   // Column addr set
	uint8_t col[] = { 0x00, 0x0, width_hight, width_low }; // x0 to x127
	SendData(col, 4);

	SendCommand(0x2B); // Row addr set
	uint8_t row[] = { pos_y >> 8, pos_y & 0xff, (pos_y >> 8) + height_hight,
			(pos_y & 0xff) + height_low }; // y0 to y159
	SendData(row, 4);

	SendCommand(0x2C); // Memory write

	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);

	// Convert to Big Endian
	if (bpp == 2) { // RGB565
		uint16_t *byte_fr565 = (uint16_t*) data_frame;
		for (uint32_t j = 0; j < height; j++) {
			for (uint32_t i = j * width; i < (j + 1) * width; i++) {
				byte_fr565[i] = (byte_fr565[i] >> 8) | (byte_fr565[i] << 8);
			}
			HAL_SPI_Transmit(hSPI, &byte_fr565[j * width], width * 2,
					HAL_MAX_DELAY);
		}
	} else if (bpp == 3) { // RGB888
		uint8_t R_565 = 0;
		uint8_t G_565 = 0;
		uint8_t B_565 = 0;
		uint16_t RGB_565 = 0;
		for (int i = 0; i < width * height; i++) {
			B_565 = (data_frame[3 * i + 0] >> 3) & 0x1F;
			G_565 = (data_frame[3 * i + 1] >> 2) & 0x3F;
			R_565 = (data_frame[3 * i + 2] >> 3) & 0x1F;
			RGB_565 = (R_565 << 11) | (G_565 << 5) | B_565;
			RGB_565 = (RGB_565 >> 8) | (RGB_565 << 8);
			HAL_SPI_Transmit(hSPI, &RGB_565, sizeof(uint16_t), HAL_MAX_DELAY);
		}
	}
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

static void extract_BMP_Info(uint8_t *Frame_header_Buffer, bmp_info *bmp) {
	memcpy(&bmp->bmp_size, Frame_header_Buffer + 2, 4);
	memcpy(&bmp->width, Frame_header_Buffer + 0x12, 4);
	memcpy(&bmp->height, Frame_header_Buffer + 0x16, 4);
	memcpy(&bmp->bpp, Frame_header_Buffer + 0x1c, 2);
	bmp->bpp = bmp->bpp / 8;
}

static void Upside_down() {
	static uint8_t USD_flag = 0;
#ifdef ILI9341
	if (!USD_flag) {
		SendCommand(0x36);
		uint8_t ctl = 0xA8;
		SendData(&ctl, 1);
	} else {
		SendCommand(0x36);
		uint8_t ctl = 0xe8;
		SendData(&ctl, 1);
	}
#else
    SendCommand(0x36);
    uint8_t ctl = 0x20;
    SendData(&ctl, 1);
#endif
	USD_flag = (USD_flag == 0) ? 1 : 0;
}

static void video_display(obj_status obj, uint16_t *buf) {
#ifdef ILI9341
	SendCommand(0x2A); // Column addr set
	uint8_t col[] = { obj.pos_x >> 8, obj.pos_x & 0xff, ((obj.pos_x + obj.width
			- 1) >> 8), ((obj.pos_x + obj.width - 1) & 0xff) }; // x0 to x127
	SendData(col, 4);

	SendCommand(0x2B);
	uint8_t row[] = { obj.pos_y >> 8, obj.pos_y & 0xff, ((obj.pos_y + 130 - 1)
			>> 8), ((obj.pos_y + 120 - 1) & 0xff) }; // y0 to y159
	SendData(row, 4);
#else
    SendCommand(0x2A);                                                  // Column addr set
    uint8_t col[] = {0x00, obj.pos_x, 0x00, obj.pos_x + obj.width - 1}; // x0 to x127
    SendData(col, 4);

    SendCommand(0x2B);
    uint8_t row[] = {0x00, obj.pos_y, 0x00, obj.pos_y + obj.height - 1}; // y0 to y159
    SendData(row, 4);

#endif

	SendCommand(0x2C); // Memory write
	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	uint32_t total_byte = obj.width * obj.height * 2;
	num_trunk = (total_byte + 65535) / 65535;

	if (num_trunk > 1) {
		SizePerTrunk = total_byte / num_trunk;
        dma_tx_done_spi2 = 0;
#ifdef USING_CACHE
        SCB_CleanDCache_by_Addr((uint32_t*)buf, ALIGN32(SizePerTrunk));
        __DSB();
        asm volatile("" ::: "memory");
#endif
        HAL_SPI_Transmit_DMA(hSPI, (uint8_t*)buf, SizePerTrunk );
	} else {
		SizePerTrunk = total_byte;
        dma_tx_done_spi2 = 0;
#ifdef USING_CACHE
        SCB_CleanDCache_by_Addr((uint32_t*)buf, ALIGN32(SizePerTrunk));
        __DSB();
        asm volatile("" ::: "memory");
#endif
		//HAL_SPI_Transmit(hSPI, buf, SizePerTrunk,HAL_MAX_DELAY);
		HAL_SPI_Transmit_DMA(hSPI, (uint8_t*)buf, SizePerTrunk);
	}
}

static void Allocate_video_buffer(uint16_t **Fr, uint32_t Size) {
	*Fr = (uint16_t*) malloc(Size);
}

static void Deallocate_video_buffer(uint16_t **Fr) {
	free(*Fr);
	*Fr = NULL;

}

// File browser
static void Browser_FillBgColor(uint16_t color1, uint16_t color2) {
	uint8_t data[2][2] = { { color1 >> 8, color1 & 0xFF }, { color2 >> 8, color2 & 0xFF } };
	for (int k = 0; k < 8; k++) {
#ifdef USING_CACHE
        SCB_CleanDCache_by_Addr((uint32_t*)data[!(k%2)], 2);
#endif
		Draw_ChunkOfColor(0, k*30, 320, 30, *data[!(k%2)]);
	}
}
// AVI_MPJEG video


static uint32_t AVI_DataOffset(FIL *f_Jpeg) {
	UINT br = 0;
	uint32_t buf = 0;
	uint32_t Junk_size = 0;
	uint32_t List_size = 0;
	f_lseek(f_Jpeg, 0x38);
	f_read(f_Jpeg, &buf, 4, &br);
	video_type = (eAVI_type)buf;

	do {
		// Find chunk
		f_read(f_Jpeg, &buf, 4, &br);
		// Check Video Type

		if (buf == aJunk) { // found JUNK
			f_read(f_Jpeg, &buf, 4, &br);
			Junk_size = buf; // JUNK size
			f_lseek(f_Jpeg, f_tell(f_Jpeg) + Junk_size);
			Junk_size = 0;
		}

		if (buf == aLIST) { // found LIST
			f_read(f_Jpeg, &buf, 4, &br);
			List_size = buf;
			f_read(f_Jpeg, &buf, 4, &br);
			if (buf == aMovi) { // found Movi
				return List_size;
			} else {
				f_lseek(f_Jpeg, f_tell(f_Jpeg) + List_size - 4);
			}
			List_size = 0;
		}

		if (br < 4) {
			break;
		}
	} while (br);
	return 0x0;
}


/***********************************API functions for LCD display****************************/
// ------------------------LCD display------------------------
uint32_t LCD_DisplayJPEG(const char *filename) {
	FIL JpegFile;
	FRESULT res;
	JDEC Jdec;          // Decompression object
	JRESULT Jres;      // Result of JPEG decompression
	uint32_t JpegFileSize = 0; // File size
	BYTE scale;

	// Open the JPEG file

	res = f_open(&JpegFile, filename, FA_READ);
	if (res != FR_OK) {
		return 1; // File open error
	}

	// Get the file size
	JpegFileSize = f_size(&JpegFile);
	// Prepare to decompress the JPEG file
	Jres = jd_prepare(&Jdec, STM32_in_func, Buff, sizeof(Buff), &JpegFile);
	if (Jres != JDR_OK) {
		f_close(&JpegFile);
		return 2; // JPEG format error
	}
	// Scale
	for (scale = 0; scale < 3; scale++) {
		if ((Jdec.width >> scale) <= 320 && (Jdec.height >> scale) <= 240) {
			break;
		}
	}

	if (scale) {
		scale--;
	}
	// Start to decompress the JPEG file
	Jres = jd_decomp(&Jdec, STM32_out_func, 0);

	if (Jres != JDR_OK) {
		f_close(&JpegFile);
		return 3; // Decompression error
	}
#ifdef REALSE_FULL_SCREEN
	while (!dma_tx_done_spi2);
	// Wait DMA
	LCD_DrawPixData(0, 0, 320, 240, &FrameBuff[0][0]);
#endif
	// Close the JPEG file
	f_close(&JpegFile);

	return 0; // Success
}

uint32_t JPEG() {

	JDEC Jdec;          // Decompression object
	JRESULT Jres;      // Result of JPEG decompression
	BYTE scale;
	// Prepare to decompress the JPEG file
	Jres = jd_prepare(&Jdec, mem_input, Buff, sizeof(Buff), Jpeg_frame);
	if (Jres != JDR_OK) {
		return 2; // JPEG format error
	}
	// Scale
	for (scale = 0; scale < 3; scale++) {
		if ((Jdec.width >> scale) <= 320 && (Jdec.height >> scale) <= 240) {
			break;
		}
	}
	if (scale) {
		scale--;
	}
	// Start to decompress the JPEG file
	Jres = jd_decomp(&Jdec, STM32_out_func, scale);
	if (Jres != JDR_OK) {
		return 3; // Decompression error
	}
#ifdef REALSE_FULL_SCREEN
	while (!dma_tx_done_spi2);
	// Wait DMA
	LCD_DrawPixData(0, 0, 320, 240, &FrameBuff[0][0]);
#endif
	return 0; // Success
}

void LCD_Init(SPI_HandleTypeDef *hspi_ptr, uint8_t *LCD_Playing_Ctrl,
		uint8_t IsHorizol) {
	hSPI = hspi_ptr;
	IsDisplayContent = LCD_Playing_Ctrl;
	// Initialize the LCD
	Reset();
	// Software reset
	SendCommand(0x01);
	HAL_Delay(150);
	// Sleep out
	SendCommand(0x11);
	HAL_Delay(150);
	// Interface Pixel Format
	SendCommand(0x3A);
	uint8_t data = 0x55; // 16-bit color
	SendData(&data, 1);
	// Gamma
	SendCommand(ILI9341_GAMMASET); // Gamma curve selected
	writedata(2);
	SendCommand(ILI9341_GAMMASET); // Gamma curve selected
	writedata(1);
	// Coordinate display
	SendCommand(0x36);
	uint8_t ctl = 0;
	ctl = IsHorizol ? 0xe8 : 0x00; // 0xe8 = horizol, 0x00
	SendData(&ctl, 1);

	// Display ON
	SendCommand(0x29);
	HAL_Delay(10);
	SendCommand(0xf6);
	writedata(0x0);
	writedata(0x0);
	writedata(0x0);
	writedata(0x0);
	writedata(0x0);
	writedata(0x20);
}

void LCD_FillScreen(uint16_t color, uint16_t end_x, uint16_t end_y) {
	uint8_t data[2] = { color >> 8, color & 0xFF };
	uint16_t w = end_x;
	uint16_t h = end_y;
	SendCommand(0x2A);                                        // Column addr set
	uint8_t col[] = { 0x00, 0x00, (end_x - 1) >> 8, (end_x - 1) & 0xFF }; // x0 to x127
	SendData(col, 4);

	SendCommand(0x2B);                                           // Row addr set
	uint8_t row[] = { 0x00, 0x00, (end_y - 1) >> 8, (end_y - 1) & 0xFF }; // y0 to y159
	SendData(row, 4);

	SendCommand(0x2C); // Memory write

	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	for (int i = 0; i < w * h; i++) {
		HAL_SPI_Transmit(hSPI, data, 2, HAL_MAX_DELAY);
	}

	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void LCD_AdjustGamma(void) {
	SendCommand(0xE0); // Positive Gamma Correction
	uint8_t gamma_pos[] = { 0x1F, 0x35, 0x2F, 0x10, 0x12, 0x0A, 0x50, 0xF5,
			0x3A, 0x0A, 0x12, 0x05, 0x12, 0x0C, 0x00 };
	SendData(gamma_pos, sizeof(gamma_pos));

	SendCommand(0xE1); // Negative Gamma Correction
	uint8_t gamma_neg[] = { 0x00, 0x0E, 0x14, 0x03, 0x11, 0x07, 0x31, 0xC1,
			0x48, 0x08, 0x0F, 0x0C, 0x31, 0x36, 0x0F };
	SendData(gamma_neg, sizeof(gamma_neg));
}

// Fill entire screen by 1 color
void Draw_ChunkOfColor(uint16_t pos_x, uint16_t pos_y, uint16_t width,
		uint16_t height, uint16_t color) {
	uint8_t data[2] = { color >> 8, color & 0xFF };
	SendCommand(0x2A); // Column addr set
	uint8_t col[] = { pos_x >> 8, pos_x & 0xff, ((pos_x + width - 1) >> 8),
			((pos_x + width - 1) & 0xff) }; // x0 to 319
	SendData(col, 4);
	SendCommand(0x2B);
	uint8_t row[] = { pos_y >> 8, pos_y & 0xff, ((pos_y + height - 1) >> 8),
			((pos_y + height - 1) & 0xff) }; // y0 to 239
	SendData(row, 4);

	SendCommand(0x2C); // Memory write

	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);

	// With Little Endian
	for (int i = 0; i < width * height; i++) {
		HAL_SPI_Transmit(hSPI, data, 2, HAL_MAX_DELAY);
	}
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void LCD_DrawPixData(uint16_t pos_x, uint16_t pos_y, uint16_t width, uint16_t height, uint16_t *data_frame) {
#ifdef ILI9341
	SendCommand(0x2A);                                        // Column addr set
	uint8_t col[] = { pos_x >> 8, pos_x & 0xff, ((pos_x + width - 1) >> 8),
			((pos_x + width - 1) & 0xff) }; // x0 to 319
	SendData(col, 4);
	SendCommand(0x2B);
	uint8_t row[] = { pos_y >> 8, pos_y & 0xff, ((pos_y + height - 1) >> 8),
			((pos_y + height - 1) & 0xff) }; // y0 to 239
	SendData(row, 4);
#else
    SendCommand(0x2A);                                      // Column addr set
    uint8_t col[] = {0x00, pos_x, 0x00, pos_x + width - 1}; // x0 to x127
    SendData(col, 4);

    SendCommand(0x2B);                                       // Row addr set
    uint8_t row[] = {0x00, pos_y, 0x00, pos_y + height - 1}; // y0 to y159
    SendData(row, 4);
#endif

	SendCommand(0x2C); // Memory write
	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	uint32_t total_byte = width * height * 2;
	num_trunk = (total_byte + 65535) / 65535;

	if (num_trunk > 1) {
		SizePerTrunk = total_byte / num_trunk;
        dma_tx_done_spi2 = 0;
#ifdef USING_CACHE
        SCB_CleanDCache_by_Addr((uint32_t*)FrameBuff[0], SizePerTrunk);
#endif
        HAL_SPI_Transmit_DMA(hSPI, (uint8_t*)data_frame, SizePerTrunk );
	} else {
        SizePerTrunk = total_byte;
#ifdef USING_CACHE
        SCB_CleanDCache_by_Addr((uint8_t*) data_frame, SizePerTrunk);
#endif
        HAL_SPI_Transmit(hSPI, (uint8_t*) data_frame, SizePerTrunk,HAL_MAX_DELAY);
		HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
	}
}
// Display BMP image from SD card
uint8_t LCD_DisplayBMP(const char *file_name) {
	uint8_t header[36];
	bmp_info bmp;
	FIL file;
	UINT br;
	uint32_t Offset = 0;
	uint32_t SizeOfFrameBuff = 0;
	Upside_down();
	// open file
	while (1) {
		if (f_open(&file, file_name, FA_READ) == FR_OK) {
#if IWDGG
            HAL_IWDG_Refresh(&hiwdg);
#endif
			break;
		}
	}
	// read header file
	while (1) {
		f_lseek(&file, 0x0);
		if (f_read(&file, header, sizeof(header), &br) == FR_OK) {
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
	uint8_t *Frame_buf = (uint8_t*) malloc(SizeOfFrameBuff);

	br = 0;
	int i = 0;
	if (bmp.bpp == 2) { // RGB565
		Offset = 0x42;
		// read data
		while ((int) ((total_pix * bmp.bpp) - SizeOfFrameBuff * i) > 0) {
			f_lseek(&file, Offset);
			while (1) {
				if (f_read(&file, Frame_buf, SizeOfFrameBuff, &br) == FR_OK) {
#if IWDGG
                    HAL_IWDG_Refresh(&hiwdg);
#endif
					break;
				}
			}
			Display_BMPImage(pos_x, pos_y, bmp.width, w_per_chunk, Frame_buf,
					bmp.bpp);
			pos_y += w_per_chunk;
			i++;
			Offset = Offset + SizeOfFrameBuff;
		}
	} else if (bmp.bpp == 3) { // RGB888
		if (Frame_buf == NULL) {
			return 0;
		}
		Offset = 0x36;
		while ((int) ((total_pix * bmp.bpp) - SizeOfFrameBuff * i) > 0) {
			f_lseek(&file, Offset);
			while (1) {
				if (f_read(&file, Frame_buf, SizeOfFrameBuff, &br) == FR_OK) {
#if IWDGG
                    HAL_IWDG_Refresh(&hiwdg);
#endif
					break;
				}
			}
			Display_BMPImage(pos_x, pos_y, bmp.width, w_per_chunk, Frame_buf,
					bmp.bpp);
			pos_y += w_per_chunk;
			i++;
			Offset = Offset + SizeOfFrameBuff;
		}
	} else {
		Upside_down();
		f_close(&file);
		free(Frame_buf);
		return 0;
	}
	Upside_down();
	f_close(&file);
	free(Frame_buf);
	return 1;
}
// Play AVI MJPEG video from SD card


uint8_t LCD_PlayAVIVideo(const char *file_name) {
	UINT br;
	uint32_t period = 0;
	uint32_t chunk_type = 0;
	FIL file;

	if (!f_open(&file, file_name, FA_READ) == FR_OK) {
		return 0;
	}
	if (!AVI_DataOffset(&file))
		return 0;

	while (1) {
		while(!dma_tx_done_spi2);
		// Align to even
		// Decode jpeg
		if(video_type == emAVI_OnlyVideo){
			if( f_tell(&file) & 0x1 ) {
				f_lseek(&file, f_tell(&file) + 1);
			}
			// Get frame size
			f_read(&file, &chunk_type, 4, &br);
			f_read(&file, &FrameSize_Remain, 4, &br);
			// Get data frame
			f_read(&file, Jpeg_frame, FrameSize_Remain, &br); // read data input
			JPEG();
		}
		else{
			AVIaudioLoadFile(&file);
			start_dma_transfer(4096);
			while(1);
			// Play video
		}
	}
	f_close(&file);
	return 0;
}
// Play RAW video from SD card
uint8_t LCD_PlayRawVideo(const char *file_name, uint32_t *frame_num) {
	FIL file;
	UINT br;
	uint32_t Size_Per_Chunk = total_pix_per_chunk * byte_per_pix;
	uint32_t base_offset = *frame_num * w_numchunk_in_frame * Size_Per_Chunk;
	uint32_t offset = base_offset;
	obj_status object2 = { 0, 0, display_w, line_per_chunk };
	int i = 0;
	// Check Is video playing?
	Start = HAL_GetTick();
	if (*IsDisplayContent == 0) { //Stop and Cancel
		if (*frame_num != 0) {
			*frame_num = 0;
			Deallocate_video_buffer(&FrameA);
			Deallocate_video_buffer(&FrameB);
			f_close(&file);
		}
		return 0;
	}
	// Open file and allocate buffer
	if (*frame_num == 0) {
		if (!f_open(&file, file_name, FA_READ) == FR_OK) {
			return 0;
		}
		Allocate_video_buffer(&FrameA, total_pix_per_chunk * byte_per_pix);
		Allocate_video_buffer(&FrameB, total_pix_per_chunk * byte_per_pix);
	}

	// Read and display
	while (1) {
		while (1) {
			f_lseek(&file, offset);
			if ((f_read(&file, FrameA, Size_Per_Chunk - 1, &br) == FR_OK)) {
#if IWDGG
                HAL_IWDG_Refresh(&hiwdg);
#endif
				break;
			}
		}
#ifdef USING_CACHE
		SCB_InvalidateDCache_by_Addr((uint32_t*)FrameB, ALIGN32(Size_Per_Chunk - 1));
        __DSB();
        asm volatile("" ::: "memory");
#endif
		// Check EOF
		if (br < (Size_Per_Chunk - 1)) {
			Deallocate_video_buffer(&FrameA);
			Deallocate_video_buffer(&FrameB);
			return 0;
		}

		while (!dma_tx_done_spi2)
			;
		if (*IsDisplayContent == 0) { //Stop and Cancel
			break;
		}
		video_display(object2, FrameA);

		object2.pos_y += line_per_chunk;
		i++;
		offset = base_offset + i * Size_Per_Chunk;
		f_lseek(&file, offset);
		while (1) {
			if ((f_read(&file, FrameB, Size_Per_Chunk - 1, &br) == FR_OK)) {
#if IWDGG
                HAL_IWDG_Refresh(&hiwdg);
#endif
				break;
			}
		}
#ifdef USING_CACHE
		SCB_InvalidateDCache_by_Addr((uint32_t*)FrameA, ALIGN32(Size_Per_Chunk - 1));
        __DSB();
        asm volatile("" ::: "memory");
#endif
		// Check EOF
		if (br < (Size_Per_Chunk - 1)) {
			Deallocate_video_buffer(&FrameA);
			Deallocate_video_buffer(&FrameB);
			return 0;

		}
		while (!dma_tx_done_spi2)
			;

		if (*IsDisplayContent == 0) { //Stop and Cancel
			break;
		}
		video_display(object2, FrameB);
		object2.pos_y += line_per_chunk;
		i++;
		offset = base_offset + i * Size_Per_Chunk;
		if (!(i % w_numchunk_in_frame)) {
			break;
		}
	}
	End = HAL_GetTick();
	if(*frame_num%100 == 0){
		printf("FPS: %d\n", 1000 / (End-Start));
	}
	*frame_num += 1;

	return 1;
}
// Draw character and string
void LCD_WriteChar(uint16_t x, uint16_t y, char ch, FontDef font,
		uint16_t color, uint16_t bgcolor) {
	uint32_t i, b, j;
	LCD_SetAddressWindow(x, y, font.width, font.height);
	SendCommand(0x2C);
	for (i = 0; i < font.height; i++) {
		b = font.data[(ch - 32) * font.height + i];
		for (j = 0; j < font.width; j++) {
			if ((b << j) & 0x8000) {
				uint8_t data[] = { color >> 8, color & 0xFF };
				SendData(data, sizeof(data));
			} else {
				uint8_t data[] = { bgcolor >> 8, bgcolor & 0xFF };
				SendData(data, sizeof(data));
			}
		}
	}
}

void LCD_WriteString(uint16_t x, uint16_t y, const char *str, FontDef font,
		uint16_t color, uint16_t bgcolor) {
	while (*str) {
		if (x + font.width >= display_w) {
			x = 0;
			y += font.height;
			if (y + font.height >= display_h) {
				break;
			}

			if (*str == ' ') {
				// skip spaces in the beginning of the new line
				str++;
				continue;
			}
		}

		LCD_WriteChar(x, y, *str, font, color, bgcolor);
		x += font.width;
		str++;
	}
}

// ------------------------File browser-------------------------
// Initialize file browser
void Browser_Init(Browser_FileInfo *FileList) {

	FileInMenuList = FileList;
	Browser_MenuBackGround();
	for (int i = 0; i < 8; i++) {
		Browser_WriteFile2Menu(i, FileInMenuList[i].name);
	}
	Browser_FileCtrl(IR_None, 0);
}
// Fill pointer color
void Browser_FillCtrlPtr(uint8_t row, uint16_t color) {
	if (prev_pointer == -1) {
	} else {
		Draw_ChunkOfColor(0, prev_pointer * 30, 4, 30,
				SD_Browser_BGColor[prev_pointer % 2]);
	}
	Draw_ChunkOfColor(0, row * 30, 4, 30, color);
	prev_pointer = row;
}
// Write file name to menu
void Browser_WriteFile2Menu(uint8_t N_o, const char *str) {
	char st[28];
	memcpy(st, str, 27);
	LCD_WriteString(8, N_o * 30 + 6, st, Font_11x18, 0xffff,
			SD_Browser_BGColor[N_o % 2]);
}
// Fill menu background
void Browser_MenuBackGround() {
	Browser_FillBgColor(0x10a6, 0x08cf);
}
// Update page
void Browser_Page_Update(uint8_t ptr_location) {
	if (*IsDisplayContent) {
		Prev_Page = -1;
	} else {
		Cur_Page = ptr_location / 8;
		if (Cur_Page != Prev_Page) {
			Browser_MenuBackGround();
			for (int i = Cur_Page * 8; i < Cur_Page * 8 + 8; i++) {
				Browser_WriteFile2Menu(i % 8, FileInMenuList[i].name);
			}
			Prev_Page = Cur_Page;
		}
		Browser_FillCtrlPtr(ptr_location % 8, SDBrower_ptr_color);
	}
}
// File format filter
void Browser_FileFormatFilter(const char *str) {
	char *pos = NULL;
	for (int i = 0; i < 5; i++) {
		pos = strstr(str, SP_FileFormat[i]);
		if (pos != NULL) {
//			printf("[Debug] File Format: %s\n", SP_FileFormat[i]);
			fileFormat = (Browser_FileFormat) i;
			break;
		}
	}
}
// File control
void Browser_FileCtrl(uint32_t button_code, uint8_t Sel_N_o) {
	if (*IsDisplayContent) {
		return;
	}
	if (button_code == IR_Play_Pause) { //Enter
		Browser_FileFormatFilter(FileInMenuList[Sel_N_o].name);
	} else if (button_code == IR_EQ) { //Back
		Browser_MenuBackGround();
		Prev_Page = -1;
	}
	Browser_Page_Update(Sel_N_o);

}
