// kernelvga.c - Functions for VGA printing within kernel
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

// Internal helper to move lines up by one line
void vgaScrollUp() {
  volatile uint16_t* vga = (volatile uint16_t*)VGA_MEMORY;

  // Shift each line of text up one row
  for (int row = 1; row < VGA_HEIGHT; row++) {
    for (int col = 0; col < VGA_WIDTH; col++) {
      vga[(row - 1) * VGA_WIDTH + col] = vga[row * VGA_WIDTH + col];
    }
  }

  // Clear the last row
  for (int col = 0; col < VGA_WIDTH; col++) {
    vga[(VGA_HEIGHT - 1) * VGA_WIDTH + col] = ((uint16_t)vgaColor << 8) | ' ';
  }
}

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
// Function to print a string to the VGA screen
void vgaPrint(char *buffer) {
  volatile uint16_t* vga = (volatile uint16_t*)VGA_MEMORY;

  while (*buffer) {
    char c = *buffer++;

    // Handle newline character
    if (c == '\n') {
      terminalRow++;
      terminalCol = 0;
    } else {
      // Write character with current color attribute
      uint16_t value = ((uint16_t)vgaColor << 8) | c;
      vga[terminalRow * VGA_WIDTH + terminalCol] = value;
      
      // Move cursor to the next position
      terminalCol++;
      if (terminalCol >= VGA_WIDTH) {
        terminalCol = 0;
        terminalRow++;
      }
    }

    // Scroll the screen if the bottom is reached
    if (terminalRow >= VGA_HEIGHT) {
      vgaScrollUp();
      terminalRow = VGA_HEIGHT - 1;
    }
  }

  // Update the cursor position
  vgaSetCursor(terminalRow, terminalCol);
}

void vgaPrintColor(char *buffer, uint8_t fg, uint8_t bg) {
  volatile uint16_t* vga = (volatile uint16_t*)VGA_MEMORY;
  uint8_t attribute = (bg << 4) | (fg & 0x0F);

  while (*buffer) {
    char c = *buffer++;

    if (c == '\n') {
      terminalRow++;
      terminalCol = 0;
    } else {
      uint16_t value = ((uint16_t)attribute << 8) | c;
      vga[terminalRow * VGA_WIDTH + terminalCol] = value;

      terminalCol++;
      if (terminalCol >= VGA_WIDTH) {
        terminalCol = 0;
        terminalRow++;
      }
    }

    if (terminalRow >= VGA_HEIGHT) {
      vgaScrollUp();
      terminalRow = VGA_HEIGHT - 1;
    }
  }

  vgaSetCursor(terminalRow, terminalCol);
}

