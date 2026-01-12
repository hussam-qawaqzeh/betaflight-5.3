TARGET_MCU        := RP2040
TARGET_MCU_FAMILY := RP2040

# Typical RP2040 on Pico has 2MB flash
MCU_FLASH_SIZE  = 2048

# Indicate RP2040 build where relevant to pico-sdk
DEVICE_FLAGS    += -DPICO_RP2040=1

# For pico-sdk, define flash-related attributes
DEVICE_FLAGS    += \
                   -DPICO_FLASH_SPI_CLKDIV=2 \
                   -DPICO_FLASH_SIZE_BYTES=2097152

