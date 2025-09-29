#!/bin/bash
# Compile .img floppy disk image of all source code. Run in qemu if 'run' specified.
set -e

# Clean up old binaries and setup build environment
clean() {
  echo "RM [build]"
  rm -rf build
  rm -rf NobleOS.img
  mkdir build
  mkdir build/boot build/kernel
}

# Create blank floppy disk image
createDisk() {
  echo "DD [NobleOS.img]"
  dd if=/dev/zero of=NobleOS.img bs=512 count=2880 status=none
}

# Assemble assembly source with NASM
#  $1 = asm input file
#  $2 = bin output file
assemble() {
  echo "AS [$1]"
  nasm -f bin $1 -o $2
}

# Write a binary file to disk
#  $1 = binary file
#  $2 = seek count
writeToDisk() {
  echo "DD [$1]"
  dd if=$1 of=NobleOS.img seek=$2 bs=512 conv=notrunc status=none
}

run() {
  echo "QEMU [NobleOS.img]"
  qemu-system-i386 -drive file=NobleOS.img,format=raw,if=floppy
}

# Main script
clean
createDisk

# ==== COMPILE ====
# ---- BOOTLOADER ----
assemble src/boot/boot.asm build/boot/boot.bin

# ---- KERNEL ----
assemble src/kernel/kernel.asm build/kernel/kernel.bin

# ==== WRITE TO DISK ====
writeToDisk build/boot/boot.bin 0
writeToDisk build/kernel/kernel.bin 1

# Run if 'run' argument added
if [[ $1 == "run" ]]; then
  run
fi
