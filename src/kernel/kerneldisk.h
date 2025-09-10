// kerneldisk.h - Header file for disk reading driver built into kernel binary. Wrapper for kerneldisk.asm
#ifndef KERNELDISK_H
#define KERNELDISK_H

#include "common.h"

void kernelReadSectors(uint32_t lba, uint8_t count, void* buffer);

#endif // KERNELDISK_H
