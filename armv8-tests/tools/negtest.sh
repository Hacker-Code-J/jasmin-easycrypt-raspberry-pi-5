#!/usr/bin/env bash
# Expected-failure tests: every 08-negative/*.jazz must be REJECTED by
# `jasminc -arch armv8a` with an error message matching its "// EXPECT:" line.
cd "$(dirname "$0")/../08-negative" || exit 2
pass=0; fail=0
for f in *.jazz; do
  expect=$(sed -n 's|^// EXPECT: ||p' "$f")
  what=$(sed -n '1s|^// ||p' "$f")
  if out=$(jasminc -arch armv8a -o /dev/null "$f" 2>&1); then
    echo "  [FAIL] ${f%.jazz}: compiled, but should be rejected"; fail=$((fail + 1))
  elif echo "$out" | grep -Eq "$expect"; then
    ice=""; echo "$out" | grep -q "internal compilation error" && ice=" [internal compiler error]"
    printf "  [PASS] %-17s rejected%s: %s\n" "${f%.jazz}" "$ice" "$what"; pass=$((pass + 1))
  else
    echo "  [FAIL] ${f%.jazz}: rejected with an unexpected message:"; echo "$out" | sed 's/^/      /'
    fail=$((fail + 1))
  fi
done
echo "  negative tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
