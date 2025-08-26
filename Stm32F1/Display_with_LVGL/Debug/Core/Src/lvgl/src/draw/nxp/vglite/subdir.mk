################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_buf_vglite.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_arc.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_border.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_fill.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_img.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_label.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_layer.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_line.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_triangle.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_buf.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_matrix.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_path.c \
../Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_utils.c 

OBJS += \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_buf_vglite.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_arc.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_border.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_fill.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_img.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_label.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_layer.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_line.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_triangle.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_buf.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_matrix.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_path.o \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_utils.o 

C_DEPS += \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_buf_vglite.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_arc.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_border.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_fill.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_img.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_label.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_layer.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_line.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_triangle.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_buf.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_matrix.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_path.d \
./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_utils.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/draw/nxp/vglite/%.o Core/Src/lvgl/src/draw/nxp/vglite/%.su Core/Src/lvgl/src/draw/nxp/vglite/%.cyclo: ../Core/Src/lvgl/src/draw/nxp/vglite/%.c Core/Src/lvgl/src/draw/nxp/vglite/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-nxp-2f-vglite

clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-nxp-2f-vglite:
	-$(RM) ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_buf_vglite.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_buf_vglite.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_buf_vglite.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_buf_vglite.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_arc.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_arc.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_arc.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_arc.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_border.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_border.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_border.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_border.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_fill.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_fill.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_fill.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_fill.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_img.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_img.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_img.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_img.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_label.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_label.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_label.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_label.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_layer.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_layer.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_layer.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_layer.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_line.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_line.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_line.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_line.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_triangle.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_triangle.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_triangle.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_draw_vglite_triangle.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_buf.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_buf.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_buf.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_buf.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_matrix.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_matrix.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_matrix.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_matrix.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_path.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_path.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_path.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_path.su ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_utils.cyclo ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_utils.d ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_utils.o ./Core/Src/lvgl/src/draw/nxp/vglite/lv_vglite_utils.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-nxp-2f-vglite

