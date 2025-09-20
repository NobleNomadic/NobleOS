// memory.h - Header for memory management and paging functions
#ifndef MEMORY_H
#define MEMORY_H

#include "stddef.h" // For integer types

// Each page directory and page table has 1024 entries (4 KB * 1024 = 4 MB)
// Page size = 4 KB
#define PAGE_SIZE    0x1000
#define NUM_ENTRIES  1024

// Flags for page directory and page table entries
#define PAGE_PRESENT 0x1   // page is present
#define PAGE_RW      0x2   // read/write
#define PAGE_USER    0x4   // user/supervisor (0 = supervisor only)

// Functions to control paging
void enablePaging();

void setupPaging();

// Function to map a physical address to a 4kb virtual page address
void mapPage(uint32_t virtAddr, uint32_t physAddr, uint32_t flags);


#endif // MEMORY_H

