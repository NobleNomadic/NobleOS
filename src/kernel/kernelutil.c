// kernelutil.c - Function implementation for utility functions in kernel binary
#include "kernelutil.h"

#include "kernelcommon.h"
#include "kernelvga.h"

// Keyboard helper definitions for debugging function
#define PS2_DATA_PORT   0x60
#define PS2_STATUS_PORT 0x64

// Helper function to convert integer to printable string
void intToStr(int num, char *str) {
  int i = 0, isNegative = 0;

  // Handle 0
  if (num == 0) {
    str[i++] = '0';
    str[i] = '\0';
    return;
  }

  // Check for negative
  if (num < 0) {
    isNegative = 1;
    num = -num;
  }

  // Loop over digits
  while (num != 0) {
    str[i++] = (num % 10) + '0';
    num /= 10;
  }

  if (isNegative) {
    str[i++] = '-';
  }

  str[i] = '\0';

  // Reverse string
  int start = 0, end = i - 1;
  while (start < end) {
    char tmp = str[start];
    str[start] = str[end];
    str[end] = tmp;
    start++;
    end--;
  }
}

void dumpKernelState(KernelStateMessage *kernelState) { 
  terminalWrite("=== KERNEL STATE DUMP ===\n\n", kernelState);

  terminalWrite("HEADER: ", kernelState);
  terminalWrite(kernelState->header ? kernelState->header : "(NULL)", kernelState);
  terminalWrite("\n\n", kernelState);

  char numStr[12];
  
  // Print module request
  terminalWrite("MODULE REQUEST: ", kernelState);
  intToStr(kernelState->moduleRequest, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n", kernelState);

  // Print syscall request
  terminalWrite("SYSCALL REQUEST: ", kernelState);
  intToStr(kernelState->syscallRequest, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n", kernelState);

  // Print panic request
  terminalWrite("PANIC REQUEST: ", kernelState);
  intToStr(kernelState->panicRequest, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n", kernelState);

  // Print dump request
  terminalWrite("DUMP REQUEST: ", kernelState);
  intToStr(kernelState->dumpRequest, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n\n", kernelState);

  // Print last states of each module - can help trace errors
  terminalWrite("MODULE 1 STATE: ", kernelState);
  intToStr(kernelState->module1State, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n", kernelState);

  terminalWrite("MODULE 2 STATE: ", kernelState);
  intToStr(kernelState->module2State, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n", kernelState);

  terminalWrite("MODULE 3 STATE: ", kernelState);
  intToStr(kernelState->module3State, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n", kernelState);

  terminalWrite("MODULE 4 STATE: ", kernelState);
  intToStr(kernelState->module4State, numStr);
  terminalWrite(numStr, kernelState);
  terminalWrite("\n", kernelState);

  terminalWrite("=========================\n", kernelState);
}

// Dump the kernel and wait for input before continuing
void debugKernelState(KernelStateMessage *kernelState) {
  // Print the kernel state message
  terminalSetColor(VGA_COLOR_GREEN, VGA_COLOR_BLACK, kernelState);
  terminalWrite("[*] DEBUGGING BREAKPOINT\n", kernelState);
  dumpKernelState(kernelState);

  // Wait for keypress before returning
  terminalWrite("> ", kernelState);
  while (1) {
    if (inb(PS2_STATUS_PORT) & 1) { // Wait for PS2 status to be ready
      inb(PS2_DATA_PORT);
      break;
    }
  }

  terminalWrite("\n", kernelState);

  terminalSetColor(VGA_COLOR_LIGHT_GRAY, VGA_COLOR_BLACK, kernelState);
  
  return;
}

// Hang the OS
void kernelPanic(KernelStateMessage *kernelLastState) {
  terminalSetColor(VGA_COLOR_RED, VGA_COLOR_BLACK, kernelLastState);

  // Print last kernel state and hang
  terminalWrite("[!] KERNEL PANIC! LAST KERNEL STATE:\n", kernelLastState);
  dumpKernelState(kernelLastState);

  while (1) {}
}

