#pragma once
#include <cstddef>
inline int LZ4_compress_default(const char*, char*, int, int) { return 0; }
inline int LZ4_compressBound(int sz) { return sz + sz/255 + 16; }
inline int LZ4_sizeofState() { return 16384; }
inline int LZ4_compress_fast_extState(void*, const char*, char*, int, int, int) { return 0; }
