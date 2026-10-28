/* AAPCS64 conformance tests of Jasmin-generated code (see trampoline.S). */
#include <stdint.h>
#include <stdio.h>
#include "../lib/testlib.h"

uint64_t abi_call(void *fn, uint64_t a0, uint64_t a1, uint64_t *status);
uint64_t abi_call_dirty32(void *fn, uint64_t a0, uint64_t a1);
void stack_snapshot(void *fn, uint64_t arg, uint64_t depth, uint64_t *out);

/* 64-bit functions from 02-isa/isa.jazz and 01-upstream (link time). */
extern uint64_t pressure(uint64_t, uint64_t);
extern uint64_t gcd(uint64_t, uint64_t);
extern uint64_t arrays(uint64_t, uint64_t, uint64_t);
extern uint64_t collatz(uint64_t);
extern uint64_t compare(uint64_t, uint64_t);
/* 32-bit functions */
extern uint32_t arith32(uint32_t, uint32_t), logic32(uint32_t, uint32_t);
extern uint32_t shift32(uint32_t, uint32_t), csel32(uint32_t, uint32_t);
extern uint32_t rot32(uint32_t, uint32_t), word32_wrap(uint32_t, uint32_t);
/* stack zeroization variants */
extern uint64_t sz_none(uint64_t), sz_loop(uint64_t), sz_unrolled(uint64_t);

static const char *regname(int bit) {
  static const char *n[] = {"x19", "x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27",
                            "x28", "x29", "d8",  "d9",  "d10", "d11", "d12", "d13", "d14",
                            "d15", "sp"};
  return bit < 20 ? n[bit] : "?";
}

int main(void) {
  int fails = 0;

  /* 1. callee-saved registers and SP */
  struct { const char *name; void *fn; } f64[] = {
    {"pressure", (void *)pressure}, {"gcd", (void *)gcd}, {"arrays", (void *)arrays},
    {"collatz", (void *)collatz},   {"compare", (void *)compare},
    {"sz_none", (void *)sz_none},   {"sz_loop", (void *)sz_loop},
    {"sz_unrolled", (void *)sz_unrolled},
  };
  for (unsigned k = 0; k < sizeof f64 / sizeof f64[0]; k++) {
    uint64_t bad = 0;
    long n = 20000;
    for (long t = 0; t < n; t++) {
      uint64_t st = 0, a = tl_input(t, 0), b = tl_input(t, 1);
      if (f64[k].fn == (void *)gcd && b == 0) b = 1;
      abi_call(f64[k].fn, a, b, &st);
      bad |= st;
    }
    if (bad) {
      fails++;
      printf("  [FAIL] callee-saved %-12s clobbered:", f64[k].name);
      for (int i = 0; i < 20; i++) if (bad >> i & 1) printf(" %s", regname(i));
      printf("\n");
    } else {
      printf("  [PASS] callee-saved %-12s x19-x29, d8-d15, sp preserved (%ld calls)\n", f64[k].name, n);
    }
  }

  /* 2. 32-bit arguments with garbage in the upper halves */
  struct { const char *name; uint32_t (*fn)(uint32_t, uint32_t); } f32[] = {
    {"arith32", arith32}, {"logic32", logic32}, {"shift32", shift32},
    {"csel32", csel32},   {"rot32", rot32},     {"word32_wrap", word32_wrap},
  };
  for (unsigned k = 0; k < sizeof f32 / sizeof f32[0]; k++) {
    long n = 200000, bad = 0;
    for (long t = 0; t < n; t++) {
      uint32_t a = (uint32_t)tl_input(t, 0), b = (uint32_t)tl_input(t, 1);
      if (f32[k].fn == arith32 && b == 0) b = 1;  /* division by zero is undefined */
      uint32_t clean = f32[k].fn(a, b);
      uint32_t dirty = (uint32_t)abi_call_dirty32((void *)f32[k].fn, a, b);
      bad += clean != dirty;
    }
    if (bad) fails++;
    printf("  [%s] dirty upper halves  %-12s %ld/%ld results differ\n", bad ? "FAIL" : "PASS",
           f32[k].name, bad, n);
  }

  /* 3. stack zeroization: classify every word fn left below the stack pointer */
  struct { const char *name; void *fn; int zeroized; } fz[] = {
    {"sz_none", (void *)sz_none, 0}, {"sz_loop", (void *)sz_loop, 1},
    {"sz_unrolled", (void *)sz_unrolled, 1},
  };
  const uint64_t key = 0x0123456789abcdefULL;
  enum { DEPTH = 1024 };
  for (unsigned k = 0; k < sizeof fz / sizeof fz[0]; k++) {
    uint64_t snap[DEPTH / 8];
    int secret = 0, code = 0, other = 0, zero = 0;
    stack_snapshot(fz[k].fn, key, DEPTH, snap);
    for (int i = 0; i < DEPTH / 8; i++) {
      uint64_t w = snap[i];
      int is_secret = 0;
      for (int r = 0; r < 32; r++) {
        uint64_t v = (r ? (key << r) | (key >> (64 - r)) : key) ^ key;
        if (w == v && w != 0) is_secret = 1;
      }
      if (w == 0xaaaaaaaaaaaaaaaaULL) continue;
      else if (w == 0) zero++;
      else if (is_secret) secret++;
      else if (w - (uint64_t)(uintptr_t)stack_snapshot < 4096) code++;  /* return address */
      else other++;
    }
    int ok = fz[k].zeroized ? (secret == 0 && other == 0) : secret > 0;
    if (!ok) fails++;
    printf("  [%s] stack after %-12s secret words: %2d, return addresses: %d, zeroed words: %2d, "
           "other: %d\n", ok ? "PASS" : "FAIL", fz[k].name, secret, code, zero, other);
  }
  return fails != 0;
}
