/* Checks the ISA-coverage functions against independent C models
   (GCC built-ins and unsigned __int128), on random and edge inputs.
   This catches errors in the Jasmin *algorithms* themselves, which the
   interpreter-vs-native comparison of tools/difftest.py cannot see. */
#include <stdint.h>
#include <stdio.h>
#include "../lib/testlib.h"

typedef unsigned __int128 u128;
typedef struct { uint64_t a, b; } pair_t;

extern pair_t add128(uint64_t, uint64_t, uint64_t, uint64_t);
extern pair_t sub128(uint64_t, uint64_t, uint64_t, uint64_t);
extern uint64_t sub_carry(uint64_t, uint64_t);
extern pair_t mul64x64(uint64_t, uint64_t);
extern pair_t madd_msub(uint64_t, uint64_t, uint64_t);
extern pair_t rot64(uint64_t, uint64_t);
extern uint64_t popcount(uint64_t);
extern uint64_t compare(uint64_t, uint64_t);
extern pair_t casts(uint64_t);
extern uint64_t gcd(uint64_t, uint64_t);

static uint64_t rotl(uint64_t x, unsigned k) { k &= 63; return k ? (x << k) | (x >> (64 - k)) : x; }
static uint64_t rotr(uint64_t x, unsigned k) { return rotl(x, 64 - (k & 63)); }
static uint64_t ref_gcd(uint64_t a, uint64_t b) { while (b) { uint64_t r = a % b; a = b; b = r; } return a; }

static uint64_t ref_compare(uint64_t a, uint64_t b) {
  int64_t sa = (int64_t)a, sb = (int64_t)b;
  return (uint64_t)(a == b) | (uint64_t)(a != b) << 1 | (uint64_t)(a < b) << 2 |
         (uint64_t)(a <= b) << 3 | (uint64_t)(a > b) << 4 | (uint64_t)(a >= b) << 5 |
         (uint64_t)(sa < sb) << 6 | (uint64_t)(sa <= sb) << 7 |
         (uint64_t)(sa > sb) << 8 | (uint64_t)(sa >= sb) << 9;
}

int main(void) {
  const long N = 1000000;
  for (long t = 0; t < N; t++) {
    uint64_t a = tl_input(t, 0), b = tl_input(t, 1), c = tl_input(t, 2), d = tl_input(t, 3);
    u128 A = (u128)b << 64 | a, B = (u128)d << 64 | c;

    pair_t r = add128(a, b, c, d);
    TL_CHECK("add128", ((u128)r.b << 64 | r.a) == A + B, a, b);
    r = sub128(a, b, c, d);
    TL_CHECK("sub128", ((u128)r.b << 64 | r.a) == A - B, a, b);
    TL_CHECK("sub_carry", sub_carry(a, b) == (a >= b), a, b);
    r = mul64x64(a, b);
    TL_CHECK("mul64x64", ((u128)r.a << 64 | r.b) == (u128)a * b, a, b);
    r = madd_msub(a, b, c);
    TL_CHECK("madd_msub", r.a == c + a * b && r.b == c - a * b, a, b);
    r = rot64(a, b);
    TL_CHECK("rot64", r.a == rotr(rotr(rotl(a, 13), 7), (unsigned)b) && r.b == rotl(a, (unsigned)b), a, b);
    TL_CHECK("popcount", popcount(a) == (uint64_t)__builtin_popcountll(a), a, 0);
    TL_CHECK("compare", compare(a, b) == ref_compare(a, b), a, b);
    TL_CHECK("compare(a,a)", compare(a, a) == ref_compare(a, a), a, a);
    uint32_t w = (uint32_t)a + 0x80000000u;
    r = casts(a);
    TL_CHECK("casts", r.a == (uint64_t)w && r.b == (uint64_t)(int64_t)(int32_t)w, a, 0);
    if (t % 16 == 0) TL_CHECK("gcd", gcd(a, b) == ref_gcd(a, b), a, b);
  }
  return tl_report("isa models", N);
}
