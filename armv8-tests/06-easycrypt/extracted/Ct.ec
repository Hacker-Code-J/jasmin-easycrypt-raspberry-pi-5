require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

module M = {
  proc ct_memeq (a:W64.t, b:W64.t, len:W64.t) : W64.t = {
    var acc:W64.t;
    var i:W64.t;
    var x:W64.t;
    var y:W64.t;
    acc <- (W64.of_int 0);
    i <- (W64.of_int 0);
    while ((i \ult len)) {
      x <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (a + i))));
      y <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (b + i))));
      x <- (x `^` y);
      acc <- (acc `|` x);
      i <- (i + (W64.of_int 1));
    }
    acc <- (acc - (W64.of_int 1));
    acc <- (acc `>>` (W8.of_int 63));
    return acc;
  }
  proc leaky_memeq (a:W64.t, b:W64.t, len:W64.t) : W64.t = {
    var r:W64.t;
    var i:W64.t;
    var x:W64.t;
    var y:W64.t;
    r <- (W64.of_int 1);
    i <- (W64.of_int 0);
    while ((i \ult len)) {
      x <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (a + i))));
      y <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (b + i))));
      if ((x <> y)) {
        r <- (W64.of_int 0);
        i <- len;
      } else {
        i <- (i + (W64.of_int 1));
      }
    }
    return r;
  }
  proc ct_cswap4 (c:W64.t, p:W64.t, q:W64.t) : unit = {
    var mask:W64.t;
    var i:int;
    var x:W64.t;
    var y:W64.t;
    var t:W64.t;
    mask <- (W64.of_int 0);
    mask <- (mask - c);
    i <- 0;
    while ((i < 4)) {
      x <- (loadW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))));
      y <- (loadW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))));
      t <- (x `^` y);
      t <- (t `&` mask);
      x <- (x `^` t);
      y <- (y `^` t);
      Glob.mem <-
      (storeW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))) x);
      Glob.mem <-
      (storeW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))) y);
      i <- (i + 1);
    }
    return ();
  }
  proc leaky_cswap4 (c:W64.t, p:W64.t, q:W64.t) : unit = {
    var i:int;
    var x:W64.t;
    var y:W64.t;
    if ((c = (W64.of_int 1))) {
      i <- 0;
      while ((i < 4)) {
        x <- (loadW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))));
        y <- (loadW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))));
        Glob.mem <-
        (storeW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))) y);
        Glob.mem <-
        (storeW64 Glob.mem (W64.to_uint (q + (W64.of_int (8 * i)))) x);
        i <- (i + 1);
      }
    } else {
      
    }
    return ();
  }
  proc ct_lookup16 (table:W64.t, idx:W64.t) : W64.t = {
    var r:W64.t;
    var i:W64.t;
    var v:W64.t;
    var eq:bool;
    r <- (W64.of_int 0);
    i <- (W64.of_int 0);
    while ((i \ult (W64.of_int 16))) {
      v <- (loadW64 Glob.mem (W64.to_uint (table + ((W64.of_int 8) * i))));
      eq <- (i = idx);
      r <- (eq ? v : r);
      i <- (i + (W64.of_int 1));
    }
    return r;
  }
  proc leaky_lookup16 (table:W64.t, idx:W64.t) : W64.t = {
    var r:W64.t;
    idx <- (idx `&` (W64.of_int 15));
    r <- (loadW64 Glob.mem (W64.to_uint (table + ((W64.of_int 8) * idx))));
    return r;
  }
  proc leaky_div (a:W64.t, b:W64.t) : W64.t = {
    
    a <- (a \udiv b);
    return a;
  }
}.
