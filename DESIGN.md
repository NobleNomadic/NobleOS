# Design
NobleOS uses a microkernel design. It has a minimal memory management scheme with no paging, processes, or virtual memory. Instead memory is flat and the kernel simply has a structure to store data about currently used memory.

## Bootloader
The bootloader does not do much except switch to 32 bit protected mode, and load the kernel into memory before giving it control.

## Kernel
The kernel binary is small and only has a small VGA driver for displaying logs while setting up the operating system, and an ATA disk driver for reading the rest of the operating system into memory.

### Syscalls
Once it sets up userspace, the kernel can be interacted with again through syscalls to access drivers. Whenever a program uses `int 0x80`, the kernel will handle the requests and return to the code that called it. Depending on the value in eax, a certain syscall will be run using the ebx and ecx registers for additional arguments and data.

| Syscall number | Action         | Arguments                                     |
| -------------- | -------------- | --------------------------------------------- |
| 1              | print          | EBX: Buffer to print                          |
| 2              | read keyboard  | EBX: Buffer to write into                     |
| 3              | disk read      | EBX: File ID to read ECX: Buffer to write to  |
| 4              | disk write     | EBX: File ID to write to ECX: Buffer to write |

## Drivers
There are 3 main drivers/modules in NobleOS. A VGA driver for printing to the screen, a keyboard driver for reading input from the keyboard, and an ATA disk driver which also manages the filesystem.

### VGA
The VGA driver can handle printing to the screen with newlines, and standard VGA colors.

### Keyboard
The keyboard driver uses a blocking input system to get a single line of input and return a string into a provided buffer.

### Disk
The disk driver can read and write raw sectors to the disk, but the raw binary also contains code for interacting with the filesystem to avoid a seperate filesystem module which is really just a fancy wrapper for the disk functions.
