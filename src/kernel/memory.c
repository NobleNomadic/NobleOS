// memory.c - Basic paging setup for 32-bit protected mode
#include "memory.h" // related header

// A page directory and one page table for the first 4 MB
// Must be 4 KB aligned
__attribute__((aligned(PAGE_SIZE)))
static uint32_t pageDirectory[NUM_ENTRIES];

__attribute__((aligned(PAGE_SIZE)))
static uint32_t firstPageTable[NUM_ENTRIES];

// Load a page directory into CR3
static inline void loadPageDirectory(uint32_t *pageDir) {
  __asm__ volatile ("mov %0, %%cr3" :: "r"(pageDir));
}

// Enable paging by setting the PG bit in CR0
void enablePaging() {
  uint32_t cr0;
  __asm__ volatile ("mov %%cr0, %0" : "=r"(cr0));
  cr0 |= 0x80000000; // set bit 31 (paging)
  __asm__ volatile ("mov %0, %%cr0" :: "r"(cr0));
}

// Build a simple identity map for the first 4 MB
void setupPaging() {
  // clear page directory
  for (int i = 0; i < NUM_ENTRIES; i++) {
    pageDirectory[i] = 0x00000002; // supervisor, R/W, not present
  }

  // identity map first 4 MB using first page table
  for (int i = 0; i < NUM_ENTRIES; i++) {
    uint32_t physAddr = i * PAGE_SIZE;
    firstPageTable[i] = physAddr | PAGE_PRESENT | PAGE_RW;
  }

  // set page directory entry 0 to point to our first page table
  pageDirectory[0] = ((uint32_t)firstPageTable) | PAGE_PRESENT | PAGE_RW;

  // load the page directory and enable paging
  loadPageDirectory(pageDirectory);
  enablePaging();
}

// Map a 4 KB page
void mapPage(uint32_t virtAddr, uint32_t physAddr, uint32_t flags) {
  uint32_t dirIndex = (virtAddr >> 22) & 0x3FF;
  uint32_t tblIndex = (virtAddr >> 12) & 0x3FF;

  // One page table
  firstPageTable[tblIndex] = (physAddr & 0xFFFFF000) | flags | PAGE_PRESENT;

  // Make page directory point to page table
  pageDirectory[dirIndex] = ((uint32_t)firstPageTable) | PAGE_PRESENT | PAGE_RW;
}

