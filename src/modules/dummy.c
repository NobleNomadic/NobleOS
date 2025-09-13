// Test module that instantly returns to the kernel
#include "common.h"

int _start(KernelStateMessage *state) {
  return 0;
}
