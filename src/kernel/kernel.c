/* kernel.c - OS entry point */
#include "common.h"
#include "kernelvga.h"      // high-level terminal API
#include "kernelkeyboard.h" // basic keyboard driver
#include "kerneldisk.h"     // Sector loading driver

/* Linker/entry: jump to kernelMain.
   Keep this symbol simple so the linker script can point _start -> this. */
void _start(void) {
  __asm__ volatile ("jmp kernelMain\n");
}

// ==== KERNEL MAIN ====
void kernelMain(void) {
  terminalInitialize();

  terminalWrite("[*] KERNEL BOOTED\n");

  while (1) {
    char line[128];
    terminalWrite("# ");
    keyboardReadLine(line, sizeof(line));

    char* loadAddress = (char*)0x20000;
    kernelReadSectors(20, 1, loadAddress);
    void (*loadedCode)(void) = (void(*)(void))0x20000;
    loadedCode();
  }
}

