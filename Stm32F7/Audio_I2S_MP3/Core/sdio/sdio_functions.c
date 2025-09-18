/******************************************************************************
 *  File        : sd_functions.c
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

#include "fatfs.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "bsp_driver_sd.h"
typedef enum efile_format
{
    emJPG,
    emBMP,
    emWAV,
    emRGB,
	emAVI,
	emMP3,
    emDAT,
    emNone
} efile_format;

typedef struct SDFile_Info
{
    char name[50];
    efile_format format;
    uint32_t size;
} SDFile_Info;

extern char SDPath[4];

SDFile_Info *SDFileInMenuList = NULL;

FATFS sdio_fs;
BSP_SD_CardInfo myCardInfo;
// Filter name
const char* get_file_extension(const char *filename) {
    const char *dot = strrchr(filename, '.');  // tìm dấu '.' cuối cùng
    if(!dot || dot == filename) return "";     // không có '.' hoặc '.' ở đầu (ẩn file)
    return dot + 1;                            // trả về phần sau '.'
}

efile_format getFileFormat(const char *str_type){
	if(strcmp(str_type,"jpg") == 0){
		return emJPG;
	}
	else if(strcmp(str_type,"bmp") == 0){
		return emBMP;
	}
	else if(strcmp(str_type,"wav") == 0){
		return emWAV;
	}
	else if(strcmp(str_type,"rgb") == 0){
		return emRGB;
	}
	else if(strcmp(str_type,"avi") == 0){
		return emAVI;
	}
	else if(strcmp(str_type,"mp3") == 0){
		return emMP3;
	}
	else if(strcmp(str_type,"dat") == 0){
		return emDAT;
	}
	else{
		return emNone;
	}
}

int sdio_get_space_kb(void) {
	FATFS *pfs;
	DWORD fre_clust, tot_sect, fre_sect, total_kb, free_kb;
	FRESULT res = f_getfree(SDPath, &fre_clust, &pfs);
	if (res != FR_OK)
		return res;

	tot_sect = (pfs->n_fatent - 2) * pfs->csize;
	fre_sect = fre_clust * pfs->csize;
	total_kb = tot_sect / 2;
	free_kb = fre_sect / 2;
	printf("💾 Total: %lu KB, Free: %lu KB\r\n", total_kb, free_kb);
	return FR_OK;
}

int sdio_mount(void) {
	FRESULT res;

	printf("Attempting mount at %s...\r\n", SDPath);
	res = f_mount(&sdio_fs, SDPath, 1);
	if (res == FR_OK) {
		printf("SD card mounted successfully at %s\r\n", SDPath);

		// Capacity and free space reporting
		sdio_get_space_kb();

		// Get Card Info
		BSP_SD_GetCardInfo(&myCardInfo);
		printf("Card Type: %s\r\n", myCardInfo.CardType ? "SDSC" : "SDHC/SDXC");
		printf("Card Version: %s\r\n",
				myCardInfo.CardVersion ? "CARD_V1_X" : "CARD_V2_X");
		printf("Card Class: %lu\r\n", myCardInfo.Class);
		return FR_OK;
	}

	// Any other mount error
	printf("Mount failed with code: %d\r\n", res);
	return res;
}

int sdio_unmount(void) {
	FRESULT res = f_mount(NULL, SDPath, 1);
	printf("SD card unmounted: %s\r\n\r\n\r\n",
			(res == FR_OK) ? "OK" : "Failed");
	return res;
}

int sdio_write_file(const char *filename, const char *text) {
	FIL file;
	UINT bw;
	FRESULT res = f_open(&file, filename, FA_CREATE_ALWAYS | FA_WRITE);
	if (res != FR_OK)
		return res;

	res = f_write(&file, text, strlen(text), &bw);
	f_close(&file);
	printf("Write %u bytes to %s\r\n", bw, filename);
	return (res == FR_OK && bw == strlen(text)) ? FR_OK : FR_DISK_ERR;
}

int sdio_append_file(const char *filename, const char *text) {
	FIL file;
	UINT bw;
	FRESULT res = f_open(&file, filename, FA_OPEN_ALWAYS | FA_WRITE);
	if (res != FR_OK)
		return res;

	res = f_lseek(&file, f_size(&file));
	if (res != FR_OK) {
		f_close(&file);
		return res;
	}

	res = f_write(&file, text, strlen(text), &bw);
	f_close(&file);
	printf("Appended %u bytes to %s\r\n", bw, filename);
	return (res == FR_OK && bw == strlen(text)) ? FR_OK : FR_DISK_ERR;
}

int sdio_read_file(const char *filename, char *buffer, UINT bufsize,
		UINT *bytes_read) {
	FIL file;
	*bytes_read = 0;

	FRESULT res = f_open(&file, filename, FA_READ);
	if (res != FR_OK) {
		printf("f_open failed with code: %d\r\n", res);
		return res;
	}

	res = f_read(&file, buffer, bufsize - 1, bytes_read);
	if (res != FR_OK) {
		printf("f_read failed with code: %d\r\n", res);
		f_close(&file);
		return res;
	}

	buffer[*bytes_read] = '\0';

	res = f_close(&file);
	if (res != FR_OK) {
		printf("f_close failed with code: %d\r\n", res);
		return res;
	}

	printf("Read %u bytes from %s\r\n", *bytes_read, filename);
	return FR_OK;
}

typedef struct CsvRecord {
	char field1[32];
	char field2[32];
	int value;
} CsvRecord;

int sdio_read_csv(const char *filename, CsvRecord *records, int max_records,
		int *record_count) {
	FIL file;
	char line[128];
	*record_count = 0;

	FRESULT res = f_open(&file, filename, FA_READ);
	if (res != FR_OK) {
		printf("Failed to open CSV: %s (%d)", filename, res);
		return res;
	}

	printf("📄 Reading CSV: %s\r\n", filename);
	while (f_gets(line, sizeof(line), &file) && *record_count < max_records) {
		char *token = strtok(line, ",");
		if (!token)
			continue;
		strncpy(records[*record_count].field1, token,
				sizeof(records[*record_count].field1));

		token = strtok(NULL, ",");
		if (!token)
			continue;
		strncpy(records[*record_count].field2, token,
				sizeof(records[*record_count].field2));

		token = strtok(NULL, ",");
		if (token)
			records[*record_count].value = atoi(token);
		else
			records[*record_count].value = 0;

		(*record_count)++;
	}

	f_close(&file);

	// Print parsed data
	for (int i = 0; i < *record_count; i++) {
		printf("[%d] %s | %s | %d", i, records[i].field1, records[i].field2,
				records[i].value);
	}

	return FR_OK;
}

int sdio_delete_file(const char *filename) {
	FRESULT res = f_unlink(filename);
	printf("Delete %s: %s\r\n", filename, (res == FR_OK ? "OK" : "Failed"));
	return res;
}

int sdio_rename_file(const char *oldname, const char *newname) {
	FRESULT res = f_rename(oldname, newname);
	printf("Rename %s to %s: %s\r\n", oldname, newname,
			(res == FR_OK ? "OK" : "Failed"));
	return res;
}

FRESULT sdio_create_directory(const char *path) {
	FRESULT res = f_mkdir(path);
	printf("Create directory %s: %s\r\n", path,
			(res == FR_OK ? "OK" : "Failed"));
	return res;
}

void sdio_list_directory_recursive(const char *path, int depth) {
	DIR dir;
	FILINFO fno;
//	char lfn[256];
//	fno.fname = lfn;
//	fno.fsize = sizeof(lfn);
	uint8_t num_file = 0;
	FRESULT res = f_opendir(&dir, path);
	if (res != FR_OK) {
		printf("%*s[ERR] Cannot open: %s\r\n", depth * 2, "", path);
		return;
	}

	while (1) {
		res = f_readdir(&dir, &fno);
		if (res != FR_OK || fno.fname[0] == 0)
			break;

		const char *name = (*fno.fname) ? fno.fname : fno.fname;

		if (fno.fattrib & AM_DIR) {
			if (strcmp(name, ".") && strcmp(name, "..")) {
				printf("%*s📁 %s\r\n", depth * 2, "", name);
				// File filter
				memcpy(SDFileInMenuList[num_file].name, name, 50);
				SDFileInMenuList[num_file].format = getFileFormat(get_file_extension(SDFileInMenuList[num_file].name));
				char newpath[128];
				snprintf(newpath, sizeof(newpath), "%s/%s", path, name);
				num_file++;
				sdio_list_directory_recursive(newpath, depth + 1);
			}
		} else {
			memcpy(SDFileInMenuList[num_file].name, name, 50);
			SDFileInMenuList[num_file].format = getFileFormat(get_file_extension(SDFileInMenuList[num_file].name));
			printf("%*s📄 %s (%lu bytes)\r\n", depth * 2, "", name,
					(unsigned long) fno.fsize);
			num_file++;
		}

	}
	f_closedir(&dir);
}

void sdio_list_files(SDFile_Info *FileList) {
	SDFileInMenuList = FileList;
	printf("📂 Files on SD Card:\r\n");
	sdio_list_directory_recursive(SDPath, 0);
	printf("\r\n\r\n");
}
