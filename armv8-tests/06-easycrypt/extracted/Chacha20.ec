require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

require import BArray64.

module M = {
  proc qr (x:BArray64.t, a:int, b:int, c:int, d:int) : BArray64.t = {
    
    x <- (BArray64.set32 x a ((BArray64.get32 x a) + (BArray64.get32 x b)));
    x <-
    (BArray64.set32 x d ((BArray64.get32 x d) `^` (BArray64.get32 x a)));
    x <- (BArray64.set32 x d ((BArray64.get32 x d) `|<<|` (W8.of_int 16)));
    x <- (BArray64.set32 x c ((BArray64.get32 x c) + (BArray64.get32 x d)));
    x <-
    (BArray64.set32 x b ((BArray64.get32 x b) `^` (BArray64.get32 x c)));
    x <- (BArray64.set32 x b ((BArray64.get32 x b) `|<<|` (W8.of_int 12)));
    x <- (BArray64.set32 x a ((BArray64.get32 x a) + (BArray64.get32 x b)));
    x <-
    (BArray64.set32 x d ((BArray64.get32 x d) `^` (BArray64.get32 x a)));
    x <- (BArray64.set32 x d ((BArray64.get32 x d) `|<<|` (W8.of_int 8)));
    x <- (BArray64.set32 x c ((BArray64.get32 x c) + (BArray64.get32 x d)));
    x <-
    (BArray64.set32 x b ((BArray64.get32 x b) `^` (BArray64.get32 x c)));
    x <- (BArray64.set32 x b ((BArray64.get32 x b) `|<<|` (W8.of_int 7)));
    return x;
  }
  proc init (key:W64.t, nonce:W64.t, counter:W32.t) : BArray64.t = {
    var x:BArray64.t;
    var i:int;
    x <- witness;
    x <- (BArray64.set32 x 0 (W32.of_int 1634760805));
    x <- (BArray64.set32 x 1 (W32.of_int 857760878));
    x <- (BArray64.set32 x 2 (W32.of_int 2036477234));
    x <- (BArray64.set32 x 3 (W32.of_int 1797285236));
    i <- 0;
    while ((i < 8)) {
      x <-
      (BArray64.set32 x (4 + i)
      (loadW32 Glob.mem (W64.to_uint (key + (W64.of_int (4 * i))))));
      i <- (i + 1);
    }
    x <- (BArray64.set32 x 12 counter);
    i <- 0;
    while ((i < 3)) {
      x <-
      (BArray64.set32 x (13 + i)
      (loadW32 Glob.mem (W64.to_uint (nonce + (W64.of_int (4 * i))))));
      i <- (i + 1);
    }
    return x;
  }
  proc chacha20_block (out:W64.t, key:W64.t, nonce:W64.t, counter:W32.t) : 
  unit = {
    var s_out:W64.t;
    var s_key:W64.t;
    var s_nonce:W64.t;
    var s_counter:W32.t;
    var x:BArray64.t;
    var round:W64.t;
    var i:int;
    var y:BArray64.t;
    var v:W32.t;
    x <- witness;
    y <- witness;
    s_out <- out;
    s_key <- key;
    s_nonce <- nonce;
    s_counter <- counter;
    x <@ init (key, nonce, counter);
    round <- (W64.of_int 10);
    while ((round <> (W64.of_int 0))) {
      x <@ qr (x, 0, 4, 8, 12);
      x <@ qr (x, 1, 5, 9, 13);
      x <@ qr (x, 2, 6, 10, 14);
      x <@ qr (x, 3, 7, 11, 15);
      x <@ qr (x, 0, 5, 10, 15);
      x <@ qr (x, 1, 6, 11, 12);
      x <@ qr (x, 2, 7, 8, 13);
      x <@ qr (x, 3, 4, 9, 14);
      round <- (round - (W64.of_int 1));
    }
    key <- s_key;
    nonce <- s_nonce;
    counter <- s_counter;
    out <- s_out;
    i <- 0;
    while ((i < 4)) {
      y <- (BArray64.set32 y i (BArray64.get32 x i));
      i <- (i + 1);
    }
    v <- (W32.of_int 1634760805);
    y <- (BArray64.set32 y 0 ((BArray64.get32 y 0) + v));
    v <- (W32.of_int 857760878);
    y <- (BArray64.set32 y 1 ((BArray64.get32 y 1) + v));
    v <- (W32.of_int 2036477234);
    y <- (BArray64.set32 y 2 ((BArray64.get32 y 2) + v));
    v <- (W32.of_int 1797285236);
    y <- (BArray64.set32 y 3 ((BArray64.get32 y 3) + v));
    i <- 0;
    while ((i < 4)) {
      Glob.mem <-
      (storeW32 Glob.mem (W64.to_uint (out + (W64.of_int (4 * i))))
      (BArray64.get32 y i));
      i <- (i + 1);
    }
    i <- 0;
    while ((i < 8)) {
      v <- (loadW32 Glob.mem (W64.to_uint (key + (W64.of_int (4 * i)))));
      v <- (v + (BArray64.get32 x (4 + i)));
      Glob.mem <-
      (storeW32 Glob.mem
      (W64.to_uint ((out + (W64.of_int 16)) + (W64.of_int (4 * i)))) 
      v);
      i <- (i + 1);
    }
    v <- (BArray64.get32 x 12);
    v <- (v + counter);
    Glob.mem <- (storeW32 Glob.mem (W64.to_uint (out + (W64.of_int 48))) v);
    i <- 0;
    while ((i < 3)) {
      v <- (loadW32 Glob.mem (W64.to_uint (nonce + (W64.of_int (4 * i)))));
      v <- (v + (BArray64.get32 x (13 + i)));
      Glob.mem <-
      (storeW32 Glob.mem
      (W64.to_uint ((out + (W64.of_int 52)) + (W64.of_int (4 * i)))) 
      v);
      i <- (i + 1);
    }
    return ();
  }
}.
