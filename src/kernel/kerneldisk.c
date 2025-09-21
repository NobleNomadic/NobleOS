// kerneldisk.c - Functions for simple raw sector reading ATA disk driver within kernel
#include "kerneldisk.h" // related header

#include "stddef.h"

/* Read `sectors` sectors (512 bytes each) from `lba` into `buffer`. */
void kernelDiskReadSectors(uint32_t lba, uint8_t sectors, void *buffer) {
  uint8_t *buf = (uint8_t*)buffer;

  // Select drive + high LBA nibble
  outb(0x1F6, 0xE0 | ((lba >> 24) & 0x0F));

  // Sector count
  outb(0x1F2, sectors);

  // LBA low/mid/high
  outb(0x1F3, (uint8_t)(lba & 0xFF));
  outb(0x1F4, (uint8_t)((lba >> 8) & 0xFF));
  outb(0x1F5, (uint8_t)((lba >> 16) & 0xFF));

  // Send READ SECTORS command (0x20)
  outb(0x1F7, 0x20);

  // Wait for BSY to clear (bit 7 cleared), then DRQ set (bit 3)
  uint8_t status;
  do {
    status = inb(0x1F7);
  } while (status & 0x80); // wait for BSY clear

  // Now read words: 256 words per sector
  uint16_t *wptr = (uint16_t*)buf;
  int words = 256 * sectors;
  for (int i = 0; i < words; i++) {
    wptr[i] = inw(0x1F0);
  }
}

