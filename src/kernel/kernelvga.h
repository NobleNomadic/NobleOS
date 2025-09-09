#ifndef KERNELVGA_H
#define KERNELVGA_H

#include "common.h"

/* VGA dimensions and memory */
static const size_t VGA_WIDTH  = 80;
static const size_t VGA_HEIGHT = 25;
/* volatile so compiler doesn't cache writes */
extern volatile uint16_t* const VGA_MEMORY;

/* Terminal state (defined in kernelvga.c) */
extern size_t terminalRow;
extern size_t terminalColumn;
extern uint8_t terminalColor;

/* VGA color enum */
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

/* small helpers - defined inline */
static inline uint8_t vgaColor(uint8_t fg, uint8_t bg) {
  return (uint8_t)((fg & 0x0F) | ((bg & 0x0F) << 4));
}

static inline uint16_t vgaEntry(unsigned char uc, uint8_t color) {
  return (uint16_t)uc | (uint16_t)color << 8;
}

/* Terminal API */
void terminalInitialize(void);
void terminalPutChar(char c);
void terminalWrite(const char* str);
void terminalClear(void);

/* Cursor and color control */
void terminalSetCursor(size_t row, size_t col);
void terminalSetColor(uint8_t fg, uint8_t bg);

#endif /* KERNELVGA_H */

