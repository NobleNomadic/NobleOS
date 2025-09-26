#!/bin/bash
# Build and compile all source into image file. Requires NASM
set -e

clean() {
  echo "RM [build]"
  rm -rf build
  rm -rf NobleOS.img
  mkdir build
  mkdir build/boot build/kernel build/fat build/drivers
}

assemble() {
  echo "AS [$1]"
  nasm -f bin $1 -o $2
}

createDisk() {
  echo "DD [NobleOS.img]"
  dd if=/dev/null of=NobleOS.img status=none bs=1M count=10
}

writeToDisk() {
  echo "DD [$1]"
  dd if=$1 of=NobleOS.img conv=notrunc status=none seek=$2
}

run() {
  qemu-system-i386 -drive file=NobleOS.img,format=raw,if=ide
}

# Main script
clean
createDisk

# ==== ASSEMBLE SOURCE ====
# ---- Bootloader ----
assemble src/boot/boot.asm build/boot/boot.bin

# ---- Initial FAT ----
assemble src/fat/fat.asm build/fat/fat.bin

# ---- Kernel ----
assemble src/kernel/kernel.asm build/kernel/kernel.bin

# ---- Drivers ----
assemble src/drivers/test.asm build/drivers/test.bin

# ==== WRITE TO DISK ====
writeToDisk build/boot/boot.bin 0
writeToDisk build/fat/fat.bin 1
writeToDisk build/kernel/kernel.bin 2
writeToDisk build/drivers/test.bin 7

if [[ $1 == "run" ]]; then
  run
fi
