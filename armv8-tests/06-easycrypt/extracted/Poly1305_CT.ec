require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

from Jasmin require import JLeakage.

require import BArray32 BArray40.

module M = {
  proc split_0 (lo:W64.t, hi:W64.t) : JLeakage.leakage * BArray40.t = {
    var leak:JLeakage.leakages;
    var l:BArray40.t;
    var t:W64.t;
    l <- witness;
    leak <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    l <- (BArray40.set64 l 0 lo);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    l <-
    (BArray40.set64 l 0 ((BArray40.get64 l 0) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    l <- (BArray40.set64 l 1 (lo `>>` (W8.of_int 26)));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    l <-
    (BArray40.set64 l 1 ((BArray40.get64 l 1) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    l <- (BArray40.set64 l 2 (lo `>>` (W8.of_int 52)));
    t <- (hi `<<` (W8.of_int 12));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    l <- (BArray40.set64 l 2 ((BArray40.get64 l 2) `|` t));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    l <-
    (BArray40.set64 l 2 ((BArray40.get64 l 2) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    l <- (BArray40.set64 l 3 (hi `>>` (W8.of_int 14)));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    l <-
    (BArray40.set64 l 3 ((BArray40.get64 l 3) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    l <- (BArray40.set64 l 4 (hi `>>` (W8.of_int 40)));
    return ((LeakList leak), l);
  }
  proc block (h:BArray40.t, r:BArray40.t, s:BArray32.t, lo:W64.t, hi:W64.t,
              hibit:W64.t) : JLeakage.leakage * BArray40.t = {
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var leak_c:JLeakage.leakage;
    var b:BArray40.t;
    var i:int;
    var d:BArray40.t;
    var c:W64.t;
    b <- witness;
    d <- witness;
    leak <- [];
    (leak_c, b) <@ split_0 (lo, hi);
    leak <- (leak ++ [leak_c]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    b <- (BArray40.set64 b 4 ((BArray40.get64 b 4) `|` hibit));
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 5)])]);
    i <- 0;
    while ((i < 5)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int i); (Leak_int i)])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int i)])]);
      h <-
      (BArray40.set64 h i ((BArray40.get64 h i) + (BArray40.get64 b i)));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    d <- (BArray40.set64 d 0 ((BArray40.get64 h 0) * (BArray40.get64 r 0)));
    leak <-
    (leak ++ [(LeakList [(Leak_int 3); (Leak_int 1); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 1) * (BArray32.get64 s 3))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 2); (Leak_int 2); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 2) * (BArray32.get64 s 2))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 1); (Leak_int 3); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 3) * (BArray32.get64 s 1))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 0); (Leak_int 4); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 4) * (BArray32.get64 s 0))));
    leak <- (leak ++ [(LeakList [(Leak_int 1); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    d <- (BArray40.set64 d 1 ((BArray40.get64 h 0) * (BArray40.get64 r 1)));
    leak <-
    (leak ++ [(LeakList [(Leak_int 0); (Leak_int 1); (Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 1) * (BArray40.get64 r 0))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 3); (Leak_int 2); (Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 2) * (BArray32.get64 s 3))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 2); (Leak_int 3); (Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 3) * (BArray32.get64 s 2))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 1); (Leak_int 4); (Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 4) * (BArray32.get64 s 1))));
    leak <- (leak ++ [(LeakList [(Leak_int 2); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    d <- (BArray40.set64 d 2 ((BArray40.get64 h 0) * (BArray40.get64 r 2)));
    leak <-
    (leak ++ [(LeakList [(Leak_int 1); (Leak_int 1); (Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 1) * (BArray40.get64 r 1))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 0); (Leak_int 2); (Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 2) * (BArray40.get64 r 0))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 3); (Leak_int 3); (Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 3) * (BArray32.get64 s 3))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 2); (Leak_int 4); (Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 4) * (BArray32.get64 s 2))));
    leak <- (leak ++ [(LeakList [(Leak_int 3); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    d <- (BArray40.set64 d 3 ((BArray40.get64 h 0) * (BArray40.get64 r 3)));
    leak <-
    (leak ++ [(LeakList [(Leak_int 2); (Leak_int 1); (Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 1) * (BArray40.get64 r 2))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 1); (Leak_int 2); (Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 2) * (BArray40.get64 r 1))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 0); (Leak_int 3); (Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 3) * (BArray40.get64 r 0))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 3); (Leak_int 4); (Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 4) * (BArray32.get64 s 3))));
    leak <- (leak ++ [(LeakList [(Leak_int 4); (Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    d <- (BArray40.set64 d 4 ((BArray40.get64 h 0) * (BArray40.get64 r 4)));
    leak <-
    (leak ++ [(LeakList [(Leak_int 3); (Leak_int 1); (Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 1) * (BArray40.get64 r 3))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 2); (Leak_int 2); (Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 2) * (BArray40.get64 r 2))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 1); (Leak_int 3); (Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 3) * (BArray40.get64 r 1))));
    leak <-
    (leak ++ [(LeakList [(Leak_int 0); (Leak_int 4); (Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 4) * (BArray40.get64 r 0))));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    c <- ((BArray40.get64 d 0) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <- (BArray40.set64 h 0 (BArray40.get64 d 0));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <-
    (BArray40.set64 h 0 ((BArray40.get64 h 0) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    d <- (BArray40.set64 d 1 ((BArray40.get64 d 1) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    c <- ((BArray40.get64 d 1) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    h <- (BArray40.set64 h 1 (BArray40.get64 d 1));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    h <-
    (BArray40.set64 h 1 ((BArray40.get64 h 1) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    d <- (BArray40.set64 d 2 ((BArray40.get64 d 2) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    c <- ((BArray40.get64 d 2) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    h <- (BArray40.set64 h 2 (BArray40.get64 d 2));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    h <-
    (BArray40.set64 h 2 ((BArray40.get64 h 2) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    d <- (BArray40.set64 d 3 ((BArray40.get64 d 3) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    c <- ((BArray40.get64 d 3) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    h <- (BArray40.set64 h 3 (BArray40.get64 d 3));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    h <-
    (BArray40.set64 h 3 ((BArray40.get64 h 3) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    d <- (BArray40.set64 d 4 ((BArray40.get64 d 4) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    c <- ((BArray40.get64 d 4) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    h <- (BArray40.set64 h 4 (BArray40.get64 d 4));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    h <-
    (BArray40.set64 h 4 ((BArray40.get64 h 4) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    c <- (c `<<` (W8.of_int 2));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    c <- ((BArray40.get64 h 0) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <-
    (BArray40.set64 h 0 ((BArray40.get64 h 0) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    h <- (BArray40.set64 h 1 ((BArray40.get64 h 1) + c));
    return ((LeakList leak), h);
  }
  proc poly1305 (out:W64.t, m:W64.t, len:W64.t, key:W64.t) : JLeakage.leakage = {
    var _b:JLeakage.leakages;
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_1:JLeakage.leakages;
    var leak_2:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var leak_c:JLeakage.leakage;
    var leak_cond:JLeakage.leakages;
    var s_out:W64.t;
    var s_key:W64.t;
    var lo:W64.t;
    var t:W64.t;
    var hi:W64.t;
    var r:BArray40.t;
    var k:int;
    var s:BArray32.t;
    var h:BArray40.t;
    var hibit:W64.t;
    var i:W64.t;
    var c:W64.t;
    var sh:W64.t;
    var g:BArray40.t;
    var mask:W64.t;
    var nmask:W64.t;
    var cf:bool;
    var  _0:bool;
    g <- witness;
    h <- witness;
    r <- witness;
    s <- witness;
    leak <- [];
    s_out <- out;
    s_key <- key;
    leak <- (leak ++ [(LeakList [(Leak_int (W64.to_uint key))])]);
    lo <- (loadW64 Glob.mem (W64.to_uint key));
    t <- (W64.of_int 1152921487695413247);
    lo <- (lo `&` t);
    leak <-
    (leak ++ [(LeakList [(Leak_int (W64.to_uint (key + (W64.of_int 8))))])]);
    hi <- (loadW64 Glob.mem (W64.to_uint (key + (W64.of_int 8))));
    t <- (W64.of_int 1152921487695413244);
    hi <- (hi `&` t);
    (leak_c, r) <@ split_0 (lo, hi);
    leak <- (leak ++ [leak_c]);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 4)])]);
    k <- 0;
    while ((k < 4)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (k + 1))])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      s <- (BArray32.set64 s k (BArray40.get64 r (k + 1)));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      t <- ((BArray32.get64 s k) `<<` (W8.of_int 2));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      s <- (BArray32.set64 s k ((BArray32.get64 s k) + t));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      k <- (k + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 5)])]);
    k <- 0;
    while ((k < 5)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      h <- (BArray40.set64 h k (W64.of_int 0));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      k <- (k + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    hibit <- (W64.of_int (1 `<<` 24));
    leak_cond <- [];
    _b <- [];
    leak_cond <-
    (leak_cond ++ [(LeakList [(Leak_bool ((W64.of_int 16) \ule len))])]);
    while (((W64.of_int 16) \ule len)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (W64.to_uint m))])]);
      lo <- (loadW64 Glob.mem (W64.to_uint m));
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (m + (W64.of_int 8))))])]);
      hi <- (loadW64 Glob.mem (W64.to_uint (m + (W64.of_int 8))));
      (leak_c, h) <@ block (h, r, s, lo, hi, hibit);
      leak_0 <- (leak_0 ++ [leak_c]);
      m <- (m + (W64.of_int 16));
      len <- (len - (W64.of_int 16));
      _b <- (_b ++ [(LeakList leak_0)]);
      leak_cond <-
      (leak_cond ++ [(LeakList [(Leak_bool ((W64.of_int 16) \ule len))])]);
    }
    leak <- (leak ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
    leak <- (leak ++ [(LeakList [(Leak_bool (len <> (W64.of_int 0)))])]);
    if ((len <> (W64.of_int 0))) {
      leak_0 <- [];
      lo <- (W64.of_int 0);
      hi <- (W64.of_int 0);
      i <- (W64.of_int 0);
      leak_cond <- [];
      _b <- [];
      leak_cond <- (leak_cond ++ [(LeakList [(Leak_bool (i \ule len))])]);
      while ((i \ule len)) {
        leak_1 <- [];
        c <- (W64.of_int 1);
        leak_1 <- (leak_1 ++ [(LeakList [(Leak_bool (i \ult len))])]);
        if ((i \ult len)) {
          leak_2 <- [];
          leak_2 <-
          (leak_2 ++ [(LeakList [(Leak_int (W64.to_uint (m + i)))])]);
          c <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (m + i))));
          leak_1 <- (leak_1 ++ [(LeakList leak_2)]);
        } else {
          leak_2 <- [];
          leak_1 <- (leak_1 ++ [(LeakList leak_2)]);
        }
        sh <- (i `<<` (W8.of_int 3));
        c <- (c `<<` (truncateu8 (sh `&` (W64.of_int 63))));
        leak_1 <-
        (leak_1 ++ [(LeakList [(Leak_bool (i \ult (W64.of_int 8)))])]);
        if ((i \ult (W64.of_int 8))) {
          leak_2 <- [];
          lo <- (lo `|` c);
          leak_1 <- (leak_1 ++ [(LeakList leak_2)]);
        } else {
          leak_2 <- [];
          hi <- (hi `|` c);
          leak_1 <- (leak_1 ++ [(LeakList leak_2)]);
        }
        i <- (i + (W64.of_int 1));
        _b <- (_b ++ [(LeakList leak_1)]);
        leak_cond <- (leak_cond ++ [(LeakList [(Leak_bool (i \ule len))])]);
      }
      leak_0 <-
      (leak_0 ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
      hibit <- (W64.of_int 0);
      (leak_c, h) <@ block (h, r, s, lo, hi, hibit);
      leak_0 <- (leak_0 ++ [leak_c]);
      leak <- (leak ++ [(LeakList leak_0)]);
    } else {
      leak_0 <- [];
      leak <- (leak ++ [(LeakList leak_0)]);
    }
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    c <- ((BArray40.get64 h 1) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    h <-
    (BArray40.set64 h 1 ((BArray40.get64 h 1) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    h <- (BArray40.set64 h 2 ((BArray40.get64 h 2) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    c <- ((BArray40.get64 h 2) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    h <-
    (BArray40.set64 h 2 ((BArray40.get64 h 2) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    h <- (BArray40.set64 h 3 ((BArray40.get64 h 3) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    c <- ((BArray40.get64 h 3) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    h <-
    (BArray40.set64 h 3 ((BArray40.get64 h 3) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    h <- (BArray40.set64 h 4 ((BArray40.get64 h 4) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    c <- ((BArray40.get64 h 4) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    h <-
    (BArray40.set64 h 4 ((BArray40.get64 h 4) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    c <- (c `<<` (W8.of_int 2));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    c <- ((BArray40.get64 h 0) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    h <-
    (BArray40.set64 h 0 ((BArray40.get64 h 0) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    h <- (BArray40.set64 h 1 ((BArray40.get64 h 1) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    g <- (BArray40.set64 g 0 ((BArray40.get64 h 0) + (W64.of_int 5)));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    c <- ((BArray40.get64 g 0) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    g <-
    (BArray40.set64 g 0 ((BArray40.get64 g 0) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    g <- (BArray40.set64 g 1 ((BArray40.get64 h 1) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    c <- ((BArray40.get64 g 1) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    g <-
    (BArray40.set64 g 1 ((BArray40.get64 g 1) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    g <- (BArray40.set64 g 2 ((BArray40.get64 h 2) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    c <- ((BArray40.get64 g 2) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    g <-
    (BArray40.set64 g 2 ((BArray40.get64 g 2) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    g <- (BArray40.set64 g 3 ((BArray40.get64 h 3) + c));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    c <- ((BArray40.get64 g 3) `>>` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    g <-
    (BArray40.set64 g 3 ((BArray40.get64 g 3) `&` (W64.of_int 67108863)));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    g <- (BArray40.set64 g 4 ((BArray40.get64 h 4) + c));
    t <- (W64.of_int (1 `<<` 26));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    g <- (BArray40.set64 g 4 ((BArray40.get64 g 4) - t));
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    mask <- ((BArray40.get64 g 4) `>>` (W8.of_int 63));
    mask <- (mask - (W64.of_int 1));
    nmask <- (invw mask);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 5)])]);
    k <- 0;
    while ((k < 5)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      g <- (BArray40.set64 g k ((BArray40.get64 g k) `&` mask));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      h <- (BArray40.set64 h k ((BArray40.get64 h k) `&` nmask));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k); (Leak_int k)])]);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int k)])]);
      h <-
      (BArray40.set64 h k ((BArray40.get64 h k) `|` (BArray40.get64 g k)));
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      k <- (k + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    leak <- (leak ++ [(LeakList [(Leak_int 1)])]);
    lo <- ((BArray40.get64 h 1) `<<` (W8.of_int 26));
    leak <- (leak ++ [(LeakList [(Leak_int 0)])]);
    lo <- (lo `|` (BArray40.get64 h 0));
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    t <- ((BArray40.get64 h 2) `<<` (W8.of_int 52));
    lo <- (lo `|` t);
    leak <- (leak ++ [(LeakList [(Leak_int 2)])]);
    hi <- ((BArray40.get64 h 2) `>>` (W8.of_int 12));
    leak <- (leak ++ [(LeakList [(Leak_int 3)])]);
    t <- ((BArray40.get64 h 3) `<<` (W8.of_int 14));
    hi <- (hi `|` t);
    leak <- (leak ++ [(LeakList [(Leak_int 4)])]);
    t <- ((BArray40.get64 h 4) `<<` (W8.of_int 40));
    hi <- (hi `|` t);
    key <- s_key;
    leak <-
    (leak ++ [(LeakList [(Leak_int (W64.to_uint (key + (W64.of_int 16))))])]);
    t <- (loadW64 Glob.mem (W64.to_uint (key + (W64.of_int 16))));
    (cf, lo) <- (adc_64 lo t false);
    leak <-
    (leak ++ [(LeakList [(Leak_int (W64.to_uint (key + (W64.of_int 24))))])]);
    t <- (loadW64 Glob.mem (W64.to_uint (key + (W64.of_int 24))));
    ( _0, hi) <- (adc_64 hi t cf);
    out <- s_out;
    leak <- (leak ++ [(LeakList [(Leak_int (W64.to_uint out))])]);
    Glob.mem <- (storeW64 Glob.mem (W64.to_uint out) lo);
    leak <-
    (leak ++ [(LeakList [(Leak_int (W64.to_uint (out + (W64.of_int 8))))])]);
    Glob.mem <- (storeW64 Glob.mem (W64.to_uint (out + (W64.of_int 8))) hi);
    return (LeakList leak);
  }
}.
