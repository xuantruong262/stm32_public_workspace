################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_core.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ctlreq.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ioreq.c \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_pipes.c 

OBJS += \
./Middlewares/STM32_USBH_Library/Core/usbh_core.o \
./Middlewares/STM32_USBH_Library/Core/usbh_ctlreq.o \
./Middlewares/STM32_USBH_Library/Core/usbh_ioreq.o \
./Middlewares/STM32_USBH_Library/Core/usbh_pipes.o 

C_DEPS += \
./Middlewares/STM32_USBH_Library/Core/usbh_core.d \
./Middlewares/STM32_USBH_Library/Core/usbh_ctlreq.d \
./Middlewares/STM32_USBH_Library/Core/usbh_ioreq.d \
./Middlewares/STM32_USBH_Library/Core/usbh_pipes.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/STM32_USBH_Library/Core/usbh_core.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_core.c Middlewares/STM32_USBH_Library/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Middlewares/STM32_USBH_Library/Core/usbh_ctlreq.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ctlreq.c Middlewares/STM32_USBH_Library/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Middlewares/STM32_USBH_Library/Core/usbh_ioreq.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ioreq.c Middlewares/STM32_USBH_Library/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Middlewares/STM32_USBH_Library/Core/usbh_pipes.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_pipes.c Middlewares/STM32_USBH_Library/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-STM32_USBH_Library-2f-Core

clean-Middlewares-2f-STM32_USBH_Library-2f-Core:
	-$(RM) ./Middlewares/STM32_USBH_Library/Core/usbh_core.cyclo ./Middlewares/STM32_USBH_Library/Core/usbh_core.d ./Middlewares/STM32_USBH_Library/Core/usbh_core.o ./Middlewares/STM32_USBH_Library/Core/usbh_core.su ./Middlewares/STM32_USBH_Library/Core/usbh_ctlreq.cyclo ./Middlewares/STM32_USBH_Library/Core/usbh_ctlreq.d ./Middlewares/STM32_USBH_Library/Core/usbh_ctlreq.o ./Middlewares/STM32_USBH_Library/Core/usbh_ctlreq.su ./Middlewares/STM32_USBH_Library/Core/usbh_ioreq.cyclo ./Middlewares/STM32_USBH_Library/Core/usbh_ioreq.d ./Middlewares/STM32_USBH_Library/Core/usbh_ioreq.o ./Middlewares/STM32_USBH_Library/Core/usbh_ioreq.su ./Middlewares/STM32_USBH_Library/Core/usbh_pipes.cyclo ./Middlewares/STM32_USBH_Library/Core/usbh_pipes.d ./Middlewares/STM32_USBH_Library/Core/usbh_pipes.o ./Middlewares/STM32_USBH_Library/Core/usbh_pipes.su

.PHONY: clean-Middlewares-2f-STM32_USBH_Library-2f-Core

