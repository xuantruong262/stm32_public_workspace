################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/widgets/keyboard/lv_keyboard.c 

OBJS += \
./Core/Src/lvgl/src/widgets/keyboard/lv_keyboard.o 

C_DEPS += \
./Core/Src/lvgl/src/widgets/keyboard/lv_keyboard.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/widgets/keyboard/%.o Core/Src/lvgl/src/widgets/keyboard/%.su Core/Src/lvgl/src/widgets/keyboard/%.cyclo: ../Core/Src/lvgl/src/widgets/keyboard/%.c Core/Src/lvgl/src/widgets/keyboard/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-keyboard

clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-keyboard:
	-$(RM) ./Core/Src/lvgl/src/widgets/keyboard/lv_keyboard.cyclo ./Core/Src/lvgl/src/widgets/keyboard/lv_keyboard.d ./Core/Src/lvgl/src/widgets/keyboard/lv_keyboard.o ./Core/Src/lvgl/src/widgets/keyboard/lv_keyboard.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-keyboard

