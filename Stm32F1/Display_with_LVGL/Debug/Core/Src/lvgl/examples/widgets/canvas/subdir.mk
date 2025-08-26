################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_1.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_10.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_11.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_2.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_3.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_4.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_5.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_6.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_7.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_8.c \
../Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_9.c 

OBJS += \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_1.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_10.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_11.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_2.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_3.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_4.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_5.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_6.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_7.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_8.o \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_9.o 

C_DEPS += \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_1.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_10.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_11.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_2.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_3.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_4.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_5.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_6.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_7.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_8.d \
./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_9.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/examples/widgets/canvas/%.o Core/Src/lvgl/examples/widgets/canvas/%.su Core/Src/lvgl/examples/widgets/canvas/%.cyclo: ../Core/Src/lvgl/examples/widgets/canvas/%.c Core/Src/lvgl/examples/widgets/canvas/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-examples-2f-widgets-2f-canvas

clean-Core-2f-Src-2f-lvgl-2f-examples-2f-widgets-2f-canvas:
	-$(RM) ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_1.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_1.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_1.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_1.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_10.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_10.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_10.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_10.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_11.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_11.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_11.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_11.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_2.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_2.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_2.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_2.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_3.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_3.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_3.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_3.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_4.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_4.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_4.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_4.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_5.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_5.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_5.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_5.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_6.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_6.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_6.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_6.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_7.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_7.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_7.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_7.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_8.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_8.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_8.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_8.su ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_9.cyclo ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_9.d ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_9.o ./Core/Src/lvgl/examples/widgets/canvas/lv_example_canvas_9.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-examples-2f-widgets-2f-canvas

