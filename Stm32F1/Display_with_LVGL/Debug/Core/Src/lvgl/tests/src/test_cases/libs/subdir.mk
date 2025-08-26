################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/tests/src/test_cases/libs/test_barcode.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_bin_decoder.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_bmp.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_ffmpeg.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_font_stress.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_freetype.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_libjpeg_turbo.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_libpng.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_lodepng.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_memmove.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_qrcode.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_svg_decoder.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_tiny_ttf.c \
../Core/Src/lvgl/tests/src/test_cases/libs/test_tjpgd.c 

OBJS += \
./Core/Src/lvgl/tests/src/test_cases/libs/test_barcode.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_bin_decoder.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_bmp.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_ffmpeg.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_font_stress.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_freetype.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_libjpeg_turbo.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_libpng.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_lodepng.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_memmove.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_qrcode.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_svg_decoder.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_tiny_ttf.o \
./Core/Src/lvgl/tests/src/test_cases/libs/test_tjpgd.o 

C_DEPS += \
./Core/Src/lvgl/tests/src/test_cases/libs/test_barcode.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_bin_decoder.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_bmp.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_ffmpeg.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_font_stress.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_freetype.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_libjpeg_turbo.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_libpng.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_lodepng.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_memmove.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_qrcode.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_svg_decoder.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_tiny_ttf.d \
./Core/Src/lvgl/tests/src/test_cases/libs/test_tjpgd.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/tests/src/test_cases/libs/%.o Core/Src/lvgl/tests/src/test_cases/libs/%.su Core/Src/lvgl/tests/src/test_cases/libs/%.cyclo: ../Core/Src/lvgl/tests/src/test_cases/libs/%.c Core/Src/lvgl/tests/src/test_cases/libs/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-tests-2f-src-2f-test_cases-2f-libs

clean-Core-2f-Src-2f-lvgl-2f-tests-2f-src-2f-test_cases-2f-libs:
	-$(RM) ./Core/Src/lvgl/tests/src/test_cases/libs/test_barcode.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_barcode.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_barcode.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_barcode.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_bin_decoder.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_bin_decoder.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_bin_decoder.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_bin_decoder.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_bmp.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_bmp.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_bmp.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_bmp.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_ffmpeg.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_ffmpeg.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_ffmpeg.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_ffmpeg.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_font_stress.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_font_stress.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_font_stress.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_font_stress.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_freetype.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_freetype.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_freetype.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_freetype.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_libjpeg_turbo.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_libjpeg_turbo.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_libjpeg_turbo.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_libjpeg_turbo.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_libpng.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_libpng.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_libpng.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_libpng.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_lodepng.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_lodepng.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_lodepng.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_lodepng.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_memmove.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_memmove.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_memmove.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_memmove.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_qrcode.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_qrcode.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_qrcode.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_qrcode.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_svg_decoder.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_svg_decoder.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_svg_decoder.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_svg_decoder.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_tiny_ttf.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_tiny_ttf.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_tiny_ttf.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_tiny_ttf.su ./Core/Src/lvgl/tests/src/test_cases/libs/test_tjpgd.cyclo ./Core/Src/lvgl/tests/src/test_cases/libs/test_tjpgd.d ./Core/Src/lvgl/tests/src/test_cases/libs/test_tjpgd.o ./Core/Src/lvgl/tests/src/test_cases/libs/test_tjpgd.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-tests-2f-src-2f-test_cases-2f-libs

