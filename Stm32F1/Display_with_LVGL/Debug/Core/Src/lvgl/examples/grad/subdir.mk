################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/examples/grad/lv_example_grad_1.c \
../Core/Src/lvgl/examples/grad/lv_example_grad_2.c \
../Core/Src/lvgl/examples/grad/lv_example_grad_3.c \
../Core/Src/lvgl/examples/grad/lv_example_grad_4.c 

OBJS += \
./Core/Src/lvgl/examples/grad/lv_example_grad_1.o \
./Core/Src/lvgl/examples/grad/lv_example_grad_2.o \
./Core/Src/lvgl/examples/grad/lv_example_grad_3.o \
./Core/Src/lvgl/examples/grad/lv_example_grad_4.o 

C_DEPS += \
./Core/Src/lvgl/examples/grad/lv_example_grad_1.d \
./Core/Src/lvgl/examples/grad/lv_example_grad_2.d \
./Core/Src/lvgl/examples/grad/lv_example_grad_3.d \
./Core/Src/lvgl/examples/grad/lv_example_grad_4.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/examples/grad/%.o Core/Src/lvgl/examples/grad/%.su Core/Src/lvgl/examples/grad/%.cyclo: ../Core/Src/lvgl/examples/grad/%.c Core/Src/lvgl/examples/grad/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-examples-2f-grad

clean-Core-2f-Src-2f-lvgl-2f-examples-2f-grad:
	-$(RM) ./Core/Src/lvgl/examples/grad/lv_example_grad_1.cyclo ./Core/Src/lvgl/examples/grad/lv_example_grad_1.d ./Core/Src/lvgl/examples/grad/lv_example_grad_1.o ./Core/Src/lvgl/examples/grad/lv_example_grad_1.su ./Core/Src/lvgl/examples/grad/lv_example_grad_2.cyclo ./Core/Src/lvgl/examples/grad/lv_example_grad_2.d ./Core/Src/lvgl/examples/grad/lv_example_grad_2.o ./Core/Src/lvgl/examples/grad/lv_example_grad_2.su ./Core/Src/lvgl/examples/grad/lv_example_grad_3.cyclo ./Core/Src/lvgl/examples/grad/lv_example_grad_3.d ./Core/Src/lvgl/examples/grad/lv_example_grad_3.o ./Core/Src/lvgl/examples/grad/lv_example_grad_3.su ./Core/Src/lvgl/examples/grad/lv_example_grad_4.cyclo ./Core/Src/lvgl/examples/grad/lv_example_grad_4.d ./Core/Src/lvgl/examples/grad/lv_example_grad_4.o ./Core/Src/lvgl/examples/grad/lv_example_grad_4.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-examples-2f-grad

