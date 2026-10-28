/* ChaCha20 block function: RFC 8439 test vector, then differential testing
   against OpenSSL's ChaCha20 (an independent implementation). */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <openssl/evp.h>
#include "../lib/testlib.h"

extern void chacha20_block(uint8_t out[64], const uint8_t key[32], const uint8_t nonce[12],
                           uint32_t counter);

/* OpenSSL's IV for EVP_chacha20 is counter (32-bit LE) || nonce. */
static void openssl_block(uint8_t out[64], const uint8_t key[32], const uint8_t nonce[12],
                          uint32_t counter) {
  uint8_t iv[16], zero[64] = {0};
  int len;
  memcpy(iv, &counter, 4);
  memcpy(iv + 4, nonce, 12);
  EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
  EVP_EncryptInit_ex(ctx, EVP_chacha20(), NULL, key, iv);
  EVP_EncryptUpdate(ctx, out, &len, zero, 64);
  EVP_CIPHER_CTX_free(ctx);
}

int main(void) {
  /* RFC 8439, section 2.3.2 */
  uint8_t key[32], nonce[12] = {0, 0, 0, 0x09, 0, 0, 0, 0x4a, 0, 0, 0, 0}, out[64], ref[64];
  for (int i = 0; i < 32; i++) key[i] = (uint8_t)i;
  static const uint8_t expected[64] = {
    0x10, 0xf1, 0xe7, 0xe4, 0xd1, 0x3b, 0x59, 0x15, 0x50, 0x0f, 0xdd, 0x1f, 0xa3, 0x20, 0x71, 0xc4,
    0xc7, 0xd1, 0xf4, 0xc7, 0x33, 0xc0, 0x68, 0x03, 0x04, 0x22, 0xaa, 0x9a, 0xc3, 0xd4, 0x6c, 0x4e,
    0xd2, 0x82, 0x64, 0x46, 0x07, 0x9f, 0xaa, 0x09, 0x14, 0xc2, 0xd7, 0x05, 0xd9, 0x8b, 0x02, 0xa2,
    0xb5, 0x12, 0x9c, 0xd1, 0xde, 0x16, 0x4e, 0xb9, 0xcb, 0xd0, 0x83, 0xe8, 0xa2, 0x50, 0x3c, 0x4e};
  chacha20_block(out, key, nonce, 1);
  int rfc_ok = memcmp(out, expected, 64) == 0;
  printf("  [%s] chacha20_block: RFC 8439 2.3.2 test vector\n", rfc_ok ? "PASS" : "FAIL");

  /* random keys, nonces and counters (including 0 and 2^32-1) vs OpenSSL */
  const long N = 200000;
  for (long t = 0; t < N; t++) {
    tl_fill(key, 32);
    tl_fill(nonce, 12);
    uint32_t ctr = t % 3 == 0 ? 0xffffffffu : t % 3 == 1 ? 0 : (uint32_t)tl_rand();
    chacha20_block(out, key, nonce, ctr);
    openssl_block(ref, key, nonce, ctr);
    TL_CHECK("chacha20_block vs OpenSSL", memcmp(out, ref, 64) == 0, ctr, t);
  }
  int r = tl_report("chacha20_block vs OpenSSL EVP_chacha20", N);
  return r || !rfc_ok;
}
