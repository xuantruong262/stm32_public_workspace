#include "jpeg_lcd.h"
#include <display.h>
extern SPI_HandleTypeDef hspi2;

volatile int dma_tx_done_spi2 = 1;
volatile int dma_rx_done_spi2 = 0;
extern UINT Height_Of_Jpeg;
extern UINT Buff[8192];
extern uint32_t out_time;
int frame_size = 0;
#if IWDGG
extern IWDG_HandleTypeDef hiwdg;
#endif

#define ILI9341
#define aLIST 0x5453494c
#define aMovi 0x69766f6d
#define aJunk 0x4b4e554a

// This define for video
#ifdef ILI9341
#define display_w 320
#define display_h 240
#elif ST7735
#define display_w 160
#define display_h 128
#endif

#define w_numchunk_in_frame 4
#define byte_per_pix 2
#define line_per_chunk display_h / w_numchunk_in_frame
#define total_pix_per_chunk line_per_chunk* display_w

// This define for image
#define w_per_chunk 32

extern uint16_t frame_buffer[240][320];

void SendCommand(uint8_t cmd) {
	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_RESET); // Command mode
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	HAL_SPI_Transmit(&hspi2, &cmd, 1, HAL_MAX_DELAY);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void SendData(uint8_t *data, uint16_t size) {
	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET); // Data mode
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
	HAL_SPI_Transmit(&hspi2, data, size, HAL_MAX_DELAY);
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
	HAL_SPI_Transmit(&hspi2, &dt, 1, HAL_MAX_DELAY);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void LCD_Init(uint8_t IsHorizol) {

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
	ctl = IsHorizol ? 0xe8 : 0x00;
	//    ctl = IsHorizol ? 0x60 : 0x00;
	SendData(&ctl, 1);

	// Litle endian

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

// Fill entire screen by 1 color
void FillScreen(uint16_t color, uint16_t end_x, uint16_t end_y) {

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
		HAL_SPI_Transmit(&hspi2, data, 2, HAL_MAX_DELAY);
	}

	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void TFT_AdjustGamma(void) {
	SendCommand(0xE0); // Positive Gamma Correction
	uint8_t gamma_pos[] = { 0x1F, 0x35, 0x2F, 0x10, 0x12, 0x0A, 0x50, 0xF5,
			0x3A, 0x0A, 0x12, 0x05, 0x12, 0x0C, 0x00 };
	SendData(gamma_pos, sizeof(gamma_pos));

	SendCommand(0xE1); // Negative Gamma Correction
	uint8_t gamma_neg[] = { 0x00, 0x0E, 0x14, 0x03, 0x11, 0x07, 0x31, 0xC1,
			0x48, 0x08, 0x0F, 0x0C, 0x31, 0x36, 0x0F };
	SendData(gamma_neg, sizeof(gamma_neg));
}

void Draw_ChunkOfColor(uint8_t pos_x, uint8_t pos_y, uint8_t width,
		uint8_t height, uint16_t color) {
	uint8_t data[2] = { color >> 8, color & 0xFF };
	SendCommand(0x2A);                                    // Column addr set
	uint8_t col[] = { 0x00, 0x0, 0x00, pos_x + width - 1 }; // x0 to x127
	SendData(col, 4);

	SendCommand(0x2B);                                       // Row addr set
	uint8_t row[] = { 0x00, pos_y, 0x00, pos_y + height - 1 }; // y0 to y159
	SendData(row, 4);

	SendCommand(0x2C); // Memory write

	HAL_GPIO_WritePin(TFT_TransMode_GPIO_Port, TFT_TransMode_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);

	// With Little Endian
	for (int i = 0; i < width * height; i++) {
		HAL_SPI_Transmit(&hspi2, data, 2, HAL_MAX_DELAY);
	}
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void Draw_PixData(uint16_t pos_x, uint16_t pos_y, uint16_t width,
		uint16_t height, uint16_t *data_frame) {
#ifdef ILI9341
	SendCommand(0x2A);                                        // Column addr set
	uint8_t col[] = { pos_x >> 8, pos_x & 0xff, ((width - 1) >> 8), ((width - 1) & 0xff) }; // x0 to 319
	SendData(col, 4);
	SendCommand(0x2B);
	uint8_t row[] = { pos_y >> 8, pos_y & 0xff, ((height - 1) >> 8), ((height - 1) & 0xff) }; // y0 to 239
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
	uint8_t words_pack = (total_byte + 65535) / 65535;

	if (total_byte > 65535) {
		for (int i = 0; i < words_pack; ++i) {
			HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
			// HAL_SPI_Transmit(&hspi2, data_frame + i*(total_byte / (words_pack*2)), total_byte / words_pack,
			// HAL_MAX_DELAY);
			dma_tx_done_spi2 = 0;
			HAL_SPI_Transmit_DMA(&hspi2,
					data_frame + i * (total_byte / (words_pack * 2)),
					total_byte / words_pack);
			while (!dma_tx_done_spi2)
				;
		}
	} else {
		HAL_SPI_Transmit(&hspi2, data_frame, total_byte, HAL_MAX_DELAY);
//		while (!dma_tx_done_spi2)
//			;
	}
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
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
			HAL_SPI_Transmit(&hspi2, &byte_fr565[j * width], width * 2,
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
			HAL_SPI_Transmit(&hspi2, &RGB_565, sizeof(uint16_t), HAL_MAX_DELAY);
		}
	}
	HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_SET);
}

void extract_BMP_Info(uint8_t *Frame_header_Buffer, bmp_info *bmp) {
	memcpy(&bmp->bmp_size, Frame_header_Buffer + 2, 4);
	memcpy(&bmp->width, Frame_header_Buffer + 0x12, 4);
	memcpy(&bmp->height, Frame_header_Buffer + 0x16, 4);
	memcpy(&bmp->bpp, Frame_header_Buffer + 0x1c, 2);
	bmp->bpp = bmp->bpp / 8;
}

static void Upside_down() {
#ifdef ILI9341
	SendCommand(0x36);
	uint8_t ctl = 0xA8;
	SendData(&ctl, 1);
#else
    SendCommand(0x36);
    uint8_t ctl = 0x20;
    SendData(&ctl, 1);
#endif
}

uint8_t Display_BMP_picture(const char *file_name) {
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
	uint8_t Frame_buf[SizeOfFrameBuff];

	br = 0;
	int i = 0;
	if (bmp.bpp == 2) { // RGB565
		Offset = 0x42;
		// read data
		while (((total_pix * bmp.bpp) - SizeOfFrameBuff * i) > 0) {
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
		while (((total_pix * bmp.bpp) - SizeOfFrameBuff * i) > 0) {
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
		//        SendCommand(0x36);
		//        uint8_t ctl = 0x60;
		//        SendData(&ctl, 1);
		return 0;
	}
	//    SendCommand(0x36);
	//    ctl = 0x60;
	//    SendData(&ctl, 1);
	return 1;
}

void video_display(obj_status obj, uint16_t *buf) {
#ifdef ILI9341
	uint8_t width_hight = (obj.width - 1) >> 8;
	uint8_t width_low = (obj.width - 1) & 0xff;
	uint8_t height_hight = (obj.height - 1) >> 8;
	uint8_t height_low = (obj.height - 1) & 0xff;
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

	dma_tx_done_spi2 = 0;
	uint32_t total_byte = total_pix_per_chunk * byte_per_pix;
	uint32_t remains = 0;
	if (total_byte > 65535) {
		HAL_SPI_Transmit_DMA(&hspi2, buf, total_byte / 2);
		while (!dma_tx_done_spi2)
			;
		dma_tx_done_spi2 = 0;
		HAL_GPIO_WritePin(TFT_CS_GPIO_Port, TFT_CS_Pin, GPIO_PIN_RESET);
		HAL_SPI_Transmit_DMA(&hspi2, buf + total_byte / 4, total_byte / 2);
		while (!dma_tx_done_spi2)
			;
	} else {
		HAL_SPI_Transmit_DMA(&hspi2, buf, total_pix_per_chunk * byte_per_pix);
	}
}

// Need open video file before call this function
uint8_t Raw_play_video(FIL *f, uint32_t *frame_num) {
	UINT br;
	uint16_t FrameA[total_pix_per_chunk];
	uint16_t FrameB[total_pix_per_chunk];
	uint32_t Size_Per_Chunk = total_pix_per_chunk * byte_per_pix;
	uint32_t base_offset = *frame_num * w_numchunk_in_frame * Size_Per_Chunk;
	uint32_t offset = base_offset;
	obj_status object2 = { 0, 0, display_w, line_per_chunk };
	int i = 0;
	while (1) {
		while (1) {
			f_lseek(f, offset);
			if (f_read(f, FrameA, Size_Per_Chunk - 1, &br) == FR_OK) {
#if IWDGG
                HAL_IWDG_Refresh(&hiwdg);
#endif
				break;
			}
		}
		// Check EOF
		if (br < (Size_Per_Chunk - 1)) {
			return 0;
		}

		while (!dma_tx_done_spi2)
			;
		video_display(object2, FrameA);

		object2.pos_y += line_per_chunk;
		i++;
		offset = base_offset + i * Size_Per_Chunk;
		f_lseek(f, offset);
		while (1) {
			if (f_read(f, FrameB, Size_Per_Chunk - 1, &br) == FR_OK) {
#if IWDGG
                HAL_IWDG_Refresh(&hiwdg);
#endif
				break;
			}
		}
		// Check EOF
		if (br < (Size_Per_Chunk - 1)) {
			return 0;
		}
		while (!dma_tx_done_spi2)
			;
		video_display(object2, FrameB);
		object2.pos_y += line_per_chunk;
		i++;
		offset = base_offset + i * Size_Per_Chunk;
		if (!(i % w_numchunk_in_frame)) {
			break;
		}
	}
	*frame_num += 1;
	return 1;
}

void Allocate_video_buffer(uint16_t **FrA, uint16_t **FrB) {
	*FrA = (uint16_t*) malloc(5120);
	*FrB = (uint16_t*) malloc(5120);
	//   memset(*FrA,0,sizeof(uint16_t) * total_pix_per_chunk);
	//   memset(*FrB,0,sizeof(uint16_t) * total_pix_per_chunk);
}

void Deallocate_video_buffer(uint16_t *FrA, uint16_t *FrB) {
	free(FrA);
	free(FrB);
}

// AVI_MPJEG video
uint32_t AVI_DataOffset(FIL *f_Jpeg) {
	UINT br = 0;
	;
	uint32_t buf = 0;
	uint32_t offset = 0;
	uint32_t Junk_size = 0;
	do {
		// Find chunk
		f_read(f_Jpeg, &buf, 4, &br);

		if (buf == aJunk) { // found JUNK
			f_read(f_Jpeg, &buf, 4, &br);
			Junk_size = buf; // JUNK size
			f_lseek(f_Jpeg, f_tell(f_Jpeg) + Junk_size);

			f_read(f_Jpeg, &buf, 4, &br);

			if (buf == aLIST) { // found LIST
				f_read(f_Jpeg, &buf, 4, &br);
				Junk_size = buf;
				f_read(f_Jpeg, &buf, 4, &br);
				if (buf == aMovi) { // found Movi
					return Junk_size;
				} else {
					f_lseek(f_Jpeg, f_tell(f_Jpeg) + Junk_size - 4);
				}
			}
		}
		if (br < 4) {
			break;
		}
	} while (br);
	return 0x0;
}

uint8_t AVI_video_display(FIL *f_AVI) {
	UINT br;
	uint32_t buf = 0;
	uint32_t offset = 0;
	//uint8_t AVI_jpeg_frameBuf[32000];
	JDEC jd;
	JRESULT Res_TjpgDec;
	BYTE scale;
	uint32_t total_time = 0;
	if (!AVI_DataOffset(f_AVI))
		return 0;

	while (1) {
		uint32_t start_f = HAL_GetTick();
		f_read(f_AVI, &buf, 4, &br); // compress type
		if (br < 4) {
			break;
		}
		f_read(f_AVI, &frame_size, 4, &br); // file size

    // Decode jpeg
#if 0
		f_read(f_AVI, AVI_jpeg_frameBuf, frame_size, &br); //read frame
		if( (frame_size%2) ){
			f_lseek(f_AVI, f_tell(f_AVI)+1);
		}


	    Res_TjpgDec = jd_prepare(&jd, STM32_in_func_avi, Buff, sizeof(Buff), AVI_jpeg_frameBuf);
	    Height_Of_Jpeg = jd.height;
	    if (Res_TjpgDec == JDR_OK)
	    {
	        for (scale = 0; scale < 3; scale++)
	        {
	            if ((jd.width >> scale) <= 320 && (jd.height >> scale) <= 240)
	            {
	                break;
	            }
	        }
	        if (scale)
	            scale--;
	        Res_TjpgDec = jd_decomp(&jd, STM32_out_func, scale);
	        Draw_PixData(0, 0, 320, 240, &frame_buffer[0][0]);
	    }
#else

		Res_TjpgDec = jd_prepare(&jd, STM32_in_func, Buff, sizeof(Buff), f_AVI);

		Height_Of_Jpeg = jd.height;
		if (Res_TjpgDec == JDR_OK) {

			for (scale = 0; scale < 3; scale++) {
				if ((jd.width >> scale) <= 320 && (jd.height >> scale) <= 240) {
					break;
				}
			}

			if (scale)
				scale--;

			uint32_t start_ip_prepare = HAL_GetTick();
			Res_TjpgDec = jd_decomp(&jd, STM32_out_func, scale);
			uint32_t end_ip_prepare = HAL_GetTick();

			uint32_t start_draw = HAL_GetTick();
			Draw_PixData(0, 0, 320, 240, &frame_buffer[0][0]);
			uint32_t end_draw = HAL_GetTick();
			uint32_t end_f = HAL_GetTick();
			total_time = end_f - start_f;
			printf("\nTime per frame: %d,Output_time: %d,Draw_time: %d,ip_prepare: %d", total_time, out_time, end_draw-start_draw, end_ip_prepare- start_ip_prepare);
			out_time = 0;
		}
#endif
	}
}
