// kernel.c - OS entry point

// Multiboot header must be in the first 8KB of the binary
__attribute__((section(".multiboot"), used))
static const unsigned int multiboot_header[] = {
    0x1BADB002,  // magic number
    0x00000000,  // flags
    -(0x1BADB002 + 0x00000000)  // checksum = -(magic + flags)
};

// Entry point symbol for linker to start execution here
void _start(void) {
  // Call the main function
  __asm__ volatile (
    "jmp kernelMain\n"
  );
}

// FUNCTION DEFINITIONS
void outb(unsigned short port, unsigned char value); // Helper to automate output to ports
void disableCursor(); // Disable the VGA cursor

// Kernel main
void kernelMain() {
  disableCursor();
  while (1) {}
}


// ==== UTILITY FUNCTIONS ====
// Helper function to output a value to a port
void outb(unsigned short port, unsigned char value) {
  __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

// Hide the VGA cursor
void disableCursor() {
    outb(0x3D4, 0x0A);    // Select cursor start register
    outb(0x3D5, 0x20);    // Set bit 5 to disable cursor
}
