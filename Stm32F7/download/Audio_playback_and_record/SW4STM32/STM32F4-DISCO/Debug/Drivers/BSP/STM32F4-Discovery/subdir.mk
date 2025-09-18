################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.c 

OBJS += \
./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.o \
./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.o \
./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.o 

C_DEPS += \
./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.d \
./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.d \
./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.d 


# Each subdirectory must supply rules for building sources it contributes
Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.c Drivers/BSP/STM32F4-Discovery/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.c Drivers/BSP/STM32F4-Discovery/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.c Drivers/BSP/STM32F4-Discovery/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Drivers-2f-BSP-2f-STM32F4-2d-Discovery

clean-Drivers-2f-BSP-2f-STM32F4-2d-Discovery:
	-$(RM) ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.cyclo ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.d ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.o ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.su ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.cyclo ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.d ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.o ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_accelerometer.su ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.cyclo ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.d ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.o ./Drivers/BSP/STM32F4-Discovery/stm32f4_discovery_audio.su

.PHONY: clean-Drivers-2f-BSP-2f-STM32F4-2d-Discovery

