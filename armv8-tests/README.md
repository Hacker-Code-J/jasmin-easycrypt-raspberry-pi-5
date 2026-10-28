# Test campaign of the Jasmin ARMv8-A back end on the Raspberry Pi 5

Jasmin 2026.09.0 is the first release whose compiler generates code for
ARMv8-A (AArch64). The upstream test suite only verifies that its ARMv8-A
test programs *compile*; it does not execute the generated code. This
campaign executes the generated code on the Raspberry Pi 5 and compares its
results with several independent references. It is the second part of the
repository; see `../README.md` for an overview. The report is
`report/main.pdf`.

| Stage | Directory | What the stage checks |
|------:|-----------|-----------------------|
| 1 | `01-upstream/` | upstream test programs: compilation and assembly, constant-time checking with `jasmin-ct`, extraction to EasyCrypt and type checking |
| 2 | `02-isa/`, `tools/` | agreement of native execution with the reference interpreter of Jasmin (differential testing), and comparison with C models |
| 3 | `03-abi/` | conformance to the AAPCS64 calling convention (preserved registers, 32-bit arguments with undefined upper halves) and erasure of secrets from the stack |
| 4 | `04-crypto/` | ChaCha20 and Poly1305 in Jasmin, compared with the test vectors of RFC 8439 and with OpenSSL |
| 5 | `05-ct/` | constant-time checking with `jasmin-ct` (modes CT, DOIT, SCT) and timing measurements |
| 6 | `06-easycrypt/` | extraction to EasyCrypt (plain and leakage models), proofs of correctness and of constant time |
| 7 | `07-bench/` | performance compared with portable C and OpenSSL |
| 8 | `08-negative/` | programs that the back end must reject (its known limitations) |

`./run-all.sh` runs all stages (about 7 minutes on a Raspberry Pi 5);
`./run-all.sh 2 4` runs only the stages 2 and 4. The script requires the opam
switch `jasmin-ec` described in `../install-guide` and the Debian package
`libssl-dev`. The output of the last complete run is stored in
`results/run-all-output.txt`.

`01-upstream/` contains test files copied from Jasmin v2026.09.0 (MIT
License, see `01-upstream/LICENSE.jasmin`).
