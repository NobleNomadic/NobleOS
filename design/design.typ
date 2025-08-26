#align(center)[#text(size: 17pt)[
  = NobleOS Design]
  #text(size: 14pt)[#emph[NobleNomadic's Operating System]]
]

#set page(columns: 2)

= NobleOS
NobleOS is a 16 bit operating system made in x86 assembly with a modular kernel design. NobleOS provides a simple command line interface for running 16 bit userspace programs.

This is the design document outlining the plan for the structure and features of NobleOS.

== Architecture
NobleOS is a modular kernel based system. This means that the kernel is responsible primarily for managing the loading and unloading of kernel modules that provide the main functionality to the OS. 

When initially loaded, the Noble kernel will install interrupt handlers for `int 0x60`, the primary interrupt handler used for making syscalls to the kernel. Any program can setup arguments in registers, and then run `int 0x60` to trigger the interrupt and run code in the kernel. The main kernel binary syscalls are primarily for loading and unloading modules from the kernel, with other features such as interacting with drivers being provided from kernel modules.

== Kernel Modules
A kernel module is any piece of code which runs in segment `0x1000` of the operating system. These pieces of code are interacted with through their own interrupt layout specific to that module. For example while the kernel is interacted with through `int 0x60`, a driver module for reading keyboard input could use `int 0x61`.

A kernel module is 512 bytes, and starts with a 4 byte header for the name of the module, making it easier for the kernel to manage modules. Kernel modules are stored on the disk in sectors 10-19. Because each module is 512, up to 10 kernel modules to be used during the running of a system.

The kernel syscall `int 0x60` with the AH register being set to 1 is the syscall to load a new module. Each module is loaded into memory in segment `0x1000` after the kernel with an offset of `0x1000`, `0x2000`, or `0x3000`. This allows for 3 modules to be loaded at a time.

Each slot is used for a certain type of operation. The slot at offset `0x1000` is for hardware drivers, the slot at `0x2000` is for filesystem modules, and the slot `0x3000` is a slot for user programs that need to load custom modules to provide additional functionality, for example a module to provide a syscall interface for drawing graphics for games. These slots can each quickly have the current module overwritten with a new one.

== Filesystem
The filesystem is provided by loading a module into `0x1000:0x2000`. Whatever module is loaded into this memory location will be the filesystem module that provides a standard interface for loading files from the disk including binary executables, or text files.

The standard filesystem that is provided is the Noble Nomadic File System (NNFS). The NNFS provides a method for storing binary and text files on the disk that the operating system runs on. It has it's own simple interrupt system that allows a program to run `int 0x62` to trigger an interrupt and either read or write to a file.

Each file is 512 bytes of data stored on the disk from sectors 20-29. The first 4 bytes are a filename, followed by 1 byte for a file type, and 3 bytes for the directory it belongs to.

A file is read into memory at `0x2000:0x2000` from the disk by the file system module. The exception to this is the file at sector 20 on the disk. This file is typically the shell, and is loaded into memory by the filesystem at `0x2000:0x0000`. All other files are read into memory in the file buffer at offset `0x2000`. A file can also be written to the disk by copying the data in the file buffer onto a sector of the disk.

== Syscalls
Below is a list of interrupts that NobleOS uses.

kernel.asm:
- int 0x60 AH=1: Load module

nnfs.asm:
- int 0x63 AH=1: Read a file's data from disk into memory
- int 0x63 AH=2: Write the current data in the file buffer to a file on disk

== Userspace and Programs
Userspace programs are files in the filesystem which are loaded into memory at `0x2000:0x2000` and executed.
