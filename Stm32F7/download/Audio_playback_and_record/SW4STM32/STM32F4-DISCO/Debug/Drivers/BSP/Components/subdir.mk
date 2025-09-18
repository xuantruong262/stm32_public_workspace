################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/Components/cs43l22/cs43l22.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/Components/lis302dl/lis302dl.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/Components/lis3dsh/lis3dsh.c 

OBJS += \
./Drivers/BSP/Components/cs43l22.o \
./Drivers/BSP/Components/lis302dl.o \
./Drivers/BSP/Components/lis3dsh.o 

C_DEPS += \
./Drivers/BSP/Components/cs43l22.d \
./Drivers/BSP/Components/lis302dl.d \
./Drivers/BSP/Components/lis3dsh.d 


# Each subdirectory must supply rules for building sources it contributes
Drivers/BSP/Components/cs43l22.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/Components/cs43l22/cs43l22.c Drivers/BSP/Components/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Drivers/BSP/Components/lis302dl.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/Components/lis302dl/lis302dl.c Drivers/BSP/Components/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Drivers/BSP/Components/lis3dsh.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Drivers/BSP/Components/lis3dsh/lis3dsh.c Drivers/BSP/Components/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Drivers-2f-BSP-2f-Components

clean-Drivers-2f-BSP-2f-Components:
	-$(RM) ./Drivers/BSP/Components/cs43l22.cyclo ./Drivers/BSP/Components/cs43l22.d ./Drivers/BSP/Components/cs43l22.o ./Drivers/BSP/Components/cs43l22.su ./Drivers/BSP/Components/lis302dl.cyclo ./Drivers/BSP/Components/lis302dl.d ./Drivers/BSP/Components/lis302dl.o ./Drivers/BSP/Components/lis302dl.su ./Drivers/BSP/Components/lis3dsh.cyclo ./Drivers/BSP/Components/lis3dsh.d ./Drivers/BSP/Components/lis3dsh.o ./Drivers/BSP/Components/lis3dsh.su

.PHONY: clean-Drivers-2f-BSP-2f-Components

