// common.h - Common definitions for types
#ifndef COMMON_H
#define COMMON_H

/* Basic integer types */
typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef unsigned long  size_t;

// Store a message that is sent between modules
typedef struct {
  char *header;
  int module1State;
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
