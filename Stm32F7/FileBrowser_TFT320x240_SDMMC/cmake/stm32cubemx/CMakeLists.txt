cmake_minimum_required(VERSION 3.22)
# Enable CMake support for ASM and C languages
enable_language(C ASM)
# STM32CubeMX generated symbols (macros)
set(MX_Defines_Syms 
	USE_PWR_LDO_SUPPLY 
	USE_HAL_DRIVER 
	STM32H723xx
    $<$<CONFIG:Debug>:DEBUG>
)

# STM32CubeMX generated include paths
set(MX_Include_Dirs
    ${CMAKE_CURRENT_SOURCE_DIR}/../../FATFS/Target
    ${CMAKE_CURRENT_SOURCE_DIR}/../../FATFS/App
    ${CMAKE_CURRENT_SOURCE_DIR}/../../LIBJPEG/App
    ${CMAKE_CURRENT_SOURCE_DIR}/../../LIBJPEG/Target
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Inc/Legacy
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FatFs/src
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/CMSIS/Device/ST/STM32H7xx/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/CMSIS/Include
)

# STM32CubeMX generated application sources
set(MX_Application_Src
    ${CMAKE_CURRENT_SOURCE_DIR}/../../LIBJPEG/Target/jdata_conf.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../LIBJPEG/App/libjpeg.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../FATFS/App/fatfs.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../FATFS/Target/bsp_driver_sd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../FATFS/Target/sd_diskio.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../FATFS/Target/user_diskio.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Src/main.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Src/stm32h7xx_it.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Src/stm32h7xx_hal_msp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Src/sysmem.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Src/syscalls.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../startup_stm32h723xx.s
)

# STM32 HAL/LL Drivers
set(STM32_Drivers_Src
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Src/system_stm32h7xx.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_cortex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_flash.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_flash_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_gpio.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_hsem.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_dma.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_dma_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_mdma.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_i2c.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_i2c_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_exti.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_i2s.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_i2s_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_ll_sdmmc.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_ll_delayblock.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_sd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_sd_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_mmc.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_mmc_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_spi.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_spi_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_tim.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_tim_ex.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_uart.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_uart_ex.c
)

# Drivers Midllewares


set(LibJPEG_Src
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcapimin.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcapistd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdapimin.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdapistd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcomapi.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcparam.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jctrans.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdtrans.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcinit.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcmaster.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcmainct.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcprepct.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jccoefct.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jccolor.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcsample.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcdctmgr.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jfdctint.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jfdctfst.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jfdctflt.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jchuff.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcarith.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jcmarker.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdatadst.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdmaster.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdinput.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdmainct.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdcoefct.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdpostct.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdmarker.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdhuff.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdarith.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jddctmgr.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jidctint.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jidctfst.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jidctflt.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdsample.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdcolor.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdmerge.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jquant1.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jquant2.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jdatasrc.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jaricom.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jerror.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jmemmgr.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jutils.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LibJPEG/source/jmemnobs.c
)
set(FatFs_Src
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FatFs/src/diskio.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FatFs/src/ff.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FatFs/src/ff_gen_drv.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FatFs/src/option/syscall.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FatFs/src/option/ccsbcs.c
)

# Link directories setup
set(MX_LINK_DIRS

)
# Project static libraries
set(MX_LINK_LIBS 
    STM32_Drivers
    ${TOOLCHAIN_LINK_LIBRARIES}
    LibJPEG	FatFs	
)
# Interface library for includes and symbols
add_library(stm32cubemx INTERFACE)
target_include_directories(stm32cubemx INTERFACE ${MX_Include_Dirs})
target_compile_definitions(stm32cubemx INTERFACE ${MX_Defines_Syms})

# Create STM32_Drivers static library
add_library(STM32_Drivers OBJECT)
target_sources(STM32_Drivers PRIVATE ${STM32_Drivers_Src})
target_link_libraries(STM32_Drivers PUBLIC stm32cubemx)


# Create LibJPEG static library
add_library(LibJPEG OBJECT)
target_sources(LibJPEG PRIVATE ${LibJPEG_Src})
target_link_libraries(LibJPEG PUBLIC stm32cubemx)

# Create FatFs static library
add_library(FatFs OBJECT)
target_sources(FatFs PRIVATE ${FatFs_Src})
target_link_libraries(FatFs PUBLIC stm32cubemx)

# Add STM32CubeMX generated application sources to the project
target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${MX_Application_Src})

# Link directories setup
target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE ${MX_LINK_DIRS})

# Add libraries to the project
target_link_libraries(${CMAKE_PROJECT_NAME} ${MX_LINK_LIBS})

# Add the map file to the list of files to be removed with 'clean' target
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES ADDITIONAL_CLEAN_FILES ${CMAKE_PROJECT_NAME}.map)

# Validate that STM32CubeMX code is compatible with C standard
if((CMAKE_C_STANDARD EQUAL 90) OR (CMAKE_C_STANDARD EQUAL 99))
    message(ERROR "Generated code requires C11 or higher")
endif()
