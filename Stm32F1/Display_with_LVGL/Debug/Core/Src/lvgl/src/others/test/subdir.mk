################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/others/test/lv_test_display.c \
../Core/Src/lvgl/src/others/test/lv_test_helpers.c \
../Core/Src/lvgl/src/others/test/lv_test_indev.c \
../Core/Src/lvgl/src/others/test/lv_test_indev_gesture.c \
../Core/Src/lvgl/src/others/test/lv_test_screenshot_compare.c 

OBJS += \
./Core/Src/lvgl/src/others/test/lv_test_display.o \
./Core/Src/lvgl/src/others/test/lv_test_helpers.o \
./Core/Src/lvgl/src/others/test/lv_test_indev.o \
./Core/Src/lvgl/src/others/test/lv_test_indev_gesture.o \
./Core/Src/lvgl/src/others/test/lv_test_screenshot_compare.o 

C_DEPS += \
./Core/Src/lvgl/src/others/test/lv_test_display.d \
./Core/Src/lvgl/src/others/test/lv_test_helpers.d \
./Core/Src/lvgl/src/others/test/lv_test_indev.d \
./Core/Src/lvgl/src/others/test/lv_test_indev_gesture.d \
./Core/Src/lvgl/src/others/test/lv_test_screenshot_compare.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/others/test/%.o Core/Src/lvgl/src/others/test/%.su Core/Src/lvgl/src/others/test/%.cyclo: ../Core/Src/lvgl/src/others/test/%.c Core/Src/lvgl/src/others/test/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-others-2f-test

clean-Core-2f-Src-2f-lvgl-2f-src-2f-others-2f-test:
	-$(RM) ./Core/Src/lvgl/src/others/test/lv_test_display.cyclo ./Core/Src/lvgl/src/others/test/lv_test_display.d ./Core/Src/lvgl/src/others/test/lv_test_display.o ./Core/Src/lvgl/src/others/test/lv_test_display.su ./Core/Src/lvgl/src/others/test/lv_test_helpers.cyclo ./Core/Src/lvgl/src/others/test/lv_test_helpers.d ./Core/Src/lvgl/src/others/test/lv_test_helpers.o ./Core/Src/lvgl/src/others/test/lv_test_helpers.su ./Core/Src/lvgl/src/others/test/lv_test_indev.cyclo ./Core/Src/lvgl/src/others/test/lv_test_indev.d ./Core/Src/lvgl/src/others/test/lv_test_indev.o ./Core/Src/lvgl/src/others/test/lv_test_indev.su ./Core/Src/lvgl/src/others/test/lv_test_indev_gesture.cyclo ./Core/Src/lvgl/src/others/test/lv_test_indev_gesture.d ./Core/Src/lvgl/src/others/test/lv_test_indev_gesture.o ./Core/Src/lvgl/src/others/test/lv_test_indev_gesture.su ./Core/Src/lvgl/src/others/test/lv_test_screenshot_compare.cyclo ./Core/Src/lvgl/src/others/test/lv_test_screenshot_compare.d ./Core/Src/lvgl/src/others/test/lv_test_screenshot_compare.o ./Core/Src/lvgl/src/others/test/lv_test_screenshot_compare.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-others-2f-test

