################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/widgets/spinbox/lv_spinbox.c 

OBJS += \
./Core/Src/lvgl/src/widgets/spinbox/lv_spinbox.o 

C_DEPS += \
./Core/Src/lvgl/src/widgets/spinbox/lv_spinbox.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/widgets/spinbox/%.o Core/Src/lvgl/src/widgets/spinbox/%.su Core/Src/lvgl/src/widgets/spinbox/%.cyclo: ../Core/Src/lvgl/src/widgets/spinbox/%.c Core/Src/lvgl/src/widgets/spinbox/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-spinbox

clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-spinbox:
	-$(RM) ./Core/Src/lvgl/src/widgets/spinbox/lv_spinbox.cyclo ./Core/Src/lvgl/src/widgets/spinbox/lv_spinbox.d ./Core/Src/lvgl/src/widgets/spinbox/lv_spinbox.o ./Core/Src/lvgl/src/widgets/spinbox/lv_spinbox.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-spinbox

