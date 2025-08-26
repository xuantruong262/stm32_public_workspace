################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_arc.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_border.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_fill.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_image.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_label.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_line.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_mask_rectangle.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_triangle.c \
../Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_utils.c 

OBJS += \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_arc.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_border.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_fill.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_image.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_label.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_line.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_mask_rectangle.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_triangle.o \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_utils.o 

C_DEPS += \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_arc.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_border.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_fill.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_image.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_label.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_line.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_mask_rectangle.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_triangle.d \
./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_utils.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/draw/renesas/dave2d/%.o Core/Src/lvgl/src/draw/renesas/dave2d/%.su Core/Src/lvgl/src/draw/renesas/dave2d/%.cyclo: ../Core/Src/lvgl/src/draw/renesas/dave2d/%.c Core/Src/lvgl/src/draw/renesas/dave2d/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-renesas-2f-dave2d

clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-renesas-2f-dave2d:
	-$(RM) ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_arc.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_arc.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_arc.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_arc.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_border.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_border.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_border.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_border.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_fill.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_fill.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_fill.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_fill.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_image.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_image.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_image.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_image.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_label.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_label.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_label.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_label.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_line.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_line.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_line.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_line.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_mask_rectangle.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_mask_rectangle.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_mask_rectangle.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_mask_rectangle.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_triangle.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_triangle.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_triangle.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_triangle.su ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_utils.cyclo ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_utils.d ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_utils.o ./Core/Src/lvgl/src/draw/renesas/dave2d/lv_draw_dave2d_utils.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-renesas-2f-dave2d

