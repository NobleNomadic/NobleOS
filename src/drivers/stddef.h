// stddef.h - Basic commonly used definitions
#ifndef STDDEF_H
#define STDDEF_H

// Basic fixed-size integer types
typedef unsigned int   uint32_t;
typedef int            int32_t;
typedef unsigned short uint16_t;
typedef short          int16_t;
typedef unsigned char  uint8_t;
typedef char           int8_t;

// Output a byte to a port
static inline void outb(uint16_t port, uint8_t val) {
  asm volatile(
    "movb %0, %%al;"   // Move the 8-bit value into the al register
    "outb %%al, %1;"    // Send the value in al to the port
    : 
    : "r" (val), "Nd" (port)
    : "%al"
  );
}

// Read a byte from an I/O port
static inline unsigned char inb(unsigned short port) {
  unsigned char ret;
  __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
  return ret;
}

// Read a 16 bit word from a port
static inline uint16_t inw(uint16_t port) {
  uint16_t ret;
  asm volatile("inw %1, %0" : "=a"(ret) : "Nd"(port));
  return ret;
}

#endif // STDDEF_H
