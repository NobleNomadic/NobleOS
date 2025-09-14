// common.h - Common definitions for types
#ifndef COMMON_H
#define COMMON_H

/* Basic integer types */
typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef unsigned long  size_t;

// Store main message block that is sent between modules
typedef struct {
  char *header;      // General header for whatever a module decides to put here
                     // Can be used for telling kernel to trigger syscall, or calling code from another module
  int syscallNumber; // If calling code from kernel another module, this number will contain the syscall number for that function
  int skipRequest;   // If not to 0, then the next module will instantly skip and decrease the counter
  int kernelPanic;   // If set to 1, then kernel will panic next time it checks state
  int dumpRequest;   // If set to 1, then kernel will print contents of this structure when evaluating it next

  // ERROR TRACING
  // These values can be set to the last error in a module
  int module1State; // State left from last call of module 1
  int module2State;
  int module3State;
  int module4State;
} KernelStateMessage;

/* Port I/O utility function */
static inline void outb(uint16_t port, uint8_t value) {
  /* outb value to port (AL -> DX) */
  __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

// Read a byte from an I/O port
static inline unsigned char inb(unsigned short port) {
  unsigned char ret;
  __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
  return ret;
}

#endif // common.h
