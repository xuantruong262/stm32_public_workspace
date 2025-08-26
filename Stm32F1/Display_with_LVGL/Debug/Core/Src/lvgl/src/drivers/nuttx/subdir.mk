################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_cache.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_entry.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_fbdev.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_image_cache.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_lcd.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_libuv.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_mouse.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_profiler.c \
../Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_touchscreen.c 

OBJS += \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_cache.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_entry.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_fbdev.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_image_cache.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_lcd.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_libuv.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_mouse.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_profiler.o \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_touchscreen.o 

C_DEPS += \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_cache.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_entry.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_fbdev.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_image_cache.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_lcd.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_libuv.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_mouse.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_profiler.d \
./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_touchscreen.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/drivers/nuttx/%.o Core/Src/lvgl/src/drivers/nuttx/%.su Core/Src/lvgl/src/drivers/nuttx/%.cyclo: ../Core/Src/lvgl/src/drivers/nuttx/%.c Core/Src/lvgl/src/drivers/nuttx/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-drivers-2f-nuttx

clean-Core-2f-Src-2f-lvgl-2f-src-2f-drivers-2f-nuttx:
	-$(RM) ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_cache.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_cache.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_cache.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_cache.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_entry.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_entry.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_entry.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_entry.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_fbdev.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_fbdev.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_fbdev.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_fbdev.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_image_cache.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_image_cache.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_image_cache.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_image_cache.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_lcd.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_lcd.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_lcd.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_lcd.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_libuv.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_libuv.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_libuv.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_libuv.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_mouse.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_mouse.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_mouse.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_mouse.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_profiler.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_profiler.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_profiler.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_profiler.su ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_touchscreen.cyclo ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_touchscreen.d ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_touchscreen.o ./Core/Src/lvgl/src/drivers/nuttx/lv_nuttx_touchscreen.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-drivers-2f-nuttx

