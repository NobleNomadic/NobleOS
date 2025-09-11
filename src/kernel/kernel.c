/* kernel.c - OS entry point */
#include "common.h"
#include "kernelvga.h"      // high-level terminal API
#include "kernelkeyboard.h" // basic keyboard driver
#include "kerneldisk.h"     // Sector loading driver

#define MODULE_1_SECTOR 10
#define MODULE_2_SECTOR 20
#define MODULE_3_SECTOR 30
#define MODULE_4_SECTOR 40
#define MODULE_5_SECTOR 50
#define MODULE_6_SECTOR 60
#define MODULE_7_SECTOR 70
#define MODULE_8_SECTOR 80

#define MODULE_1_ENTRY 0x20000
#define MODULE_2_ENTRY 0x30000
#define MODULE_3_ENTRY 0x40000
#define MODULE_4_ENTRY 0x50000
#define MODULE_5_ENTRY 0x60000
#define MODULE_6_ENTRY 0x70000
#define MODULE_7_ENTRY 0x80000
#define MODULE_8_ENTRY 0x90000

/* Linker/entry: jump to kernelMain.
   Keep this symbol simple so the linker script can point _start -> this. */
void _start(void) {
  __asm__ volatile ("jmp kernelMain\n");
}

// ==== MODULE LOADER ====
// Load a module from disk into memory and return pointer to its entry function
void (*loadModule(uint8_t moduleNumber))(void) {
  char* moduleLoadAddress = 0;
  uint8_t sector = 0;

  if (moduleNumber == 1) {
    moduleLoadAddress = (char*)MODULE_1_ENTRY;
    sector = MODULE_1_SECTOR;
  } else if (moduleNumber == 2) {
    moduleLoadAddress = (char*)MODULE_2_ENTRY;
    sector = MODULE_2_SECTOR;
  } else if (moduleNumber == 3) {
    moduleLoadAddress = (char*)MODULE_3_ENTRY;
    sector = MODULE_3_SECTOR;
  } else if (moduleNumber == 4) {
    moduleLoadAddress = (char*)MODULE_4_ENTRY;
    sector = MODULE_4_SECTOR;
  } else if (moduleNumber == 5) {
    moduleLoadAddress = (char*)MODULE_5_ENTRY;
    sector = MODULE_5_SECTOR;
  } else if (moduleNumber == 6) {
    moduleLoadAddress = (char*)MODULE_6_ENTRY;
    sector = MODULE_6_SECTOR;
  } else if (moduleNumber == 7) {
    moduleLoadAddress = (char*)MODULE_7_ENTRY;
    sector = MODULE_7_SECTOR;
  } else if (moduleNumber == 8) {
    moduleLoadAddress = (char*)MODULE_8_ENTRY;
    sector = MODULE_8_SECTOR;
  } else {
    terminalWrite("[-] INVALID MODULE NUMBER\n");
    return 0; // Invalid module number
  }

  kernelReadSectors(sector, 10, moduleLoadAddress);

  // Return function pointer to entry
  return (void(*)(void))moduleLoadAddress;
}

// ==== KERNEL MAIN ====
void kernelMain(void) {
  terminalInitialize();
  terminalWrite("[*] KERNEL LOADED\n");

  // Load the first 3 modules into memory on boot
  terminalWrite("[*] LOADING INITIAL MODULES\n");

  terminalWrite("[*] READING MODULE 1\n");
  void (*module1Entry)(void) = loadModule(1);

  terminalWrite("[*] READING MODULE 2\n");
  void (*module2Entry)(void) = loadModule(2);

  terminalWrite("[*] READING MODULE 3\n");
  void (*module3Entry)(void) = loadModule(3);

  // ==== MAIN SHELL LOOP ====
  while (1) {
    char line[128];
    terminalWrite("# ");
    keyboardReadLine(line, sizeof(line));
  }
}

