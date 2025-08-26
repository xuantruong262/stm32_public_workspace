################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_buf_pxp.c \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp.c \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_fill.c \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_img.c \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_layer.c \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_cfg.c \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_osa.c \
../Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_utils.c 

OBJS += \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_buf_pxp.o \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp.o \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_fill.o \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_img.o \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_layer.o \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_cfg.o \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_osa.o \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_utils.o 

C_DEPS += \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_buf_pxp.d \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp.d \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_fill.d \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_img.d \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_layer.d \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_cfg.d \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_osa.d \
./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_utils.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/draw/nxp/pxp/%.o Core/Src/lvgl/src/draw/nxp/pxp/%.su Core/Src/lvgl/src/draw/nxp/pxp/%.cyclo: ../Core/Src/lvgl/src/draw/nxp/pxp/%.c Core/Src/lvgl/src/draw/nxp/pxp/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-nxp-2f-pxp

clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-nxp-2f-pxp:
	-$(RM) ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_buf_pxp.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_buf_pxp.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_buf_pxp.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_buf_pxp.su ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp.su ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_fill.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_fill.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_fill.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_fill.su ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_img.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_img.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_img.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_img.su ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_layer.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_layer.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_layer.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_draw_pxp_layer.su ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_cfg.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_cfg.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_cfg.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_cfg.su ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_osa.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_osa.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_osa.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_osa.su ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_utils.cyclo ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_utils.d ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_utils.o ./Core/Src/lvgl/src/draw/nxp/pxp/lv_pxp_utils.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-draw-2f-nxp-2f-pxp

