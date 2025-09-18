################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
/Users/AGMiD/workspace/STM32b/Audio_playback_and_record/SW4STM32/startup_stm32f407xx.s 

OBJS += \
./Application/SW4STM32/startup_stm32f407xx.o 

S_DEPS += \
./Application/SW4STM32/startup_stm32f407xx.d 


# Each subdirectory must supply rules for building sources it contributes
Application/SW4STM32/startup_stm32f407xx.o: /Users/AGMiD/workspace/STM32b/Audio_playback_and_record/SW4STM32/startup_stm32f407xx.s Application/SW4STM32/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -c -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

clean: clean-Application-2f-SW4STM32

clean-Application-2f-SW4STM32:
	-$(RM) ./Application/SW4STM32/startup_stm32f407xx.d ./Application/SW4STM32/startup_stm32f407xx.o

.PHONY: clean-Application-2f-SW4STM32

