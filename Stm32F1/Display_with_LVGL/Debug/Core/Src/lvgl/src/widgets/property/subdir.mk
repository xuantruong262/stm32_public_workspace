################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/widgets/property/lv_animimage_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_dropdown_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_image_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_keyboard_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_label_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_obj_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_roller_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_slider_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_style_properties.c \
../Core/Src/lvgl/src/widgets/property/lv_textarea_properties.c 

OBJS += \
./Core/Src/lvgl/src/widgets/property/lv_animimage_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_dropdown_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_image_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_keyboard_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_label_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_obj_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_roller_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_slider_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_style_properties.o \
./Core/Src/lvgl/src/widgets/property/lv_textarea_properties.o 

C_DEPS += \
./Core/Src/lvgl/src/widgets/property/lv_animimage_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_dropdown_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_image_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_keyboard_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_label_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_obj_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_roller_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_slider_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_style_properties.d \
./Core/Src/lvgl/src/widgets/property/lv_textarea_properties.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/widgets/property/%.o Core/Src/lvgl/src/widgets/property/%.su Core/Src/lvgl/src/widgets/property/%.cyclo: ../Core/Src/lvgl/src/widgets/property/%.c Core/Src/lvgl/src/widgets/property/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-property

clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-property:
	-$(RM) ./Core/Src/lvgl/src/widgets/property/lv_animimage_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_animimage_properties.d ./Core/Src/lvgl/src/widgets/property/lv_animimage_properties.o ./Core/Src/lvgl/src/widgets/property/lv_animimage_properties.su ./Core/Src/lvgl/src/widgets/property/lv_dropdown_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_dropdown_properties.d ./Core/Src/lvgl/src/widgets/property/lv_dropdown_properties.o ./Core/Src/lvgl/src/widgets/property/lv_dropdown_properties.su ./Core/Src/lvgl/src/widgets/property/lv_image_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_image_properties.d ./Core/Src/lvgl/src/widgets/property/lv_image_properties.o ./Core/Src/lvgl/src/widgets/property/lv_image_properties.su ./Core/Src/lvgl/src/widgets/property/lv_keyboard_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_keyboard_properties.d ./Core/Src/lvgl/src/widgets/property/lv_keyboard_properties.o ./Core/Src/lvgl/src/widgets/property/lv_keyboard_properties.su ./Core/Src/lvgl/src/widgets/property/lv_label_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_label_properties.d ./Core/Src/lvgl/src/widgets/property/lv_label_properties.o ./Core/Src/lvgl/src/widgets/property/lv_label_properties.su ./Core/Src/lvgl/src/widgets/property/lv_obj_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_obj_properties.d ./Core/Src/lvgl/src/widgets/property/lv_obj_properties.o ./Core/Src/lvgl/src/widgets/property/lv_obj_properties.su ./Core/Src/lvgl/src/widgets/property/lv_roller_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_roller_properties.d ./Core/Src/lvgl/src/widgets/property/lv_roller_properties.o ./Core/Src/lvgl/src/widgets/property/lv_roller_properties.su ./Core/Src/lvgl/src/widgets/property/lv_slider_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_slider_properties.d ./Core/Src/lvgl/src/widgets/property/lv_slider_properties.o ./Core/Src/lvgl/src/widgets/property/lv_slider_properties.su ./Core/Src/lvgl/src/widgets/property/lv_style_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_style_properties.d ./Core/Src/lvgl/src/widgets/property/lv_style_properties.o ./Core/Src/lvgl/src/widgets/property/lv_style_properties.su ./Core/Src/lvgl/src/widgets/property/lv_textarea_properties.cyclo ./Core/Src/lvgl/src/widgets/property/lv_textarea_properties.d ./Core/Src/lvgl/src/widgets/property/lv_textarea_properties.o ./Core/Src/lvgl/src/widgets/property/lv_textarea_properties.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-widgets-2f-property

