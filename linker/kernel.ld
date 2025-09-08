/* Simple kernel linker script for 0x10000 load address */
ENTRY(_start)

SECTIONS
{
  . = 0x10000;
  
  .text : {
    *(.text)
  }
  
  .data : {
    *(.data)
  }
  
  .bss : {
    *(.bss)
  }
}
