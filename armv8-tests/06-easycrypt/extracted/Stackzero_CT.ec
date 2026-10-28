require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

from Jasmin require import JLeakage.

require import BArray256.

module M = {
  proc spread (key:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var leak_0:JLeakage.leakages;
    var leak_b:JLeakage.leakages;
    var acc:W64.t;
    var v:W64.t;
    var i:int;
    var buf:BArray256.t;
    buf <- witness;
    leak <- [];
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 32)])]);
    i <- 0;
    while ((i < 32)) {
      leak_0 <- [];
      v <- key;
      v <- (v `|<<|` (W8.of_int i));
      v <- (v `^` key);
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int i)])]);
      buf <- (BArray256.set64 buf i v);
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    acc <- (W64.of_int 0);
    leak_b <- [];
    leak <- (leak ++ [(LeakList [(Leak_int 0); (Leak_int 32)])]);
    i <- 0;
    while ((i < 32)) {
      leak_0 <- [];
      leak_0 <- (leak_0 ++ [(LeakList [(Leak_int i)])]);
      v <- (BArray256.get64 buf i);
      acc <- (acc + v);
      leak_b <- (leak_b ++ [(LeakList leak_0)]);
      i <- (i + 1);
    }
    leak <- (leak ++ [(LeakList leak_b)]);
    return ((LeakList leak), acc);
  }
  proc sz_none (key:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var leak_c:JLeakage.leakage;
    leak <- [];
    (leak_c, key) <@ spread (key);
    leak <- (leak ++ [leak_c]);
    return ((LeakList leak), key);
  }
  proc sz_loop (key:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var leak_c:JLeakage.leakage;
    leak <- [];
    (leak_c, key) <@ spread (key);
    leak <- (leak ++ [leak_c]);
    return ((LeakList leak), key);
  }
  proc sz_unrolled (key:W64.t) : JLeakage.leakage * W64.t = {
    var leak:JLeakage.leakages;
    var leak_c:JLeakage.leakage;
    leak <- [];
    (leak_c, key) <@ spread (key);
    leak <- (leak ++ [leak_c]);
    return ((LeakList leak), key);
  }
}.
