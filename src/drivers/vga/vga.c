// vga.c - Main VGA driver functions
#include "vga.h" // related header

#include "../stddef.h"

/* VGA text mode constants */
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY ((volatile uint16_t*)0xB8000)

/* Default attribute: light gray on black */
static uint8_t g_fg = VGA_LIGHT_GRAY;
static uint8_t g_bg = VGA_BLACK;

/* Cursor / terminal position (row, col) */
static int terminalRow = 0;
static int terminalCol = 0;

void entry(char *message) {
  vgaPrint(message);
  return;
}

/* Internal: compute the VGA attribute byte */
static inline uint8_t vga_attribute(uint8_t fg, uint8_t bg) {
  return (uint8_t)((bg << 4) | (fg & 0x0F));
}

/* Internal: write cursor position to VGA hardware */
void vgaSetCursor(int row, int col) {
  /* clamp */
  if (row < 0) row = 0;
  if (col < 0) col = 0;
  if (row >= VGA_HEIGHT) row = VGA_HEIGHT - 1;
  if (col >= VGA_WIDTH) col = VGA_WIDTH - 1;

  terminalRow = row;
  terminalCol = col;

  uint16_t pos = (uint16_t)(row * VGA_WIDTH + col);

  /* VGA ports: index 0x0F = low byte, 0x0E = high byte */
  outb(0x3D4, 0x0F);
  outb(0x3D5, (uint8_t)(pos & 0xFF));
  outb(0x3D4, 0x0E);
  outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

/* Internal: scroll screen up by one line */
static void vgaScrollUp(void) {
  volatile uint16_t *vga = VGA_MEMORY;

  /* Move every row up one */
  for (int r = 1; r < VGA_HEIGHT; r++) {
    for (int c = 0; c < VGA_WIDTH; c++) {
      vga[(r - 1) * VGA_WIDTH + c] = vga[r * VGA_WIDTH + c];
    }
  }

  /* Clear last line */
  uint8_t attr = vga_attribute(g_fg, g_bg);
  uint16_t blank = (uint16_t)((attr << 8) | ' ');
  for (int c = 0; c < VGA_WIDTH; c++) {
    vga[(VGA_HEIGHT - 1) * VGA_WIDTH + c] = blank;
  }
}

/* Clear the screen and reset cursor */
void vgaClearScreen(void) {
  volatile uint16_t *vga = VGA_MEMORY;
  uint8_t attr = vga_attribute(g_fg, g_bg);
  uint16_t blank = (uint16_t)((attr << 8) | ' ');

  for (int r = 0; r < VGA_HEIGHT; r++) {
    for (int c = 0; c < VGA_WIDTH; c++) {
      vga[r * VGA_WIDTH + c] = blank;
    }
  }

  vgaSetCursor(0, 0);
}

/* Set default color used by vgaPrint (fg/bg are 4-bit VGA color codes) */
void vgaSetColor(uint8_t fg, uint8_t bg) {
  g_fg = fg & 0x0F;
  g_bg = bg & 0x0F;
}

/* Put a single character at the cursor, advance cursor, handle newline/scroll */
void vgaPutChar(char ch) {
  volatile uint16_t *vga = VGA_MEMORY;

  if (ch == '\n') {
    terminalRow++;
    terminalCol = 0;
  } else {
    uint8_t attr = vga_attribute(g_fg, g_bg);
    uint16_t val = (uint16_t)((attr << 8) | (uint8_t)ch);
    vga[terminalRow * VGA_WIDTH + terminalCol] = val;

    terminalCol++;
    if (terminalCol >= VGA_WIDTH) {
      terminalCol = 0;
      terminalRow++;
    }
  }

  /* If we've run past the bottom, scroll and clamp */
  if (terminalRow >= VGA_HEIGHT) {
    vgaScrollUp();
    terminalRow = VGA_HEIGHT - 1;
  }

  /* Update hardware cursor */
  vgaSetCursor(terminalRow, terminalCol);
}

/* Print a NUL-terminated string using the global color */
void vgaPrint(char *buffer) {
  if (!buffer) return;
  while (*buffer) {
    vgaPutChar(*buffer++);
  }
}

/* Print string using explicit fg/bg colors */
void vgaPrintColor(char *buffer, uint8_t fg, uint8_t bg) {
  if (!buffer) return;

  /* Temporarily swap colors, print, then restore */
  uint8_t old_fg = g_fg;
  uint8_t old_bg = g_bg;
  vgaSetColor(fg, bg);

  while (*buffer) {
    vgaPutChar(*buffer++);
  }

  vgaSetColor(old_fg, old_bg);
}

/* Print uint32_t as 8 hex digits (uppercase) */
void vgaPrintHex(uint32_t value) {
  char hex_str[9];
  const char hex_chars[] = "0123456789ABCDEF";

  for (int i = 7; i >= 0; --i) {
    hex_str[i] = hex_chars[value & 0xF];
    value >>= 4;
  }
  hex_str[8] = '\0';

  vgaPrint(hex_str);
}

/* Init helper (clears screen) */
void vgaInit(void) {
  vgaClearScreen();
  vgaSetColor(VGA_LIGHT_GRAY, VGA_BLACK);
}

