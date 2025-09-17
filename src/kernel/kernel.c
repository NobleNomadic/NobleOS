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

// Run between module switches and evaluate the kernel state. Run needed functions
void checkKernelState(KernelStateMessage kernelState) {
  // Check for panic request
  if (kernelState.panicRequest == 1) {
    kernelPanic(kernelState);
  }

  // Handle bad cases of module requests
  if (kernelState.moduleRequest < 0 || kernelState.moduleRequest > 3) {
    kernelPanic(kernelState);
  }

  // Check if a dump request was made from an object
  if (kernelState.dumpRequest) {
    dumpKernelState(kernelState);
  }
}

// ==== KERNEL MAIN ====
// Entry function pointed to by the _start function
void kernelMain(void) {
  terminalInitialize();
  terminalWrite("[*] KERNEL LOADED\n");

  terminalWrite("[*] SETTING UP KERNEL STATE\n");
  KernelStateMessage kernelState;
  kernelState.header = "KERNEL INIT STARTING";

  terminalWrite("[*] LOADING INITIAL MODULES\n");
  kernelState.header = "KERNEL LOADING MODULES";

  ModuleEntryFunction module1Entry = loadModule(1);
  ModuleEntryFunction module2Entry = loadModule(2);
  ModuleEntryFunction module3Entry = loadModule(3);
  ModuleEntryFunction module4Entry = loadModule(4);

  kernelState.header = "KERNEL FINISHED LOADING MODULES";

  // Check if modules failed to load, if any failed its a fatal error
  if (!module1Entry || !module2Entry || !module3Entry || !module4Entry) {
    terminalWrite("[-] ERROR: ONE OR MORE MODULES FAILED TO LOAD\n");
    kernelPanic(kernelState);
  }

  terminalWrite("[*] STARTING MODULE PROCESSES\n");
  kernelState.header = "STARTING MODULES";

  // OS process-like loop
  while (1) {
    // Run each module's main function
    // Each module mutates the shared KernelStateMessage
    // A module only runs if it is requested

    // ==== MODULE 1 ====
    // The first module should be the init program like the shell
    // If the first module doesn't handle the kernelState.moduleRequest properly, it will cause a kernel panic
    if (kernelState.moduleRequest == 0) {
      module1Entry(&kernelState);
    }
    checkKernelState(kernelState);


    // ==== MODULE 2 ====
    if (kernelState.moduleRequest == 1) {
      module2Entry(&kernelState);
    }
    checkKernelState(kernelState);


    // ==== MODULE 3 ====
    if (kernelState.moduleRequest == 2) {
      module3Entry(&kernelState);
    }
    checkKernelState(kernelState);


    // ==== MODULE 4 ====
    if (kernelState.moduleRequest == 3) {
      module4Entry(&kernelState);
    }
    checkKernelState(kernelState);
  }
}
