#!/usr/bin/env bash
# ARMv8-A test campaign for Jasmin 2026.09.0 / EasyCrypt r2026.07 on a
# Raspberry Pi 5. Runs every stage and prints one [PASS]/[FAIL] line per
# check (plus [INFO] lines for measurements).
#   ./run-all.sh               all stages
#   ./run-all.sh 3 5           only stages 3 and 5
# Exit code 0 iff no check failed.
set -u
cd "$(dirname "$0")"
eval "$(opam env --switch=jasmin-ec)"
ROOT=$PWD
B=$ROOT/build
mkdir -p "$B"
STAGES=${*:-"1 2 3 4 5 6 7 8"}
PASS=0; FAIL=0

ok()  { echo "  [PASS] $*"; PASS=$((PASS + 1)); }
bad() { echo "  [FAIL] $*"; FAIL=$((FAIL + 1)); }
# expect <exit-code> <description> <command...>
expect() {
  local want=$1 desc=$2; shift 2
  "$@" > "$B/last.out" 2>&1
  local got=$?
  if [ "$got" -eq "$want" ]; then ok "$desc"
  else bad "$desc (exit $got, expected $want)"; sed 's/^/      /' "$B/last.out" | head -20; fi
}
# run a test program that prints its own [PASS]/[FAIL] lines
selfcheck() {
  local out; out=$("$@" 2>&1); local rc=$?
  echo "$out"
  PASS=$((PASS + $(grep -c '\[PASS\]' <<< "$out")))
  FAIL=$((FAIL + $(grep -c '\[FAIL\]' <<< "$out")))
  if [ $rc -ne 0 ] && ! grep -q '\[FAIL\]' <<< "$out"; then bad "$1 exited with code $rc"; fi
}
jc() { jasminc -arch armv8a "$@"; }
ec() { easycrypt compile -no-eco "$@"; }
stage() { echo; echo "== Stage $1: $2"; date +"   started %H:%M:%S"; }
want() { [[ " $STAGES " == *" $1 "* ]]; }

echo "== Environment"
echo "   $(tr -d '\0' < /proc/device-tree/model), $(uname -srm)"
echo "   $(jasminc -version), EasyCrypt $(easycrypt config 2>&1 | sed -n 's/^git-hash: //p')"
echo "   $(gcc --version | head -1), $(openssl version)"

# ---------------------------------------------------------------------------
if want 1; then
stage 1 "upstream Jasmin tests on ARMv8-A (compile, assemble, CT, EasyCrypt)"
# Upstream common tests that crash the ARMv8-A back-end in 2026.09.0.
KNOWN_ICE=" bug_499 renaming swap swap_word "
for d in armv8a stack_zeroization common; do
  n=0; nok=0; xfail=0
  for f in 01-upstream/$d/*.jazz; do
    b=$(basename "$f" .jazz); n=$((n + 1))
    if jc -o "$B/up_$b.s" "$f" > "$B/up_$b.err" 2>&1 && gcc -c -o "$B/up_$b.o" "$B/up_$b.s" 2>> "$B/up_$b.err"; then
      if [ "$d" = common ] && [[ "$KNOWN_ICE" == *" $b "* ]]; then bad "$d/$b compiles now (expected known ICE): update KNOWN_ICE"; fi
      nok=$((nok + 1))
    elif [ "$d" = common ] && [[ "$KNOWN_ICE" == *" $b "* ]] && grep -q "internal compilation error" "$B/up_$b.err"; then
      xfail=$((xfail + 1))
    else
      bad "$d/$b does not compile/assemble: $(grep -v '^ *$' "$B/up_$b.err" | head -2 | tr '\n' ' ')"
    fi
  done
  ok "upstream $d: $nok/$n compiled with -arch armv8a and assembled by GNU as$([ $xfail -gt 0 ] && echo ", $xfail known internal compiler errors (mulu_32, swap_32)")"
done
for f in 01-upstream/cct-success/*.jazz; do expect 0 "jasmin-ct accepts $(basename "$f")" jasmin-ct --arch=armv8a "$f"; done
for f in 01-upstream/cct-fail/*.jazz;    do expect 1 "jasmin-ct rejects $(basename "$f")" jasmin-ct --arch=armv8a "$f"; done
mkdir -p "$B/ec_up"
for f in 01-upstream/armv8a/*.jazz 01-upstream/stack_zeroization/*.jazz; do
  b=U_$(basename "$f" .jazz | tr -- - _)
  expect 0 "jasmin2ec + EasyCrypt type-check of $(basename "$f")" \
    bash -c "jasmin2ec --arch=armv8a -o '$B/ec_up/$b.ec' '$f' && cd '$B/ec_up' && easycrypt compile -no-eco '$b.ec'"
done
fi

# ---------------------------------------------------------------------------
if want 2; then
stage 2 "differential testing: reference interpreter vs native execution"
if [ ! -x tools/jasmin-interp/_build/default/jasmin_interp.exe ]; then
  (cd tools/jasmin-interp && dune build ./jasmin_interp.exe) || bad "cannot build the interpreter"
fi
for f in 01-upstream/armv8a/*.jazz; do
  case $(basename "$f") in
    ldst.jazz) continue ;;                                  # memory: see test_ldst
    word32.jazz) X="-x ldst32" ;;
    *) X="" ;;
  esac
  selfcheck python3 tools/difftest.py "$f" -n 2000 --bits loop=12 $X
done
selfcheck python3 tools/difftest.py 02-isa/isa.jazz -n 5000
jc -o "$B/isa.s" 02-isa/isa.jazz
jc -o "$B/ldst.s" 01-upstream/armv8a/ldst.jazz
jc -o "$B/word32.s" 01-upstream/armv8a/word32.jazz
gcc -O2 -Wall -Wno-unused-function -o "$B/test_isa_models" 02-isa/test_models.c "$B/isa.s" && selfcheck "$B/test_isa_models"
gcc -O2 -Wall -Wno-unused-function -o "$B/test_ldst" 02-isa/test_ldst.c "$B/ldst.s" "$B/word32.s" && selfcheck "$B/test_ldst"
fi

# ---------------------------------------------------------------------------
if want 3; then
stage 3 "AAPCS64 conformance: callee-saved registers, 32-bit arguments, stack zeroization"
jc -o "$B/isa.s" 02-isa/isa.jazz
jc -o "$B/word32.s" 01-upstream/armv8a/word32.jazz
jc -o "$B/stackzero.s" 03-abi/stackzero.jazz
gcc -O2 -Wall -Wno-unused-function -o "$B/test_abi" 03-abi/test_abi.c 03-abi/trampoline.S \
  "$B/isa.s" "$B/word32.s" "$B/stackzero.s" && selfcheck "$B/test_abi"
fi

# ---------------------------------------------------------------------------
if want 4; then
stage 4 "cryptographic kernels: ChaCha20 and Poly1305 vs RFC 8439 and OpenSSL"
jc -o "$B/chacha20.s" 04-crypto/chacha20.jazz
jc -o "$B/poly1305.s" 04-crypto/poly1305.jazz
gcc -O2 -Wall -Wno-unused-function -o "$B/test_chacha20" 04-crypto/test_chacha20.c "$B/chacha20.s" -lcrypto \
  && selfcheck "$B/test_chacha20"
gcc -O2 -Wall -Wno-unused-function -Wno-deprecated-declarations -o "$B/test_poly1305" \
  04-crypto/test_poly1305.c "$B/poly1305.s" -lcrypto && selfcheck "$B/test_poly1305"
fi

# ---------------------------------------------------------------------------
if want 5; then
stage 5 "constant time: jasmin-ct, speculative CT, and timing measurements"
for f in ct_memeq ct_cswap4 ct_lookup16; do
  expect 0 "jasmin-ct accepts $f" jasmin-ct --arch=armv8a --slice=$f 05-ct/ct.jazz
  expect 0 "jasmin-ct --doit accepts $f" jasmin-ct --arch=armv8a --doit --slice=$f 05-ct/ct.jazz
done
for f in leaky_memeq leaky_cswap4 leaky_lookup16 leaky_div; do
  expect 1 "jasmin-ct rejects $f" jasmin-ct --arch=armv8a --slice=$f 05-ct/ct.jazz
done
for f in chacha20 poly1305; do
  expect 0 "jasmin-ct accepts $f" jasmin-ct --arch=armv8a 04-crypto/$f.jazz
  expect 0 "jasmin-ct --doit accepts $f" jasmin-ct --arch=armv8a --doit 04-crypto/$f.jazz
  expect 1 "jasmin-ct --sct rejects $f (no SLH protections)" jasmin-ct --arch=armv8a --sct 04-crypto/$f.jazz
done
expect 0 "jasmin-ct --sct accepts the SLH-hardened sct.jazz" jasmin-ct --arch=armv8a --sct 05-ct/sct.jazz
expect 1 "jasminc -arch armv8a rejects sct.jazz (SLH not implemented)" jc -o /dev/null 05-ct/sct.jazz
expect 0 "jasminc -arch x86-64 compiles sct.jazz" jasminc -arch x86-64 -o "$B/sct_x86.s" 05-ct/sct.jazz
jc -o "$B/ct.s" 05-ct/ct.jazz
gcc -O2 -Wall -Wno-unused-function -o "$B/test_ct" 05-ct/test_ct.c "$B/ct.s" -lm && selfcheck "$B/test_ct"
fi

# ---------------------------------------------------------------------------
if want 6; then
stage 6 "EasyCrypt: extraction (normal and CT models) and proofs"
E=06-easycrypt/extracted
mkdir -p $E
for pair in 02-isa/isa:Isa 03-abi/stackzero:Stackzero 04-crypto/chacha20:Chacha20 04-crypto/poly1305:Poly1305 05-ct/ct:Ct; do
  f=${pair%%:*}; n=${pair##*:}
  jasmin2ec --arch=armv8a -o $E/$n.ec $f.jazz > /dev/null 2>&1
  jasmin2ec --arch=armv8a -m CT -o $E/${n}_CT.ec $f.jazz > /dev/null 2>&1
  expect 0 "EasyCrypt type-checks $n.ec (normal model)" bash -c "cd $E && easycrypt compile -no-eco $n.ec"
  expect 0 "EasyCrypt type-checks ${n}_CT.ec (constant-time leakage model)" bash -c "cd $E && easycrypt compile -no-eco ${n}_CT.ec"
done
expect 0 "proofs/isa_correct.ec: add128 and SUBS carry flag correct" ec -I $E 06-easycrypt/proofs/isa_correct.ec
expect 0 "proofs/ct_proofs.ec: 5 constant-time (non-interference) proofs" ec -I $E 06-easycrypt/proofs/ct_proofs.ec
for f in 06-easycrypt/proofs/fail_*.ec; do
  expect 1 "$(basename "$f"): CT proof of a leaky function is rejected" ec -I $E "$f"
done
fi

# ---------------------------------------------------------------------------
if want 7; then
stage 7 "performance (informational)"
jc -o "$B/chacha20.s" 04-crypto/chacha20.jazz
jc -o "$B/poly1305.s" 04-crypto/poly1305.jazz
gcc -O2 -Wall -Wno-deprecated-declarations -o "$B/bench" 07-bench/bench.c "$B/chacha20.s" "$B/poly1305.s" -lcrypto
"$B/bench" -O2 | sed 's/^  /  [INFO] /'
fi

# ---------------------------------------------------------------------------
if want 8; then
stage 8 "expected compilation failures (ARMv8-A back-end limitations)"
selfcheck tools/negtest.sh
fi

echo
echo "== Summary: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
