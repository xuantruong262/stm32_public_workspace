################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/TJpgDec/tjpgd.c 

OBJS += \
./Core/TJpgDec/tjpgd.o 

C_DEPS += \
./Core/TJpgDec/tjpgd.d 


# Each subdirectory must supply rules for building sources it contributes
Core/TJpgDec/%.o Core/TJpgDec/%.su Core/TJpgDec/%.cyclo: ../Core/TJpgDec/%.c Core/TJpgDec/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m7 -std=gnu11 -g3 -DDEBUG -DUSE_PWR_LDO_SUPPLY -DUSE_HAL_DRIVER -DSTM32H723xx -c -I../FATFS/Target -I../FATFS/App -I../Core/Inc -I../Core/TJpgDec -I../Drivers/STM32H7xx_HAL_Driver/Inc -I../Drivers/STM32H7xx_HAL_Driver/Inc/Legacy -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32H7xx/Include -I../Drivers/CMSIS/Include -I../LIBJPEG/App -I../LIBJPEG/Target -I../Middlewares/Third_Party/LibJPEG/include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-TJpgDec

clean-Core-2f-TJpgDec:
	-$(RM) ./Core/TJpgDec/tjpgd.cyclo ./Core/TJpgDec/tjpgd.d ./Core/TJpgDec/tjpgd.o ./Core/TJpgDec/tjpgd.su

.PHONY: clean-Core-2f-TJpgDec

