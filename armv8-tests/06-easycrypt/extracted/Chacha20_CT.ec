require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

from Jasmin require import JLeakage.

require import BArray64.

module M = {
  proc qr (x:BArray64.t, a:int, b:int, c:int, d:int) : JLeakage.leakage *
                                                       BArray64.t = {
    var leak:JLeakage.leakages;
    leak <- [];
    leak <- (leak ++ [(LeakList [(Leak_int b); (Leak_int a)])]);
    leak <- (leak ++ [(LeakList [(Leak_int a)])]);
    x <- (BArray64.set32 x a ((BArray64.get32 x a) + (BArray64.get32 x b)));
    leak <- (leak ++ [(LeakList [(Leak_int a); (Leak_int d)])]);
    leak <- (leak ++ [(LeakList [(Leak_int d)])]);
    x <-
    (BArray64.set32 x d ((BArray64.get32 x d) `^` (BArray64.get32 x a)));
    leak <- (leak ++ [(LeakList [(Leak_int d)])]);
    leak <- (leak ++ [(LeakList [(Leak_int d)])]);
    x <- (BArray64.set32 x d ((BArray64.get32 x d) `|<<|` (W8.of_int 16)));
    leak <- (leak ++ [(LeakList [(Leak_int d); (Leak_int c)])]);
    leak <- (leak ++ [(LeakList [(Leak_int c)])]);
    x <- (BArray64.set32 x c ((BArray64.get32 x c) + (BArray64.get32 x d)));
    leak <- (leak ++ [(LeakList [(Leak_int c); (Leak_int b)])]);
    leak <- (leak ++ [(LeakList [(Leak_int b)])]);
    x <-
    (BArray64.set32 x b ((BArray64.get32 x b) `^` (BArray64.get32 x c)));
    leak <- (leak ++ [(LeakList [(Leak_int b)])]);
    leak <- (leak ++ [(LeakList [(Leak_int b)])]);
    x <- (BArray64.set32 x b ((BArray64.get32 x b) `|<<|` (W8.of_int 12)));
    leak <- (leak ++ [(LeakList [(Leak_int b); (Leak_int a)])]);
    leak <- (leak ++ [(LeakList [(Leak_int a)])]);
    x <- (BArray64.set32 x a ((BArray64.get32 x a) + (BArray64.get32 x b)));
    leak <- (leak ++ [(LeakList [(Leak_int a); (Leak_int d)])]);
    leak <- (leak ++ [(LeakList [(Leak_int d)])]);
    x <-
    (BArray64.set32 x d ((BArray64.get32 x d) `^` (BArray64.get32 x a)));
    leak <- (leak ++ [(LeakList [(Leak_int d)])]);
    leak <- (leak ++ [(LeakList [(Leak_int d)])]);
    x <- (BArray64.set32 x d ((BArray64.get32 x d) `|<<|` (W8.of_int 8)));
    leak <- (leak ++ [(LeakList [(Leak_int d); (Leak_int c)])]);
    leak <- (leak ++ [(LeakList [(Leak_int c)])]);
    x <- (BArray64.set32 x c ((BArray64.get32 x c) + (BArray64.get32 x d)));
    leak <- (leak ++ [(LeakList [(Leak_int c); (Leak_int b)])]);
    leak <- (leak ++ [(LeakList [(Leak_int b)])]);
    x <-
    (BArray64.set32 x b ((BArray64.get32 x b) `^` (BArray64.get32 x c)));
    leak <- (leak ++ [(LeakList [(Leak_int b)])]);
    leak <- (leak ++ [(LeakList [(Leak_int b)])]);
    x <- (BArray64.set32 x b ((BArray64.get32 x b) `|<<|` (W8.of_int 7)));
    return ((LeakList leak), x);
  }
  proc init (key:W64.t, nonce:W64.t, counter:W32.t) : JLeakage.leakage *
                                                      BArray64.t = {
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var x:BArray64.t;
    var i:int;
    x <- witness;
    leak <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    x <- (BArray64.set32 x 0 (W32.of_int 1634760805));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    x <- (BArray64.set32 x 1 (W32.of_int 857760878));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    x <- (BArray64.set32 x 2 (W32.of_int 2036477234));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    x <- (BArray64.set32 x 3 (W32.of_int 1797285236));
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 8)])]);
    i <- 0;
    while ((i < 8)) {
      leak_0 <- [];
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (key + (W64.of_int (4 * i)))))])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (4 + i))])]);
      x <-
      (BArray64.set32 x (4 + i)
      (loadW32 Glob.mem (W64.to_uint (key + (W64.of_int (4 * i))))));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    leak <- (leak ++ [(LeakList [(Leak_int 12)])]);
    x <- (BArray64.set32 x 12 counter);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 3)])]);
    i <- 0;
    while ((i < 3)) {
      leak_0 <- [];
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (nonce + (W64.of_int (4 * i)))))])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (13 + i))])]);
      x <-
      (BArray64.set32 x (13 + i)
      (loadW32 Glob.mem (W64.to_uint (nonce + (W64.of_int (4 * i))))));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    return ((LeakList leak), x);
  }
  proc chacha20_block (out:W64.t, key:W64.t, nonce:W64.t, counter:W32.t) : 
  JLeakage.leakage = {
    var _b:JLeakage.leakages;
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var leak_c:JLeakage.leakage;
    var leak_cond:JLeakage.leakages;
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
    leak <- [];
    s_out <- out;
    s_key <- key;
    s_nonce <- nonce;
    s_counter <- counter;
    (leak_c, x) <@ init (key, nonce, counter);
    leak <- (leak ++ [leak_c]);
    round <- (W64.of_int 10);
    leak_cond <- [];
    _b <- [];
    leak_cond <-
    (leak_cond ++ [(LeakList [(Leak_bool (round <> (W64.of_int 0)))])]);
    while ((round <> (W64.of_int 0))) {
      leak_0 <- [];
      (leak_c, x) <@ qr (x, 0, 4, 8, 12);
      leak_0 <- (leak_0 ++ [leak_c]);
      (leak_c, x) <@ qr (x, 1, 5, 9, 13);
      leak_0 <- (leak_0 ++ [leak_c]);
      (leak_c, x) <@ qr (x, 2, 6, 10, 14);
      leak_0 <- (leak_0 ++ [leak_c]);
      (leak_c, x) <@ qr (x, 3, 7, 11, 15);
      leak_0 <- (leak_0 ++ [leak_c]);
      (leak_c, x) <@ qr (x, 0, 5, 10, 15);
      leak_0 <- (leak_0 ++ [leak_c]);
      (leak_c, x) <@ qr (x, 1, 6, 11, 12);
      leak_0 <- (leak_0 ++ [leak_c]);
      (leak_c, x) <@ qr (x, 2, 7, 8, 13);
      leak_0 <- (leak_0 ++ [leak_c]);
      (leak_c, x) <@ qr (x, 3, 4, 9, 14);
      leak_0 <- (leak_0 ++ [leak_c]);
      round <- (round - (W64.of_int 1));
      _b <- (_b ++ [(LeakList leak_0)]);
      leak_cond <-
      (leak_cond ++ [(LeakList [(Leak_bool (round <> (W64.of_int 0)))])]);
    }
    leak <- (leak ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
    key <- s_key;
    nonce <- s_nonce;
    counter <- s_counter;
    out <- s_out;
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 4)])]);
    i <- 0;
    while ((i < 4)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int i)])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int i)])]);
      y <- (BArray64.set32 y i (BArray64.get32 x i));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    v <- (W32.of_int 1634760805);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    y <- (BArray64.set32 y 0 ((BArray64.get32 y 0) + v));
    v <- (W32.of_int 857760878);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    y <- (BArray64.set32 y 1 ((BArray64.get32 y 1) + v));
    v <- (W32.of_int 2036477234);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    y <- (BArray64.set32 y 2 ((BArray64.get32 y 2) + v));
    v <- (W32.of_int 1797285236);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    y <- (BArray64.set32 y 3 ((BArray64.get32 y 3) + v));
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 4)])]);
    i <- 0;
    while ((i < 4)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int i)])]);
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (out + (W64.of_int (4 * i)))))])]);
      Glob.mem <-
      (storeW32 Glob.mem (W64.to_uint (out + (W64.of_int (4 * i))))
      (BArray64.get32 y i));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 8)])]);
    i <- 0;
    while ((i < 8)) {
      leak_0 <- [];
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (key + (W64.of_int (4 * i)))))])]);
      v <- (loadW32 Glob.mem (W64.to_uint (key + (W64.of_int (4 * i)))));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (4 + i))])]);
      v <- (v + (BArray64.get32 x (4 + i)));
      leak_0 <-
      (leak_0 ++
      [(LeakList
       [(Leak_int
        (W64.to_uint ((out + (W64.of_int 16)) + (W64.of_int (4 * i)))))]
       )]);
      Glob.mem <-
      (storeW32 Glob.mem
      (W64.to_uint ((out + (W64.of_int 16)) + (W64.of_int (4 * i)))) 
      v);
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    leak <- (leak ++ [(LeakList [(Leak_int 12)])]);
    v <- (BArray64.get32 x 12);
    v <- (v + counter);
    leak <-
    (leak ++ [(LeakList [(Leak_int (W64.to_uint (out + (W64.of_int 48))))])]);
    Glob.mem <- (storeW32 Glob.mem (W64.to_uint (out + (W64.of_int 48))) v);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 3)])]);
    i <- 0;
    while ((i < 3)) {
      leak_0 <- [];
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (nonce + (W64.of_int (4 * i)))))])]);
      v <- (loadW32 Glob.mem (W64.to_uint (nonce + (W64.of_int (4 * i)))));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (13 + i))])]);
      v <- (v + (BArray64.get32 x (13 + i)));
      leak_0 <-
      (leak_0 ++
      [(LeakList
       [(Leak_int
        (W64.to_uint ((out + (W64.of_int 52)) + (W64.of_int (4 * i)))))]
       )]);
      Glob.mem <-
      (storeW32 Glob.mem
      (W64.to_uint ((out + (W64.of_int 52)) + (W64.of_int (4 * i)))) 
      v);
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    return (LeakList leak);
  }
}.
