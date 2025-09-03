cmake_minimum_required(VERSION 3.15)
project(STM32F103C8_Project C ASM)

# CPU/MCU flags
set(TARGET_FLAGS "-mcpu=cortex-m3 ")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${TARGET_FLAGS}")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -x assembler-with-cpp -MMD -MP")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic -fdata-sections -ffunction-sections"
)
set(MX_Defines_Syms USE_HAL_DRIVER STM32F103xB $<$<CONFIG:Debug>:DEBUG>)
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/STM32F103XX_FLASH.ld)
set(LINK_FLAGS "-T${LINKER_SCRIPT} -Wl,--gc-sections -Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map")



# Include directories
set(PROJECT_ROOT ${CMAKE_SOURCE_DIR})
message(STATUS "Project root: ${PROJECT_ROOT}")
# Thêm include path
include_directories(
    ${PROJECT_ROOT}/Core/Inc
    ${PROJECT_ROOT}/Drivers/STM32F1xx_HAL_Driver/Inc
    ${PROJECT_ROOT}/Drivers/CMSIS/Device/ST/STM32F1xx/Include
    ${PROJECT_ROOT}/Drivers/CMSIS/Include
)
# Source files
set(SOURCES
    Core/Src/main.c
    Core/Src/stm32f1xx_hal_msp.c
    Core/Src/stm32f1xx_it.c
    Core/Src/syscalls.c
    Core/Src/sysmem.c
    Core/Src/system_stm32f1xx.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_exti.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c
    Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c
    startup_stm32f103xb.s
)

# Add executable (ELF)
add_executable(${PROJECT_NAME}.elf ${SOURCES})

# Compiler flags
# target_compile_options(${PROJECT_NAME}.elf PRIVATE ${CMAKE_C_FLAGS})
target_compile_options(${PROJECT_NAME}.elf PRIVATE
    -mcpu=cortex-m3
    -mthumb
    -Wall
    -Wextra
    -Wpedantic
    -fdata-sections
    -ffunction-sections
)
set_target_properties(${PROJECT_NAME}.elf PROPERTIES LINK_FLAGS "${TARGET_FLAGS} ${LINK_FLAGS}")
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE ${MX_Defines_Syms})

# Generate HEX and BIN
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${TOOLCHAIN_PATH}/arm-none-eabi-objcopy.exe -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMAND ${TOOLCHAIN_PATH}/arm-none-eabi-objcopy.exe -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    COMMAND ${TOOLCHAIN_PATH}/arm-none-eabi-size.exe ${PROJECT_NAME}.elf
)