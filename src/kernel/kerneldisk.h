// kerneldisk.h - Header for basic raw sector reading
#ifndef KERNELDISK_H
#define KERNELDISK_H

#include "stddef.h"

void kernelDiskReadSectors(uint32_t lba, uint8_t sectors, void *buffer);

#endif // KERNELDISK_H
