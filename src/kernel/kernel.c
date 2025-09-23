// kernel.c - Kernel binary entry point
#include "kernelvga.h"  // VGA terminal system
#include "kerneldisk.h" // Built in kernel disk reader

// ==== ENTRY POINT ====
void _start(void) {
  asm volatile ("jmp kernelMain\n");
}

// ==== SYSCALL FUNCTIONS ====
// Predefine syscall functions
// Install int 0x80 handler (call once in kernel init)
void installInterruptHandler(void);
// C-level syscall handler called by the stub
void syscallHandler();

// Kernel main
void kernelMain() {
  // Setup VGA
  vgaClearScreen();
  vgaPrint("[*] KERNEL STARTED\n");

  // Setup syscall handler
  vgaPrint("[*] INSTALLING SYSCALL HANDLER\n");
  installInterruptHandler();

  asm volatile (
      "int $0x80\n"
      );

  // ==== LOAD DRIVERS ====
  vgaPrint("[*] LOADING DRIVERS\n");

  while (1) {}
}

// IDT management
// Struct for an individual IDT entry
struct idt_entry_internal {
  uint16_t base_lo;    // Lower 16 bits of handler address
  uint16_t sel;        // Kernel segment selector
  uint8_t  always0;    // Reserved (should be zero)
  uint8_t  flags;      // Flags (e.g., type and privilege level)
  uint16_t base_hi;    // Upper 16 bits of handler address
} __attribute__((packed));



// ==== SYSCALL INTERRUPT MANAGEMENT ====
// The IDT (Interrupt Descriptor Table) with only one entry for int 0x80
static struct idt_entry_internal idt[256];

// The pointer to the IDT structure
struct {
  uint16_t limit;  // The size of the IDT
  uint32_t base;   // Address of the IDT
} __attribute__((packed)) idt_ptr;

// Install the syscall handler by setting up the IDT entry for int 0x80
void installInterruptHandler(void) {
  uint32_t addr = (uint32_t)syscallHandler;

  // Set up the IDT entry for int 0x80
  idt[0x80].base_lo  = addr & 0xFFFF;
  idt[0x80].base_hi  = (addr >> 16) & 0xFFFF;
  idt[0x80].sel      = 0x08;  // Kernel code segment selector
  idt[0x80].always0  = 0;
  idt[0x80].flags    = 0x8E;  // Interrupt gate, present, dpl=0

  // Set up the IDT pointer
  idt_ptr.limit = sizeof(idt) - 1;
  idt_ptr.base  = (uint32_t)&idt;

  // Load the IDT (Interrupt Descriptor Table) using the 'lidt' instruction
  asm volatile("lidt %0" : : "m"(idt_ptr));
}

void syscallHandler() {
  uint32_t syscallNumber = 0;
  uint32_t arg1 = 0;
  uint32_t arg2 = 0;

  // Get the syscall number from EAX
  asm volatile("mov %%eax, %0" : "=r"(syscallNumber));

  // Get the first argument from EBX
  asm volatile("mov %%ebx, %0" : "=r"(arg1));

  // Get the second argument from ECX (if applicable)
  asm volatile("mov %%ecx, %0" : "=r"(arg2));

  vgaPrint("Interrupt!\n");

  // Handle the syscall based on the number in EAX
  return;
}

