(* One-time pad on booleans: the ciphertext is uniformly distributed,
   whatever the message.  Proved as a pRHL equivalence between the real
   encryption and an oracle that returns a fresh random bit. *)
require import AllCore Bool Distr DBool.

module OTP = {
  proc enc(m : bool) : bool = {
    var k;
    k <$ {0,1};
    return m ^^ k;
  }
}.

module Ideal = {
  proc enc(m : bool) : bool = {
    var r;
    r <$ {0,1};
    return r;
  }
}.

lemma otp_perfect_secrecy :
  equiv [OTP.enc ~ Ideal.enc : true ==> ={res}].
proof.
proc.
rnd (fun k => m{1} ^^ k) (fun r => m{1} ^^ r).
skip => /> &1.
smt(xorA xorK xor_false dbool1E supp_dbool).
qed.
