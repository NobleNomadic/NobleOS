// kernelvga.h - Header for built in minimal VGA driver for kernel binary
#ifndef KERNELVGA_H
#define KERNELVGA_H

// Enum for different VGA colors
typedef enum {
  VGA_GRAY = 7,
  VGA_BLACK = 0,
} VGA_COLOR;

void vgaSetCursor(int row, int col); // Move cursor to a set position
void vgaClearScreen(); // Fill screen with blank characters
void vgaSetupTerminal(); // Setup the terminal state

#endif // KERNELVGA_H
