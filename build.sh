#!/bin/bash
set -e

clean() {
  echo "RM [build]"
  rm -rf build
  rm -f NobleOS.img
  mkdir -p build/boot build/kernel
}

compileC() {
  local src=$1
  local out=$2
  echo "CC [$src]"
  i386-elf-gcc -ffreestanding -m32 -c "$src" -o "$out"
}

compileAsm() {
  local src=$1
  local out=$2
  local format=${3:-bin}
  echo "AS [$src] with format $format"
  nasm -f "$format" "$src" -o "$out"
}

linkFiles() {
  local linkerScript=$1
  local output=$2
  shift 2
  echo "LD [$output '$linkerScript']"
  i386-elf-ld -m elf_i386 "$@" -T "$linkerScript" -o "$output"
}

objcopyBinary() {
  local input=$1
  local output=$2
  echo "OB [$input -> $output]"
  i386-elf-objcopy -O binary "$input" "$output"
}

createDisk() {
  echo "DD [NobleOS.img]"
  dd if=/dev/zero of=NobleOS.img bs=512 count=4096 status=none
}

writeToDisk() {
  echo "DD [$1]"
  dd if=$1 of=NobleOS.img bs=512 conv=notrunc seek=$2 status=none
}

run() {
  echo "QEMU [NobleOS.img]"
  qemu-system-i386 -drive file=NobleOS.img,if=ide,format=raw
}

# ==== MAIN SCRIPT ====
clean

# ---- BOOTLOADER ----
compileAsm src/boot/boot.asm build/boot/boot.bin bin

# ---- KERNEL ----
compileC src/kernel/kernel.c build/kernel/kernel.o
linkFiles linker/kernel.ld build/kernel/kernel.elf build/kernel/kernel.o
objcopyBinary build/kernel/kernel.elf build/kernel/kernel.bin

# ---- DISK ----
createDisk

writeToDisk build/boot/boot.bin 0
writeToDisk build/kernel/kernel.bin 1

if [[ $1 == "run" ]]; then
  run
fi

