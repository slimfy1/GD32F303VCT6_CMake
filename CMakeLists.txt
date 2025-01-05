set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
cmake_minimum_required(VERSION 3.22)

# Устанавливаем компиляторы
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_AR arm-none-eabi-ar)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_OBJDUMP arm-none-eabi-objdump)
set(SIZE arm-none-eabi-size)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Устанавливаем проект
project(GD32F303VE_CMake C CXX ASM)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

# Опции компилятора
add_compile_options(-mcpu=cortex-m4 -mthumb -mthumb-interwork)
add_compile_options(-ffunction-sections -fdata-sections -fno-common -fmessage-length=0)

# Опции для ассемблера
add_compile_options($<$<COMPILE_LANGUAGE:ASM>:-x$<SEMICOLON>assembler-with-cpp>)

# Оптимизация и отладка
add_compile_options(-O0 -g)

# Директории для включаемых файлов
include_directories(
        include
        Drivers/CMSIS/Core/Include
        Drivers/CMSIS/Device/GD/GD32F30x/Include
        Drivers/GD32F30x_standard_peripheral/Include
)

# Определяем макросы для проекта
add_definitions(-DDEBUG -DGD32F303 -DGD32F30x -DGD32F30X_HD)

# Получаем все исходные файлы
file(GLOB_RECURSE SOURCES "src/*.*" "Drivers/*.*")

# Устанавливаем скрипт линковки
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/GD32F303VE_DEFAULT.ld)

# Опции линковщика
add_link_options(
        -Wl,-gc-sections,--print-memory-usage,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map
        -mcpu=cortex-m4 -mthumb -mthumb-interwork
        -Wl,--no-warn-rwx-segments
        -specs=nano.specs -lc -lgcc -lm -lrdimon
        -specs=nosys.specs
        -T ${LINKER_SCRIPT}
)

# Создаем исполнимый файл
add_executable(${PROJECT_NAME}.elf ${SOURCES} ${LINKER_SCRIPT})

# Пути для HEX и BIN файлов
set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

# Команда после сборки для создания HEX и BIN файлов
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
        COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
        COMMENT "Building ${HEX_FILE} and ${BIN_FILE}"
)
