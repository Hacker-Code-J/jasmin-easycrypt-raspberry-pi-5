#!/usr/bin/env bash
# Re-run every Jasmin / EasyCrypt test of the installation guide.
# Usage: ./run-tests.sh            (from the examples/ directory)
set -u
cd "$(dirname "$0")"
eval "$(opam env --switch=jasmin-ec)"

pass=0; fail=0
check() {  # check <expected-exit-code> <description> <command...>
  local want=$1 desc=$2; shift 2
  "$@" > /tmp/jasmin-ec-test.out 2>&1
  local got=$?
  if [ "$got" -eq "$want" ]; then
    echo "[PASS] $desc"; pass=$((pass + 1))
  else
    echo "[FAIL] $desc (exit $got, expected $want)"; cat /tmp/jasmin-ec-test.out
    fail=$((fail + 1))
  fi
}

echo "== Tool versions"
jasminc -version
echo "EasyCrypt $(easycrypt config 2>&1 | sed -n 's/^git-hash: //p')"
easycrypt config 2>&1 | grep '^known provers'

echo "== Jasmin"
cd jasmin
check 0 "jasminc: compile add256.jazz for ARMv8-A" \
  jasminc -arch armv8a -o add256.s add256.jazz
check 0 "gcc: link Jasmin assembly with C harness" \
  gcc -O2 -Wall -o test_add256 test_add256.c add256.s
check 0 "native run of add256 on the Raspberry Pi 5" ./test_add256
check 0 "jasminc: compile add256.jazz for x86-64 (cross target)" \
  jasminc -arch x86-64 -o add256_x86.s add256.jazz
check 0 "jasmin-ct: ct_select is constant-time" \
  jasmin-ct --arch=armv8a --slice=ct_select ct_select.jazz
check 1 "jasmin-ct: leaky_select is rejected" \
  jasmin-ct --arch=armv8a --slice=leaky_select ct_select.jazz
check 0 "jasmin2ec: extract ct_select to EasyCrypt" \
  jasmin2ec --arch=armv8a -f ct_select -o ../easycrypt/CtSelect.ec ct_select.jazz
cd ..

echo "== EasyCrypt"
cd easycrypt
check 0 "easycrypt: hello.ec (SMT smoke test)" easycrypt compile -no-eco hello.ec
check 0 "easycrypt: otp.ec (pRHL proof)" easycrypt compile -no-eco otp.ec
check 0 "easycrypt: ct_select_proof.ec (proof on extracted Jasmin)" \
  easycrypt compile -no-eco ct_select_proof.ec
check 1 "easycrypt: wrong.ec is rejected" easycrypt compile -no-eco wrong.ec
cd ..

rm -f /tmp/jasmin-ec-test.out
echo "== Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
