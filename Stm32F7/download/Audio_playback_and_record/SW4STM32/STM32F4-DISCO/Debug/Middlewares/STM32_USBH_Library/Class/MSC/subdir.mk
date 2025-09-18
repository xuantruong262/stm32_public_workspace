################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_bot.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_scsi.c 

OBJS += \
./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc.o \
./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_bot.o \
./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_scsi.o 

C_DEPS += \
./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc.d \
./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_bot.d \
./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_scsi.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc.c Middlewares/STM32_USBH_Library/Class/MSC/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_bot.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_bot.c Middlewares/STM32_USBH_Library/Class/MSC/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_scsi.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_scsi.c Middlewares/STM32_USBH_Library/Class/MSC/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-STM32_USBH_Library-2f-Class-2f-MSC

clean-Middlewares-2f-STM32_USBH_Library-2f-Class-2f-MSC:
	-$(RM) ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc.cyclo ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc.d ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc.o ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc.su ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_bot.cyclo ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_bot.d ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_bot.o ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_bot.su ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_scsi.cyclo ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_scsi.d ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_scsi.o ./Middlewares/STM32_USBH_Library/Class/MSC/usbh_msc_scsi.su

.PHONY: clean-Middlewares-2f-STM32_USBH_Library-2f-Class-2f-MSC

