(* Negative test: the constant-time statement for leaky_memeq must NOT be
   provable -- the proof script that works for ct_memeq fails here, because
   the leakage trace depends on secret data. EasyCrypt must reject it. *)
require import AllCore.
from Jasmin require import JModel_armv8a.
require Ct_CT.

lemma leaky_memeq_ct :
  equiv [ Ct_CT.M.leaky_memeq ~ Ct_CT.M.leaky_memeq : ={a, b, len} ==> res{1}.`1 = res{2}.`1 ].
proof.
proc; wp; while (={i, len, a, b, leak_cond, _b}); by auto.
qed.
