// kerneldisk.c - Functions for kernel to load sectors from the disk using the function in kerneldisk.asm
#inlcude "kerneldisk.h"

void kernelReadSectors(uint16_t cylinder, uint8_t head, uint8_t sector, uint8_t count, void* buffer) {
  // Calculate CHS address based on inputs
  uint32_t ebx = ((uint32_t)cylinder << 16) | ((uint32_t)head << 8) | sector;

  __asm__ __volatile__ (
    "movl %0, %%ebx\n"   // Load CHS values into EBX
    "movb %1, %%ch\n"    // Sector count into CH
    "movl %2, %%edi\n"   // Buffer pointer into EDI
    "call CHSDiskRead\n"
    :
    : "r"(ebx), "r"(count), "r"(buffer)
    : "eax", "ebx", "ecx", "edx", "edi"
  );
}
