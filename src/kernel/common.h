// common.h - Common definitions for types and functions used by the kernel
#ifndef COMMON_H
#define COMMON_H

/* Basic integer types */
typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef unsigned long  size_t;

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

// Multiboot header
__attribute__((section(".multiboot"), used))
static const unsigned int multiboot_header[] = {
  0x1BADB002,           /* magic */
  0x00000000,           /* flags */
  -(0x1BADB002 + 0x00000000)
};

/* Entry point symbol used by linker/startup code. Keep as C symbol. */
void _start(void);

#endif // common.h
