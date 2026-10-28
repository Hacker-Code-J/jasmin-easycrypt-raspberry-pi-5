/* Poly1305: RFC 8439 test vector, then differential testing against
   OpenSSL's EVP_MAC "POLY1305" for all message lengths 0..300 with random,
   all-0x00 and all-0xff contents (the latter push the accumulator close to
   the modulus 2^130 - 5 and exercise the final conditional subtraction). */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <openssl/evp.h>
#include <openssl/params.h>
#include "../lib/testlib.h"

extern void poly1305(uint8_t out[16], const uint8_t *m, uint64_t len, const uint8_t key[32]);

static EVP_MAC *mac;

static void openssl_poly1305(uint8_t out[16], const uint8_t *m, size_t len, const uint8_t key[32]) {
  EVP_MAC_CTX *ctx = EVP_MAC_CTX_new(mac);
  size_t outl;
  EVP_MAC_init(ctx, key, 32, NULL);
  EVP_MAC_update(ctx, m, len);
  EVP_MAC_final(ctx, out, &outl, 16);
  EVP_MAC_CTX_free(ctx);
}

int main(void) {
  mac = EVP_MAC_fetch(NULL, "POLY1305", NULL);
  if (!mac) { printf("  [FAIL] OpenSSL has no POLY1305 MAC\n"); return 1; }

  /* RFC 8439, section 2.5.2 */
  static const uint8_t key_rfc[32] = {
    0x85, 0xd6, 0xbe, 0x78, 0x57, 0x55, 0x6d, 0x33, 0x7f, 0x44, 0x52, 0xfe, 0x42, 0xd5, 0x06, 0xa8,
    0x01, 0x03, 0x80, 0x8a, 0xfb, 0x0d, 0xb2, 0xfd, 0x4a, 0xbf, 0xf6, 0xaf, 0x41, 0x49, 0xf5, 0x1b};
  static const uint8_t tag_rfc[16] = {0xa8, 0x06, 0x1d, 0xc1, 0x30, 0x51, 0x36, 0xc6,
                                      0xc2, 0x2b, 0x8b, 0xaf, 0x0c, 0x01, 0x27, 0xa9};
  const char *msg = "Cryptographic Forum Research Group";
  uint8_t tag[16], ref[16];
  poly1305(tag, (const uint8_t *)msg, strlen(msg), key_rfc);
  int rfc_ok = memcmp(tag, tag_rfc, 16) == 0;
  printf("  [%s] poly1305: RFC 8439 2.5.2 test vector\n", rfc_ok ? "PASS" : "FAIL");

  static uint8_t m[320], key[32];
  long n = 0;
  for (int pattern = 0; pattern < 3; pattern++) {
    for (int rep = 0; rep < (pattern == 0 ? 200 : 4); rep++) {
      for (size_t len = 0; len <= 300; len++) {
        if (pattern == 0) { tl_fill(m, len); tl_fill(key, 32); }
        else { memset(m, pattern == 1 ? 0x00 : 0xff, len); memset(key, pattern == 1 ? 0x00 : 0xff, 32);
               if (rep & 1) tl_fill(key, 32); }
        poly1305(tag, m, len, key);
        openssl_poly1305(ref, m, len, key);
        TL_CHECK("poly1305 vs OpenSSL", memcmp(tag, ref, 16) == 0, len, pattern);
        n++;
      }
    }
  }
  int r = tl_report("poly1305 vs OpenSSL EVP_MAC (lengths 0..300)", n);
  EVP_MAC_free(mac);
  return r || !rfc_ok;
}
