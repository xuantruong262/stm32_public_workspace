################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A1_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A2_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A4_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A8_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_ARGB8888_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I1_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I2_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I4_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I8_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_L8_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565A8_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB888_RLE_align1.c \
../Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_XRGB8888_RLE_align1.c 

OBJS += \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A1_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A2_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A4_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A8_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_ARGB8888_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I1_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I2_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I4_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I8_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_L8_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565A8_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB888_RLE_align1.o \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_XRGB8888_RLE_align1.o 

C_DEPS += \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A1_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A2_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A4_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A8_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_ARGB8888_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I1_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I2_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I4_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I8_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_L8_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565A8_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB888_RLE_align1.d \
./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_XRGB8888_RLE_align1.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/tests/test_images/stride_align1/RLE/%.o Core/Src/lvgl/tests/test_images/stride_align1/RLE/%.su Core/Src/lvgl/tests/test_images/stride_align1/RLE/%.cyclo: ../Core/Src/lvgl/tests/test_images/stride_align1/RLE/%.c Core/Src/lvgl/tests/test_images/stride_align1/RLE/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-tests-2f-test_images-2f-stride_align1-2f-RLE

clean-Core-2f-Src-2f-lvgl-2f-tests-2f-test_images-2f-stride_align1-2f-RLE:
	-$(RM) ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A1_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A1_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A1_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A1_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A2_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A2_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A2_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A2_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A4_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A4_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A4_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A4_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A8_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A8_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A8_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_A8_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_ARGB8888_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_ARGB8888_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_ARGB8888_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_ARGB8888_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I1_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I1_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I1_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I1_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I2_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I2_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I2_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I2_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I4_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I4_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I4_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I4_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I8_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I8_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I8_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_I8_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_L8_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_L8_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_L8_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_L8_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565A8_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565A8_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565A8_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565A8_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB565_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB888_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB888_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB888_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_RGB888_RLE_align1.su ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_XRGB8888_RLE_align1.cyclo ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_XRGB8888_RLE_align1.d ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_XRGB8888_RLE_align1.o ./Core/Src/lvgl/tests/test_images/stride_align1/RLE/test_XRGB8888_RLE_align1.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-tests-2f-test_images-2f-stride_align1-2f-RLE

