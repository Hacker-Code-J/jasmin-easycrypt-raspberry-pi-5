require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

from Jasmin require import JLeakage.

require import BArray32 BArray128.

module M = {
  proc add128 (alo:W64.t, ahi:W64.t, blo:W64.t, bhi:W64.t) : JLeakage.leakage *
                                                             W64.t * W64.t = {
    var leak:JLeakage.leakages;
    var cf:bool;
    var  _0:bool;
    leak <- [];
    (cf, alo) <- (adc_64 alo blo false);
    ( _0, ahi) <- (adc_64 ahi bhi cf);
    return ((LeakList leak), alo, ahi);
  }
  proc sub128 (alo:W64.t, ahi:W64.t, blo:W64.t, bhi:W64.t) : JLeakage.leakage *
                                                             W64.t * W64.t = {
    var leak:JLeakage.leakages;
    var n:bool;
    var z:bool;
    var c:bool;
    var v:bool;
    leak <- [];
    (n, z, c, v, alo) <- (SUBS_64 alo blo);
    bhi <- (invw bhi);
    ahi <- (ADC_64 ahi bhi c);
    return ((LeakList leak), alo, ahi);
  }
  proc sub_carry (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var r:W64.t;
    var n:bool;
    var z:bool;
    var c:bool;
    var v:bool;
    var one:W64.t;
    leak <- [];
    (n, z, c, v, a) <- (SUBS_64 a b);
    r <- (W64.of_int 0);
    one <- (W64.of_int 1);
    r <- (c ? one : r);
    return ((LeakList leak), r);
  }
  proc mul64x64 (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t * W64.t = {
    var leak:JLeakage.leakages;
    var hi:W64.t;
    var lo:W64.t;
    var al:W64.t;
    var ah:W64.t;
    var bl:W64.t;
    var bh:W64.t;
    var ll:W64.t;
    var lh:W64.t;
    var hl:W64.t;
    var hh:W64.t;
    var cf:bool;
    var mid:W64.t;
    var t:W64.t;
    var  _0:bool;
    var  _1:bool;
    leak <- [];
    al <- a;
    al <- (al `&` (W64.of_int 4294967295));
    ah <- (a `>>` (W8.of_int 32));
    bl <- b;
    bl <- (bl `&` (W64.of_int 4294967295));
    bh <- (b `>>` (W8.of_int 32));
    ll <- (al * bl);
    lh <- (al * bh);
    hl <- (ah * bl);
    hh <- (ah * bh);
    (cf, mid) <- (adc_64 lh hl false);
    t <- (W64.of_int 0);
    ( _0, t) <- (adc_64 t t cf);
    t <- (t `<<` (W8.of_int 32));
    hh <- (hh + t);
    t <- (mid `<<` (W8.of_int 32));
    (cf, lo) <- (adc_64 ll t false);
    t <- (mid `>>` (W8.of_int 32));
    ( _1, hh) <- (adc_64 hh t cf);
    hi <- hh;
    return ((LeakList leak), hi, lo);
  }
  proc madd_msub (a:W64.t, b:W64.t, c:W64.t) : JLeakage.leakage * W64.t *
                                               W64.t = {
    var leak:JLeakage.leakages;
    var x:W64.t;
    var y:W64.t;
    leak <- [];
    x <- (c + (a * b));
    y <- (c - (a * b));
    return ((LeakList leak), x, y);
  }
  proc rot64 (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t * W64.t = {
    var leak:JLeakage.leakages;
    var x:W64.t;
    var y:W64.t;
    var n:W64.t;
    leak <- [];
    x <- (a `|<<|` (W8.of_int 13));
    x <- (x `|>>|` (W8.of_int 7));
    x <- (x `|>>|` (truncateu8 b));
    n <- (W64.of_int 0);
    n <- (n - b);
    y <- (a `|>>|` (truncateu8 n));
    return ((LeakList leak), x, y);
  }
  proc rot32 (a:W32.t, b:W32.t) : JLeakage.leakage * W32.t = {
    var leak:JLeakage.leakages;
    var x:W32.t;
    leak <- [];
    x <- (a `|<<|` (W8.of_int 16));
    x <- (x `|<<|` (W8.of_int 12));
    x <- (x `|<<|` (W8.of_int 8));
    x <- (x `|<<|` (W8.of_int 7));
    x <- (x `|>>|` (truncateu8 b));
    return ((LeakList leak), x);
  }
  proc shifts (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var x:W64.t;
    var y:W64.t;
    leak <- [];
    x <- (a `<<` (truncateu8 (b `&` (W64.of_int 63))));
    y <- (a `>>` (truncateu8 (b `&` (W64.of_int 63))));
    x <- (x `^` y);
    y <- (a `|>>` (truncateu8 (b `&` (W64.of_int 63))));
    x <- (x + y);
    x <- (x `^` (a `<<` (W8.of_int 63)));
    x <- (x + (a `>>` (W8.of_int 1)));
    return ((LeakList leak), x);
  }
  proc logic_0 (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var x:W64.t;
    var nb:W64.t;
    var y:W64.t;
    var k:W64.t;
    leak <- [];
    nb <- (invw b);
    x <- (a `&` nb);
    y <- (a `^` nb);
    x <- (x `|` y);
    x <- (x `&` (W64.of_int 71777214294589695));
    x <- (x `|` (W64.of_int 9223372036854775809));
    k <- (W64.of_int 1311768467463790320);
    x <- (x `^` k);
    return ((LeakList leak), x);
  }
  proc popcount (a:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var m:W64.t;
    var t:W64.t;
    leak <- [];
    m <- (W64.of_int 6148914691236517205);
    t <- (a `>>` (W8.of_int 1));
    t <- (t `&` m);
    a <- (a - t);
    m <- (W64.of_int 3689348814741910323);
    t <- (a `>>` (W8.of_int 2));
    t <- (t `&` m);
    a <- (a `&` m);
    a <- (a + t);
    t <- (a `>>` (W8.of_int 4));
    a <- (a + t);
    m <- (W64.of_int 1085102592571150095);
    a <- (a `&` m);
    m <- (W64.of_int 72340172838076673);
    a <- (a * m);
    a <- (a `>>` (W8.of_int 56));
    return ((LeakList leak), a);
  }
  proc compare (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var r:W64.t;
    var one:W64.t;
    var c:bool;
    var bit:W64.t;
    leak <- [];
    r <- (W64.of_int 0);
    one <- (W64.of_int 1);
    c <- (a = b);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` bit);
    c <- (a <> b);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 1)));
    c <- (a \ult b);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 2)));
    c <- (a \ule b);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 3)));
    c <- (b \ult a);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 4)));
    c <- (b \ule a);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 5)));
    c <- (a \slt b);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 6)));
    c <- (a \sle b);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 7)));
    c <- (b \slt a);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 8)));
    c <- (b \sle a);
    bit <- (W64.of_int 0);
    bit <- (c ? one : bit);
    r <- (r `|` (bit `<<` (W8.of_int 9)));
    return ((LeakList leak), r);
  }
  proc casts (a:W64.t) : JLeakage.leakage * W64.t * W64.t = {
    var leak:JLeakage.leakages;
    var zx:W64.t;
    var sx:W64.t;
    var w:W32.t;
    var k:W32.t;
    leak <- [];
    w <- (truncateu32 a);
    k <- (W32.of_int 2147483648);
    w <- (w + k);
    zx <- (zeroextu64 w);
    sx <- (sigextu64 w);
    return ((LeakList leak), zx, sx);
  }
  proc word32_wrap (a:W32.t, b:W32.t) : JLeakage.leakage * W32.t = {
    var leak:JLeakage.leakages;
    var x:W32.t;
    var k:W32.t;
    leak <- [];
    x <- (a * b);
    k <- (W32.of_int 4294967295);
    x <- (x + k);
    x <- (x - (b `<<` (W8.of_int 31)));
    x <- (x `|>>` (W8.of_int 31));
    return ((LeakList leak), x);
  }
  proc gcd (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t = {
    var _b:JLeakage.leakages;
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_cond:JLeakage.leakages;
    var q:W64.t;
    var r:W64.t;
    leak <- [];
    leak_cond <- [];
    _b <- [];
    leak_cond <-
    (leak_cond ++ [(LeakList [(Leak_bool (b <> (W64.of_int 0)))])]);
    while ((b <> (W64.of_int 0))) {
      leak_0 <- [];
      q <- (a \udiv b);
      r <- (a - (q * b));
      a <- b;
      b <- r;
      _b <- (_b ++ [(LeakList leak_0)]);
      leak_cond <-
      (leak_cond ++ [(LeakList [(Leak_bool (b <> (W64.of_int 0)))])]);
    }
    leak <- (leak ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
    return ((LeakList leak), a);
  }
  proc collatz (n:W64.t) : JLeakage.leakage * W64.t = {
    var _b:JLeakage.leakages;
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_1:JLeakage.leakages;
    var leak_2:JLeakage.leakages;
    var leak_cond:JLeakage.leakages;
    var steps:W64.t;
    var t:W64.t;
    leak <- [];
    steps <- (W64.of_int 0);
    leak_cond <- [];
    _b <- [];
    leak_cond <-
    (leak_cond ++ [(LeakList [(Leak_bool ((W64.of_int 1) \ult n))])]);
    while (((W64.of_int 1) \ult n)) {
      leak_0 <- [];
      leak_0 <-
      (leak_0 ++ [(LeakList [(Leak_bool ((W64.of_int 1000) \ule steps))])]);
      if (((W64.of_int 1000) \ule steps)) {
        leak_1 <- [];
        n <- (W64.of_int 1);
        leak_0 <- (leak_0 ++ [(LeakList leak_1)]);
      } else {
        leak_1 <- [];
        t <- (n `&` (W64.of_int 1));
        leak_1 <-
        (leak_1 ++ [(LeakList [(Leak_bool (t = (W64.of_int 0)))])]);
        if ((t = (W64.of_int 0))) {
          leak_2 <- [];
          n <- (n `>>` (W8.of_int 1));
          leak_1 <- (leak_1 ++ [(LeakList leak_2)]);
        } else {
          leak_2 <- [];
          t <- (n + n);
          n <- (n + t);
          n <- (n + (W64.of_int 1));
          leak_1 <- (leak_1 ++ [(LeakList leak_2)]);
        }
        steps <- (steps + (W64.of_int 1));
        leak_0 <- (leak_0 ++ [(LeakList leak_1)]);
      }
      _b <- (_b ++ [(LeakList leak_0)]);
      leak_cond <-
      (leak_cond ++ [(LeakList [(Leak_bool ((W64.of_int 1) \ult n))])]);
    }
    leak <- (leak ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
    return ((LeakList leak), steps);
  }
  proc mix (x:W64.t, y:W64.t) : JLeakage.leakage * W64.t * W64.t = {
    var leak:JLeakage.leakages;
    leak <- [];
    x <- (x + y);
    y <- (y `|<<|` (W8.of_int 17));
    y <- (y `^` x);
    return ((LeakList leak), x, y);
  }
  proc pressure (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var leak_c:JLeakage.leakage;
    var r:W64.t;
    var v0:W64.t;
    var v1:W64.t;
    var v2:W64.t;
    var v3:W64.t;
    var k:W64.t;
    var v4:W64.t;
    var v5:W64.t;
    var v6:W64.t;
    var v7:W64.t;
    var v8:W64.t;
    var v9:W64.t;
    var v10:W64.t;
    var v11:W64.t;
    var v12:W64.t;
    var v13:W64.t;
    var v14:W64.t;
    var v15:W64.t;
    var v16:W64.t;
    var v17:W64.t;
    var v18:W64.t;
    var v19:W64.t;
    var v20:W64.t;
    var v21:W64.t;
    var v22:W64.t;
    var v23:W64.t;
    var p:W64.t;
    var q:W64.t;
    leak <- [];
    v0 <- (a + (W64.of_int 1));
    v1 <- (b + (W64.of_int 2));
    v2 <- (a `^` b);
    v3 <- (a - b);
    k <- (W64.of_int 3);
    v4 <- (a * k);
    k <- (W64.of_int 5);
    v5 <- (b * k);
    v6 <- (a `>>` (W8.of_int 3));
    v7 <- (b `<<` (W8.of_int 4));
    v8 <- (a + b);
    v9 <- (a `|` b);
    v10 <- (a `&` b);
    v11 <- (a * b);
    v12 <- (v0 + v1);
    v13 <- (v2 + v3);
    v14 <- (v4 `^` v5);
    v15 <- (v6 - v7);
    v16 <- (v8 * v9);
    v17 <- (v10 + v11);
    v18 <- (v12 `^` v13);
    v19 <- (v14 + v15);
    v20 <- (v16 - v17);
    k <- (W64.of_int 7);
    v21 <- (v18 * k);
    v22 <- (v19 `>>` (W8.of_int 1));
    v23 <- (v20 `<<` (W8.of_int 2));
    p <- v0;
    q <- v1;
    (leak_c, p, q) <@ mix (p, q);
    leak <- (leak ++ [leak_c]);
    v0 <- p;
    v1 <- q;
    p <- v2;
    q <- v3;
    (leak_c, p, q) <@ mix (p, q);
    leak <- (leak ++ [leak_c]);
    v2 <- p;
    v3 <- q;
    p <- v22;
    q <- v23;
    (leak_c, p, q) <@ mix (p, q);
    leak <- (leak ++ [leak_c]);
    v22 <- p;
    v23 <- q;
    r <- (v0 + v1);
    r <- (r `^` v2);
    r <- (r + v3);
    r <- (r `^` v4);
    r <- (r + v5);
    r <- (r `^` v6);
    r <- (r + v7);
    r <- (r `^` v8);
    r <- (r + v9);
    r <- (r `^` v10);
    r <- (r + v11);
    r <- (r `^` v12);
    r <- (r + v13);
    r <- (r `^` v14);
    r <- (r + v15);
    r <- (r `^` v16);
    r <- (r + v17);
    r <- (r `^` v18);
    r <- (r + v19);
    r <- (r `^` v20);
    r <- (r + v21);
    r <- (r `^` v22);
    r <- (r + v23);
    return ((LeakList leak), r);
  }
  proc arrays (a:W64.t, i:W64.t, j:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var v:W64.t;
    var k:int;
    var s:BArray128.t;
    var t:BArray32.t;
    s <- witness;
    t <- witness;
    leak <- [];
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 16)])]);
    k <- 0;
    while ((k < 16)) {
      leak_0 <- [];
      v <- (a + (W64.of_int k));
      v <- (v `|<<|` (W8.of_int k));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      s <- (BArray128.set64 s k v);
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      k <- (k + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 4)])]);
    k <- 0;
    while ((k < 4)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (k * 3))])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      t <- (BArray32.set64 t k (BArray128.get64 s (k * 3)));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      k <- (k + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    i <- (i `&` (W64.of_int 15));
    j <- (j `&` (W64.of_int 15));
    leak <- (leak ++ [(LeakList [(Leak_int (W64.to_uint i))])]);
    v <- (BArray128.get64 s (W64.to_uint i));
    leak <- (leak ++ [(LeakList [(Leak_int (W64.to_uint j))])]);
    s <- (BArray128.set64 s (W64.to_uint j) v);
    leak <- (leak ++ [(LeakList [(Leak_int (W64.to_uint j))])]);
    v <- (BArray128.get64 s (W64.to_uint j));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    v <- (v `^` (BArray32.get64 t 0));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    v <- (v + (BArray32.get64 t 1));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    v <- (v `^` (BArray32.get64 t 2));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    v <- (v + (BArray32.get64 t 3));
    return ((LeakList leak), v);
  }
}.
