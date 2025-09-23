// vga.h - Header for main VGA driver
#ifndef VGA_H
#define VGA_H

#include "../stddef.h" // for uint*_t

/* VGA color constants (4-bit) */
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

/* Initialize VGA driver state. Clears screen and resets cursor. */
void vgaInit(void);

/* Clear entire screen and reset cursor to 0,0 */
void vgaClearScreen(void);

/* Move cursor to (row, col) */
void vgaSetCursor(int row, int col);

/* Print a NUL-terminated string to the terminal using the current color */
void vgaPrint(char *buffer);

/* Print a NUL-terminated string with explicit foreground/background colors */
void vgaPrintColor(char *buffer, uint8_t fg, uint8_t bg);

/* Print a 32-bit value in hexadecimal (8 chars, uppercase) */
void vgaPrintHex(uint32_t value);

/* Optional helpers you can call if needed */
void vgaSetColor(uint8_t fg, uint8_t bg); /* set global color used by vgaPrint */
void vgaPutChar(char c);                    /* write single char at cursor */

#endif /* VGA_H */

