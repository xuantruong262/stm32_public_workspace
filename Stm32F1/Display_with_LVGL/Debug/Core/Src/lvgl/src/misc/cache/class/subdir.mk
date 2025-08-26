################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_ll.c \
../Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_rb.c \
../Core/Src/lvgl/src/misc/cache/class/lv_cache_sc_da.c 

OBJS += \
./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_ll.o \
./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_rb.o \
./Core/Src/lvgl/src/misc/cache/class/lv_cache_sc_da.o 

C_DEPS += \
./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_ll.d \
./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_rb.d \
./Core/Src/lvgl/src/misc/cache/class/lv_cache_sc_da.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/misc/cache/class/%.o Core/Src/lvgl/src/misc/cache/class/%.su Core/Src/lvgl/src/misc/cache/class/%.cyclo: ../Core/Src/lvgl/src/misc/cache/class/%.c Core/Src/lvgl/src/misc/cache/class/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-misc-2f-cache-2f-class

clean-Core-2f-Src-2f-lvgl-2f-src-2f-misc-2f-cache-2f-class:
	-$(RM) ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_ll.cyclo ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_ll.d ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_ll.o ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_ll.su ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_rb.cyclo ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_rb.d ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_rb.o ./Core/Src/lvgl/src/misc/cache/class/lv_cache_lru_rb.su ./Core/Src/lvgl/src/misc/cache/class/lv_cache_sc_da.cyclo ./Core/Src/lvgl/src/misc/cache/class/lv_cache_sc_da.d ./Core/Src/lvgl/src/misc/cache/class/lv_cache_sc_da.o ./Core/Src/lvgl/src/misc/cache/class/lv_cache_sc_da.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-misc-2f-cache-2f-class

