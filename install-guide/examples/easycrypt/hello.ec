(* Smoke test: arithmetic facts discharged by the SMT back-end (Why3). *)
require import AllCore StdRing.
import RField.

lemma add_comm_int (x y : int) : x + y = y + x.
proof. by smt(). qed.

lemma square_nonneg (x : int) : 0 <= x * x.
proof. by smt(). qed.

lemma distrib (a b c : int) : a * (b + c) = a * b + a * c.
proof. by ring. qed.
