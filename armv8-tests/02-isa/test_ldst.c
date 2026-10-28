/* Native test of the upstream memory-access functions ldst (64-bit) and
   ldst32 (32-bit), which the interpreter-based difftest cannot run.
   Each function is compared with a C model of its Jasmin source on
   random buffer contents; the whole 32-byte buffer is compared, so that
   out-of-place stores are detected too. */
#include <stdint.h>
#include <string.h>
#include "../lib/testlib.h"

extern uint64_t ldst(uint8_t *p);
extern uint32_t ldst32(uint8_t *p);

static uint64_t ld64(const uint8_t *p) { uint64_t v; memcpy(&v, p, 8); return v; }
static uint32_t ld32(const uint8_t *p) { uint32_t v; memcpy(&v, p, 4); return v; }
static uint16_t ld16(const uint8_t *p) { uint16_t v; memcpy(&v, p, 2); return v; }
static void st64(uint8_t *p, uint64_t v) { memcpy(p, &v, 8); }
static void st32(uint8_t *p, uint32_t v) { memcpy(p, &v, 4); }
static void st16(uint8_t *p, uint16_t v) { memcpy(p, &v, 2); }

static uint64_t ref_ldst(uint8_t *p) {
  uint64_t a = ld64(p), b = ld64(p + 8);
  a += b;
  st64(p, a);
  st64(p + 16, b);
  p[24] = (uint8_t)a;
  st16(p + 26, (uint16_t)a);
  a = p[24];
  b = (uint64_t)(int64_t)(int16_t)ld16(p + 26);
  a += b;
  b = ld16(p + 26);
  a += b;
  b = (uint64_t)(int64_t)(int8_t)p[24];
  a += b;
  return a + b;  /* stack round trip: a = s[0], b = s[1]; a + b */
}

static uint32_t ref_ldst32(uint8_t *p) {
  uint32_t a = ld32(p), b = ld32(p + 4);
  a += b;
  st32(p, a);
  st32(p + 8, b);
  p[12] = (uint8_t)a;
  st16(p + 14, (uint16_t)a);
  a = p[12];
  b = (uint32_t)(int32_t)(int16_t)ld16(p + 14);
  a += b;
  b = ld16(p + 14);
  a += b;
  b = (uint32_t)(int32_t)(int8_t)p[12];
  a += b;
  return a + b;
}

int main(void) {
  const long N = 1000000;
  _Alignas(16) uint8_t m1[32], m2[32];
  for (long t = 0; t < N; t++) {
    tl_fill(m1, sizeof m1);
    memcpy(m2, m1, sizeof m1);
    uint64_t r1 = ldst(m1), r2 = ref_ldst(m2);
    TL_CHECK("ldst", r1 == r2 && !memcmp(m1, m2, sizeof m1), r1, r2);
    tl_fill(m1, sizeof m1);
    memcpy(m2, m1, sizeof m1);
    uint32_t s1 = ldst32(m1), s2 = ref_ldst32(m2);
    TL_CHECK("ldst32", s1 == s2 && !memcmp(m1, m2, sizeof m1), s1, s2);
  }
  return tl_report("upstream ldst/ldst32 vs C model", N);
}
