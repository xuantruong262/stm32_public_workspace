################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/main.c \
../Core/Src/stm32f4xx_it.c \
../Core/Src/syscalls.c \
../Core/Src/sysmem.c \
../Core/Src/system_stm32f4xx.c 

S_UPPER_SRCS += \
../Core/Src/asm.S 

OBJS += \
./Core/Src/asm.o \
./Core/Src/main.o \
./Core/Src/stm32f4xx_it.o \
./Core/Src/syscalls.o \
./Core/Src/sysmem.o \
./Core/Src/system_stm32f4xx.o 

S_UPPER_DEPS += \
./Core/Src/asm.d 

C_DEPS += \
./Core/Src/main.d \
./Core/Src/stm32f4xx_it.d \
./Core/Src/syscalls.d \
./Core/Src/sysmem.d \
./Core/Src/system_stm32f4xx.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/%.o: ../Core/Src/%.S Core/Src/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -DDEBUG -c -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/Display" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/FATFS" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/PCM5102" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/MP3Helix/include" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/JPEG" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/AVI" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/FileManager" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/Keyboard" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/MicroGL2D" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/Encoder" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/MyString" -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"
Core/Src/%.o Core/Src/%.su: ../Core/Src/%.c Core/Src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DSTM32F401xC -DUSE_FULL_LL_DRIVER -DHSE_VALUE=25000000 -DHSE_STARTUP_TIMEOUT=100 -DLSE_STARTUP_TIMEOUT=5000 -DLSE_VALUE=32768 -DEXTERNAL_CLOCK_VALUE=12288000 -DHSI_VALUE=16000000 -DLSI_VALUE=32000 -DPREFETCH_ENABLE=1 -DINSTRUCTION_CACHE_ENABLE=1 -DDATA_CACHE_ENABLE=1 -DVDD_VALUE=3400 -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/Display" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/FATFS" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/PCM5102" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/MP3Helix/include" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/JPEG" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/AVI" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/FileManager" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/Keyboard" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/MicroGL2D" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/Encoder" -I"C:/Users/alhajji/Desktop/Neuer Ordner/stm32f4_fast_optimized_avi_player_osd-main/MyString" -Ofast -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-Src

clean-Core-2f-Src:
	-$(RM) ./Core/Src/asm.d ./Core/Src/asm.o ./Core/Src/main.d ./Core/Src/main.o ./Core/Src/main.su ./Core/Src/stm32f4xx_it.d ./Core/Src/stm32f4xx_it.o ./Core/Src/stm32f4xx_it.su ./Core/Src/syscalls.d ./Core/Src/syscalls.o ./Core/Src/syscalls.su ./Core/Src/sysmem.d ./Core/Src/sysmem.o ./Core/Src/sysmem.su ./Core/Src/system_stm32f4xx.d ./Core/Src/system_stm32f4xx.o ./Core/Src/system_stm32f4xx.su

.PHONY: clean-Core-2f-Src

