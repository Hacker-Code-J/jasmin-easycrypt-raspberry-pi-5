require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

require import BArray32 BArray40.

module M = {
  proc split_0 (lo:W64.t, hi:W64.t) : BArray40.t = {
    var l:BArray40.t;
    var t:W64.t;
    l <- witness;
    l <- (BArray40.set64 l 0 lo);
    l <-
    (BArray40.set64 l 0 ((BArray40.get64 l 0) `&` (W64.of_int 67108863)));
    l <- (BArray40.set64 l 1 (lo `>>` (W8.of_int 26)));
    l <-
    (BArray40.set64 l 1 ((BArray40.get64 l 1) `&` (W64.of_int 67108863)));
    l <- (BArray40.set64 l 2 (lo `>>` (W8.of_int 52)));
    t <- (hi `<<` (W8.of_int 12));
    l <- (BArray40.set64 l 2 ((BArray40.get64 l 2) `|` t));
    l <-
    (BArray40.set64 l 2 ((BArray40.get64 l 2) `&` (W64.of_int 67108863)));
    l <- (BArray40.set64 l 3 (hi `>>` (W8.of_int 14)));
    l <-
    (BArray40.set64 l 3 ((BArray40.get64 l 3) `&` (W64.of_int 67108863)));
    l <- (BArray40.set64 l 4 (hi `>>` (W8.of_int 40)));
    return l;
  }
  proc block (h:BArray40.t, r:BArray40.t, s:BArray32.t, lo:W64.t, hi:W64.t,
              hibit:W64.t) : BArray40.t = {
    var b:BArray40.t;
    var i:int;
    var d:BArray40.t;
    var c:W64.t;
    b <- witness;
    d <- witness;
    b <@ split_0 (lo, hi);
    b <- (BArray40.set64 b 4 ((BArray40.get64 b 4) `|` hibit));
    i <- 0;
    while ((i < 5)) {
      h <-
      (BArray40.set64 h i ((BArray40.get64 h i) + (BArray40.get64 b i)));
      i <- (i + 1);
    }
    d <- (BArray40.set64 d 0 ((BArray40.get64 h 0) * (BArray40.get64 r 0)));
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 1) * (BArray32.get64 s 3))));
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 2) * (BArray32.get64 s 2))));
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 3) * (BArray32.get64 s 1))));
    d <-
    (BArray40.set64 d 0
    ((BArray40.get64 d 0) + ((BArray40.get64 h 4) * (BArray32.get64 s 0))));
    d <- (BArray40.set64 d 1 ((BArray40.get64 h 0) * (BArray40.get64 r 1)));
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 1) * (BArray40.get64 r 0))));
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 2) * (BArray32.get64 s 3))));
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 3) * (BArray32.get64 s 2))));
    d <-
    (BArray40.set64 d 1
    ((BArray40.get64 d 1) + ((BArray40.get64 h 4) * (BArray32.get64 s 1))));
    d <- (BArray40.set64 d 2 ((BArray40.get64 h 0) * (BArray40.get64 r 2)));
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 1) * (BArray40.get64 r 1))));
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 2) * (BArray40.get64 r 0))));
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 3) * (BArray32.get64 s 3))));
    d <-
    (BArray40.set64 d 2
    ((BArray40.get64 d 2) + ((BArray40.get64 h 4) * (BArray32.get64 s 2))));
    d <- (BArray40.set64 d 3 ((BArray40.get64 h 0) * (BArray40.get64 r 3)));
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 1) * (BArray40.get64 r 2))));
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 2) * (BArray40.get64 r 1))));
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 3) * (BArray40.get64 r 0))));
    d <-
    (BArray40.set64 d 3
    ((BArray40.get64 d 3) + ((BArray40.get64 h 4) * (BArray32.get64 s 3))));
    d <- (BArray40.set64 d 4 ((BArray40.get64 h 0) * (BArray40.get64 r 4)));
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 1) * (BArray40.get64 r 3))));
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 2) * (BArray40.get64 r 2))));
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 3) * (BArray40.get64 r 1))));
    d <-
    (BArray40.set64 d 4
    ((BArray40.get64 d 4) + ((BArray40.get64 h 4) * (BArray40.get64 r 0))));
    c <- ((BArray40.get64 d 0) `>>` (W8.of_int 26));
    h <- (BArray40.set64 h 0 (BArray40.get64 d 0));
    h <-
    (BArray40.set64 h 0 ((BArray40.get64 h 0) `&` (W64.of_int 67108863)));
    d <- (BArray40.set64 d 1 ((BArray40.get64 d 1) + c));
    c <- ((BArray40.get64 d 1) `>>` (W8.of_int 26));
    h <- (BArray40.set64 h 1 (BArray40.get64 d 1));
    h <-
    (BArray40.set64 h 1 ((BArray40.get64 h 1) `&` (W64.of_int 67108863)));
    d <- (BArray40.set64 d 2 ((BArray40.get64 d 2) + c));
    c <- ((BArray40.get64 d 2) `>>` (W8.of_int 26));
    h <- (BArray40.set64 h 2 (BArray40.get64 d 2));
    h <-
    (BArray40.set64 h 2 ((BArray40.get64 h 2) `&` (W64.of_int 67108863)));
    d <- (BArray40.set64 d 3 ((BArray40.get64 d 3) + c));
    c <- ((BArray40.get64 d 3) `>>` (W8.of_int 26));
    h <- (BArray40.set64 h 3 (BArray40.get64 d 3));
    h <-
    (BArray40.set64 h 3 ((BArray40.get64 h 3) `&` (W64.of_int 67108863)));
    d <- (BArray40.set64 d 4 ((BArray40.get64 d 4) + c));
    c <- ((BArray40.get64 d 4) `>>` (W8.of_int 26));
    h <- (BArray40.set64 h 4 (BArray40.get64 d 4));
    h <-
    (BArray40.set64 h 4 ((BArray40.get64 h 4) `&` (W64.of_int 67108863)));
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    c <- (c `<<` (W8.of_int 2));
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    c <- ((BArray40.get64 h 0) `>>` (W8.of_int 26));
    h <-
    (BArray40.set64 h 0 ((BArray40.get64 h 0) `&` (W64.of_int 67108863)));
    h <- (BArray40.set64 h 1 ((BArray40.get64 h 1) + c));
    return h;
  }
  proc poly1305 (out:W64.t, m:W64.t, len:W64.t, key:W64.t) : unit = {
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
    s_out <- out;
    s_key <- key;
    lo <- (loadW64 Glob.mem (W64.to_uint key));
    t <- (W64.of_int 1152921487695413247);
    lo <- (lo `&` t);
    hi <- (loadW64 Glob.mem (W64.to_uint (key + (W64.of_int 8))));
    t <- (W64.of_int 1152921487695413244);
    hi <- (hi `&` t);
    r <@ split_0 (lo, hi);
    k <- 0;
    while ((k < 4)) {
      s <- (BArray32.set64 s k (BArray40.get64 r (k + 1)));
      t <- ((BArray32.get64 s k) `<<` (W8.of_int 2));
      s <- (BArray32.set64 s k ((BArray32.get64 s k) + t));
      k <- (k + 1);
    }
    k <- 0;
    while ((k < 5)) {
      h <- (BArray40.set64 h k (W64.of_int 0));
      k <- (k + 1);
    }
    hibit <- (W64.of_int (1 `<<` 24));
    while (((W64.of_int 16) \ule len)) {
      lo <- (loadW64 Glob.mem (W64.to_uint m));
      hi <- (loadW64 Glob.mem (W64.to_uint (m + (W64.of_int 8))));
      h <@ block (h, r, s, lo, hi, hibit);
      m <- (m + (W64.of_int 16));
      len <- (len - (W64.of_int 16));
    }
    if ((len <> (W64.of_int 0))) {
      lo <- (W64.of_int 0);
      hi <- (W64.of_int 0);
      i <- (W64.of_int 0);
      while ((i \ule len)) {
        c <- (W64.of_int 1);
        if ((i \ult len)) {
          c <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint (m + i))));
        } else {
          
        }
        sh <- (i `<<` (W8.of_int 3));
        c <- (c `<<` (truncateu8 (sh `&` (W64.of_int 63))));
        if ((i \ult (W64.of_int 8))) {
          lo <- (lo `|` c);
        } else {
          hi <- (hi `|` c);
        }
        i <- (i + (W64.of_int 1));
      }
      hibit <- (W64.of_int 0);
      h <@ block (h, r, s, lo, hi, hibit);
    } else {
      
    }
    c <- ((BArray40.get64 h 1) `>>` (W8.of_int 26));
    h <-
    (BArray40.set64 h 1 ((BArray40.get64 h 1) `&` (W64.of_int 67108863)));
    h <- (BArray40.set64 h 2 ((BArray40.get64 h 2) + c));
    c <- ((BArray40.get64 h 2) `>>` (W8.of_int 26));
    h <-
    (BArray40.set64 h 2 ((BArray40.get64 h 2) `&` (W64.of_int 67108863)));
    h <- (BArray40.set64 h 3 ((BArray40.get64 h 3) + c));
    c <- ((BArray40.get64 h 3) `>>` (W8.of_int 26));
    h <-
    (BArray40.set64 h 3 ((BArray40.get64 h 3) `&` (W64.of_int 67108863)));
    h <- (BArray40.set64 h 4 ((BArray40.get64 h 4) + c));
    c <- ((BArray40.get64 h 4) `>>` (W8.of_int 26));
    h <-
    (BArray40.set64 h 4 ((BArray40.get64 h 4) `&` (W64.of_int 67108863)));
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    c <- (c `<<` (W8.of_int 2));
    h <- (BArray40.set64 h 0 ((BArray40.get64 h 0) + c));
    c <- ((BArray40.get64 h 0) `>>` (W8.of_int 26));
    h <-
    (BArray40.set64 h 0 ((BArray40.get64 h 0) `&` (W64.of_int 67108863)));
    h <- (BArray40.set64 h 1 ((BArray40.get64 h 1) + c));
    g <- (BArray40.set64 g 0 ((BArray40.get64 h 0) + (W64.of_int 5)));
    c <- ((BArray40.get64 g 0) `>>` (W8.of_int 26));
    g <-
    (BArray40.set64 g 0 ((BArray40.get64 g 0) `&` (W64.of_int 67108863)));
    g <- (BArray40.set64 g 1 ((BArray40.get64 h 1) + c));
    c <- ((BArray40.get64 g 1) `>>` (W8.of_int 26));
    g <-
    (BArray40.set64 g 1 ((BArray40.get64 g 1) `&` (W64.of_int 67108863)));
    g <- (BArray40.set64 g 2 ((BArray40.get64 h 2) + c));
    c <- ((BArray40.get64 g 2) `>>` (W8.of_int 26));
    g <-
    (BArray40.set64 g 2 ((BArray40.get64 g 2) `&` (W64.of_int 67108863)));
    g <- (BArray40.set64 g 3 ((BArray40.get64 h 3) + c));
    c <- ((BArray40.get64 g 3) `>>` (W8.of_int 26));
    g <-
    (BArray40.set64 g 3 ((BArray40.get64 g 3) `&` (W64.of_int 67108863)));
    g <- (BArray40.set64 g 4 ((BArray40.get64 h 4) + c));
    t <- (W64.of_int (1 `<<` 26));
    g <- (BArray40.set64 g 4 ((BArray40.get64 g 4) - t));
    mask <- ((BArray40.get64 g 4) `>>` (W8.of_int 63));
    mask <- (mask - (W64.of_int 1));
    nmask <- (invw mask);
    k <- 0;
    while ((k < 5)) {
      g <- (BArray40.set64 g k ((BArray40.get64 g k) `&` mask));
      h <- (BArray40.set64 h k ((BArray40.get64 h k) `&` nmask));
      h <-
      (BArray40.set64 h k ((BArray40.get64 h k) `|` (BArray40.get64 g k)));
      k <- (k + 1);
    }
    lo <- ((BArray40.get64 h 1) `<<` (W8.of_int 26));
    lo <- (lo `|` (BArray40.get64 h 0));
    t <- ((BArray40.get64 h 2) `<<` (W8.of_int 52));
    lo <- (lo `|` t);
    hi <- ((BArray40.get64 h 2) `>>` (W8.of_int 12));
    t <- ((BArray40.get64 h 3) `<<` (W8.of_int 14));
    hi <- (hi `|` t);
    t <- ((BArray40.get64 h 4) `<<` (W8.of_int 40));
    hi <- (hi `|` t);
    key <- s_key;
    t <- (loadW64 Glob.mem (W64.to_uint (key + (W64.of_int 16))));
    (cf, lo) <- (adc_64 lo t false);
    t <- (loadW64 Glob.mem (W64.to_uint (key + (W64.of_int 24))));
    ( _0, hi) <- (adc_64 hi t cf);
    out <- s_out;
    Glob.mem <- (storeW64 Glob.mem (W64.to_uint out) lo);
    Glob.mem <- (storeW64 Glob.mem (W64.to_uint (out + (W64.of_int 8))) hi);
    return ();
  }
}.
