#ifndef SYSCALL_H
#define SYSCALL_H

#include "stddef.h"  // for uint8_t

// Install int 0x80 handler (call once in kernel init)
void installInterruptHandler(void);

// C-level syscall handler called by the stub
void syscallHandler();

#endif // SYSCALL_H

