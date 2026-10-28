(* Negative test: a false statement must be rejected. *)
require import AllCore.

lemma wrong (x : int) : x + 1 = x.
proof. by smt(). qed.
