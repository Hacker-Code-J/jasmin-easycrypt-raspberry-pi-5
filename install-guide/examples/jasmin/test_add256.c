/* Native test harness: links the Jasmin-generated AArch64 assembly and
   compares add256 against a portable C reference on random inputs. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern uint64_t add256(uint64_t *r, const uint64_t *a, const uint64_t *b);

static uint64_t ref_add256(uint64_t *r, const uint64_t *a, const uint64_t *b) {
  unsigned __int128 acc = 0;
  for (int i = 0; i < 4; i++) {
    acc += (unsigned __int128)a[i] + b[i];
    r[i] = (uint64_t)acc;
    acc >>= 64;
  }
  return (uint64_t)acc;
}

static uint64_t rnd64(void) {
  return ((uint64_t)rand() << 62) ^ ((uint64_t)rand() << 31) ^ (uint64_t)rand();
}

int main(void) {
  uint64_t a[4], b[4], r1[4], r2[4];
  srand(2026);
  for (int t = 0; t < 1000000; t++) {
    for (int i = 0; i < 4; i++) {
      a[i] = rnd64();
      b[i] = (t % 7 == 0) ? ~a[i] : rnd64();
    }
    if (t % 7 == 0) b[0] += 1;  /* a + b = 2^256: carry ripples through all limbs */
    uint64_t c1 = add256(r1, a, b);
    uint64_t c2 = ref_add256(r2, a, b);
    if (c1 != c2 || memcmp(r1, r2, sizeof r1) != 0) {
      printf("MISMATCH at test %d\n", t);
      return 1;
    }
  }
  printf("add256: 1000000 random tests passed\n");
  return 0;
}
