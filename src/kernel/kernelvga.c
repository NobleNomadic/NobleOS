/* kernelvga.c - VGA terminal implementation */
#include "kernelvga.h"

/* Terminal state (definitions) */
size_t terminalRow = 0;
size_t terminalColumn = 0;
uint8_t terminalColor = 0;

volatile uint16_t* const VGA_MEMORY = (volatile uint16_t*)0xB8000;

/* Internal helper: scroll up one line (simple implementation).
   Current behavior before this change wrapped to top; scrolling is nicer. */
static void terminalScroll(void) {
  /* Move each line up */
  for (size_t y = 1; y < VGA_HEIGHT; ++y) {
    for (size_t x = 0; x < VGA_WIDTH; ++x) {
      VGA_MEMORY[(y - 1) * VGA_WIDTH + x] = VGA_MEMORY[y * VGA_WIDTH + x];
    }
  }
  /* Clear last line */
  const uint16_t blank = vgaEntry(' ', terminalColor);
  for (size_t x = 0; x < VGA_WIDTH; ++x) {
    VGA_MEMORY[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = blank;
  }
}

/* Set hardware cursor */
void terminalSetCursor(size_t row, size_t col, KernelStateMessage *kernelState) {
  uint16_t pos = (uint16_t)(row * VGA_WIDTH + col);

  /* high byte */
  outb(0x3D4, 0x0E);
  outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));

  /* low byte */
  outb(0x3D4, 0x0F);
  outb(0x3D5, (uint8_t)(pos & 0xFF));
}

/* Set terminal color */
void terminalSetColor(uint8_t fg, uint8_t bg, KernelStateMessage *kernelState) {
  terminalColor = vgaColor(fg, bg);
}

// Clear VGA screen by printing a blank character to each position
void terminalClear(KernelStateMessage *kernelState) {
  // Create data to print to VGA
  const uint16_t entry = vgaEntry(' ', terminalColor);

  // Print a blank character to each character location on the terminal
  for (size_t y = 0; y < VGA_HEIGHT; y++) {
    for (size_t x = 0; x < VGA_WIDTH; x++) {
      VGA_MEMORY[y * VGA_WIDTH + x] = entry;
    }
  }

  terminalSetCursor(0, 0, kernelState);
}

/* Initialize terminal buffer */
void terminalInitialize(KernelStateMessage *kernelState) {
  terminalRow = 0;
  terminalColumn = 0;
  // Set terminal color
  terminalColor = vgaColor(VGA_COLOR_LIGHT_GRAY, VGA_COLOR_BLACK);

  terminalClear(kernelState);

  // Reset cursor position
  terminalSetCursor(0, 0, kernelState);
}

/* Put a character on screen, handling newline and scrolling */
void terminalPutChar(char c, KernelStateMessage *kernelState) {
  // Check and handle newlines
  if (c == '\n') {
    terminalColumn = 0;
    if (++terminalRow >= VGA_HEIGHT) {
      terminalScroll();
      terminalRow = VGA_HEIGHT - 1;
    }
    terminalSetCursor(terminalRow, terminalColumn, kernelState);
    return;
  }

  // Calculate the index to put charater at
  const size_t index = terminalRow * VGA_WIDTH + terminalColumn;
  VGA_MEMORY[index] = vgaEntry((unsigned char)c, terminalColor);

  if (++terminalColumn >= VGA_WIDTH) {
    terminalColumn = 0;
    if (++terminalRow >= VGA_HEIGHT) {
      terminalScroll();
      terminalRow = VGA_HEIGHT - 1;
    }
  }

  terminalSetCursor(terminalRow, terminalColumn, kernelState);
}

/* Write null-terminated string */
void terminalWrite(const char* str, KernelStateMessage *kernelState) {
  while (*str) {
    terminalPutChar(*str++, kernelState);
  }
}
