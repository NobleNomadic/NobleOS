/* kernel.c - OS entry point */
#include "common.h"
#include "kernelvga.h"      // high-level terminal API
#include "kernelkeyboard.h" // basic keyboard driver

/* Linker/entry: jump to kernelMain.
   Keep this symbol simple so the linker script can point _start -> this. */
void _start(void) {
  __asm__ volatile ("jmp kernelMain\n");
}

// ==== KERNEL MAIN ====
void kernelMain(void) {
  terminalInitialize();
  terminalSetColor(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
  terminalWrite("[*] KERNEL BOOTED\n");

  // Get a line of input
  char line[128];
  terminalWrite("ENTER TEXT\n$ ");
  keyboardReadLine(line, sizeof(line));

  // Echo back
  terminalWrite("INPUT: ");
  terminalWrite(line);
  terminalWrite("\n");

  while (1) {}
}

