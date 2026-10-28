(* Negative test: the constant-time statement for leaky_cswap4 must NOT be
   provable -- the proof script that works for ct_cswap4 fails here, because
   the leakage trace depends on secret data. EasyCrypt must reject it. *)
require import AllCore.
from Jasmin require import JModel_armv8a.
require Ct_CT.

lemma leaky_cswap4_ct :
  equiv [ Ct_CT.M.leaky_cswap4 ~ Ct_CT.M.leaky_cswap4 : ={p, q} ==> ={res} ].
proof.
by proc; sim.
qed.
