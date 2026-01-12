#
# Raspberry PICO RP2040 Make file include
#
# RP2040 uses Cortex-M0+ (ARMv6-M) - different from RP2350 (Cortex-M33)
#

DEFAULT_OUTPUT := uf2

# Run from SRAM. For RP2040, default to 0 (flash) due to limited RAM
ifeq ($(RUN_FROM_RAM),)
RUN_FROM_RAM = 0
endif

PICO_LIB_OPTIMISATION      := -O2 -fuse-linker-plugin -ffast-math -fmerge-all-constants

PICO_MK_DIR = $(TARGET_PLATFORM_DIR)/mk

ifneq ($(PICO_TRACE),)
include $(PICO_MK_DIR)/PICO_trace.mk
endif

RP2040_TARGETS = RP2040
ifneq ($(filter $(TARGET_MCU), $(RP2040_TARGETS)),)
RP2040_TARGET = $(TARGET_MCU)
endif

ifeq ($(DEBUG_HARDFAULTS),PICO)
CFLAGS          += -DDEBUG_HARDFAULTS
endif

SDK_DIR         = $(LIB_MAIN_DIR)/pico-sdk/src

#CMSIS
CMSIS_DIR      := $(SDK_DIR)/rp2_common/cmsis/stub/CMSIS

#STDPERIPH
STDPERIPH_DIR  := $(SDK_DIR)

# RP2040 specific SDK sources - using M0+ compatible code
PICO_LIB_SRC = \
            rp2_common/pico_crt0/crt0.S \
            rp2_common/hardware_sync_spin_lock/sync_spin_lock.c \
            rp2_common/hardware_gpio/gpio.c \
            rp2_common/hardware_uart/uart.c \
            rp2_common/hardware_irq/irq.c \
            rp2_common/hardware_irq/irq_handler_chain.S \
            rp2_common/hardware_timer/timer.c \
            rp2_common/hardware_clocks/clocks.c \
            rp2_common/hardware_pll/pll.c \
            rp2_common/hardware_dma/dma.c \
            rp2_common/hardware_spi/spi.c \
            rp2_common/hardware_i2c/i2c.c \
            rp2_common/hardware_adc/adc.c \
            rp2_common/hardware_pio/pio.c \
            rp2_common/hardware_watchdog/watchdog.c \
            rp2_common/hardware_flash/flash.c \
            rp2_common/hardware_ticks/ticks.c \
            rp2_common/pico_unique_id/unique_id.c \
            rp2_common/pico_platform_panic/panic.c \
            rp2_common/pico_multicore/multicore.c \
            common/pico_sync/mutex.c \
            common/pico_time/time.c \
            common/pico_sync/lock_core.c \
            common/hardware_claim/claim.c \
            common/pico_sync/critical_section.c \
            rp2_common/hardware_sync/sync.c \
            rp2_common/pico_runtime_init/runtime_init.c \
            rp2_common/pico_runtime_init/runtime_init_clocks.c \
            rp2_common/pico_runtime_init/runtime_init_stack_guard.c \
            rp2_common/pico_runtime/runtime.c \
            rp2_common/hardware_xosc/xosc.c \
            common/pico_sync/sem.c \
            common/pico_time/timeout_helper.c \
            common/pico_util/datetime.c \
            common/pico_util/pheap.c \
            common/pico_util/queue.c \
            rp2040/pico_platform/platform.c \
            rp2_common/pico_atomic/atomic.c \
            rp2_common/pico_bootrom/bootrom.c \
            rp2_common/pico_bootrom/bootrom_lock.c \
            rp2_common/pico_divider/divider_hardware.S \
            rp2_common/pico_flash/flash.c \
            rp2_common/hardware_divider/divider.S \
            rp2_common/hardware_vreg/vreg.c \
            rp2_common/pico_standard_binary_info/standard_binary_info.c \
            rp2_common/pico_clib_interface/newlib_interface.c \
            rp2_common/pico_malloc/malloc.c \
            rp2_common/pico_stdlib/stdlib.c \
            rp2_common/pico_bit_ops/bit_ops_aeabi.S \
            rp2_common/pico_int64_ops/pico_int64_ops_aeabi.S \
            rp2_common/pico_mem_ops/mem_ops_aeabi.S

TINY_USB_SRC_DIR = $(LIB_MAIN_DIR)/pico-sdk/lib/tinyusb/src
TINYUSB_SRC := \
            $(TINY_USB_SRC_DIR)/tusb.c \
            $(TINY_USB_SRC_DIR)/class/cdc/cdc_device.c \
            $(TINY_USB_SRC_DIR)/common/tusb_fifo.c \
            $(TINY_USB_SRC_DIR)/device/usbd.c \
            $(TINY_USB_SRC_DIR)/device/usbd_control.c \
            $(TINY_USB_SRC_DIR)/portable/raspberrypi/rp2040/dcd_rp2040.c \
            $(TINY_USB_SRC_DIR)/portable/raspberrypi/rp2040/rp2040_usb.c

TINYUSB_SRC += \
            $(TINY_USB_SRC_DIR)/class/vendor/vendor_device.c

# pico_float - Software implementation for M0+
PICO_LIB_SRC += \
            rp2_common/pico_float/float_init_rom_rp2040.c \
            rp2_common/pico_float/float_math.c \
            rp2_common/pico_float/float_aeabi_rp2040.S \
            rp2_common/pico_float/float_v1_rom_shim_rp2040.S

PICO_FLOAT_WRAP_FNS = \
            __aeabi_fadd \
            __aeabi_fdiv \
            __aeabi_fmul \
            __aeabi_frsub \
            __aeabi_fsub \
            __aeabi_cfcmpeq \
            __aeabi_cfrcmple \
            __aeabi_cfcmple \
            __aeabi_fcmpeq \
            __aeabi_fcmplt \
            __aeabi_fcmple \
            __aeabi_fcmpge \
            __aeabi_fcmpgt \
            __aeabi_fcmpun \
            __aeabi_i2f \
            __aeabi_l2f \
            __aeabi_ui2f \
            __aeabi_ul2f \
            __aeabi_f2iz \
            __aeabi_f2lz \
            __aeabi_f2uiz \
            __aeabi_f2ulz \
            __aeabi_f2d \
            sqrtf \
            cosf \
            sinf \
            tanf \
            atan2f \
            expf \
            logf \
            ldexpf \
            copysignf \
            truncf \
            floorf \
            ceilf \
            roundf \
            sincosf \
            asinf \
            acosf \
            atanf \
            sinhf \
            coshf \
            tanhf \
            asinhf \
            acoshf \
            atanhf \
            exp2f \
            log2f \
            exp10f \
            log10f \
            powf \
            powintf \
            hypotf \
            cbrtf \
            fmodf \
            dremf \
            remainderf \
            remquof \
            expm1f \
            log1pf \
            fmaf

PICO_FLOAT_LD_FLAGS = $(foreach fn, $(PICO_FLOAT_WRAP_FNS), -Wl,--wrap=$(fn))

# pico_double - Software implementation for M0+
PICO_LIB_SRC += \
            rp2_common/pico_double/double_init_rom_rp2040.c \
            rp2_common/pico_double/double_math.c \
            rp2_common/pico_double/double_aeabi_rp2040.S \
            rp2_common/pico_double/double_v1_rom_shim_rp2040.S

PICO_DOUBLE_WRAP_FNS = \
            __aeabi_dadd \
            __aeabi_ddiv \
            __aeabi_dmul \
            __aeabi_drsub \
            __aeabi_dsub \
            __aeabi_cdcmpeq \
            __aeabi_cdrcmple \
            __aeabi_cdcmple \
            __aeabi_dcmpeq \
            __aeabi_dcmplt \
            __aeabi_dcmple \
            __aeabi_dcmpge \
            __aeabi_dcmpgt \
            __aeabi_dcmpun \
            __aeabi_i2d \
            __aeabi_l2d \
            __aeabi_ui2d \
            __aeabi_ul2d \
            __aeabi_d2iz \
            __aeabi_d2lz \
            __aeabi_d2uiz \
            __aeabi_d2ulz \
            __aeabi_d2f \
            sqrt \
            cos \
            sin \
            tan \
            atan2 \
            exp \
            log \
            ldexp \
            copysign \
            trunc \
            floor \
            ceil \
            round \
            sincos \
            asin \
            acos \
            atan \
            sinh \
            cosh \
            tanh \
            asinh \
            acosh \
            atanh \
            exp2 \
            log2 \
            exp10 \
            log10 \
            pow \
            powint \
            hypot \
            cbrt \
            fmod \
            drem \
            remainder \
            remquo \
            expm1 \
            log1p \
            fma

PICO_DOUBLE_LD_FLAGS = $(foreach fn, $(PICO_DOUBLE_WRAP_FNS), -Wl,--wrap=$(fn))

VPATH := $(VPATH):$(STDPERIPH_DIR)

ifdef RP2040_TARGET
TARGET_MCU_LIB_LOWER = rp2040
TARGET_MCU_LIB_UPPER = RP2040
endif

#CMSIS
VPATH       := $(VPATH):$(CMSIS_DIR)/Core/Include:$(CMSIS_DIR)/Device/$(TARGET_MCU_LIB_UPPER)/Include
CMSIS_SRC   :=

INCLUDE_DIRS += \
            $(TARGET_PLATFORM_DIR)/include \
            $(TARGET_PLATFORM_DIR)/include/pico \
            $(TARGET_PLATFORM_DIR) \
            $(TARGET_PLATFORM_DIR)/usb \
            $(TARGET_PLATFORM_DIR)/startup

SYS_INCLUDE_DIRS = \
            $(SDK_DIR)/common/pico_bit_ops_headers/include \
            $(SDK_DIR)/common/pico_base_headers/include \
            $(SDK_DIR)/common/boot_picoboot_headers/include \
            $(SDK_DIR)/common/boot_picobin_headers/include \
            $(SDK_DIR)/common/pico_usb_reset_interface_headers/include \
            $(SDK_DIR)/common/pico_time/include \
            $(SDK_DIR)/common/boot_uf2_headers/include \
            $(SDK_DIR)/common/pico_divider_headers/include \
            $(SDK_DIR)/common/pico_util/include \
            $(SDK_DIR)/common/pico_stdlib_headers/include \
            $(SDK_DIR)/common/hardware_claim/include \
            $(SDK_DIR)/common/pico_binary_info/include \
            $(SDK_DIR)/common/pico_sync/include \
            $(SDK_DIR)/rp2_common/pico_stdio_uart/include \
            $(SDK_DIR)/rp2_common/pico_stdio_usb/include \
            $(SDK_DIR)/rp2_common/hardware_boot_lock/include \
            $(SDK_DIR)/rp2_common/tinyusb/include \
            $(SDK_DIR)/rp2_common/hardware_rtc/include \
            $(SDK_DIR)/rp2_common/pico_mem_ops/include \
            $(SDK_DIR)/rp2_common/hardware_exception/include \
            $(SDK_DIR)/rp2_common/hardware_sync_spin_lock/include \
            $(SDK_DIR)/rp2_common/pico_runtime_init/include \
            $(SDK_DIR)/rp2_common/pico_standard_link/include \
            $(SDK_DIR)/rp2_common/hardware_pio/include \
            $(SDK_DIR)/rp2_common/pico_platform_compiler/include \
            $(SDK_DIR)/rp2_common/hardware_divider/include \
            $(SDK_DIR)/rp2_common/hardware_flash/include \
            $(SDK_DIR)/rp2_common/hardware_dma/include \
            $(SDK_DIR)/rp2_common/pico_bit_ops/include \
            $(SDK_DIR)/rp2_common/hardware_clocks/include \
            $(SDK_DIR)/rp2_common/pico_unique_id/include \
            $(SDK_DIR)/rp2_common/hardware_watchdog/include \
            $(SDK_DIR)/rp2_common/pico_rand/include \
            $(SDK_DIR)/rp2_common/hardware_uart/include \
            $(SDK_DIR)/rp2_common/hardware_interp/include \
            $(SDK_DIR)/rp2_common/pico_printf/include \
            $(SDK_DIR)/rp2_common/pico_double/include \
            $(SDK_DIR)/rp2_common/hardware_vreg/include \
            $(SDK_DIR)/rp2_common/hardware_spi/include \
            $(SDK_DIR)/rp2_common/pico_standard_binary_info/include \
            $(SDK_DIR)/rp2_common/pico_int64_ops/include \
            $(SDK_DIR)/rp2_common/hardware_irq/include \
            $(SDK_DIR)/rp2_common/pico_divider/include \
            $(SDK_DIR)/rp2_common/pico_flash/include \
            $(SDK_DIR)/rp2_common/hardware_sync/include \
            $(SDK_DIR)/rp2_common/pico_bootrom/include \
            $(SDK_DIR)/rp2_common/boot_bootrom_headers/include \
            $(SDK_DIR)/rp2_common/pico_crt0/include \
            $(SDK_DIR)/rp2_common/pico_clib_interface/include \
            $(SDK_DIR)/rp2_common/pico_stdio/include \
            $(SDK_DIR)/rp2_common/pico_runtime/include \
            $(SDK_DIR)/rp2_common/pico_time_adapter/include \
            $(SDK_DIR)/rp2_common/pico_platform_panic/include \
            $(SDK_DIR)/rp2_common/hardware_adc/include \
            $(SDK_DIR)/rp2_common/cmsis/include \
            $(SDK_DIR)/rp2_common/hardware_pll/include \
            $(SDK_DIR)/rp2_common/pico_platform_sections/include \
            $(SDK_DIR)/rp2_common/pico_fix/include \
            $(SDK_DIR)/rp2_common/hardware_base/include \
            $(SDK_DIR)/rp2_common/hardware_xosc/include \
            $(SDK_DIR)/rp2_common/hardware_pwm/include \
            $(SDK_DIR)/rp2_common/pico_float/include \
            $(SDK_DIR)/rp2_common/hardware_resets/include \
            $(SDK_DIR)/rp2_common/pico_stdlib/include \
            $(SDK_DIR)/rp2_common/hardware_i2c/include \
            $(SDK_DIR)/rp2_common/pico_atomic/include \
            $(SDK_DIR)/rp2_common/pico_multicore/include \
            $(SDK_DIR)/rp2_common/hardware_gpio/include \
            $(SDK_DIR)/rp2_common/pico_malloc/include \
            $(SDK_DIR)/rp2_common/hardware_timer/include \
            $(SDK_DIR)/rp2_common/hardware_ticks/include \
            $(SDK_DIR)/rp2_common/hardware_xip_cache/include \
            $(CMSIS_DIR)/Core/Include \
            $(CMSIS_DIR)/Device/$(TARGET_MCU_LIB_UPPER)/Include \
            $(SDK_DIR)/$(TARGET_MCU_LIB_LOWER)/pico_platform/include \
            $(SDK_DIR)/$(TARGET_MCU_LIB_LOWER)/hardware_regs/include \
            $(SDK_DIR)/$(TARGET_MCU_LIB_LOWER)/hardware_structs/include \
            $(SDK_DIR)/$(TARGET_MCU_LIB_LOWER)/boot_stage2/include \
            $(LIB_MAIN_DIR)/pico-sdk/lib/tinyusb/src

# Cortex-M0+ flags for RP2040
ARCH_FLAGS      = -mthumb -mcpu=cortex-m0plus -march=armv6-m
ARCH_FLAGS      += -DPICO_COPY_TO_RAM=$(RUN_FROM_RAM)
ARCH_FLAGS      += -DPICO_RP2040=1

PICO_STDIO_USB_FLAGS = \
            -DLIB_PICO_PRINTF=1 \
            -DLIB_PICO_PRINTF_PICO=1  \
            -DLIB_PICO_STDIO=1  \
            -DLIB_PICO_STDIO_USB=1 \
            -DCFG_TUSB_DEBUG=0  \
            -DCFG_TUSB_MCU=OPT_MCU_RP2040  \
            -DCFG_TUSB_OS=OPT_OS_NONE  \
            -DLIB_PICO_FIX_RP2040_USB_DEVICE_ENUMERATION=1 \
            -DPICO_RP2040_USB_DEVICE_UFRAME_FIX=1  \
            -DPICO_STDIO_USB_CONNECT_WAIT_TIMEOUT_MS=3000 \
            -DLIB_PICO_UNIQUEID=1 \
            -DCFG_TUD_MSC=0

PICO_STDIO_WRAP_FNS  = \
            sprintf \
            snprintf \
            vsnprintf \
            printf \
            vprintf \
            puts \
            putchar \
            getchar

PICO_STDIO_LD_FLAGS = $(foreach fn, $(PICO_STDIO_WRAP_FNS), -Wl,--wrap=$(fn))

PICO_BIT_OPS_LD_FLAGS = \
            -Wl,--wrap=__ctzdi2

PICO_MEM_OPS_LD_FLAGS = \
            -Wl,--wrap=memcpy \
            -Wl,--wrap=memset \
            -Wl,--wrap=__aeabi_memcpy \
            -Wl,--wrap=__aeabi_memset \
            -Wl,--wrap=__aeabi_memcpy4 \
            -Wl,--wrap=__aeabi_memset4 \
            -Wl,--wrap=__aeabi_memcpy8 \
            -Wl,--wrap=__aeabi_memset8

EXTRA_LD_FLAGS += $(PICO_STDIO_LD_FLAGS) $(PICO_TRACE_LD_FLAGS) $(PICO_FLOAT_LD_FLAGS) $(PICO_DOUBLE_LD_FLAGS) $(PICO_BIT_OPS_LD_FLAGS) $(PICO_MEM_OPS_LD_FLAGS)

ifdef RP2040_TARGET

DEVICE_FLAGS    += \
            -D$(RP2040_TARGET) \
            -DPICO_RP2040=1 \
            -DLIB_BOOT_STAGE2_HEADERS=1 \
            -DLIB_PICO_ATOMIC=1 \
            -DLIB_PICO_BIT_OPS=1 \
            -DLIB_PICO_BIT_OPS_PICO=1 \
            -DLIB_PICO_CLIB_INTERFACE=1 \
            -DLIB_PICO_CRT0=1 \
            -DLIB_PICO_DIVIDER=1 \
            -DLIB_PICO_DIVIDER_HARDWARE=1 \
            -DLIB_PICO_DOUBLE=1 \
            -DLIB_PICO_DOUBLE_PICO=1 \
            -DLIB_PICO_FLOAT=1 \
            -DLIB_PICO_FLOAT_PICO=1 \
            -DLIB_PICO_INT64_OPS=1 \
            -DLIB_PICO_INT64_OPS_PICO=1 \
            -DLIB_PICO_MALLOC=1 \
            -DLIB_PICO_MEM_OPS=1 \
            -DLIB_PICO_MEM_OPS_PICO=1 \
            -DLIB_PICO_NEWLIB_INTERFACE=1 \
            -DLIB_PICO_PLATFORM=1 \
            -DLIB_PICO_PLATFORM_COMPILER=1 \
            -DLIB_PICO_PLATFORM_PANIC=1 \
            -DLIB_PICO_PLATFORM_SECTIONS=1 \
            -DLIB_PICO_PRINTF=1 \
            -DLIB_PICO_PRINTF_PICO=1 \
            -DLIB_PICO_RUNTIME=1 \
            -DLIB_PICO_RUNTIME_INIT=1 \
            -DLIB_PICO_STANDARD_BINARY_INFO=1 \
            -DLIB_PICO_STANDARD_LINK=1 \
            -DLIB_PICO_STDIO=1 \
            -DLIB_PICO_STDIO_UART=1 \
            -DLIB_PICO_STDLIB=1 \
            -DLIB_PICO_SYNC=1 \
            -DLIB_PICO_SYNC_CRITICAL_SECTION=1 \
            -DLIB_PICO_SYNC_MUTEX=1 \
            -DLIB_PICO_SYNC_SEM=1 \
            -DLIB_PICO_TIME=1 \
            -DLIB_PICO_TIME_ADAPTER=1 \
            -DLIB_PICO_UTIL=1 \
            -DPICO_32BIT=1 \
            -DPICO_BUILD=1 \
            -DPICO_NO_FLASH=0 \
            -DPICO_NO_HARDWARE=0 \
            -DPICO_ON_DEVICE=1 \
            -DPICO_USE_BLOCKED_RAM=0

ifeq ($(RUN_FROM_RAM),1)
LD_SCRIPT       = $(LINKER_DIR)/pico_rp2040_RunFromRAM.ld
else
LD_SCRIPT       = $(LINKER_DIR)/pico_rp2040_RunFromFLASH.ld
endif

STARTUP_SRC     = PICO/startup/bs2_default_padded_checksummed_rp2040.S

OPTIMISE_SPEED  = -O2

PICO_LIB_SRC += \
            rp2_common/pico_stdio/stdio.c \
            rp2_common/pico_printf/printf.c

ifneq ($(PICO_TRACE),)
PICO_LIB_SRC += \
            rp2_common/pico_stdio_uart/stdio_uart.c
endif

PICO_STDIO_USB_SRC = \
            rp2_common/pico_stdio_usb/reset_interface.c \
            rp2_common/pico_fix/rp2040_usb_device_enumeration/rp2040_usb_device_enumeration.c

PICO_LIB_SRC += $(PICO_STDIO_USB_SRC)

SYS_INCLUDE_DIRS += \
            $(SDK_DIR)/rp2_common/pico_fix/rp2040_usb_device_enumeration/include

else
$(error Unknown MCU for Raspberry PICO RP2040 target)
endif

DEVICE_FLAGS    += -DHSE_VALUE=$(HSE_VALUE) -DPICO

DEVICE_FLAGS    += $(PICO_STDIO_USB_FLAGS)

MCU_COMMON_SRC = \
            drivers/accgyro/accgyro_mpu.c \
            drivers/dshot_bitbang_decode.c \
            drivers/inverter.c \
            drivers/bus_spi.c \
            drivers/bus_spi_config.c \
            drivers/bus_i2c_utils.c \
            drivers/serial_pinconfig.c \
            drivers/usb_io.c \
            drivers/dshot.c \
            drivers/adc.c \
            PICO/adc_pico.c \
            PICO/bus_i2c_pico.c \
            PICO/bus_spi_pico.c \
            PICO/bus_quadspi_pico.c \
            PICO/config_flash.c \
            PICO/debug_pico.c \
            PICO/dma_pico.c \
            PICO/dshot_bidir_pico.c \
            PICO/dshot_pico.c \
            PICO/exti_pico.c \
            PICO/io_pico.c \
            PICO/persistent.c \
            PICO/pwm_motor_pico.c \
            PICO/pwm_servo_pico.c \
            PICO/pwm_beeper_pico.c \
            PICO/serial_usb_vcp_pico.c \
            PICO/system.c \
            PICO/uart/serial_uart_pico.c \
            PICO/uart/uart_hw.c \
            PICO/uart/uart_pio.c \
            PICO/uart/uart_rx_program.c \
            PICO/uart/uart_tx_program.c \
            PICO/usb/usb_cdc.c \
            PICO/usb/usb_descriptors.c \
            PICO/usb/usb_msc_pico.c \
            PICO/multicore.c \
            PICO/debug_pin.c \
            PICO/light_ws2811strip_pico.c

MSC_SRC = \
            drivers/usb_msc_common.c \
            msc/usbd_storage.c \
            msc/usbd_storage_emfat.c \
            msc/emfat.c \
            msc/emfat_file.c

DEVICE_STDPERIPH_SRC := \
            $(PICO_LIB_SRC) \
            $(STDPERIPH_SRC) \
            $(TINYUSB_SRC) \
            $(PICO_TRACE_SRC)

PICO_LIB_OBJS = $(addsuffix .o, $(basename $(PICO_LIB_SRC)))
PICO_LIB_OBJS += $(addsuffix .o, $(basename $(PICO_TRACE_SRC)))
PICO_LIB_TARGETS := $(foreach pobj, $(PICO_LIB_OBJS), %/$(pobj))
$(PICO_LIB_TARGETS): CC_DEFAULT_OPTIMISATION := $(PICO_LIB_OPTIMISATION)
