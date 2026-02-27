#pragma once
#include <cstdint>

class EspClass {
public:
    uint32_t getFreeHeap() { return 100000; }
    uint32_t getPsramSize() { return 8000000; }
    uint32_t getFreePsram() { return 7000000; }
    const char* getChipModel() { return "ESP32-S3"; }
    uint32_t getCpuFreqMHz() { return 240; }
    void restart() {}
};
extern EspClass ESP;

#include <sys/time.h>
inline int settimeofday(const struct timeval*, const struct timezone*) { return 0; }
