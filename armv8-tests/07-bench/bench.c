/* Throughput of the Jasmin ChaCha20 block function and Poly1305 on the
   Raspberry Pi 5 (Cortex-A76), compared with portable C implementations of
   the same algorithms (compiled with the flags given on the command line)
   and with OpenSSL (hand-written NEON assembly).
   Each figure is the median of 11 runs; results are in cycles per byte at
   the nominal clock given by CPU_MHZ (2400 MHz on a Pi 5). */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <openssl/evp.h>

#ifndef CPU_MHZ
#define CPU_MHZ 2400.0
#endif

extern void chacha20_block(uint8_t out[64], const uint8_t key[32], const uint8_t nonce[12], uint32_t ctr);
extern void poly1305(uint8_t out[16], const uint8_t *m, uint64_t len, const uint8_t key[32]);

/* ---------------- portable C references ---------------- */
#define ROTL(x, n) (((x) << (n)) | ((x) >> (32 - (n))))
#define QR(a, b, c, d) \
  a += b; d ^= a; d = ROTL(d, 16); c += d; b ^= c; b = ROTL(b, 12); \
  a += b; d ^= a; d = ROTL(d, 8);  c += d; b ^= c; b = ROTL(b, 7);
static void c_chacha20_block(uint8_t out[64], const uint8_t key[32], const uint8_t nonce[12], uint32_t ctr) {
  uint32_t s[16] = {0x61707865, 0x3320646e, 0x79622d32, 0x6b206574}, x[16];
  memcpy(s + 4, key, 32);
  s[12] = ctr;
  memcpy(s + 13, nonce, 12);
  memcpy(x, s, sizeof x);
  for (int i = 0; i < 10; i++) {
    QR(x[0], x[4], x[8], x[12]) QR(x[1], x[5], x[9], x[13])
    QR(x[2], x[6], x[10], x[14]) QR(x[3], x[7], x[11], x[15])
    QR(x[0], x[5], x[10], x[15]) QR(x[1], x[6], x[11], x[12])
    QR(x[2], x[7], x[8], x[13]) QR(x[3], x[4], x[9], x[14])
  }
  for (int i = 0; i < 16; i++) x[i] += s[i];
  memcpy(out, x, 64);
}

static uint32_t le32(const uint8_t *p) { uint32_t v; memcpy(&v, p, 4); return v; }
/* poly1305-donna-32 (radix 2^26), the algorithm of 04-crypto/poly1305.jazz */
static void c_poly1305(uint8_t out[16], const uint8_t *m, size_t len, const uint8_t key[32]) {
  uint32_t r0 = le32(key) & 0x3ffffff, r1 = (le32(key + 3) >> 2) & 0x3ffff03,
           r2 = (le32(key + 6) >> 4) & 0x3ffc0ff, r3 = (le32(key + 9) >> 6) & 0x3f03fff,
           r4 = (le32(key + 12) >> 8) & 0x00fffff;
  uint32_t s1 = r1 * 5, s2 = r2 * 5, s3 = r3 * 5, s4 = r4 * 5;
  uint32_t h0 = 0, h1 = 0, h2 = 0, h3 = 0, h4 = 0;
  uint8_t buf[16];
  while (len) {
    uint32_t hibit = 1 << 24;
    const uint8_t *b = m;
    size_t n = len < 16 ? len : 16;
    if (n < 16) { memset(buf, 0, 16); memcpy(buf, m, n); buf[n] = 1; b = buf; hibit = 0; }
    h0 += le32(b) & 0x3ffffff;        h1 += (le32(b + 3) >> 2) & 0x3ffffff;
    h2 += (le32(b + 6) >> 4) & 0x3ffffff; h3 += (le32(b + 9) >> 6) & 0x3ffffff;
    h4 += (le32(b + 12) >> 8) | hibit;
    uint64_t d0 = (uint64_t)h0 * r0 + (uint64_t)h1 * s4 + (uint64_t)h2 * s3 + (uint64_t)h3 * s2 + (uint64_t)h4 * s1;
    uint64_t d1 = (uint64_t)h0 * r1 + (uint64_t)h1 * r0 + (uint64_t)h2 * s4 + (uint64_t)h3 * s3 + (uint64_t)h4 * s2;
    uint64_t d2 = (uint64_t)h0 * r2 + (uint64_t)h1 * r1 + (uint64_t)h2 * r0 + (uint64_t)h3 * s4 + (uint64_t)h4 * s3;
    uint64_t d3 = (uint64_t)h0 * r3 + (uint64_t)h1 * r2 + (uint64_t)h2 * r1 + (uint64_t)h3 * r0 + (uint64_t)h4 * s4;
    uint64_t d4 = (uint64_t)h0 * r4 + (uint64_t)h1 * r3 + (uint64_t)h2 * r2 + (uint64_t)h3 * r1 + (uint64_t)h4 * r0;
    uint32_t c = (uint32_t)(d0 >> 26); h0 = (uint32_t)d0 & 0x3ffffff;
    d1 += c; c = (uint32_t)(d1 >> 26); h1 = (uint32_t)d1 & 0x3ffffff;
    d2 += c; c = (uint32_t)(d2 >> 26); h2 = (uint32_t)d2 & 0x3ffffff;
    d3 += c; c = (uint32_t)(d3 >> 26); h3 = (uint32_t)d3 & 0x3ffffff;
    d4 += c; c = (uint32_t)(d4 >> 26); h4 = (uint32_t)d4 & 0x3ffffff;
    h0 += c * 5; c = h0 >> 26; h0 &= 0x3ffffff; h1 += c;
    m += n; len -= n;
  }
  uint32_t c = h1 >> 26; h1 &= 0x3ffffff; h2 += c; c = h2 >> 26; h2 &= 0x3ffffff; h3 += c;
  c = h3 >> 26; h3 &= 0x3ffffff; h4 += c; c = h4 >> 26; h4 &= 0x3ffffff; h0 += c * 5;
  c = h0 >> 26; h0 &= 0x3ffffff; h1 += c;
  uint32_t g0 = h0 + 5; c = g0 >> 26; g0 &= 0x3ffffff;
  uint32_t g1 = h1 + c; c = g1 >> 26; g1 &= 0x3ffffff;
  uint32_t g2 = h2 + c; c = g2 >> 26; g2 &= 0x3ffffff;
  uint32_t g3 = h3 + c; c = g3 >> 26; g3 &= 0x3ffffff;
  uint32_t g4 = h4 + c - (1 << 26);
  uint32_t mask = (g4 >> 31) - 1;
  h0 = (h0 & ~mask) | (g0 & mask); h1 = (h1 & ~mask) | (g1 & mask); h2 = (h2 & ~mask) | (g2 & mask);
  h3 = (h3 & ~mask) | (g3 & mask); h4 = (h4 & ~mask) | (g4 & mask);
  uint64_t f0 = ((h0) | (h1 << 26)) & 0xffffffff, f1 = ((h1 >> 6) | (h2 << 20)) & 0xffffffff,
           f2 = ((h2 >> 12) | (h3 << 14)) & 0xffffffff, f3 = ((h3 >> 18) | (h4 << 8)) & 0xffffffff;
  f0 += le32(key + 16); f1 += le32(key + 20) + (f0 >> 32); f2 += le32(key + 24) + (f1 >> 32);
  f3 += le32(key + 28) + (f2 >> 32);
  uint32_t t[4] = {(uint32_t)f0, (uint32_t)f1, (uint32_t)f2, (uint32_t)f3};
  memcpy(out, t, 16);
}

/* ---------------- timing ---------------- */
static double now(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return ts.tv_sec + ts.tv_nsec * 1e-9;
}
static int cmp(const void *a, const void *b) {
  double x = *(const double *)a, y = *(const double *)b;
  return (x > y) - (x < y);
}

enum { MSG = 4096 };
static uint8_t key[32], nonce[12], msg[MSG], out[MSG];
static EVP_MAC *mac;

static void run(int which, long reps) {
  uint8_t tag[16];
  int len;
  switch (which) {
  case 0: for (long i = 0; i < reps; i++) chacha20_block(out, key, nonce, (uint32_t)i); break;
  case 1: for (long i = 0; i < reps; i++) c_chacha20_block(out, key, nonce, (uint32_t)i); break;
  case 2: { /* OpenSSL: encrypt 64 bytes per call, comparable to one block */
    uint8_t iv[16] = {0};
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(ctx, EVP_chacha20(), NULL, key, iv);
    for (long i = 0; i < reps; i++) EVP_EncryptUpdate(ctx, out, &len, msg, 64);
    EVP_CIPHER_CTX_free(ctx);
    break; }
  case 3: { /* OpenSSL bulk: 4096 bytes per call (NEON, several blocks in parallel) */
    uint8_t iv[16] = {0};
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(ctx, EVP_chacha20(), NULL, key, iv);
    for (long i = 0; i < reps / 64; i++) EVP_EncryptUpdate(ctx, out, &len, msg, MSG);
    EVP_CIPHER_CTX_free(ctx);
    break; }
  case 4: for (long i = 0; i < reps / 64; i++) poly1305(tag, msg, MSG, key); break;
  case 5: for (long i = 0; i < reps / 64; i++) c_poly1305(tag, msg, MSG, key); break;
  default: {
    size_t outl;
    for (long i = 0; i < reps / 64; i++) {
      EVP_MAC_CTX *ctx = EVP_MAC_CTX_new(mac);
      EVP_MAC_init(ctx, key, 32, NULL);
      EVP_MAC_update(ctx, msg, MSG);
      EVP_MAC_final(ctx, tag, &outl, 16);
      EVP_MAC_CTX_free(ctx);
    }
    break; }
  }
  __asm__ volatile("" ::: "memory");
}

int main(int argc, char **argv) {
  const char *cflags = argc > 1 ? argv[1] : "?";
  for (int i = 0; i < 32; i++) key[i] = (uint8_t)(i * 7 + 1);
  for (int i = 0; i < MSG; i++) msg[i] = (uint8_t)i;
  mac = EVP_MAC_fetch(NULL, "POLY1305", NULL);

  /* sanity: the C references agree with the Jasmin code */
  uint8_t a[64], b[64];
  chacha20_block(a, key, nonce, 7); c_chacha20_block(b, key, nonce, 7);
  uint8_t t1[16], t2[16];
  poly1305(t1, msg, 1000, key); c_poly1305(t2, msg, 1000, key);
  if (memcmp(a, b, 64) || memcmp(t1, t2, 16)) { printf("reference mismatch\n"); return 1; }

  struct { const char *name; int which; } rows[] = {
    {"ChaCha20 block  Jasmin (scalar)", 0}, {"ChaCha20 block  C (scalar)", 1},
    {"ChaCha20 64 B   OpenSSL", 2},        {"ChaCha20 4 KiB  OpenSSL (NEON)", 3},
    {"Poly1305 4 KiB  Jasmin (radix 2^26)", 4}, {"Poly1305 4 KiB  C (radix 2^26)", 5},
    {"Poly1305 4 KiB  OpenSSL", 6},
  };
  const long reps = 200000;
  printf("  %-38s %10s %10s   (C: gcc %s, %.0f MHz)\n", "kernel", "ns/byte", "cycles/B", cflags, CPU_MHZ);
  for (unsigned k = 0; k < sizeof rows / sizeof rows[0]; k++) {
    double v[11];
    run(rows[k].which, reps / 10);                    /* warm-up */
    for (int r = 0; r < 11; r++) {
      double t0 = now();
      run(rows[k].which, reps);
      v[r] = (now() - t0) / (reps * 64.0);            /* seconds per byte */
    }
    qsort(v, 11, sizeof v[0], cmp);
    printf("  %-38s %10.3f %10.2f\n", rows[k].name, v[5] * 1e9, v[5] * CPU_MHZ * 1e6);
  }
  EVP_MAC_free(mac);
  return 0;
}
