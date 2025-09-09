// kerneldisk.h - Header file for disk reading driver built into kernel binary. Wrapper for kerneldisk.asm
#ifndef KERNELDISK_H
#define KERNELDISK_h

// Define external disk read function
extern void CHSDiskRead(void);

void kernelReadSectors(uint16_t cylinder, uint8_t head, uint8_t sector, uint8_t count, void* buffer);

#endif // KERNELDISK_H
