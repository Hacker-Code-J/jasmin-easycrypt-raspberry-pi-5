(* Functional correctness of ARMv8-A arithmetic kernels from 02-isa/isa.jazz,
   proved on the EasyCrypt model produced by `jasmin2ec --arch=armv8a`. *)
require import AllCore IntDiv StdOrder.
import IntOrder.
from Jasmin require import JModel_armv8a.
require Isa.

(* ------------------------------------------------------------------ *)
(* Integer lemmas                                                       *)

(* Splitting a two-digit number modulo M^2. *)
lemma mod_split (M x y : int) : 0 < M =>
  (x + M * y) %% (M * M) = x %% M + M * ((y + x %/ M) %% M).
proof.
move=> hM.
have -> : x + M * y = x %% M + M * (y + x %/ M).
  by rewrite {1}(divz_eq x M); ring.
rewrite {1}(divz_eq (y + x %/ M) M).
have -> : x %% M + M * ((y + x %/ M) %/ M * M + (y + x %/ M) %% M)
        = (x %% M + M * ((y + x %/ M) %% M)) + ((y + x %/ M) %/ M) * (M * M) by ring.
rewrite modzMDr modz_small //.
have hr : 0 <= x %% M < M by smt(modz_ge0 ltz_pmod).
have hz : 0 <= (y + x %/ M) %% M < M by smt(modz_ge0 ltz_pmod).
have : M * ((y + x %/ M) %% M) <= M * (M - 1) by apply ler_wpmul2l; smt().
smt().
qed.

(* The carry out of an addition of two digits is their quotient by M. *)
lemma carry_div (M x : int) : 0 < M => 0 <= x < 2 * M =>
  (if M <= x then 1 else 0) = x %/ M.
proof.
move=> hM hx; case: (M <= x) => h.
+ have -> : x = (x - M) + 1 * M by ring.
  by rewrite divzMDr 1:/# divz_small; smt().
+ by rewrite divz_small; smt().
qed.

(* ------------------------------------------------------------------ *)
(* 128-bit addition with ADDS / ADCS                                     *)

op val128 (lo hi : W64.t) = to_uint lo + W64.modulus * to_uint hi.

lemma add128_correct a0 a1 b0 b1 :
  hoare [ Isa.M.add128 : alo = a0 /\ ahi = a1 /\ blo = b0 /\ bhi = b1
          ==> val128 res.`1 res.`2 = (val128 a0 a1 + val128 b0 b1) %% W64.modulus ^ 2 ].
proof.
proc; wp; skip => />.
have hc : b2i (carry_add a0 b0 false) = (to_uint a0 + to_uint b0) %/ W64.modulus.
  rewrite /carry_add /b2i /=; apply carry_div => //.
  by move: (W64.to_uint_cmp a0) (W64.to_uint_cmp b0) => /= ? ?; smt().
rewrite /val128 !W64.addcE /= hc /b2i /= !W64.to_uintD /=.
have -> : to_uint a0 + 18446744073709551616 * to_uint a1 + (to_uint b0 + 18446744073709551616 * to_uint b1)
        = (to_uint a0 + to_uint b0) + 18446744073709551616 * (to_uint a1 + to_uint b1) by ring.
have -> : 340282366920938463463374607431768211456 = 18446744073709551616 * 18446744073709551616 by done.
by rewrite mod_split // W64.of_uintK /= modzDml modzDmr.
qed.

(* ------------------------------------------------------------------ *)
(* The A64 carry flag of a subtraction means "no borrow"                *)

lemma sub_carry_correct a0 b0 :
  hoare [ Isa.M.sub_carry : a = a0 /\ b = b0
          ==> res = if to_uint b0 <= to_uint a0 then W64.one else W64.zero ].
proof.
proc; wp; skip => />.
rewrite /SUBS_64 /ADCS_64 /ADC_64 /nzcv_64 /b2i /=.
rewrite !W64.to_uintD W64.to_uint_invw /= modzDml.
move: (W64.to_uint_cmp a0) (W64.to_uint_cmp b0) => /= ha hb.
have -> : to_uint a0 + (18446744073709551615 - to_uint b0) + 1
        = (to_uint a0 - to_uint b0) + 18446744073709551616 by ring.
case: (to_uint b0 <= to_uint a0) => h.
+ by rewrite modzDr modz_small; smt().
+ by rewrite modz_small; smt().
qed.
