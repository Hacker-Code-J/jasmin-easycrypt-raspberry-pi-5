(* Negative test: the constant-time statement for leaky_lookup16 must NOT be
   provable -- the proof script that works for ct_lookup16 fails here, because
   the leakage trace depends on secret data. EasyCrypt must reject it. *)
require import AllCore.
from Jasmin require import JModel_armv8a.
require Ct_CT.

lemma leaky_lookup16_ct :
  equiv [ Ct_CT.M.leaky_lookup16 ~ Ct_CT.M.leaky_lookup16 : ={table} ==> res{1}.`1 = res{2}.`1 ].
proof.
by proc; sim.
qed.
