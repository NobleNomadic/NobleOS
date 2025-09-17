#include "kernelcommon.h"
#include "kernelkeyboard.h"
#include "kernelvga.h"

#define PS2_DATA_PORT   0x60
#define PS2_STATUS_PORT 0x64

// Scan code set 1, simple uppercase only
static const char scancodeTable[128] = {
  0, 27,'1','2','3','4','5','6','7','8','9','0','-','=', '\b',
  '\t','Q','W','E','R','T','Y','U','I','O','P','[',']','\n',0,
  'A','S','D','F','G','H','J','K','L',';','\'','`',0,'\\',
  'Z','X','C','V','B','N','M',',','.','/',0,'*',0,' ',
};

// Blocking call: waits for a new keypress and returns ASCII char
char keyboardGetChar(void) {
  static uint8_t last_scancode = 0;
  uint8_t scancode = 0;

  while (1) {
    if (inb(PS2_STATUS_PORT) & 1) { // data ready
      scancode = inb(PS2_DATA_PORT);

      if (scancode & 0x80) {
        // Key release: clear last_scancode if it matches
        if ((scancode & 0x7F) == last_scancode) last_scancode = 0;
        continue;
      }

      if (scancode != last_scancode) {
        last_scancode = scancode;
        break;
      }
    }
  }

  if (scancode < 128) return scancodeTable[scancode];
  return 0;
}

// Read a line from keyboard into buffer, echoing input
void keyboardReadLine(char* buffer, size_t maxlen) {
  size_t idx = 0;

  while (1) {
    char c = keyboardGetChar();

    if (c == '\n' || c == '\r') {
      buffer[idx] = '\0';
      terminalPutChar('\n');
      break;
    } else if (c == '\b') {
      if (idx > 0) {
        idx--;

        // Move cursor back one position
        if (terminalColumn == 0) {
          if (terminalRow > 0) {
            terminalRow--;
            terminalColumn = VGA_WIDTH - 1;
          }
        } else {
          terminalColumn--;
        }

        // Erase the character on screen
        const size_t index = terminalRow * VGA_WIDTH + terminalColumn;
        VGA_MEMORY[index] = vgaEntry(' ', terminalColor);

        // Update hardware cursor
        terminalSetCursor(terminalRow, terminalColumn);
      }
    } else if (idx < maxlen - 1) {
      buffer[idx++] = c;
      terminalPutChar(c);
    }
    // ignore extra characters if buffer full
  }
}

