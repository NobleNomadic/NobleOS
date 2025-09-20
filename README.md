# NobleOS
32 bit operating system made in C. This is my little operating system that I am making after experimenting with OS dev and making [NomadOS](https://github.com/NobleNomadic/NomadOS). This is my hobby operating system that I am making for myself, and so lots of standard features and proper system design principles are not included.

## Design
NobleOS is designed to be a modular kernel where the main kernel binary provides little functionality except to load modules from the disk. Each module is a standalone binary that can use its disk and memory space however it wants including loading other small parts within their memory section of 64K RAM. Each module can communicate through a standardized messaging system for requesting code from other modules. This means a userspace module like a shell can run code from a complex driver to save memory space within its module memory.
