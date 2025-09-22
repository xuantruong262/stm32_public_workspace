/******************************************************************************
 *  File        : sd_functions.h
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

#ifndef __SDIO_FUNCTIONS_H__
#define __SDIO_FUNCTIONS_H__

#include "fatfs.h"
#include <stdint.h>

//Sd file browser
typedef enum eSDFileFormat
{
    emSdJPG,
    emSdBMP,
    emSdWAV,
    emSdRGB,
	emSdAVI,
	emSdMP3,
    emSdDAT,
	emSdFolder,
	emSdFile,
    emSdNone
} eSDFileFormat;

typedef struct SDFile_Info
{
    char name[50];
    eSDFileFormat format;
    struct SDFile_Info *Directory_Ptr;
    struct SDFile_Info *Previous_Ptr;
    int childCount;
    uint32_t size;
} SDFile_Info;

// Mount and unmount
int sdio_mount(void);
int sdio_unmount(void);

// Basic file operations
int sdio_write_file(const char *filename, const char *text);
int sdio_append_file(const char *filename, const char *text);
int sdio_read_file(const char *filename, char *buffer, UINT bufsize, UINT *bytes_read);
int sdio_delete_file(const char *filename);
int sdio_rename_file(const char *oldname, const char *newname);
int print_directory(SDFile_Info *dir, int depth, int count);

// Directory handling
FRESULT sdio_create_directory(const char *path);
void sdio_list_directory_recursive(const char *path, int depth, SDFile_Info ** directory);
void sdio_list_files(SDFile_Info *FileList);
int find_file_recursive(SDFile_Info *dir, int count, const char *target, char *outPath, const char *parent);
void Move2Folder(SDFile_Info **Current_Page, SDFile_Info Des_Folder,char *path);
void Back2PrevFolder(SDFile_Info **Current_Page, SDFile_Info *Root ,char *path);
void TrimPath(char *path);
void AddPath(char *path, char*next_path);
// Space information
int sdio_get_space_kb(void);

//csv File operations
// CSV Record structure
typedef struct CsvRecord {
    char field1[32];
    char field2[32];
    int value;
} CsvRecord;

// CSV reader (caller defines record array)
int sdio_read_csv(const char *filename, CsvRecord *records, int max_records, int *record_count);

#endif // __SD_FUNCTIONS_H__
