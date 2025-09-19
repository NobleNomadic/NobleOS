// kernelutil.h - Utility functions for the main kernel binary
#ifndef KERNELUTIL_H
#define KERNELUTIL_H

#include "kernelcommon.h"

// Dump the kernel state to the screen
void dumpKernelState(KernelStateMessage *kernelState);

// Dump kernel state and wait for keypress to continue
void debugKernelState(KernelStateMessage *kernelState);

// Shutdown the operating system and hang
void kernelPanic(KernelStateMessage *kernelState);

#endif // KERNELUTIL_H

