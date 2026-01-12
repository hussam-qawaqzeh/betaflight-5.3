/*
 * Minimal RP2040 target definitions for Betaflight PICO platform
 */
#pragma once

#ifndef TARGET_BOARD_IDENTIFIER
#define TARGET_BOARD_IDENTIFIER "2040"
#endif

#ifndef USBD_PRODUCT_STRING
#define USBD_PRODUCT_STRING     "Betaflight RP2040"
#endif

#ifdef PICO_TRACE
#include "pico_trace.h"
#define bprintf tprintf
#else
#define bprintf(fmt,...)
#endif

#ifndef RP2040
#define RP2040
#endif

#define USE_UART0
#define USE_UART1
#define UART_RX_BUFFER_SIZE 1024
#define UART_TX_BUFFER_SIZE 1024
#define UARTHARDWARE_MAX_PINS 8
#define UART_TRAIT_AF_PORT 1

#define USE_SPI
#define SPIDEV_COUNT 2
#define USE_SPI_DEVICE_0
#define USE_SPI_DEVICE_1
#define USE_SPI_DMA_ENABLE_LATE
#define MAX_SPI_PIN_SEL 4

#define USE_I2C
#define I2CDEV_COUNT 2
#define USE_I2C_DEVICE_0
#define USE_I2C_DEVICE_1

#define USE_ADC

#define USE_VCP

// Assume on-board flash (see linker files)
#define CONFIG_IN_FLASH

// Pico flash writes are all aligned and in batches of FLASH_PAGE_SIZE (256)
#define FLASH_CONFIG_STREAMER_BUFFER_SIZE   FLASH_PAGE_SIZE
#define FLASH_CONFIG_BUFFER_TYPE            uint8_t

/* DMA Settings */
#define DMA_IRQ_CORE_NUM 1

#undef USE_SOFTSERIAL1
#undef USE_SOFTSERIAL2
#undef USE_TRANSPONDER
#undef USE_TIMER
#undef USE_RCC

/* Default PIO indices - keep consistent with other PICO targets */
#define PIO_DSHOT_INDEX    0
#define PIO_UART_INDEX     1
#define PIO_LEDSTRIP_INDEX 2

/* Feature defaults */
#undef USE_DSHOT_BITBANG
#define USE_DSHOT_TELEMETRY

#undef USE_VTX
#undef USE_RPM_LIMIT

// Various untested or unsupported elements are undefined below
#undef USE_RX_SPI
#undef USE_RX_PWM
#undef USE_RX_PPM
#undef USE_RX_CC2500
#undef USE_RX_EXPRESSLRS
#undef USE_RX_SX1280
#undef USE_SERIALRX_GHST
#undef USE_SERIALRX_IBUS
#undef USE_SERIALRX_JETIEXBUS
#undef USE_SERIALRX_SBUS
#undef USE_SERIALRX_SPEKTRUM
#undef USE_SERIALRX_SUMD
#undef USE_SERIALRX_SUMH
#undef USE_SERIALRX_XBUS
#undef USE_SERIALRX_FPORT

#undef USE_TELEMETRY_GHST
#undef USE_TELEMETRY_FRSKY_HUB
#undef USE_TELEMETRY_HOTT
#undef USE_TELEMETRY_IBUS
#undef USE_TELEMETRY_IBUS_EXTENDED
#undef USE_TELEMETRY_JETIEXBUS
#undef USE_TELEMETRY_LTM
#undef USE_TELEMETRY_MAVLINK
#undef USE_TELEMETRY_SMARTPORT
#undef USE_TELEMETRY_SRXL

// Other unsupported features on PICO platform
#undef USE_OSD
#undef USE_RANGEFINDER_HCSR04
#undef USE_PWM_OUTPUT
#undef USE_DYN_NOTCH_FILTER
#undef USE_SERIAL_4WAY_BLHELI_INTERFACE
#undef USE_SERIAL_4WAY_BLHELI_BOOTLOADER
#undef USE_SERIAL_4WAY_SK_BOOTLOADER
#undef USE_MULTI_GYRO
#undef USE_MAG
#undef USE_MAG_HMC5883
#undef USE_MAG_SPI_HMC5883
#undef USE_VTX_RTC6705
#undef USE_VTX_RTC6705_SOFTSPI
#undef USE_SRXL
#undef USE_SPEKTRUM
#undef USE_SPEKTRUM_BIND
#undef USE_SERIAL_PASSTHROUGH
#undef USE_MSP_UART
#undef USE_MSP_DISPLAYPORT
#undef USE_ESC_SENSOR
#undef USE_VTX_TRAMP
#undef USE_VTX_SMARTAUDIO
#undef USE_SPEKTRUM_VTX_CONTROL
#undef USE_VTX_COMMON
#undef USE_OSD_HD
#undef USE_USB_MSC
#undef USE_CMS
