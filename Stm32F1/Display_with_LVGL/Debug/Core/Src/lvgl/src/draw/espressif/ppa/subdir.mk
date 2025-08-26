################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa.c \
../Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_buf.c \
../Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_fill.c \
../Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_img.c 

OBJS += \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa.o \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_buf.o \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_fill.o \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_img.o 

C_DEPS += \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa.d \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_buf.d \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_fill.d \
./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_img.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/draw/espressif/ppa/%.o Core/Src/lvgl/src/draw/espressif/ppa/%.su Core/Src/lvgl/src/draw/espressif/ppa/%.cyclo: ../Core/Src/lvgl/src/draw/espressif/ppa/%.c Core/Src/lvgl/src/draw/espressif/ppa/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-espressif-2f-ppa

clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-espressif-2f-ppa:
	-$(RM) ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa.cyclo ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa.d ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa.o ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa.su ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_buf.cyclo ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_buf.d ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_buf.o ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_buf.su ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_fill.cyclo ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_fill.d ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_fill.o ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_fill.su ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_img.cyclo ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_img.d ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_img.o ./Core/Src/lvgl/src/draw/espressif/ppa/lv_draw_ppa_img.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-espressif-2f-ppa

