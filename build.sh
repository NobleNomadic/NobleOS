#!/bin/bash
set -e

clean() {
  echo "RM [build]"
  rm -rf build
  rm -f NobleOS.img
  mkdir -p build
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

# Linker system
# Define linker configurations here: map name -> linker script and flags
declare -A linker_scripts=(
  [kernel]="linker/kernel.ld"
  [flat]="linker/flat.ld"
)

declare -A linker_flags=(
  [kernel]="-m elf_i386"
  [flat]="-m elf_i386"
)

# Generic linker function accepting:
#   1) linker config name (e.g. "kernel")
#   2) output file
#   3+) input object files
linkFiles() {
  local config=$1
  local output=$2
  shift 2
  local linker_script="${linker_scripts[$config]}"
  local flags="${linker_flags[$config]}"

  if [[ -z "$linker_script" ]]; then
    echo "Error: Unknown linker config '$config'"
    exit 1
  fi

  echo "LD [$output] using config '$config' with script '$linker_script'"
  i386-elf-ld $flags "$@" -T "$linker_script" -o "$output"
}

objcopyBinary() {
  local input=$1
  local output=$2
  echo "OB [$input -> $output]"
  i386-elf-objcopy -O binary "$input" "$output"
}

writeToDisk() {
  local sizeSectors=${1:-40960}
  echo "DD [NobleOS.img]"
  dd if=/dev/zero of=NobleOS.img bs=512 count="$sizeSectors" status=none

  echo "DD [boot.bin]"
  dd if=build/boot.bin of=NobleOS.img conv=notrunc bs=512 count=1 status=none

  echo "DD [kernel.bin]"
  dd if=build/kernel.bin of=NobleOS.img conv=notrunc bs=512 seek=1 status=none

  echo "DD [dummy.bin]"
  dd if=build/dummy.bin of=NobleOS.img conv=notrunc bs=512 seek=9 status=none

  echo "DD [dummy.bin]"
  dd if=build/dummy.bin of=NobleOS.img conv=notrunc bs=512 seek=19 status=none

  echo "DD [dummy.bin]"
  dd if=build/dummy.bin of=NobleOS.img conv=notrunc bs=512 seek=29 status=none

  echo "DD [dummy.bin]"
  dd if=build/dummy.bin of=NobleOS.img conv=notrunc bs=512 seek=39 status=none

}

run() {
  echo "QEMU [NobleOS.img]"
  qemu-system-i386 -drive file=NobleOS.img,if=ide,format=raw
}

# ==== MAIN SCRIPT ====
clean

# ---- KERNEL ----
compileC src/kernel/kernel.c build/kernel.o
compileC src/kernel/kernelvga.c build/kernelvga.o
compileC src/kernel/kernelkeyboard.c build/kernelkeyboard.o
compileC src/kernel/kerneldisk.c build/kerneldisk.o
compileC src/kernel/kernelutil.c build/kernelutil.o

compileAsm src/kernel/kerneldisk.asm build/kerneldisk_asm.o elf32
compileAsm src/boot/boot.asm build/boot.bin bin

# Use modular linker for kernel
linkFiles kernel build/kernel.elf build/kernel.o build/kernelvga.o build/kernelkeyboard.o build/kerneldisk.o build/kerneldisk_asm.o build/kernelutil.o
objcopyBinary build/kernel.elf build/kernel.bin
# ---- MODULES ----
compileC src/modules/dummy.c build/dummy.o
linkFiles flat build/dummy.elf build/dummy.o
objcopyBinary build/dummy.elf build/dummy.bin

writeToDisk 40960

if [[ $1 == "run" ]]; then
  run
fi

