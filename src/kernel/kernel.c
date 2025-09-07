/* kernel.c - OS entry point */
#include "common.h"
#include "kernelvga.h" /* high-level terminal API */

/* Linker/entry: jump to kernelMain.
   Keep this symbol simple so the linker script can point _start -> this. */
void _start(void) {
  __asm__ volatile ("jmp kernelMain\n");
}

// ==== KERNEL MAIN ====
void kernelMain(void) {
  terminalInitialize();
  terminalWrite("[*] Kernel booted\n");

  // Hang system
  while (1) {}
}

