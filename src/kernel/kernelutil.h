// kernelutil.h - Utility functions for the main kernel binary
#ifndef KERNELUTIL_H
#define KERNELUTIL_H

#include "kernelcommon.h"

// Dump the kernel state to the screen
void dumpKernelState(KernelStateMessage kernelState);

// Shutdown the operating system and hang
void kernelPanic(KernelStateMessage lastKernelState);

#endif // KERNELUTIL_H
