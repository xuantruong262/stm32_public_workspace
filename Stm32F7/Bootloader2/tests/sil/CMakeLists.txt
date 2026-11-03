cmake_minimum_required(VERSION 3.22)

project(bootloader_sil C)
enable_testing()

set(BOOTLOADER_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../bootloader/bootloader")

add_executable(bootloader_sil_tests
    test_bootloader.c
    sil_flash.c
    sil_runtime.c
    ${BOOTLOADER_ROOT}/Core/Src/boot_image.c
    ${BOOTLOADER_ROOT}/Core/Src/boot_update.c
    ${BOOTLOADER_ROOT}/Core/Src/boot_swap.c
    ${BOOTLOADER_ROOT}/Core/Src/boot_manager.c
    ${BOOTLOADER_ROOT}/Core/Src/boot_protocol.c)

target_compile_features(bootloader_sil_tests PRIVATE c_std_11)
target_compile_definitions(bootloader_sil_tests PRIVATE BOOT_SIL=1)
target_include_directories(bootloader_sil_tests PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/include
    ${BOOTLOADER_ROOT}/Core/Inc
    ${CMAKE_CURRENT_LIST_DIR}/../../boot_contract/Inc)

if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(bootloader_sil_tests PRIVATE
        -Wall -Wextra -Wpedantic -Werror
        -fprofile-arcs -ftest-coverage)
    target_link_options(bootloader_sil_tests PRIVATE --coverage)
elseif(MSVC)
    target_compile_options(bootloader_sil_tests PRIVATE /W4 /WX)
endif()

add_test(NAME bootloader_sil COMMAND bootloader_sil_tests)
