cmake_minimum_required(VERSION 3.22)

#
# This file is generated only once,
# and is not re-generated if converter is called multiple times.
#
# User is free to modify the file as much as necessary
#

# Setup compiler settings
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)


# Define the build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

option(APP_S1_SMOKE
    "S1 hardware-test profile: GPIOG/PG7 only; no USB, update API, or confirmation"
    OFF)

# The production app source is deliberately reusable for A/B integration
# tests.  The target name identifies the immutable payload artifact, while
# the blink interval makes the two test images visually distinguishable.
set(APP_TARGET_NAME "app_1" CACHE STRING "Application artifact target name")
set(APP_BLINK_PERIOD_MS "500" CACHE STRING "GPIOG/PG7 blink period in milliseconds")
if(NOT APP_TARGET_NAME MATCHES "^[A-Za-z][A-Za-z0-9_]*$")
    message(FATAL_ERROR "APP_TARGET_NAME must be a valid CMake target name")
endif()
if(NOT APP_BLINK_PERIOD_MS MATCHES "^[1-9][0-9]*$")
    message(FATAL_ERROR "APP_BLINK_PERIOD_MS must be a positive integer")
endif()

# Keep the smoke profile isolated while production builds can name their
# immutable payload artifact explicitly (app_1, app_2, ...).
if(APP_S1_SMOKE)
    set(APP_PROJECT_NAME app_smoke)
else()
    set(APP_PROJECT_NAME ${APP_TARGET_NAME})
endif()

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# Core project settings
project(${APP_PROJECT_NAME})
message("Build type: " ${CMAKE_BUILD_TYPE})

# Enable CMake support for ASM and C languages
enable_language(C ASM)

# Create an executable object type
add_executable(${APP_PROJECT_NAME})

# Add STM32CubeMX generated sources
add_subdirectory(cmake/stm32cubemx)

# Link directories setup
target_link_directories(${APP_PROJECT_NAME} PRIVATE
    # Add user defined library search paths
)

# Add sources to executable
set(APP_BOOTLOADER_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../app_bootloader")
set(BOOT_CONTRACT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../boot_contract")
if(NOT APP_S1_SMOKE)
    target_sources(${APP_PROJECT_NAME} PRIVATE
        ${APP_BOOTLOADER_ROOT}/Src/app_bootloader.c
        Core/Src/app_update_cdc.c
    )
endif()

# Add include paths
target_include_directories(${APP_PROJECT_NAME} PRIVATE
    Core/Inc
)
if(NOT APP_S1_SMOKE)
    target_include_directories(${APP_PROJECT_NAME} PRIVATE
        ${APP_BOOTLOADER_ROOT}/Inc
        ${BOOT_CONTRACT_ROOT}/Inc
    )
endif()

# Add project symbols (macros)
target_compile_definitions(${APP_PROJECT_NAME} PRIVATE
    USER_VECT_TAB_ADDRESS
    APP_BLINK_PERIOD_MS=${APP_BLINK_PERIOD_MS}
)
target_compile_definitions(STM32_Drivers PRIVATE USER_VECT_TAB_ADDRESS)

if(APP_S1_SMOKE)
    target_compile_definitions(${APP_PROJECT_NAME} PRIVATE APP_S1_SMOKE=1)
endif()

# Remove wrong libob.a library dependency when using cpp files
list(REMOVE_ITEM CMAKE_C_IMPLICIT_LINK_LIBRARIES ob)

# Add linked libraries
target_link_libraries(${APP_PROJECT_NAME}
    stm32cubemx

    # Add user defined libraries
)

add_custom_command(TARGET ${APP_PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${APP_PROJECT_NAME}>
            $<TARGET_FILE_DIR:${APP_PROJECT_NAME}>/${APP_PROJECT_NAME}.bin
    COMMENT "Generating raw application payload"
)
