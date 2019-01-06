cmake_minimum_required(VERSION 3.12)
project(blinky C ASM)

set(CMAKE_VERBOSE_MAKEFILE 1)

# set(NRF52_SDK "...")
# or
# -DNRF52_SDK=...

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_COMPILER "/usr/local/bin/arm-none-eabi-gcc")
set(CMAKE_ASM_COMPILER "/usr/local/bin/arm-none-eabi-gcc")

set(ARCH_FLAGS "\
        -mabi=aapcs \
        -mcpu=cortex-m4 \
        -mfloat-abi=hard \
        -mfpu=fpv4-sp-d16 \
        -mthumb \
")

set(GLOBAL_FLAGS "${ARCH_FLAGS} \
        -DNRF52 \
        -DNRF52832_XXAA \
")

set(CMAKE_ASM_FLAGS "${GLOBAL_FLAGS} \
        -x assembler-with-cpp \
")

set(CMAKE_C_FLAGS "${GLOBAL_FLAGS} \
        -O3 \
        -Wall \
        -Werror \
        -fdata-sections \
        -ffunction-sections \
        -fno-builtin \
        -fno-strict-aliasing \
        -fshort-enums \
        -std=c99 \
")

include_directories(
        ${NRF52_SDK}/components/toolchain/cmsis/include
        ${NRF52_SDK}/modules/nrfx/mdk

        ${NRF52_SDK}/components/libraries/delay
        ${NRF52_SDK}/modules/nrfx
        ${NRF52_SDK}/modules/nrfx/templates/nRF52832  # nrfx_config.h
        ${NRF52_SDK}/integration/nrfx
        ${NRF52_SDK}/components/libraries/util
        ${NRF52_SDK}/components/drivers_nrf/nrf_soc_nosd  # nrf_error.h (alternative: components/softdevice/s132/headers)
)

set(CMAKE_EXE_LINKER_FLAGS "${ARCH_FLAGS} \
        --specs=nano.specs \
        -T${PROJECT_SOURCE_DIR}/blinky.ld \
        -Wl,--gc-sections \
        -L${NRF52_SDK}/modules/nrfx/mdk \
        -lc \
        -lnosys \
        -lm \
")

set(CMAKE_C_LINK_EXECUTABLE "${CMAKE_C_COMPILER} <LINK_FLAGS> <OBJECTS> -o <TARGET>")

add_executable(${CMAKE_PROJECT_NAME}
        main.c
        ${NRF52_SDK}/modules/nrfx/mdk/gcc_startup_nrf52.S
        ${NRF52_SDK}/modules/nrfx/mdk/system_nrf52.c
)


add_custom_command(
        OUTPUT ${CMAKE_PROJECT_NAME}.hex
        COMMAND arm-none-eabi-objcopy -O ihex ${CMAKE_PROJECT_NAME} ${CMAKE_PROJECT_NAME}.hex
        DEPENDS ${CMAKE_PROJECT_NAME}
)

add_custom_target(
        hex
        DEPENDS ${CMAKE_PROJECT_NAME}.hex
)

add_custom_target(
        flash
        DEPENDS ${CMAKE_PROJECT_NAME}.hex
        COMMAND nrfjprog -f nrf52 --program ${CMAKE_PROJECT_NAME}.hex --sectorerase
)

add_custom_target(
        flash_softdevice
        COMMAND nrfjprog -f nrf52 --program ${SDK_ROOT}/components/softdevice/s132/hex/s132_nrf52_6.1.0_softdevice.hex --sectorerase
)

add_custom_target(
        reset
        COMMAND nrfjprog -f nrf52 --reset
)

add_custom_target(
        erase
        COMMAND nrfjprog -f nrf52 --eraseall
)
