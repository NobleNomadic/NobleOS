#!/bin/bash
set -e

rm -rf build
rm -f NobleOS.img
mkdir -p build

# Compile kernel.c to 32-bit object file
i386-elf-gcc -ffreestanding -m32 -c src/kernel/kernel.c -o build/kernel.o
i386-elf-gcc -ffreestanding -m32 -c src/kernel/kernelvga.c -o build/kernelvga.o
i386-elf-gcc -ffreestanding -m32 -c src/kernel/kernelkeyboard.c -o build/kernelkeyboard.o
i386-elf-gcc -ffreestanding -m32 -c src/kernel/kerneldisk.c -o build/kerneldisk.o

# Link them together (linker script should place code at 0x00100000)
i386-elf-ld -m elf_i386 build/kernel.o build/kernelvga.o build/kernelkeyboard.o build/kerneldisk.o -T linker/kernel.ld -o build/kernel.elf

# Convert ELF to flat binary. Kernel must be linked with virtual address 0x00100000.
i386-elf-objcopy -O binary build/kernel.elf build/kernel.bin

# Compile bootloader (512 byte boot sector)
nasm -f bin src/boot/boot.asm -o build/boot.bin

echo "[*] Compiled"

# Create an empty disk image (10MB here, change if you want)
dd if=/dev/zero of=NobleOS.img bs=512 count=$((1024*20))  # 10 MB

# write the boot sector to sector 0
dd if=build/boot.bin of=NobleOS.img conv=notrunc bs=512 count=1

# write kernel binary starting at sector 1
dd if=build/kernel.bin of=NobleOS.img conv=notrunc bs=512 seek=1

echo "[*] Image generated"

# Run in qemu using an emulated IDE disk
qemu-system-x86_64 -drive file=NobleOS.img,if=ide,format=raw
