// kernel.c - Kernel binary entry point
#include "kernelvga.h"  // VGA terminal system
#include "kerneldisk.h" // Built in kernel disk reader
#include "syscall.h"    // Syscall interrupt manager

// ==== ENTRY POINT ====
void _start(void) {
  asm volatile ("jmp kernelMain\n");
}

// Kernel main
void kernelMain() {
  // Setup VGA
  vgaClearScreen();
  vgaPrint("[*] KERNEL STARTED\n");

  // Setup syscall handler
  vgaPrint("[*] INSTALLING SYSCALL HANDLER\n");
  installInterruptHandler();

  static char buffer[512];
  for (int i = 0; i < 512; i++) buffer[i] = 0;

  kernelDiskReadSectors(5, 1, buffer);
  // Ensure printable string termination (in case disk data lacks NUL).
  buffer[511] = '\0';
  vgaPrint(buffer);

  while (1) {}
}
