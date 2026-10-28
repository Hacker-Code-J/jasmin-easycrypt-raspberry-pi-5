# Installation guide: Jasmin and EasyCrypt on the Raspberry Pi 5

This directory contains a step-by-step guide (`main.pdf`, built from
`main.tex`) for installing the Jasmin compiler 2026.09.0 and the EasyCrypt
proof assistant r2026.07 on a Raspberry Pi 5 with Debian 12 (AArch64). The
guide records every executed command together with its output, and it
documents the problems that occurred and their resolutions. This is the
first part of the repository; see `../README.md` for an overview.

The directory `examples/` contains the four tests of the guide (11 checks): a Jasmin
program compiled to ARMv8-A and executed natively, a constant-time check,
EasyCrypt proofs, and the translation of a Jasmin function to EasyCrypt with
a correctness proof.

- `make` builds `main.pdf`.
- `make test` reruns the 11 checks (the opam switch `jasmin-ec` described in
  the guide must be active).
