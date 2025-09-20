// kernel.c - Kernel binary entry point
#include "memory.h"    // Paging and memory controller
#include "kernelvga.h" // VGA terminal system

// ==== ENTRY POINT ====
void _start(void) {
  asm volatile ("jmp kernelMain\n");
}

// Kernel main
void kernelMain() {
  // Setup VGA
  vgaClearScreen();

  // Setup and enable paging
  setupPaging();

  // Map the kernel's address to match with physical
  mapPage(0x0010000, 0x0010000, PAGE_RW);

  // Hang system
  while (1) {}
}
