################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/demos/widgets/lv_demo_widgets.c \
../Core/Src/lvgl/demos/widgets/lv_demo_widgets_analytics.c \
../Core/Src/lvgl/demos/widgets/lv_demo_widgets_components.c \
../Core/Src/lvgl/demos/widgets/lv_demo_widgets_profile.c \
../Core/Src/lvgl/demos/widgets/lv_demo_widgets_shop.c 

OBJS += \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets.o \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_analytics.o \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_components.o \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_profile.o \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_shop.o 

C_DEPS += \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets.d \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_analytics.d \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_components.d \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_profile.d \
./Core/Src/lvgl/demos/widgets/lv_demo_widgets_shop.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/demos/widgets/%.o Core/Src/lvgl/demos/widgets/%.su Core/Src/lvgl/demos/widgets/%.cyclo: ../Core/Src/lvgl/demos/widgets/%.c Core/Src/lvgl/demos/widgets/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-demos-2f-widgets

clean-Core-2f-Src-2f-lvgl-2f-demos-2f-widgets:
	-$(RM) ./Core/Src/lvgl/demos/widgets/lv_demo_widgets.cyclo ./Core/Src/lvgl/demos/widgets/lv_demo_widgets.d ./Core/Src/lvgl/demos/widgets/lv_demo_widgets.o ./Core/Src/lvgl/demos/widgets/lv_demo_widgets.su ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_analytics.cyclo ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_analytics.d ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_analytics.o ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_analytics.su ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_components.cyclo ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_components.d ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_components.o ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_components.su ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_profile.cyclo ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_profile.d ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_profile.o ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_profile.su ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_shop.cyclo ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_shop.d ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_shop.o ./Core/Src/lvgl/demos/widgets/lv_demo_widgets_shop.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-demos-2f-widgets

