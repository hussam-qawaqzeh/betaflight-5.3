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

## Pin Mapping (GPIO Function Assignments)

The RP2040 GPIO pins can be assigned to different peripheral functions. Below are the valid pin assignments for each peripheral:

### SPI Pin Mapping

**SPI0:**
| Function | Available GPIO Pins |
|----------|---------------------|
| SCK (Clock) | GP2, GP6, GP18, GP22 |
| MISO (RX) | GP0, GP4, GP16, GP20 |
| MOSI (TX) | GP3, GP7, GP19, GP23 |

**SPI1:**
| Function | Available GPIO Pins |
|----------|---------------------|
| SCK (Clock) | GP10, GP14, GP26 |
| MISO (RX) | GP8, GP12, GP24, GP28 |
| MOSI (TX) | GP11, GP15, GP27 |

### I2C Pin Mapping

I2C pins follow a pattern: `pin % 4` determines the function.
- **I2C0**: SDA on pins where `pin % 4 == 0`, SCL on pins where `pin % 4 == 1`
- **I2C1**: SDA on pins where `pin % 4 == 2`, SCL on pins where `pin % 4 == 3`

Example: GP8 % 4 = 0, so GP8 can be used as I2C0 SDA. GP9 % 4 = 1, so GP9 can be used as I2C0 SCL.

**I2C0:**
| Function | Available GPIO Pins |
|----------|---------------------|
| SDA | GP0, GP4, GP8, GP12, GP16, GP20, GP24, GP28 |
| SCL | GP1, GP5, GP9, GP13, GP17, GP21, GP25, GP29 |

**I2C1:**
| Function | Available GPIO Pins |
|----------|---------------------|
| SDA | GP2, GP6, GP10, GP14, GP18, GP22, GP26 |
| SCL | GP3, GP7, GP11, GP15, GP19, GP23, GP27 |

### UART Pin Mapping

**UART0:**
| Function | Available GPIO Pins |
|----------|---------------------|
| TX | GP0, GP12, GP16, GP28 |
| RX | GP1, GP13, GP17, GP29 |

**UART1:**
| Function | Available GPIO Pins |
|----------|---------------------|
| TX | GP4, GP8, GP20, GP24 |
| RX | GP5, GP9, GP21, GP25 |

### ADC Pin Mapping

The RP2040 has 4 ADC channels on fixed pins:

| ADC Channel | GPIO Pin |
|-------------|----------|
| ADC0 | GP26 |
| ADC1 | GP27 |
| ADC2 | GP28 |
| ADC3 | GP29 |
| Temperature | Internal (Channel 4) |

### Motor/PWM Pin Mapping

**All GPIO pins (GP0-GP29) can be used for PWM/Motor output.**

The RP2040 has 8 PWM slices, each with 2 channels (A and B):

| PWM Slice | Channel A | Channel B |
|-----------|-----------|-----------|
| Slice 0 | GP0, GP16 | GP1, GP17 |
| Slice 1 | GP2, GP18 | GP3, GP19 |
| Slice 2 | GP4, GP20 | GP5, GP21 |
| Slice 3 | GP6, GP22 | GP7, GP23 |
| Slice 4 | GP8, GP24 | GP9, GP25 |
| Slice 5 | GP10, GP26 | GP11, GP27 |
| Slice 6 | GP12, GP28 | GP13, GP29 |
| Slice 7 | GP14 | GP15 |

For DShot motor protocol, motors use PIO (Programmable I/O) instead of hardware PWM. Due to PIO hardware limitations, **all motor pins must be within a 16-pin range** (either GP0-GP15 or GP16-GP29). This applies to all motors collectively - you cannot mix motors from both ranges.

### LED Strip Pin

Any GPIO pin (GP0-GP29) can be used for WS2811/WS2812 LED strips (configured via PIO).

**To configure LED strip on a specific pin (e.g., GP25):**

Using Betaflight CLI:
```
resource LED_STRIP 1 A25
save
```

Or using Betaflight Configurator:
1. Go to **CLI** tab
2. Type: `resource LED_STRIP 1 A25`
3. Type: `save`

**Note:** Pin notation in Betaflight CLI uses `A` prefix for GPIO pins (A25 = GP25).

## Viewing Current Pin Assignments

To see which pins are currently assigned to each resource, use these CLI commands:

**View all resource assignments:**
```
resource
```

**View specific resource (e.g., motors):**
```
resource MOTOR
```

**View all resources with pins (detailed):**
```
resource show all
```

**Common resource names:**
- `MOTOR` - Motor outputs
- `LED_STRIP` - WS2811/WS2812 LED data pin
- `SPI_SCK`, `SPI_MISO`, `SPI_MOSI` - SPI pins
- `I2C_SCL`, `I2C_SDA` - I2C pins
- `SERIAL_TX`, `SERIAL_RX` - UART pins
- `ADC_BATT`, `ADC_CURR`, `ADC_RSSI` - ADC inputs

## Configuring Peripherals (SPI, I2C, UART)

### SPI Configuration

**Important:** Betaflight uses `SPI_SDI` (Serial Data In = MISO) and `SPI_SDO` (Serial Data Out = MOSI) instead of `SPI_MISO`/`SPI_MOSI`.

**SPI1 (device index 1):**
```
resource SPI_SCK 1 A02    # GP2 - Clock
resource SPI_SDI 1 A00    # GP0 - Data In (MISO)
resource SPI_SDO 1 A03    # GP3 - Data Out (MOSI)
save
```

**SPI2 (device index 2):**
```
resource SPI_SCK 2 A10    # GP10 - Clock
resource SPI_SDI 2 A08    # GP8 - Data In (MISO)
resource SPI_SDO 2 A11    # GP11 - Data Out (MOSI)
save
```

### SPI Chip Select (CS) Configuration

SPI CS pins are configured per device (gyro, flash, etc.), not per SPI bus:

**Gyro CS pin:**
```
resource GYRO_CS 1 A04    # GP4 for gyro chip select
save
```

**Flash CS pin:**
```
resource FLASH_CS 1 A05   # GP5 for flash chip select
save
```

**OSD CS pin:**
```
resource OSD_CS 1 A06     # GP6 for OSD chip select
save
```

**RX SPI CS pin:**
```
resource RX_SPI_CS 1 A07  # GP7 for RX chip select
save
```

**Note:** Any GPIO pin (GP0-GP29) can be used for CS. CS pins are directly controlled as GPIO outputs.

### I2C Configuration

**Important:** RP2040 has 2 hardware I2C buses (I2C0 and I2C1). The pins you choose determine which hardware bus is used:
- GP0,1,4,5,8,9,12,13,16,17,20,21,24,25,28,29 → **I2C0 hardware**
- GP2,3,6,7,10,11,14,15,18,19,22,23,26,27 → **I2C1 hardware**

**I2C1 (device index 1) using I2C0 hardware pins:**
```
resource I2C_SCL 1 A01    # GP1 (I2C0 hardware)
resource I2C_SDA 1 A00    # GP0 (I2C0 hardware)
save
```

**I2C2 (device index 2) using I2C1 hardware pins:**
```
resource I2C_SCL 2 A19    # GP19 (I2C1 hardware)
resource I2C_SDA 2 A18    # GP18 (I2C1 hardware)
save
```

### I2C Troubleshooting (BMP280, etc.)

If your I2C device (like BMP280 barometer) is not detected after assigning pins:

1. **Verify pin compatibility:** Make sure SDA and SCL pins are on the same hardware I2C bus:
   - I2C0: SDA (pin % 4 == 0), SCL (pin % 4 == 1)
   - I2C1: SDA (pin % 4 == 2), SCL (pin % 4 == 3)

2. **Enable the sensor in CLI (REQUIRED):**
   ```
   set baro_hardware = BMP280
   set baro_i2c_device = 1       # Match the I2C device index you configured (1 or 2)
   save
   ```
   
   **⚠️ IMPORTANT:** After saving, you MUST **reboot** the flight controller for sensor detection to work:
   - Disconnect and reconnect USB, OR
   - Use the CLI command: `mcu_reset`

3. **Check wiring:** Ensure VCC (3.3V), GND, SDA, and SCL are connected correctly.
   - BMP280 requires 3.3V (NOT 5V)
   - Use pull-up resistors (4.7kΩ) on SDA and SCL if not built into the sensor module

4. **Verify with status command (after reboot):**
   ```
   status
   ```
   Look for "Barometer: BMP280" or check that I2C devices detected is > 0.

5. **Check current baro settings:**
   ```
   get baro
   ```
   Verify `baro_hardware = BMP280` and `baro_i2c_device` matches your configuration.

6. **Common I2C addresses:**
   - BMP280: 0x76 (default) or 0x77 (if SDO pin is high)
   - BMP388: 0x76 or 0x77

### UART Configuration

**UART1 (device index 1 = UART0 hardware):**
```
resource SERIAL_TX 1 A00   # GP0
resource SERIAL_RX 1 A01   # GP1
save
```

**UART2 (device index 2 = UART1 hardware):**
```
resource SERIAL_TX 2 A04   # GP4
resource SERIAL_RX 2 A05   # GP5
save
```

### Motor Configuration

**Configure 4 motors:**
```
resource MOTOR 1 A02    # Motor 1 on GP2
resource MOTOR 2 A03    # Motor 2 on GP3
resource MOTOR 3 A04    # Motor 3 on GP4
resource MOTOR 4 A05    # Motor 4 on GP5
save
```

**Note:** For DShot protocol, all motor pins must be within the same 16-pin range (GP0-15 or GP16-29).

### Removing a Resource Assignment

To unassign a pin:
```
resource MOTOR 1 NONE
save
```

### Resetting All Resources to Default

To restore all pin assignments to their default values:
```
defaults
save
```

**Warning:** This will reset ALL settings, not just pin assignments!

To reset only resource assignments while keeping other settings:
```
resource reset
save
```


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
