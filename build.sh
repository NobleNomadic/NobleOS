#!/bin/bash
# Build and compile all source into image file. Requires NASM
set -e

clean() {
  echo "RM [build]"
  rm -rf build
  rm -rf NobleOS.img
  mkdir build
  mkdir build/boot build/kernel
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

assemble src/boot/boot.asm build/boot/boot.bin
writeToDisk build/boot/boot.bin 0

if [[ $1 == "run" ]]; then
  run
fi
