################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/helix_mp3_decoder/bitstream.c \
../Middlewares/helix_mp3_decoder/buffers.c \
../Middlewares/helix_mp3_decoder/dct32.c \
../Middlewares/helix_mp3_decoder/debug.c \
../Middlewares/helix_mp3_decoder/dequant.c \
../Middlewares/helix_mp3_decoder/dqchan.c \
../Middlewares/helix_mp3_decoder/helix_main.c \
../Middlewares/helix_mp3_decoder/huffman.c \
../Middlewares/helix_mp3_decoder/hufftabs.c \
../Middlewares/helix_mp3_decoder/imdct.c \
../Middlewares/helix_mp3_decoder/mp3dec.c \
../Middlewares/helix_mp3_decoder/mp3tabs.c \
../Middlewares/helix_mp3_decoder/polyphase.c \
../Middlewares/helix_mp3_decoder/scalfact.c \
../Middlewares/helix_mp3_decoder/stproc.c \
../Middlewares/helix_mp3_decoder/subband.c \
../Middlewares/helix_mp3_decoder/timing.c \
../Middlewares/helix_mp3_decoder/trigtabs.c 

OBJS += \
./Middlewares/helix_mp3_decoder/bitstream.o \
./Middlewares/helix_mp3_decoder/buffers.o \
./Middlewares/helix_mp3_decoder/dct32.o \
./Middlewares/helix_mp3_decoder/debug.o \
./Middlewares/helix_mp3_decoder/dequant.o \
./Middlewares/helix_mp3_decoder/dqchan.o \
./Middlewares/helix_mp3_decoder/helix_main.o \
./Middlewares/helix_mp3_decoder/huffman.o \
./Middlewares/helix_mp3_decoder/hufftabs.o \
./Middlewares/helix_mp3_decoder/imdct.o \
./Middlewares/helix_mp3_decoder/mp3dec.o \
./Middlewares/helix_mp3_decoder/mp3tabs.o \
./Middlewares/helix_mp3_decoder/polyphase.o \
./Middlewares/helix_mp3_decoder/scalfact.o \
./Middlewares/helix_mp3_decoder/stproc.o \
./Middlewares/helix_mp3_decoder/subband.o \
./Middlewares/helix_mp3_decoder/timing.o \
./Middlewares/helix_mp3_decoder/trigtabs.o 

C_DEPS += \
./Middlewares/helix_mp3_decoder/bitstream.d \
./Middlewares/helix_mp3_decoder/buffers.d \
./Middlewares/helix_mp3_decoder/dct32.d \
./Middlewares/helix_mp3_decoder/debug.d \
./Middlewares/helix_mp3_decoder/dequant.d \
./Middlewares/helix_mp3_decoder/dqchan.d \
./Middlewares/helix_mp3_decoder/helix_main.d \
./Middlewares/helix_mp3_decoder/huffman.d \
./Middlewares/helix_mp3_decoder/hufftabs.d \
./Middlewares/helix_mp3_decoder/imdct.d \
./Middlewares/helix_mp3_decoder/mp3dec.d \
./Middlewares/helix_mp3_decoder/mp3tabs.d \
./Middlewares/helix_mp3_decoder/polyphase.d \
./Middlewares/helix_mp3_decoder/scalfact.d \
./Middlewares/helix_mp3_decoder/stproc.d \
./Middlewares/helix_mp3_decoder/subband.d \
./Middlewares/helix_mp3_decoder/timing.d \
./Middlewares/helix_mp3_decoder/trigtabs.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/helix_mp3_decoder/%.o Middlewares/helix_mp3_decoder/%.su Middlewares/helix_mp3_decoder/%.cyclo: ../Middlewares/helix_mp3_decoder/%.c Middlewares/helix_mp3_decoder/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -c -I../../../Inc -I../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../Drivers/BSP/STM32F4-Discovery -I../../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc -I../../../Middlewares/ST/STM32_USB_Host_Library/Core/Inc -I../../../Middlewares/ST/STM32_Audio/Addons/PDM/Inc -I../../../Middlewares/Third_Party/FatFs/src -I../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-helix_mp3_decoder

clean-Middlewares-2f-helix_mp3_decoder:
	-$(RM) ./Middlewares/helix_mp3_decoder/bitstream.cyclo ./Middlewares/helix_mp3_decoder/bitstream.d ./Middlewares/helix_mp3_decoder/bitstream.o ./Middlewares/helix_mp3_decoder/bitstream.su ./Middlewares/helix_mp3_decoder/buffers.cyclo ./Middlewares/helix_mp3_decoder/buffers.d ./Middlewares/helix_mp3_decoder/buffers.o ./Middlewares/helix_mp3_decoder/buffers.su ./Middlewares/helix_mp3_decoder/dct32.cyclo ./Middlewares/helix_mp3_decoder/dct32.d ./Middlewares/helix_mp3_decoder/dct32.o ./Middlewares/helix_mp3_decoder/dct32.su ./Middlewares/helix_mp3_decoder/debug.cyclo ./Middlewares/helix_mp3_decoder/debug.d ./Middlewares/helix_mp3_decoder/debug.o ./Middlewares/helix_mp3_decoder/debug.su ./Middlewares/helix_mp3_decoder/dequant.cyclo ./Middlewares/helix_mp3_decoder/dequant.d ./Middlewares/helix_mp3_decoder/dequant.o ./Middlewares/helix_mp3_decoder/dequant.su ./Middlewares/helix_mp3_decoder/dqchan.cyclo ./Middlewares/helix_mp3_decoder/dqchan.d ./Middlewares/helix_mp3_decoder/dqchan.o ./Middlewares/helix_mp3_decoder/dqchan.su ./Middlewares/helix_mp3_decoder/helix_main.cyclo ./Middlewares/helix_mp3_decoder/helix_main.d ./Middlewares/helix_mp3_decoder/helix_main.o ./Middlewares/helix_mp3_decoder/helix_main.su ./Middlewares/helix_mp3_decoder/huffman.cyclo ./Middlewares/helix_mp3_decoder/huffman.d ./Middlewares/helix_mp3_decoder/huffman.o ./Middlewares/helix_mp3_decoder/huffman.su ./Middlewares/helix_mp3_decoder/hufftabs.cyclo ./Middlewares/helix_mp3_decoder/hufftabs.d ./Middlewares/helix_mp3_decoder/hufftabs.o ./Middlewares/helix_mp3_decoder/hufftabs.su ./Middlewares/helix_mp3_decoder/imdct.cyclo ./Middlewares/helix_mp3_decoder/imdct.d ./Middlewares/helix_mp3_decoder/imdct.o ./Middlewares/helix_mp3_decoder/imdct.su ./Middlewares/helix_mp3_decoder/mp3dec.cyclo ./Middlewares/helix_mp3_decoder/mp3dec.d ./Middlewares/helix_mp3_decoder/mp3dec.o ./Middlewares/helix_mp3_decoder/mp3dec.su ./Middlewares/helix_mp3_decoder/mp3tabs.cyclo ./Middlewares/helix_mp3_decoder/mp3tabs.d ./Middlewares/helix_mp3_decoder/mp3tabs.o ./Middlewares/helix_mp3_decoder/mp3tabs.su ./Middlewares/helix_mp3_decoder/polyphase.cyclo ./Middlewares/helix_mp3_decoder/polyphase.d ./Middlewares/helix_mp3_decoder/polyphase.o ./Middlewares/helix_mp3_decoder/polyphase.su ./Middlewares/helix_mp3_decoder/scalfact.cyclo ./Middlewares/helix_mp3_decoder/scalfact.d ./Middlewares/helix_mp3_decoder/scalfact.o ./Middlewares/helix_mp3_decoder/scalfact.su ./Middlewares/helix_mp3_decoder/stproc.cyclo ./Middlewares/helix_mp3_decoder/stproc.d ./Middlewares/helix_mp3_decoder/stproc.o ./Middlewares/helix_mp3_decoder/stproc.su ./Middlewares/helix_mp3_decoder/subband.cyclo ./Middlewares/helix_mp3_decoder/subband.d ./Middlewares/helix_mp3_decoder/subband.o ./Middlewares/helix_mp3_decoder/subband.su ./Middlewares/helix_mp3_decoder/timing.cyclo ./Middlewares/helix_mp3_decoder/timing.d ./Middlewares/helix_mp3_decoder/timing.o ./Middlewares/helix_mp3_decoder/timing.su ./Middlewares/helix_mp3_decoder/trigtabs.cyclo ./Middlewares/helix_mp3_decoder/trigtabs.d ./Middlewares/helix_mp3_decoder/trigtabs.o ./Middlewares/helix_mp3_decoder/trigtabs.su

.PHONY: clean-Middlewares-2f-helix_mp3_decoder

