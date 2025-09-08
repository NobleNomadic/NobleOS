#!/bin/bash
set -e

rm -rf build
rm -rf *.iso

mkdir -p build

# Compile kernel.c to 32-bit object file
i386-elf-gcc -ffreestanding -m32 -c src/kernel/kernel.c -o build/kernel.o
i386-elf-gcc -ffreestanding -m32 -c src/kernel/kernelvga.c -o build/kernelvga.o
i386-elf-gcc -ffreestanding -m32 -c src/kernel/kernelkeyboard.c -o build/kernelkeyboard.o

# Link them together
i386-elf-ld -m elf_i386 build/kernel.o build/kernelvga.o build/kernelkeyboard.o -T linker/kernel.ld -o build/kernel.elf

# Copy into ISO folder
cp build/kernel.elf iso/boot/kernel.elf

echo "Compile complete"

grub-mkrescue -o NobleOS.iso iso

echo "ISO generated"

qemu-system-i386 -cdrom NobleOS.iso
