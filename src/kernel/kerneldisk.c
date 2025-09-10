// kerneldisk.c - Functions for kernel to load sectors from the disk using the function in kerneldisk.asm
#include "kerneldisk.h"
#include "common.h"

extern void CHSDiskRead(void);

void kernelReadSectors(uint16_t cylinder, uint8_t head, uint8_t sector, uint8_t count, void* buffer) {
  // Pack CHS into EBX
  uint32_t chs = ((uint32_t)cylinder << 16) | ((uint32_t)head << 8) | sector;
  
  __asm__ volatile (
    "call CHSDiskRead\n\t"
    :
    : "b"(chs),              // EBX gets the packed CHS value
      "D"(buffer),           // EDI gets the buffer pointer  
      "c"((uint32_t)count << 8)  // ECX gets count in CH (high byte)
    : "eax", "edx", "memory"
  );
}
