/* kernel.c - OS entry point */
#include "kernelcommon.h"
#include "kernelvga.h"      // high-level terminal API
#include "kernelkeyboard.h" // basic keyboard driver
#include "kerneldisk.h"     // Sector loading driver
#include "kernelutil.h"     // Utility functions for the kernel

#define MODULE_1_SECTOR 10
#define MODULE_2_SECTOR 20
#define MODULE_3_SECTOR 30
#define MODULE_4_SECTOR 40

#define MODULE_1_ENTRY 0x20000
#define MODULE_2_ENTRY 0x30000
#define MODULE_3_ENTRY 0x40000
#define MODULE_4_ENTRY 0x50000

// Module entry function type
typedef void (*ModuleEntryFunction)(KernelStateMessage*);

/* Linker/entry: jump to kernelMain.
   Keep this symbol simple so the linker script can point _start -> this. */
void _start(void) {
  __asm__ volatile ("jmp kernelMain\n");
}

// ==== MODULE LOADER ====
// Load a module from disk into memory and return pointer to its entry function
ModuleEntryFunction loadModule(uint8_t moduleNumber) {
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
  } else {
    terminalWrite("[-] INVALID MODULE NUMBER\n");
    return 0; // Invalid module number
  }

  kernelReadSectors(sector, 10, moduleLoadAddress);

  // Return function pointer to entry
  return (ModuleEntryFunction)moduleLoadAddress;
}

// ==== KERNEL MAIN ====
void kernelMain(void) {
  terminalInitialize();
  terminalWrite("[*] KERNEL LOADED\n");

  terminalWrite("[*] SETTING UP KERNEL STATE\n");
  KernelStateMessage kernelState;

  terminalWrite("[*] LOADING INITIAL MODULES");

  ModuleEntryFunction module1Entry = loadModule(1);
  terminalWrite(".");
  ModuleEntryFunction module2Entry = loadModule(2);
  terminalWrite(".");
  ModuleEntryFunction module3Entry = loadModule(3);
  terminalWrite(".");
  ModuleEntryFunction module4Entry = loadModule(4);
  terminalWrite(".\n");

  // Check if modules failed to load, if any failed its a fatal error
  if (!module1Entry || !module2Entry || !module3Entry || !module4Entry) {
    terminalWrite("[-] ERROR: One or more modules failed to load.\n");
    kernelPanic(kernelState);
  }

  // Call init module
  terminalWrite("[*] RUNNING INIT MODULE\n");

  // OS process-like loop
  while (1) {
    // Run each module's main function
    // Each module mutates the shared KernelStateMessage
    module1Entry(&kernelState);
    module2Entry(&kernelState);
    module3Entry(&kernelState);
    module4Entry(&kernelState);
  }
}
