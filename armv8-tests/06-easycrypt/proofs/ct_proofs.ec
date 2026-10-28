(* Constant-time security of the Jasmin kernels, proved on the leakage
   model produced by `jasmin2ec -m CT` (each procedure returns, as first
   component, the trace of branch conditions and memory addresses).

   Non-interference statement: two runs that agree on the public inputs
   produce the same leakage, whatever the secrets -- the memory contents
   (Glob.mem) and the secret arguments are NOT assumed equal. *)
require import AllCore.
from Jasmin require import JModel_armv8a.
require Ct_CT Chacha20_CT Poly1305_CT.

lemma ct_memeq_ct :
  equiv [ Ct_CT.M.ct_memeq ~ Ct_CT.M.ct_memeq :
          ={a, b, len} ==> res{1}.`1 = res{2}.`1 ].
proof.
(* the loaded bytes differ, but the trace only depends on i, len, a, b *)
proc; wp; while (={i, len, a, b, leak_cond, _b}); by auto.
qed.

(* idx is secret *)
lemma ct_lookup16_ct :
  equiv [ Ct_CT.M.ct_lookup16 ~ Ct_CT.M.ct_lookup16 :
          ={table} ==> res{1}.`1 = res{2}.`1 ].
proof.
(* the comparison i = idx feeds a CSEL, not a branch: it is not leaked *)
proc; wp; while (={i, table, leak_cond, _b}); by auto.
qed.

(* the swap bit c is secret *)
lemma ct_cswap4_ct :
  equiv [ Ct_CT.M.ct_cswap4 ~ Ct_CT.M.ct_cswap4 :
          ={p, q} ==> ={res} ].
proof. by proc; sim. qed.

(* the key (in memory) is secret; pointers and counter are public *)
lemma chacha20_ct :
  equiv [ Chacha20_CT.M.chacha20_block ~ Chacha20_CT.M.chacha20_block :
          ={out, key, nonce, counter} ==> ={res} ].
proof. by proc; inline *; sim. qed.

(* the key and the message (in memory) are secret; len is public *)
lemma poly1305_ct :
  equiv [ Poly1305_CT.M.poly1305 ~ Poly1305_CT.M.poly1305 :
          ={out, m, len, key} ==> ={res} ].
proof. by proc; inline *; sim. qed.
