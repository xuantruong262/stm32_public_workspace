################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/examples/assets/animimg001.c \
../Core/Src/lvgl/examples/assets/animimg002.c \
../Core/Src/lvgl/examples/assets/animimg003.c \
../Core/Src/lvgl/examples/assets/img_caret_down.c \
../Core/Src/lvgl/examples/assets/img_cogwheel_argb.c \
../Core/Src/lvgl/examples/assets/img_cogwheel_indexed16.c \
../Core/Src/lvgl/examples/assets/img_cogwheel_rgb.c \
../Core/Src/lvgl/examples/assets/img_hand.c \
../Core/Src/lvgl/examples/assets/img_skew_strip.c \
../Core/Src/lvgl/examples/assets/img_star.c \
../Core/Src/lvgl/examples/assets/img_svg_img.c \
../Core/Src/lvgl/examples/assets/imgbtn_left.c \
../Core/Src/lvgl/examples/assets/imgbtn_mid.c \
../Core/Src/lvgl/examples/assets/imgbtn_right.c 

OBJS += \
./Core/Src/lvgl/examples/assets/animimg001.o \
./Core/Src/lvgl/examples/assets/animimg002.o \
./Core/Src/lvgl/examples/assets/animimg003.o \
./Core/Src/lvgl/examples/assets/img_caret_down.o \
./Core/Src/lvgl/examples/assets/img_cogwheel_argb.o \
./Core/Src/lvgl/examples/assets/img_cogwheel_indexed16.o \
./Core/Src/lvgl/examples/assets/img_cogwheel_rgb.o \
./Core/Src/lvgl/examples/assets/img_hand.o \
./Core/Src/lvgl/examples/assets/img_skew_strip.o \
./Core/Src/lvgl/examples/assets/img_star.o \
./Core/Src/lvgl/examples/assets/img_svg_img.o \
./Core/Src/lvgl/examples/assets/imgbtn_left.o \
./Core/Src/lvgl/examples/assets/imgbtn_mid.o \
./Core/Src/lvgl/examples/assets/imgbtn_right.o 

C_DEPS += \
./Core/Src/lvgl/examples/assets/animimg001.d \
./Core/Src/lvgl/examples/assets/animimg002.d \
./Core/Src/lvgl/examples/assets/animimg003.d \
./Core/Src/lvgl/examples/assets/img_caret_down.d \
./Core/Src/lvgl/examples/assets/img_cogwheel_argb.d \
./Core/Src/lvgl/examples/assets/img_cogwheel_indexed16.d \
./Core/Src/lvgl/examples/assets/img_cogwheel_rgb.d \
./Core/Src/lvgl/examples/assets/img_hand.d \
./Core/Src/lvgl/examples/assets/img_skew_strip.d \
./Core/Src/lvgl/examples/assets/img_star.d \
./Core/Src/lvgl/examples/assets/img_svg_img.d \
./Core/Src/lvgl/examples/assets/imgbtn_left.d \
./Core/Src/lvgl/examples/assets/imgbtn_mid.d \
./Core/Src/lvgl/examples/assets/imgbtn_right.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/examples/assets/%.o Core/Src/lvgl/examples/assets/%.su Core/Src/lvgl/examples/assets/%.cyclo: ../Core/Src/lvgl/examples/assets/%.c Core/Src/lvgl/examples/assets/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-examples-2f-assets

clean-Core-2f-Src-2f-lvgl-2f-examples-2f-assets:
	-$(RM) ./Core/Src/lvgl/examples/assets/animimg001.cyclo ./Core/Src/lvgl/examples/assets/animimg001.d ./Core/Src/lvgl/examples/assets/animimg001.o ./Core/Src/lvgl/examples/assets/animimg001.su ./Core/Src/lvgl/examples/assets/animimg002.cyclo ./Core/Src/lvgl/examples/assets/animimg002.d ./Core/Src/lvgl/examples/assets/animimg002.o ./Core/Src/lvgl/examples/assets/animimg002.su ./Core/Src/lvgl/examples/assets/animimg003.cyclo ./Core/Src/lvgl/examples/assets/animimg003.d ./Core/Src/lvgl/examples/assets/animimg003.o ./Core/Src/lvgl/examples/assets/animimg003.su ./Core/Src/lvgl/examples/assets/img_caret_down.cyclo ./Core/Src/lvgl/examples/assets/img_caret_down.d ./Core/Src/lvgl/examples/assets/img_caret_down.o ./Core/Src/lvgl/examples/assets/img_caret_down.su ./Core/Src/lvgl/examples/assets/img_cogwheel_argb.cyclo ./Core/Src/lvgl/examples/assets/img_cogwheel_argb.d ./Core/Src/lvgl/examples/assets/img_cogwheel_argb.o ./Core/Src/lvgl/examples/assets/img_cogwheel_argb.su ./Core/Src/lvgl/examples/assets/img_cogwheel_indexed16.cyclo ./Core/Src/lvgl/examples/assets/img_cogwheel_indexed16.d ./Core/Src/lvgl/examples/assets/img_cogwheel_indexed16.o ./Core/Src/lvgl/examples/assets/img_cogwheel_indexed16.su ./Core/Src/lvgl/examples/assets/img_cogwheel_rgb.cyclo ./Core/Src/lvgl/examples/assets/img_cogwheel_rgb.d ./Core/Src/lvgl/examples/assets/img_cogwheel_rgb.o ./Core/Src/lvgl/examples/assets/img_cogwheel_rgb.su ./Core/Src/lvgl/examples/assets/img_hand.cyclo ./Core/Src/lvgl/examples/assets/img_hand.d ./Core/Src/lvgl/examples/assets/img_hand.o ./Core/Src/lvgl/examples/assets/img_hand.su ./Core/Src/lvgl/examples/assets/img_skew_strip.cyclo ./Core/Src/lvgl/examples/assets/img_skew_strip.d ./Core/Src/lvgl/examples/assets/img_skew_strip.o ./Core/Src/lvgl/examples/assets/img_skew_strip.su ./Core/Src/lvgl/examples/assets/img_star.cyclo ./Core/Src/lvgl/examples/assets/img_star.d ./Core/Src/lvgl/examples/assets/img_star.o ./Core/Src/lvgl/examples/assets/img_star.su ./Core/Src/lvgl/examples/assets/img_svg_img.cyclo ./Core/Src/lvgl/examples/assets/img_svg_img.d ./Core/Src/lvgl/examples/assets/img_svg_img.o ./Core/Src/lvgl/examples/assets/img_svg_img.su ./Core/Src/lvgl/examples/assets/imgbtn_left.cyclo ./Core/Src/lvgl/examples/assets/imgbtn_left.d ./Core/Src/lvgl/examples/assets/imgbtn_left.o ./Core/Src/lvgl/examples/assets/imgbtn_left.su ./Core/Src/lvgl/examples/assets/imgbtn_mid.cyclo ./Core/Src/lvgl/examples/assets/imgbtn_mid.d ./Core/Src/lvgl/examples/assets/imgbtn_mid.o ./Core/Src/lvgl/examples/assets/imgbtn_mid.su ./Core/Src/lvgl/examples/assets/imgbtn_right.cyclo ./Core/Src/lvgl/examples/assets/imgbtn_right.d ./Core/Src/lvgl/examples/assets/imgbtn_right.o ./Core/Src/lvgl/examples/assets/imgbtn_right.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-examples-2f-assets

