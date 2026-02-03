#if defined(__x86_64__)
// The x86_64 slice of the prebuilt TesseractCore archive references NEON-only
// symbols. Provide Intel fallbacks so linking succeeds.

namespace tesseract {
float DotProductNative(const float* u, const float* v, int len);

float DotProductNEON(const float* u, const float* v, int len) {
    // On Intel, fall back to the native (SSE) implementation.
    return DotProductNative(u, v, len);
}
}  // namespace tesseract

// intSimdMatrixNEON is a function pointer selected by SIMDDect; point it to the
// generic path so the x86 slice links even though NEON is unavailable.
using IntSimdFn = void (*)(const void*, const void*, const void*, void*);

extern "C" __attribute__((used, visibility("default"), section("__DATA,__data"))) IntSimdFn tesseract_intSimdMatrix
    asm("_ZN9tesseract13IntSimdMatrix13intSimdMatrixE") = nullptr;

extern "C" __attribute__((used, visibility("default"), section("__DATA,__data"))) IntSimdFn tesseract_intSimdMatrixNEON
    asm("_ZN9tesseract13IntSimdMatrix17intSimdMatrixNEONE") = tesseract_intSimdMatrix;
#endif
