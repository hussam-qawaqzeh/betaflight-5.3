/*
 * This file is part of Betaflight - RP2040 specific atomic operations.
 *
 * RP2040 uses Cortex-M0+ which does NOT have BASEPRI register.
 * We use PRIMASK-based global interrupt disable/enable instead.
 */

#pragma once

#include <stdint.h>

#if defined(RP2040)

// RP2040 (Cortex-M0+) doesn't have BASEPRI - use PRIMASK instead
// These are simpler but less efficient (completely disable all interrupts)

// Get current PRIMASK value
__attribute__( ( always_inline ) ) static inline uint32_t __rp2040_get_PRIMASK(void)
{
    uint32_t result;
    __ASM volatile ("MRS %0, primask" : "=r" (result));
    return result;
}

// Set PRIMASK value  
__attribute__( ( always_inline ) ) static inline void __rp2040_set_PRIMASK(uint32_t priMask)
{
    __ASM volatile ("MSR primask, %0" : : "r" (priMask) : "memory");
}

// Emulate __get_BASEPRI using PRIMASK
__attribute__( ( always_inline ) ) static inline uint8_t __get_BASEPRI(void)
{
    return (uint8_t)__rp2040_get_PRIMASK();
}

// Emulate __set_BASEPRI using PRIMASK
__attribute__( ( always_inline ) ) static inline void __set_BASEPRI(uint32_t basePri)
{
    if (basePri != 0) {
        __ASM volatile ("cpsid i" : : : "memory");  // Disable interrupts
    } else {
        __ASM volatile ("cpsie i" : : : "memory");  // Enable interrupts
    }
}

// Non-barrier versions
__attribute__( ( always_inline ) ) static inline void __set_BASEPRI_nb(uint32_t basePri)
{
    if (basePri != 0) {
        __ASM volatile ("cpsid i");  // Disable interrupts
    } else {
        __ASM volatile ("cpsie i");  // Enable interrupts
    }
}

// Emulate __set_BASEPRI_MAX - on M0+ we just disable interrupts
__attribute__( ( always_inline ) ) static inline void __set_BASEPRI_MAX(uint32_t basePri)
{
    (void)basePri;
    __ASM volatile ("cpsid i" : : : "memory");  // Disable interrupts
}

__attribute__( ( always_inline ) ) static inline void __set_BASEPRI_MAX_nb(uint32_t basePri)
{
    (void)basePri;
    __ASM volatile ("cpsid i");  // Disable interrupts
}

// restore PRIMASK (called as cleanup function), with global memory barrier
static inline void __basepriRestoreMem(uint8_t *val)
{
    __rp2040_set_PRIMASK(*val);
}

// set interrupt disable, with global memory barrier, returns true
static inline uint8_t __basepriSetMemRetVal(uint8_t prio)
{
    (void)prio;
    __ASM volatile ("cpsid i" : : : "memory");
    return 1;
}

// restore PRIMASK (called as cleanup function), no memory barrier
static inline void __basepriRestore(uint8_t *val)
{
    if (*val == 0) {
        __ASM volatile ("cpsie i");
    }
}

// set interrupt disable, no memory barrier, returns true
static inline uint8_t __basepriSetRetVal(uint8_t prio)
{
    (void)prio;
    __ASM volatile ("cpsid i");
    return 1;
}

// Run block with interrupts disabled, restoring on exit.
// All exit paths are handled. Implemented as for loop, does intercept break and continue
// Full memory barrier is placed at start and at exit of block
#define ATOMIC_BLOCK(prio) for ( uint8_t __basepri_save __attribute__ ((__cleanup__ (__basepriRestoreMem), __unused__)) = __rp2040_get_PRIMASK(), \
                                     __ToDo = __basepriSetMemRetVal(prio); __ToDo ; __ToDo = 0 )

// Run block with interrupts disabled, but do not create memory barrier.
#define ATOMIC_BLOCK_NB(prio) for ( uint8_t __basepri_save __attribute__ ((__cleanup__ (__basepriRestore), __unused__)) = __rp2040_get_PRIMASK(), \
                                    __ToDo = __basepriSetRetVal(prio); __ToDo ; __ToDo = 0 )

// ATOMIC_BARRIER macros
#ifndef __UNIQL
# define __UNIQL_CONCAT2(x,y) x ## y
# define __UNIQL_CONCAT(x,y) __UNIQL_CONCAT2(x,y)
# define __UNIQL(x) __UNIQL_CONCAT(x,__LINE__)
#endif

#define ATOMIC_BARRIER_ENTER(dataPtr, refStr)                              \
    __asm__ volatile ("\t# barrier (" refStr ") enter\n" : "+m" (*(dataPtr)))

#define ATOMIC_BARRIER_LEAVE(dataPtr, refStr)                              \
    __asm__ volatile ("\t# barrier (" refStr ") leave\n" : "m" (*(dataPtr)))

// gcc version, uses local function for cleanup.
#define ATOMIC_BARRIER(data)                                            \
    __extension__ void  __UNIQL(__barrierEnd)(typeof(data) **__d) {     \
         ATOMIC_BARRIER_LEAVE(*__d, #data);                             \
    }                                                                   \
    typeof(data) __attribute__((__cleanup__(__UNIQL(__barrierEnd)))) *__UNIQL(__barrier) = &data; \
    ATOMIC_BARRIER_ENTER(__UNIQL(__barrier), #data);                    \
    do {} while(0)                                                      \
/**/

// define these wrappers for atomic operations, using gcc builtins
#define ATOMIC_OR(ptr, val) __sync_fetch_and_or(ptr, val)
#define ATOMIC_AND(ptr, val) __sync_fetch_and_and(ptr, val)

#endif // RP2040
