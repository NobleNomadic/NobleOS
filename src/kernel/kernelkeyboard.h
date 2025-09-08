// kernelkeyboard.h - Header for built in kernel keyboard driver
#ifndef KERNELKEYBOARD_H
#define KERNELKEYBOARD_H

// Blocking: waits for a keypress and returns an ASCII char.
// Unmapped/non-printable keys return 0.
char keyboardGetChar(void);

// Read a line of input from keyboard into buffer
void keyboardReadLine(char* buffer, size_t maxlen);

#endif /* KERNELKEYBOARD_H */

