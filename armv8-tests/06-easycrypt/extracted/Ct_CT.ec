require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

from Jasmin require import JLeakage.

module M = {
  proc ct_memeq (a:W64.t, b:W64.t, len:W64.t) : JLeakage.leakage * W64.t = {
    var _b:JLeakage.leakages;
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_cond:JLeakage.leakages;
    var acc:W64.t;
    var i:W64.t;
    var x:W64.t;
    var y:W64.t;
    leak <- [];
    acc <- (W64.of_int 0);
    i <- (W64.of_int 0);
    leak_cond <- [];
    _b <- [];
    leak_cond <- (leak_cond ++ [(LeakList [(Leak_bool (i \ult len))])]);
    while ((i \ult len)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (W64.to_uint (a + i)))])]);
      x <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (a + i))));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (W64.to_uint (b + i)))])]);
      y <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (b + i))));
      x <- (x `^` y);
      acc <- (acc `|` x);
      i <- (i + (W64.of_int 1));
      _b <- (_b ++ [(LeakList leak_0)]);
      leak_cond <- (leak_cond ++ [(LeakList [(Leak_bool (i \ult len))])]);
    }
    leak <- (leak ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
    acc <- (acc - (W64.of_int 1));
    acc <- (acc `>>` (W8.of_int 63));
    return ((LeakList leak), acc);
  }
  proc leaky_memeq (a:W64.t, b:W64.t, len:W64.t) : JLeakage.leakage * W64.t = {
    var _b:JLeakage.leakages;
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_1:JLeakage.leakages;
    var leak_cond:JLeakage.leakages;
    var r:W64.t;
    var i:W64.t;
    var x:W64.t;
    var y:W64.t;
    leak <- [];
    r <- (W64.of_int 1);
    i <- (W64.of_int 0);
    leak_cond <- [];
    _b <- [];
    leak_cond <- (leak_cond ++ [(LeakList [(Leak_bool (i \ult len))])]);
    while ((i \ult len)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (W64.to_uint (a + i)))])]);
      x <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (a + i))));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int (W64.to_uint (b + i)))])]);
      y <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (b + i))));
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_bool (x <> y))])]);
      if ((x <> y)) {
        leak_1 <- [];
        r <- (W64.of_int 0);
        i <- len;
        leak_0 <- (leak_0 ++ [(LeakList leak_1)]);
      } else {
        leak_1 <- [];
        i <- (i + (W64.of_int 1));
        leak_0 <- (leak_0 ++ [(LeakList leak_1)]);
      }
      _b <- (_b ++ [(LeakList leak_0)]);
      leak_cond <- (leak_cond ++ [(LeakList [(Leak_bool (i \ult len))])]);
    }
    leak <- (leak ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
    return ((LeakList leak), r);
  }
  proc ct_cswap4 (c:W64.t, p:W64.t, q:W64.t) : JLeakage.leakage = {
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var mask:W64.t;
    var i:int;
    var x:W64.t;
    var y:W64.t;
    var t:W64.t;
    leak <- [];
    mask <- (W64.of_int 0);
    mask <- (mask - c);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 4)])]);
    i <- 0;
    while ((i < 4)) {
      leak_0 <- [];
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (p + (W64.of_int (8 * i)))))])]);
      x <- (loadW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))));
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (q + (W64.of_int (8 * i)))))])]);
      y <- (loadW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))));
      t <- (x `^` y);
      t <- (t `&` mask);
      x <- (x `^` t);
      y <- (y `^` t);
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (p + (W64.of_int (8 * i)))))])]);
      Glob.mem <-
      (storeW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))) x);
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (q + (W64.of_int (8 * i)))))])]);
      Glob.mem <-
      (storeW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))) y);
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    return (LeakList leak);
  }
  proc leaky_cswap4 (c:W64.t, p:W64.t, q:W64.t) : JLeakage.leakage = {
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_1:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var i:int;
    var x:W64.t;
    var y:W64.t;
    leak <- [];
    leak <- (leak ++ [(LeakList [(Leak_bool (c = (W64.of_int 1)))])]);
    if ((c = (W64.of_int 1))) {
      leak_0 <- [];
      leak_b <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int 0); (Leak_int 4)])]);
      i <- 0;
      while ((i < 4)) {
        leak_1 <- [];
        leak_1 <-
        (leak_1 ++
        [(LeakList [(Leak_int (W64.to_uint (p + (W64.of_int (8 * i)))))])]);
        x <- (loadW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))));
        leak_1 <-
        (leak_1 ++
        [(LeakList [(Leak_int (W64.to_uint (q + (W64.of_int (8 * i)))))])]);
        y <- (loadW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))));
        leak_1 <-
        (leak_1 ++
        [(LeakList [(Leak_int (W64.to_uint (p + (W64.of_int (8 * i)))))])]);
        Glob.mem <-
        (storeW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))) y);
        leak_1 <-
        (leak_1 ++
        [(LeakList [(Leak_int (W64.to_uint (q + (W64.of_int (8 * i)))))])]);
        Glob.mem <-
        (storeW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))) x);
        leak_b <- (leak_b ++ [(LeakList leak_1)]);
        i <- (i + 1);
      }
      leak_0 <- (leak_0 ++ [(LeakList leak_b)]);
      leak <- (leak ++ [(LeakList leak_0)]);
    } else {
      leak_0 <- [];
      leak <- (leak ++ [(LeakList leak_0)]);
    }
    return (LeakList leak);
  }
  proc ct_lookup16 (table:W64.t, idx:W64.t) : JLeakage.leakage * W64.t = {
    var _b:JLeakage.leakages;
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_cond:JLeakage.leakages;
    var r:W64.t;
    var i:W64.t;
    var v:W64.t;
    var eq:bool;
    leak <- [];
    r <- (W64.of_int 0);
    i <- (W64.of_int 0);
    leak_cond <- [];
    _b <- [];
    leak_cond <-
    (leak_cond ++ [(LeakList [(Leak_bool (i \ult (W64.of_int 16)))])]);
    while ((i \ult (W64.of_int 16))) {
      leak_0 <- [];
      leak_0 <-
      (leak_0 ++
      [(LeakList [(Leak_int (W64.to_uint (table + ((W64.of_int 8) * i))))])]);
      v <- (loadW64 Glob.mem (W64.to_uint (table + ((W64.of_int 8) * i))));
      eq <- (i = idx);
      r <- (eq ? v : r);
      i <- (i + (W64.of_int 1));
      _b <- (_b ++ [(LeakList leak_0)]);
      leak_cond <-
      (leak_cond ++ [(LeakList [(Leak_bool (i \ult (W64.of_int 16)))])]);
    }
    leak <- (leak ++ [(LeakList [(LeakList leak_cond); (LeakList _b)])]);
    return ((LeakList leak), r);
  }
  proc leaky_lookup16 (table:W64.t, idx:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var r:W64.t;
    leak <- [];
    idx <- (idx `&` (W64.of_int 15));
    leak <-
    (leak ++
    [(LeakList [(Leak_int (W64.to_uint (table + ((W64.of_int 8) * idx))))])]);
    r <- (loadW64 Glob.mem (W64.to_uint (table + ((W64.of_int 8) * idx))));
    return ((LeakList leak), r);
  }
  proc leaky_div (a:W64.t, b:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    leak <- [];
    a <- (a \udiv b);
    return ((LeakList leak), a);
  }
}.
