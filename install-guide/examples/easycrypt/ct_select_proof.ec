(* Functional correctness of the Jasmin function ct_select, proved on the
   EasyCrypt model produced by jasmin2ec (file CtSelect.ec). *)
require import AllCore.
from Jasmin require import JModel_armv8a.
require import CtSelect.

lemma ct_select_correct (c0 a0 b0 : W64.t) :
  hoare [ M.ct_select :
          c = c0 /\ a = a0 /\ b = b0 /\ (c0 = W64.one \/ c0 = W64.zero)
          ==> res = if c0 = W64.one then a0 else b0 ].
proof.
proc; wp; skip => /> [-> | ->] /=.
- (* c = 1: mask = -1 = all ones, so a0 & mask = a0 and b0 & ~mask = 0 *)
  by rewrite W64.minus_one W64.andw1_s -W64.xor1w W64.xorwK W64.andw0 W64.orw0.
- (* c = 0: mask = 0, so a0 & mask = 0 and b0 & ~mask = b0 *)
  have -> : -W64.zero = W64.zero by ring.
  rewrite -W64.xor1w W64.xorw0 W64.andw1_s W64.andw0 W64.or0w.
  smt(W64.to_uint0 W64.to_uint1).
qed.
