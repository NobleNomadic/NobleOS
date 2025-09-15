// kernelutil.c - Function implementation for utility functions in kernel binary
#include "kernelutil.h"

#include "kernelcommon.h"
#include "kernelvga.h"

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

void dumpKernelState(KernelStateMessage kernelState) { 
  terminalWrite("=== KERNEL STATE DUMP ===\n\n");

  terminalWrite("HEADER: ");
  terminalWrite(kernelState.header ? kernelState.header : "(NULL)");
  terminalWrite("\n\n");

  char numStr[12];
  
  // Print module request
  terminalWrite("MODULE REQUEST: ");
  intToStr(kernelState.moduleRequest, numStr);
  terminalWrite(numStr);
  terminalWrite("\n");

  // Print syscall request
  terminalWrite("SYSCALL REQUEST: ");
  intToStr(kernelState.syscallRequest, numStr);
  terminalWrite(numStr);
  terminalWrite("\n");

  // Print panic request
  terminalWrite("PANIC REQUEST: ");
  intToStr(kernelState.panicRequest, numStr);
  terminalWrite(numStr);
  terminalWrite("\n");

  // Print dump request
  terminalWrite("DUMP REQUEST: ");
  intToStr(kernelState.dumpRequest, numStr);
  terminalWrite(numStr);
  terminalWrite("\n\n");

  // Print last states of each module - can help trace errors
  terminalWrite("MODULE 1 STATE: ");
  intToStr(kernelState.module1State, numStr);
  terminalWrite(numStr);
  terminalWrite("\n");

  terminalWrite("MODULE 2 STATE: ");
  intToStr(kernelState.module2State, numStr);
  terminalWrite(numStr);
  terminalWrite("\n");

  terminalWrite("MODULE 3 STATE: ");
  intToStr(kernelState.module3State, numStr);
  terminalWrite(numStr);
  terminalWrite("\n");

  terminalWrite("MODULE 4 STATE: ");
  intToStr(kernelState.module4State, numStr);
  terminalWrite(numStr);
  terminalWrite("\n");

  terminalWrite("=========================\n");
}

void kernelPanic(KernelStateMessage kernelLastState) {
  terminalSetColor(VGA_COLOR_RED, VGA_COLOR_BLACK);

  // Print last kernel state and hang
  terminalWrite("[!] KERNEL PANIC! LAST KERNEL STATE:\n");
  dumpKernelState(kernelLastState);

  while (1) {}
}
