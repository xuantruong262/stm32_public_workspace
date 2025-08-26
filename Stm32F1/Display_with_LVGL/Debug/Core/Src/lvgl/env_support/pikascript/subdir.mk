################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/env_support/pikascript/pika_lv_point_t.c \
../Core/Src/lvgl/env_support/pikascript/pika_lv_timer_t.c \
../Core/Src/lvgl/env_support/pikascript/pika_lv_wegit.c \
../Core/Src/lvgl/env_support/pikascript/pika_lvgl.c \
../Core/Src/lvgl/env_support/pikascript/pika_lvgl_indev_t.c \
../Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_event.c \
../Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_obj.c \
../Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_style_t.c 

OBJS += \
./Core/Src/lvgl/env_support/pikascript/pika_lv_point_t.o \
./Core/Src/lvgl/env_support/pikascript/pika_lv_timer_t.o \
./Core/Src/lvgl/env_support/pikascript/pika_lv_wegit.o \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl.o \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_indev_t.o \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_event.o \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_obj.o \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_style_t.o 

C_DEPS += \
./Core/Src/lvgl/env_support/pikascript/pika_lv_point_t.d \
./Core/Src/lvgl/env_support/pikascript/pika_lv_timer_t.d \
./Core/Src/lvgl/env_support/pikascript/pika_lv_wegit.d \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl.d \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_indev_t.d \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_event.d \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_obj.d \
./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_style_t.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/env_support/pikascript/%.o Core/Src/lvgl/env_support/pikascript/%.su Core/Src/lvgl/env_support/pikascript/%.cyclo: ../Core/Src/lvgl/env_support/pikascript/%.c Core/Src/lvgl/env_support/pikascript/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-env_support-2f-pikascript

clean-Core-2f-Src-2f-lvgl-2f-env_support-2f-pikascript:
	-$(RM) ./Core/Src/lvgl/env_support/pikascript/pika_lv_point_t.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lv_point_t.d ./Core/Src/lvgl/env_support/pikascript/pika_lv_point_t.o ./Core/Src/lvgl/env_support/pikascript/pika_lv_point_t.su ./Core/Src/lvgl/env_support/pikascript/pika_lv_timer_t.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lv_timer_t.d ./Core/Src/lvgl/env_support/pikascript/pika_lv_timer_t.o ./Core/Src/lvgl/env_support/pikascript/pika_lv_timer_t.su ./Core/Src/lvgl/env_support/pikascript/pika_lv_wegit.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lv_wegit.d ./Core/Src/lvgl/env_support/pikascript/pika_lv_wegit.o ./Core/Src/lvgl/env_support/pikascript/pika_lv_wegit.su ./Core/Src/lvgl/env_support/pikascript/pika_lvgl.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lvgl.d ./Core/Src/lvgl/env_support/pikascript/pika_lvgl.o ./Core/Src/lvgl/env_support/pikascript/pika_lvgl.su ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_indev_t.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_indev_t.d ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_indev_t.o ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_indev_t.su ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_event.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_event.d ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_event.o ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_event.su ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_obj.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_obj.d ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_obj.o ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_obj.su ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_style_t.cyclo ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_style_t.d ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_style_t.o ./Core/Src/lvgl/env_support/pikascript/pika_lvgl_lv_style_t.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-env_support-2f-pikascript

