# NobleOS
32 bit operating system made in C. This is my little operating system that I am making after experimenting with OS dev and making [NomadOS](https://github.com/NobleNomadic/NomadOS). This is my hobby operating system that I am making for myself, and so lots of standard features and proper system design principles are not included.

## Design
NobleOS is designed to be a hybrid kernel of a monolith and microkernel. The main kernel binary has simple drivers built in for printing to the screen and reading from the disk, but the rest of the drivers are loaded as modules seperate from the kernel binary.

Once the kernel is loaded, it then uses the built in disk reading driver to load in the main filesystem driver. This filesystem keeps track of all data on the disk using a FAT style system. Data is stored in sector 20 (end of the kernel on the disk) to keep track of file metadata and where they are stored on the disk.

Additional kernel modules and userspace is setup by loading files from this system into memory.
