// kernelvga.h - Header for built in minimal VGA driver for kernel binary
#ifndef KERNELVGA_H
#define KERNELVGA_H

#include "stddef.h"

// Enum for different VGA colors
typedef enum {
  VGA_BLACK        = 0,
  VGA_BLUE         = 1,
  VGA_GREEN        = 2,
  VGA_CYAN         = 3,
  VGA_RED          = 4,
  VGA_MAGENTA      = 5,
  VGA_BROWN        = 6,
  VGA_LIGHT_GRAY   = 7,
  VGA_DARK_GRAY    = 8,
  VGA_LIGHT_BLUE   = 9,
  VGA_LIGHT_GREEN  = 10,
  VGA_LIGHT_CYAN   = 11,
  VGA_LIGHT_RED    = 12,
  VGA_LIGHT_MAGENTA= 13,
  VGA_YELLOW       = 14,
  VGA_WHITE        = 15
} VGA_COLOR;

void vgaSetCursor(int row, int col); // Move cursor to a set position
void vgaClearScreen(); // Fill screen with blank characters
void vgaPrint(char *buffer); // Print a string to the terminal
void vgaPrintColor(char *buffer, uint8_t fg, uint8_t bg ); // Print a colored string

#endif // KERNELVGA_H
