#!/usr/bin/env python3
"""Differential testing of Jasmin export functions on ARMv8-A.

For every selected export function of FILE.jazz with scalar arguments
(reg u8/u16/u32/u64) and at most two scalar results, this script

  1. compiles FILE.jazz with `jasminc -arch armv8a`,
  2. generates and builds a C driver that calls the native code,
  3. generates N queries (edge values + random values),
  4. evaluates every query with the reference interpreter (tools/jasmin-interp,
     i.e. the Jasmin source semantics) and with the native code,
  5. compares the results.

Queries on which the interpreter reports an error (undefined behaviour in
Jasmin, e.g. division by zero) are not compared; they are counted as
"undefined" and the native result is shown for information.

Usage: difftest.py FILE.jazz [-f fn1,fn2] [-n 2000] [--seed 1] [--show-undef]
Exit code 0 iff no mismatch was found.
"""
import argparse
import os
import random
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
INTERP = os.path.join(HERE, "jasmin-interp", "_build", "default", "jasmin_interp.exe")

CTYPE = {8: "uint8_t", 16: "uint16_t", 32: "uint32_t", 64: "uint64_t"}


def parse_exports(src):
    """Return {name: (arg_widths, result_widths)} for scalar export functions."""
    src = re.sub(r"//[^\n]*", "", src)
    src = re.sub(r"/\*.*?\*/", "", src, flags=re.S)
    src = re.sub(r"#\[[^\]]*\]", "", src)
    out = {}
    pat = re.compile(r"export\s+fn\s+(\w+)\s*\(([^)]*)\)\s*(?:->\s*([^{]*))?\{")
    for m in pat.finditer(src):
        name, params, rets = m.group(1), m.group(2), m.group(3) or ""
        args, ok = [], True
        for group in filter(None, (p.strip() for p in params.split(","))):
            toks = [t for t in group.split() if not t.startswith("#")]
            if len(toks) < 3 or toks[0] != "reg" or not re.fullmatch(r"u(8|16|32|64)", toks[1]):
                ok = False
                break
            args += [int(toks[1][1:])] * (len(toks) - 2)
        res = []
        for r in filter(None, (r.strip(" ()\n") for r in rets.split(","))):
            toks = r.split()
            if len(toks) != 2 or toks[0] != "reg" or not re.fullmatch(r"u(8|16|32|64)", toks[1]):
                ok = False
                break
            res.append(int(toks[1][1:]))
        if ok and len(res) <= 2:
            out[name] = (args, res)
    return out


def c_driver(funcs):
    lines = [
        "#include <stdint.h>", "#include <stdio.h>", "#include <string.h>",
        "#include <stdlib.h>", "",
        "typedef struct { uint64_t a, b; } pair_t;",
        "static uint64_t rd(void) { char s[64]; if (scanf(\"%63s\", s) != 1) exit(1);"
        " return strtoull(s, 0, 0); }", "",
    ]
    for name, (args, res) in funcs.items():
        ret = "void" if not res else ("pair_t" if len(res) == 2 else CTYPE[res[0]])
        params = ", ".join(CTYPE[w] for w in args) or "void"
        lines.append(f'extern {ret} jz_{name}({params}) __asm__("{name}");')
    lines += ["", "int main(void) {", "  char name[128];",
              "  while (scanf(\"%127s\", name) == 1) {"]
    for name, (args, res) in funcs.items():
        lines.append(f'    if (!strcmp(name, "{name}")) {{')
        for i, w in enumerate(args):
            lines.append(f"      {CTYPE[w]} a{i} = ({CTYPE[w]})rd();")
        call = f"jz_{name}({', '.join(f'a{i}' for i in range(len(args)))})"
        mask = lambda w: "" if w == 64 else f" & 0x{(1 << w) - 1:x}ULL"
        if not res:
            lines.append(f'      {call}; printf("{name}\\n");')
        elif len(res) == 1:
            lines.append(f"      uint64_t r = (uint64_t){call};")
            lines.append(f'      printf("{name} 0x%llx\\n", (unsigned long long)(r{mask(res[0])}));')
        else:
            lines.append(f"      pair_t r = {call};")
            lines.append(f'      printf("{name} 0x%llx 0x%llx\\n", (unsigned long long)(r.a{mask(res[0])}),'
                         f" (unsigned long long)(r.b{mask(res[1])}));")
        lines.append("      continue;\n    }")
    lines += ['    fprintf(stderr, "unknown function %s\\n", name); return 2;', "  }",
              "  return 0;", "}"]
    return "\n".join(lines) + "\n"


def edge_values(w):
    m = (1 << w) - 1
    vals = {0, 1, 2, 3, m, m - 1, m >> 1, (m >> 1) + 1, (m >> 1) - 1,
            0x55555555_55555555 & m, 0xAAAAAAAA_AAAAAAAA & m}
    for k in range(0, w, 7):
        vals.add((1 << k) & m)
    return sorted(vals)


def gen_queries(funcs, n, rng, limits):
    qs = []
    for name, (args, _) in funcs.items():
        if name in limits:
            args = [min(w, limits[name]) for w in args]
        if not args:
            qs.append(name)
            continue
        edges = [edge_values(w) for w in args]
        # all pairs of edge values on the first two arguments, then random
        for _ in range(n):
            vals = []
            for i, w in enumerate(args):
                if rng.random() < 0.3:
                    vals.append(rng.choice(edges[i]))
                else:
                    vals.append(rng.getrandbits(w))
            qs.append(name + " " + " ".join(hex(v) for v in vals))
    return qs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("jazz")
    ap.add_argument("-f", "--functions")
    ap.add_argument("-x", "--exclude", default="",
                    help="functions to skip (e.g. ones that dereference pointers)")
    ap.add_argument("-n", type=int, default=2000)
    ap.add_argument("--bits", action="append", default=[], metavar="FN=W",
                    help="limit the arguments of FN to W bits (e.g. loop bounds)")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--show-undef", action="store_true")
    a = ap.parse_args()

    funcs = parse_exports(open(a.jazz).read())
    if a.functions:
        wanted = a.functions.split(",")
        missing = [f for f in wanted if f not in funcs]
        if missing:
            sys.exit(f"not a scalar export function: {missing}")
        funcs = {f: funcs[f] for f in wanted}
    funcs = {f: v for f, v in funcs.items() if f not in a.exclude.split(",")}
    if not funcs:
        sys.exit("no scalar export function found")

    with tempfile.TemporaryDirectory() as tmp:
        asm = os.path.join(tmp, "prog.s")
        drv = os.path.join(tmp, "driver.c")
        exe = os.path.join(tmp, "native")
        r = subprocess.run(["jasminc", "-arch", "armv8a", "-o", asm, a.jazz],
                           capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit(r.stdout + r.stderr)
        open(drv, "w").write(c_driver(funcs))
        subprocess.run(["gcc", "-O1", "-o", exe, drv, asm], check=True)

        queries = gen_queries(funcs, a.n, random.Random(a.seed),
                              {k: int(v) for k, v in (b.split("=") for b in a.bits)})
        data = "\n".join(queries) + "\n"
        ref = subprocess.run([INTERP, a.jazz], input=data, capture_output=True,
                             text=True, check=True).stdout.splitlines()
        nat = subprocess.run([exe], input=data, capture_output=True,
                             text=True, check=True).stdout.splitlines()

    stats = {f: [0, 0, 0] for f in funcs}  # agree, undefined, mismatch
    shown = 0
    for q, r, n in zip(queries, ref, nat):
        f = q.split()[0]
        if " ERROR " in r + " ":
            stats[f][1] += 1
            if a.show_undef and shown < 5:
                print(f"    undefined in Jasmin: {q}  -> interpreter: {r[len(f)+1:]}, native: {n[len(f)+1:]}")
                shown += 1
        elif r == n:
            stats[f][0] += 1
        else:
            stats[f][2] += 1
            print(f"    MISMATCH {q}: interpreter={r[len(f)+1:]} native={n[len(f)+1:]}")
    assert len(ref) == len(nat) == len(queries)

    bad = 0
    for f, (ok, undef, mis) in stats.items():
        status = "PASS" if mis == 0 else "FAIL"
        extra = f", {undef} undefined" if undef else ""
        print(f"  [{status}] {os.path.basename(a.jazz)}:{f}  {ok} agree{extra}, {mis} mismatch")
        bad += mis
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
