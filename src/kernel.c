// kernel.c - OS entry point

// ===== BASIC TYPES (no stdlib) =====
typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef unsigned long  size_t;

// ===== MULTIBOOT HEADER =====
__attribute__((section(".multiboot"), used))
static const unsigned int multiboot_header[] = {
    0x1BADB002,  // magic number
    0x00000000,  // flags
    -(0x1BADB002 + 0x00000000)  // checksum
};

// Entry point symbol for linker to start execution here
void _start(void) {
    __asm__ volatile ("jmp kernelMain\n");
}

// ===== VGA TERMINAL =====
static const size_t VGA_WIDTH  = 80;
static const size_t VGA_HEIGHT = 25;
static uint16_t* const VGA_MEMORY = (uint16_t*)0xB8000;

size_t terminalRow;
size_t terminalColumn;
uint8_t terminalColor;

// Enum for VGA hardware colors
typedef enum {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GRAY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
} vga_color;

// Send a value to a port
void outb(uint16_t port, uint8_t value) {
  __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

// Generate a VGA byte with color attribute + ascii char
static inline uint8_t vgaColor(uint8_t fg, uint8_t bg) {
    return fg | bg << 4;
}

// Put byte into VGA buffer
static inline uint16_t vgaEntry(unsigned char uc, uint8_t color) {
    return (uint16_t) uc | (uint16_t) color << 8;
}

// Update VGA hardware cursor
void terminalSetCursor(size_t row, size_t col) {
  uint16_t pos = row * VGA_WIDTH + col;

  // high byte
  outb(0x3D4, 0x0E);
  outb(0x3D5, (pos >> 8) & 0xFF);

  // low byte
  outb(0x3D4, 0x0F);
  outb(0x3D5, pos & 0xFF);
}

// Setup the terminal and VGA
void terminalInitialize() {
  terminalRow = 0;
  terminalColumn = 0;
  terminalColor = vgaColor(VGA_COLOR_LIGHT_GRAY, VGA_COLOR_BLACK);
  for (size_t y = 0; y < VGA_HEIGHT; y++) {
    for (size_t x = 0; x < VGA_WIDTH; x++) {
      const size_t index = y * VGA_WIDTH + x;
      VGA_MEMORY[index] = vgaEntry(' ', terminalColor);
    }
  }
}

// Put a character on the VGA display
void terminalPutChar(char c) {
  // If newline, then start new row
  if (c == '\n') {
    terminalColumn = 0;

    // Handle end of row
    if (++terminalRow == VGA_HEIGHT) {
      terminalRow = 0;
    }
    return;
  }

  // Write char to video memory
  const size_t index = terminalRow * VGA_WIDTH + terminalColumn;
  VGA_MEMORY[index] = vgaEntry(c, terminalColor);

  if (++terminalColumn == VGA_WIDTH) {
    terminalColumn = 0;
    if (++terminalRow == VGA_HEIGHT) {
      terminalRow = 0;
    }
  }

  // Update the cursor position
  terminalSetCursor(terminalRow, terminalColumn);
}

// Loop over string and print each character
void terminalWrite(const char* str) {
  while (*str) {
    terminalPutChar(*str++);
  }
}

// ===== KERNEL MAIN =====
void kernelMain() {
  terminalInitialize();
  terminalWrite("Hello from kernel!\n");
  terminalColor = VGA_COLOR_LIGHT_BLUE;
  terminalWrite("Blue text!\n");

  // Hang system
  while (1) {}
}

