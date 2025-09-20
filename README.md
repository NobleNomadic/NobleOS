# NobleOS
NobleOS is my 32 bit hobby operating system made in C.

## General Specs
- 32 Bit
- Microkernel/module based drivers
- Minimal memory management system
- VGA display
- Custom FAT-like filesystem

## Design
NobleOS is a microkernel design with the kernel in the lower half of memory. It has a simple paging system where the kernel lives in a 4kb page, and user programs are assigned less privalged pages of the same size. There is no multitasking, however multiple user programs can be in memory at once, for example a shell program can load code into memory and run it, however a shell can't run at the same time as a background process.
