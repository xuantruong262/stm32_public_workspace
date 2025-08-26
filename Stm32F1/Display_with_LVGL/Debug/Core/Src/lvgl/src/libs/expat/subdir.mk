################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/libs/expat/xmlparse.c \
../Core/Src/lvgl/src/libs/expat/xmlrole.c \
../Core/Src/lvgl/src/libs/expat/xmltok.c \
../Core/Src/lvgl/src/libs/expat/xmltok_impl.c \
../Core/Src/lvgl/src/libs/expat/xmltok_ns.c 

OBJS += \
./Core/Src/lvgl/src/libs/expat/xmlparse.o \
./Core/Src/lvgl/src/libs/expat/xmlrole.o \
./Core/Src/lvgl/src/libs/expat/xmltok.o \
./Core/Src/lvgl/src/libs/expat/xmltok_impl.o \
./Core/Src/lvgl/src/libs/expat/xmltok_ns.o 

C_DEPS += \
./Core/Src/lvgl/src/libs/expat/xmlparse.d \
./Core/Src/lvgl/src/libs/expat/xmlrole.d \
./Core/Src/lvgl/src/libs/expat/xmltok.d \
./Core/Src/lvgl/src/libs/expat/xmltok_impl.d \
./Core/Src/lvgl/src/libs/expat/xmltok_ns.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/libs/expat/%.o Core/Src/lvgl/src/libs/expat/%.su Core/Src/lvgl/src/libs/expat/%.cyclo: ../Core/Src/lvgl/src/libs/expat/%.c Core/Src/lvgl/src/libs/expat/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-libs-2f-expat

clean-Core-2f-Src-2f-lvgl-2f-src-2f-libs-2f-expat:
	-$(RM) ./Core/Src/lvgl/src/libs/expat/xmlparse.cyclo ./Core/Src/lvgl/src/libs/expat/xmlparse.d ./Core/Src/lvgl/src/libs/expat/xmlparse.o ./Core/Src/lvgl/src/libs/expat/xmlparse.su ./Core/Src/lvgl/src/libs/expat/xmlrole.cyclo ./Core/Src/lvgl/src/libs/expat/xmlrole.d ./Core/Src/lvgl/src/libs/expat/xmlrole.o ./Core/Src/lvgl/src/libs/expat/xmlrole.su ./Core/Src/lvgl/src/libs/expat/xmltok.cyclo ./Core/Src/lvgl/src/libs/expat/xmltok.d ./Core/Src/lvgl/src/libs/expat/xmltok.o ./Core/Src/lvgl/src/libs/expat/xmltok.su ./Core/Src/lvgl/src/libs/expat/xmltok_impl.cyclo ./Core/Src/lvgl/src/libs/expat/xmltok_impl.d ./Core/Src/lvgl/src/libs/expat/xmltok_impl.o ./Core/Src/lvgl/src/libs/expat/xmltok_impl.su ./Core/Src/lvgl/src/libs/expat/xmltok_ns.cyclo ./Core/Src/lvgl/src/libs/expat/xmltok_ns.d ./Core/Src/lvgl/src/libs/expat/xmltok_ns.o ./Core/Src/lvgl/src/libs/expat/xmltok_ns.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-libs-2f-expat

