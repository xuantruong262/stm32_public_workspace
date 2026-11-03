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

option(BOOT_S1_DIRECT_HANDOFF
    "S1 hardware-test profile: jump directly to Primary vector without image-state logic"
    OFF)

option(BOOT_S2_PRIMARY_VALIDATION
    "S2 hardware-test profile: validate Primary image before vector hand-off"
    OFF)

if(BOOT_S1_DIRECT_HANDOFF AND BOOT_S2_PRIMARY_VALIDATION)
    message(FATAL_ERROR "BOOT_S1_DIRECT_HANDOFF and BOOT_S2_PRIMARY_VALIDATION are mutually exclusive")
endif()

# Set the project name
set(CMAKE_PROJECT_NAME bootloader)

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# Core project settings
project(${CMAKE_PROJECT_NAME})
message("Build type: " ${CMAKE_BUILD_TYPE})

# Enable CMake support for ASM and C languages
enable_language(C ASM)

# Create an executable object type
add_executable(${CMAKE_PROJECT_NAME})

# Add STM32CubeMX generated sources
add_subdirectory(cmake/stm32cubemx)

# Link directories setup
target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined library search paths
)

# Add sources to executable
target_sources(${CMAKE_PROJECT_NAME} PRIVATE
    Core/Src/boot_image.c
    Core/Src/boot_flash.c
    Core/Src/boot_manager.c
    Core/Src/boot_update.c
    Core/Src/boot_protocol.c
    Core/Src/boot_cdc_transport.c
    Core/Src/boot_swap.c
    Core/Src/boot_request.c
)

# Add include paths
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    Core/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../boot_contract/Inc
)

# Add project symbols (macros)
target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined symbols
)

if(BOOT_S1_DIRECT_HANDOFF)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE BOOT_S1_DIRECT_HANDOFF=1)
endif()

if(BOOT_S2_PRIMARY_VALIDATION)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE BOOT_S2_PRIMARY_VALIDATION=1)
endif()

# Remove wrong libob.a library dependency when using cpp files
list(REMOVE_ITEM CMAKE_C_IMPLICIT_LINK_LIBRARIES ob)

# Add linked libraries
target_link_libraries(${CMAKE_PROJECT_NAME}
    stm32cubemx

    # Add user defined libraries
)
