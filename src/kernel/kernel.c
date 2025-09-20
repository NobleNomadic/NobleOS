// kernel.c - OS entry point
void _start(void) {
  __asm__ volatile ("jmp kernelMain\n");
}

void kernelMain() {
  volatile unsigned short* vga = (volatile unsigned short*)0xB8000;
  vga[0] = (0x0F << 8) | 'H';
  vga[1] = (0x0F << 8) | 'i';
  vga[2] = (0x0F << 8) | '!';
  
  while (1) {}
}
