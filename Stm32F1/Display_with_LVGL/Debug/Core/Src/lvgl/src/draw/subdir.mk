################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/draw/lv_draw.c \
../Core/Src/lvgl/src/draw/lv_draw_3d.c \
../Core/Src/lvgl/src/draw/lv_draw_arc.c \
../Core/Src/lvgl/src/draw/lv_draw_buf.c \
../Core/Src/lvgl/src/draw/lv_draw_image.c \
../Core/Src/lvgl/src/draw/lv_draw_label.c \
../Core/Src/lvgl/src/draw/lv_draw_line.c \
../Core/Src/lvgl/src/draw/lv_draw_mask.c \
../Core/Src/lvgl/src/draw/lv_draw_rect.c \
../Core/Src/lvgl/src/draw/lv_draw_triangle.c \
../Core/Src/lvgl/src/draw/lv_draw_vector.c \
../Core/Src/lvgl/src/draw/lv_image_decoder.c 

OBJS += \
./Core/Src/lvgl/src/draw/lv_draw.o \
./Core/Src/lvgl/src/draw/lv_draw_3d.o \
./Core/Src/lvgl/src/draw/lv_draw_arc.o \
./Core/Src/lvgl/src/draw/lv_draw_buf.o \
./Core/Src/lvgl/src/draw/lv_draw_image.o \
./Core/Src/lvgl/src/draw/lv_draw_label.o \
./Core/Src/lvgl/src/draw/lv_draw_line.o \
./Core/Src/lvgl/src/draw/lv_draw_mask.o \
./Core/Src/lvgl/src/draw/lv_draw_rect.o \
./Core/Src/lvgl/src/draw/lv_draw_triangle.o \
./Core/Src/lvgl/src/draw/lv_draw_vector.o \
./Core/Src/lvgl/src/draw/lv_image_decoder.o 

C_DEPS += \
./Core/Src/lvgl/src/draw/lv_draw.d \
./Core/Src/lvgl/src/draw/lv_draw_3d.d \
./Core/Src/lvgl/src/draw/lv_draw_arc.d \
./Core/Src/lvgl/src/draw/lv_draw_buf.d \
./Core/Src/lvgl/src/draw/lv_draw_image.d \
./Core/Src/lvgl/src/draw/lv_draw_label.d \
./Core/Src/lvgl/src/draw/lv_draw_line.d \
./Core/Src/lvgl/src/draw/lv_draw_mask.d \
./Core/Src/lvgl/src/draw/lv_draw_rect.d \
./Core/Src/lvgl/src/draw/lv_draw_triangle.d \
./Core/Src/lvgl/src/draw/lv_draw_vector.d \
./Core/Src/lvgl/src/draw/lv_image_decoder.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/draw/%.o Core/Src/lvgl/src/draw/%.su Core/Src/lvgl/src/draw/%.cyclo: ../Core/Src/lvgl/src/draw/%.c Core/Src/lvgl/src/draw/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw

clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw:
	-$(RM) ./Core/Src/lvgl/src/draw/lv_draw.cyclo ./Core/Src/lvgl/src/draw/lv_draw.d ./Core/Src/lvgl/src/draw/lv_draw.o ./Core/Src/lvgl/src/draw/lv_draw.su ./Core/Src/lvgl/src/draw/lv_draw_3d.cyclo ./Core/Src/lvgl/src/draw/lv_draw_3d.d ./Core/Src/lvgl/src/draw/lv_draw_3d.o ./Core/Src/lvgl/src/draw/lv_draw_3d.su ./Core/Src/lvgl/src/draw/lv_draw_arc.cyclo ./Core/Src/lvgl/src/draw/lv_draw_arc.d ./Core/Src/lvgl/src/draw/lv_draw_arc.o ./Core/Src/lvgl/src/draw/lv_draw_arc.su ./Core/Src/lvgl/src/draw/lv_draw_buf.cyclo ./Core/Src/lvgl/src/draw/lv_draw_buf.d ./Core/Src/lvgl/src/draw/lv_draw_buf.o ./Core/Src/lvgl/src/draw/lv_draw_buf.su ./Core/Src/lvgl/src/draw/lv_draw_image.cyclo ./Core/Src/lvgl/src/draw/lv_draw_image.d ./Core/Src/lvgl/src/draw/lv_draw_image.o ./Core/Src/lvgl/src/draw/lv_draw_image.su ./Core/Src/lvgl/src/draw/lv_draw_label.cyclo ./Core/Src/lvgl/src/draw/lv_draw_label.d ./Core/Src/lvgl/src/draw/lv_draw_label.o ./Core/Src/lvgl/src/draw/lv_draw_label.su ./Core/Src/lvgl/src/draw/lv_draw_line.cyclo ./Core/Src/lvgl/src/draw/lv_draw_line.d ./Core/Src/lvgl/src/draw/lv_draw_line.o ./Core/Src/lvgl/src/draw/lv_draw_line.su ./Core/Src/lvgl/src/draw/lv_draw_mask.cyclo ./Core/Src/lvgl/src/draw/lv_draw_mask.d ./Core/Src/lvgl/src/draw/lv_draw_mask.o ./Core/Src/lvgl/src/draw/lv_draw_mask.su ./Core/Src/lvgl/src/draw/lv_draw_rect.cyclo ./Core/Src/lvgl/src/draw/lv_draw_rect.d ./Core/Src/lvgl/src/draw/lv_draw_rect.o ./Core/Src/lvgl/src/draw/lv_draw_rect.su ./Core/Src/lvgl/src/draw/lv_draw_triangle.cyclo ./Core/Src/lvgl/src/draw/lv_draw_triangle.d ./Core/Src/lvgl/src/draw/lv_draw_triangle.o ./Core/Src/lvgl/src/draw/lv_draw_triangle.su ./Core/Src/lvgl/src/draw/lv_draw_vector.cyclo ./Core/Src/lvgl/src/draw/lv_draw_vector.d ./Core/Src/lvgl/src/draw/lv_draw_vector.o ./Core/Src/lvgl/src/draw/lv_draw_vector.su ./Core/Src/lvgl/src/draw/lv_image_decoder.cyclo ./Core/Src/lvgl/src/draw/lv_image_decoder.d ./Core/Src/lvgl/src/draw/lv_image_decoder.o ./Core/Src/lvgl/src/draw/lv_image_decoder.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw

