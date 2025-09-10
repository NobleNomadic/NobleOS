// kerneldisk.c - Functions for kernel to load sectors from the disk using the function in kerneldisk.asm
#include "kerneldisk.h"
#include "common.h"

extern void CHSDiskRead(void);

// Constants for CHS calculation
#define SECTORS_PER_TRACK 63
#define HEADS_PER_CYLINDER 16

void kernelReadSectors(uint32_t lba, uint8_t count, void* buffer) {
    uint16_t cylinder;
    uint8_t head, sector;

    // Calculate CHS from LBA
    uint32_t temp = lba;
    cylinder = temp / (HEADS_PER_CYLINDER * SECTORS_PER_TRACK);
    temp = temp % (HEADS_PER_CYLINDER * SECTORS_PER_TRACK);
    head = temp / SECTORS_PER_TRACK;
    sector = (temp % SECTORS_PER_TRACK) + 1;  // sectors start at 1

    // Pack CHS into EBX
    uint32_t chs = ((uint32_t)cylinder << 16) | ((uint32_t)head << 8) | sector;

    __asm__ volatile (
        "call CHSDiskRead\n\t"
        :
        : "b"(chs),                  // EBX gets the packed CHS value
          "D"(buffer),               // EDI gets the buffer pointer  
          "c"((uint32_t)count << 8)  // ECX gets count in CH (high byte)
        : "eax", "edx", "memory"
    );
}

