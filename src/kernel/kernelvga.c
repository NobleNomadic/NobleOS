#include "kernelvga.h"
#include "stddef.h"

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000
#define VGA_COLOR 0x07  // Light gray on black background

// State of the terminal
int terminalRow = 0;
int terminalCol = 0;
int vgaColor = VGA_COLOR;

// Move cursor to a set position
void vgaSetCursor(int row, int col) {
  terminalRow = row;
  terminalCol = col;

  uint16_t pos = row * VGA_WIDTH + col;

  // VGA port I/O to update cursor using outb function
  outb(0x3D4, 0x0F);                 // Set the high byte of the cursor position
  outb(0x3D5, pos & 0xFF);           // Send the low byte of the cursor position
  outb(0x3D4, 0x0E);                 // Set the low byte of the cursor position
  outb(0x3D5, (pos >> 8) & 0xFF);    // Send the high byte of the cursor position
}

// Clear the screen by writing blank spaces to VGA memory
void vgaClearScreen() {
  volatile uint16_t* vga = (volatile uint16_t*)VGA_MEMORY;

  // Fill screen with blank characters (space) and set color
  for (int row = 0; row < VGA_HEIGHT; row++) {
    for (int col = 0; col < VGA_WIDTH; col++) {
      // Write blank space with the current color
      vga[row * VGA_WIDTH + col] = ((uint16_t)vgaColor << 8) | ' ';
    }
  }

  // Reset cursor position to top-left
  uint16_t pos = 0 * VGA_WIDTH + 0;
  outb(0x3D4, 0x0F);                 // Set the high byte of the cursor position
  outb(0x3D5, pos & 0xFF);           // Send the low byte of the cursor position
  outb(0x3D4, 0x0E);                 // Set the low byte of the cursor position
  outb(0x3D5, (pos >> 8) & 0xFF);    // Send the high byte of the cursor position
}

