/* Constant-time kernels on the Raspberry Pi 5:
   1. functional tests against C models;
   2. a dudect-style timing test: Welch's t statistic between two input
      classes, measured with the ARMv8 virtual counter (CNTVCT_EL0).
      |t| > 4.5 is taken as evidence of a timing leak (TVLA threshold). */
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../lib/testlib.h"

extern uint64_t ct_memeq(const uint8_t *a, const uint8_t *b, uint64_t len);
extern uint64_t leaky_memeq(const uint8_t *a, const uint8_t *b, uint64_t len);
extern void ct_cswap4(uint64_t c, uint64_t *p, uint64_t *q);
extern void leaky_cswap4(uint64_t c, uint64_t *p, uint64_t *q);
extern uint64_t ct_lookup16(const uint64_t *table, uint64_t idx);
extern uint64_t leaky_lookup16(const uint64_t *table, uint64_t idx);

static inline uint64_t ticks(void) {
  uint64_t t;
  __asm__ volatile("isb\n\tmrs %0, cntvct_el0" : "=r"(t) :: "memory");
  return t;
}
static uint64_t freq(void) {
  uint64_t f;
  __asm__ volatile("mrs %0, cntfrq_el0" : "=r"(f));
  return f;
}

/* Welch's t statistic, computed online. */
typedef struct { double n[2], mean[2], m2[2]; } welch_t;
static void welch_add(welch_t *w, int cls, double x) {
  w->n[cls]++;
  double d = x - w->mean[cls];
  w->mean[cls] += d / w->n[cls];
  w->m2[cls] += d * (x - w->mean[cls]);
}
static double welch_t_value(const welch_t *w) {
  double v0 = w->m2[0] / (w->n[0] - 1), v1 = w->m2[1] / (w->n[1] - 1);
  return (w->mean[0] - w->mean[1]) / sqrt(v0 / w->n[0] + v1 / w->n[1]);
}

enum { LEN = 4096, SAMPLES = 40000, BATCH = 4 };
static uint8_t A[LEN], B[2][LEN];
static uint64_t P[2][4], Q[2][4];

/* class 0: inputs that make a leaky implementation slow, class 1: fast */
static double measure(int which, int cls) {
  uint64_t t0, t1;
  volatile uint64_t sink = 0;
  switch (which) {
  case 0: t0 = ticks(); for (int k = 0; k < BATCH; k++) sink += ct_memeq(A, B[cls], LEN); t1 = ticks(); break;
  case 1: t0 = ticks(); for (int k = 0; k < BATCH; k++) sink += leaky_memeq(A, B[cls], LEN); t1 = ticks(); break;
  case 2: t0 = ticks(); for (int k = 0; k < BATCH * 64; k++) ct_cswap4(cls, P[0], Q[0]); t1 = ticks(); break;
  default: t0 = ticks(); for (int k = 0; k < BATCH * 64; k++) leaky_cswap4(cls, P[0], Q[0]); t1 = ticks(); break;
  }
  (void)sink;
  return (double)(t1 - t0);
}

int main(void) {
  int fails = 0;
  /* ---------------- functional tests ---------------- */
  {
    const long N = 200000;
    uint8_t x[64], y[64];
    uint64_t p[4], q[4], p0[4], q0[4], table[16];
    for (long t = 0; t < N; t++) {
      size_t len = tl_rand() % 65;
      tl_fill(x, sizeof x);
      memcpy(y, x, sizeof y);
      if (len && (t & 1)) y[tl_rand() % len] ^= (uint8_t)(1 + tl_rand() % 255);
      uint64_t eq = memcmp(x, y, len) == 0;
      TL_CHECK("ct_memeq", ct_memeq(x, y, len) == eq, len, eq);
      TL_CHECK("leaky_memeq", leaky_memeq(x, y, len) == eq, len, eq);
      tl_fill(p, sizeof p); tl_fill(q, sizeof q);
      memcpy(p0, p, sizeof p); memcpy(q0, q, sizeof q);
      uint64_t c = t & 1;
      ct_cswap4(c, p, q);
      TL_CHECK("ct_cswap4", !memcmp(p, c ? q0 : p0, 32) && !memcmp(q, c ? p0 : q0, 32), c, t);
      tl_fill(table, sizeof table);
      uint64_t idx = tl_rand() % 16;
      TL_CHECK("ct_lookup16", ct_lookup16(table, idx) == table[idx], idx, t);
      TL_CHECK("leaky_lookup16", leaky_lookup16(table, idx) == table[idx], idx, t);
    }
    fails += tl_report("ct_memeq, ct_cswap4, ct_lookup16 (+ leaky versions) vs C", N);
  }

  /* ---------------- timing tests ---------------- */
  printf("  timing: CNTVCT_EL0 at %.1f MHz, %d samples per class\n", freq() / 1e6, SAMPLES / 2);
  tl_fill(A, LEN);
  memcpy(B[0], A, LEN);                   /* class 0: equal -> full scan */
  memcpy(B[1], A, LEN); B[1][0] ^= 1;     /* class 1: differ at byte 0  */
  struct { const char *name; int which, should_leak; } tests[] = {
    {"ct_memeq", 0, 0}, {"leaky_memeq", 1, 1}, {"ct_cswap4", 2, 0}, {"leaky_cswap4", 3, 1},
  };
  for (unsigned k = 0; k < sizeof tests / sizeof tests[0]; k++) {
    welch_t w = {0};
    for (int i = 0; i < 2000; i++) measure(tests[k].which, i & 1);       /* warm-up */
    for (int i = 0; i < SAMPLES; i++) {
      int cls = (int)(tl_rand() & 1);
      welch_add(&w, cls, measure(tests[k].which, cls));
    }
    double t = welch_t_value(&w);
    int leak = fabs(t) > 4.5;
    int ok = leak == tests[k].should_leak;
    if (!ok) fails++;
    printf("  [%s] timing %-13s mean ticks %8.1f vs %8.1f  |t| = %8.2f  -> %s (expected %s)\n",
           ok ? "PASS" : "FAIL", tests[k].name, w.mean[0], w.mean[1], fabs(t),
           leak ? "leak" : "no leak detected", tests[k].should_leak ? "leak" : "no leak");
  }
  return fails != 0;
}
