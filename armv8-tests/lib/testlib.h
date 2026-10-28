/* Small shared helpers for the native ARMv8-A test harnesses. */
#ifndef TESTLIB_H
#define TESTLIB_H

#include <stdint.h>
#include <stdio.h>
#include <string.h>

static long tl_failures = 0;

/* Deterministic PRNG (splitmix64): runs are reproducible. */
static uint64_t tl_state = 0x2026102100000000ULL;
static inline uint64_t tl_rand(void) {
  uint64_t z = (tl_state += 0x9E3779B97F4A7C15ULL);
  z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
  z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
  return z ^ (z >> 31);
}

static inline void tl_fill(void *p, size_t n) {
  uint8_t *b = p;
  for (size_t i = 0; i < n; i++) b[i] = (uint8_t)tl_rand();
}

/* Edge values that exercise carries, sign bits and zero. */
static const uint64_t tl_edges[] = {
  0, 1, 2, 3, 0x7fffffffffffffffULL, 0x8000000000000000ULL, 0xffffffffffffffffULL,
  0xfffffffffffffffeULL, 0xffffffffULL, 0x100000000ULL, 0x80000000ULL,
  0x5555555555555555ULL, 0xaaaaaaaaaaaaaaaaULL,
};
#define TL_NEDGES (sizeof tl_edges / sizeof tl_edges[0])

/* Input number `arg` of test number t: the first TL_NEDGES^2 tests
   enumerate all pairs of edge values, then 1 in 4 inputs is an edge value. */
static inline uint64_t tl_input(long t, int arg) {
  if (t < (long)(TL_NEDGES * TL_NEDGES) && arg < 2)
    return tl_edges[arg == 0 ? t / TL_NEDGES : t % TL_NEDGES];
  uint64_t r = tl_rand();
  return (r & 3) == 0 ? tl_edges[(r >> 2) % TL_NEDGES] : tl_rand();
}

#define TL_CHECK(name, cond, x, y)                                          \
  do {                                                                      \
    if (!(cond)) {                                                          \
      if (tl_failures++ < 10)                                               \
        printf("  FAIL %s: inputs 0x%016llx 0x%016llx\n", (name),           \
               (unsigned long long)(x), (unsigned long long)(y));           \
    }                                                                       \
  } while (0)

static int tl_report(const char *what, long n) {
  if (tl_failures)
    printf("  [FAIL] %s: %ld failures over %ld tests\n", what, tl_failures, n);
  else
    printf("  [PASS] %s: %ld tests\n", what, n);
  return tl_failures != 0;
}

#endif
