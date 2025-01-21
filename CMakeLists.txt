set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
cmake_minimum_required(VERSION 3.22)

# Compiler set
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_AR arm-none-eabi-ar)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_OBJDUMP arm-none-eabi-objdump)
set(SIZE arm-none-eabi-size)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Project config
project(GD32F303VE_CMake C CXX ASM)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

# Compiler options
add_compile_options(-mcpu=cortex-m4 -mthumb -mthumb-interwork)
add_compile_options(-ffunction-sections -fdata-sections -fno-common -fmessage-length=0)

# Hardware floating point
add_compile_definitions(ARM_MATH_CM4;ARM_MATH_MATRIX_CHECK;ARM_MATH_ROUNDING)
add_compile_options(-mfloat-abi=hard -mfpu=fpv4-sp-d16)
add_link_options(-mfloat-abi=hard -mfpu=fpv4-sp-d16)


# Uncomment for software floating point
#add_compile_options(-mfloat-abi=soft)

# Assembler options
add_compile_options($<$<COMPILE_LANGUAGE:ASM>:-x$<SEMICOLON>assembler-with-cpp>)

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    message(STATUS "Maximum optimization for speed")
    add_compile_options(-Ofast)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    message(STATUS "Maximum optimization for speed, debug info included")
    add_compile_options(-Ofast -g)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel")
    message(STATUS "Maximum optimization for size")
    add_compile_options(-Os)
else ()
    message(STATUS "Minimal optimization, debug info included")
    add_compile_options(-Og -g)
endif ()

# Include directories
include_directories(
        include
        Drivers/CMSIS/Core/Include
        Drivers/CMSIS/Device/GD/GD32F30x/Include
        Drivers/GD32F30x_standard_peripheral/Include
        Library/GPIO
)

# Project macros and defines
add_definitions(-DDEBUG -DGD32F303 -DGD32F30x -DGD32F30X_HD)

# Startup file (исходный файл, который содержит Reset_Handler)
set(STARTUP_FILE "Drivers/CMSIS/Device/GD/GD32F30x/Source/startup_gd32f303_hd.s")

# Set global sources
file(GLOB_RECURSE SOURCES
        "src/*.c"
        "Drivers/**/*.c"
)


# Additional libraries
file(GLOB_RECURSE LIB_SOURCES
        "Library/GPIO/gpio.c"
)

# Set linker script
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/GD32F303VETx_FLASH.ld)

# Linker options
add_link_options(
        -Wl,-gc-sections,--print-memory-usage,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map
        -mcpu=cortex-m4 -mthumb -mthumb-interwork
        -Wl,--no-warn-rwx-segments
        -specs=nano.specs -lc -lgcc -lm -lrdimon
        -specs=nosys.specs
        -T ${LINKER_SCRIPT}
)

# Executable target (порядок: Startup → FreeRTOS → библиотеки → основной код)
add_executable(${PROJECT_NAME}.elf
        ${STARTUP_FILE}
        ${FREERTOS_SOURCES}
        ${LIB_SOURCES}
        ${SOURCES}
)

# Path to HEX and BIN
set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

# Command to create HEX and BIN
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
        COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
        COMMENT "Building ${HEX_FILE} and ${BIN_FILE}"
)
