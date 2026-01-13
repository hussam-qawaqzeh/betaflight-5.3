# RP2040 Target for Betaflight

This document describes the RP2040 microcontroller support in Betaflight.

## Hardware Specifications Support Status

The RP2040 is the official microcontroller chip designed by Raspberry Pi. Below is the support status for each specification:

### Processor

| Specification | Status | Implementation |
|---------------|--------|----------------|
| Dual-core ARM Cortex M0+ processor | ✅ Supported | `multicore.c` - Queue-based inter-core communication |
| Flexible clock running up to 133 MHz | ✅ Supported | `system.c` - SystemCoreClock configuration |

### Memory

| Specification | Status | Implementation |
|---------------|--------|----------------|
| Built-in 264KB SRAM | ✅ Supported | Linker script: 256KB RAM + 4KB SCRATCH_X + 4KB SCRATCH_Y |
| 2MB Flash | ✅ Supported | `target.mk` - MCU_FLASH_SIZE=2048 |

### USB

| Specification | Status | Implementation |
|---------------|--------|----------------|
| Type-C connector support | ✅ Supported | Hardware independent (board design) |
| USB 1.1 host and device support | ✅ Supported | TinyUSB integration in `serial_usb_vcp_pico.c` |
| Drag-and-drop programming via USB mass storage | ✅ Supported | UF2 output format (`DEFAULT_OUTPUT := uf2`) |

### GPIO

| Specification | Status | Implementation |
|---------------|--------|----------------|
| 29 GPIO pins (20 via headers, rest via soldering) | ✅ Supported | `io_pico.c` - GPIO0-29 (30 pins total, GPIO0-29 = 30 IO lines) |

### Peripherals

| Specification | Status | Implementation |
|---------------|--------|----------------|
| SPI × 2 | ✅ Supported | `bus_spi_pico.c` - Full DMA support |
| I2C × 2 | ✅ Supported | `bus_i2c_pico.c` - Interrupt-driven |
| UART × 2 | ✅ Supported | `uart_hw.c` - Hardware UARTs + PIO UARTs |
| 12-bit ADC × 4 channels | ✅ Supported | `adc_pico.c` - DMA-based continuous sampling |
| Controllable PWM channel × 16 | ✅ Supported | `pwm_motor_pico.c`, `pwm_servo_pico.c`, `pwm_beeper_pico.c` |

### Advanced Features

| Specification | Status | Implementation |
|---------------|--------|----------------|
| Accurate clock and timer on-chip | ✅ Supported | `system.c` - Hardware timer for timing functions |
| Temperature sensor | ✅ Supported | `adc_pico.c` - Internal temperature channel |
| On-chip accelerated floating-point library | ✅ Supported | `RP2040.mk` - pico_float, pico_double ROM routines |
| 8 × Programmable I/O (PIO) state machines | ✅ Supported | Used for DShot, UART, LED strip |

### Low-Power Modes

| Specification | Status | Implementation |
|---------------|--------|----------------|
| Low-power sleep and dormant modes | ⚠️ Not Used | Available via pico-sdk but not utilized in flight controller context |

## PIO State Machine Allocation

The RP2040 has 2 PIO blocks with 4 state machines each (8 total). Betaflight uses them as follows:

| PIO Index | Usage | Implementation |
|-----------|-------|----------------|
| PIO_DSHOT_INDEX (0) | DShot motor protocol | `dshot_pico.c` |
| PIO_UART_INDEX (1) | Additional UARTs | `uart_pio.c` |
| PIO_LEDSTRIP_INDEX (2) | WS2811 LED strips | `light_ws2811strip_pico.c` |

## Building for RP2040

```bash
make TARGET=RP2040
```

The build produces a `.uf2` file that can be flashed by:
1. Holding the BOOTSEL button while connecting USB
2. Dragging the `.uf2` file to the mounted drive

## Memory Map

```
FLASH:        0x10000000 - 0x101FBFFF (2032KB for code/data)
FLASH_CONFIG: 0x101FC000 - 0x101FFFFF (16KB for configuration)
RAM:          0x20000000 - 0x2003FFFF (256KB)
SCRATCH_X:    0x20040000 - 0x20040FFF (4KB - Core 1 stack)
SCRATCH_Y:    0x20041000 - 0x20041FFF (4KB - Core 0 stack)

Total Flash: 2032KB + 16KB = 2048KB (2MB)
Total SRAM:  256KB + 4KB + 4KB = 264KB
```

## Limitations

The following features are disabled for RP2040:

- OSD support
- VTX control
- Softserial
- Some receiver protocols (PPM, PWM input)
- 4-way ESC interface

## Notes

- The RP2040 uses Cortex-M0+ which lacks a DWT cycle counter. Timing is done via the hardware timer.
- DMA is handled on Core 1 to minimize interference with flight control on Core 0.
- Flash writes require execution from RAM and are handled via the multicore system.
