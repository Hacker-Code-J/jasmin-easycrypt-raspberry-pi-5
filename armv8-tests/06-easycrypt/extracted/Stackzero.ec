require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

require import BArray256.

module M = {
  proc spread (key:W64.t) : W64.t = {
    var acc:W64.t;
    var v:W64.t;
    var i:int;
    var buf:BArray256.t;
    buf <- witness;
    i <- 0;
    while ((i < 32)) {
      v <- key;
      v <- (v `|<<|` (W8.of_int i));
      v <- (v `^` key);
      buf <- (BArray256.set64 buf i v);
      i <- (i + 1);
    }
    acc <- (W64.of_int 0);
    i <- 0;
    while ((i < 32)) {
      v <- (BArray256.get64 buf i);
      acc <- (acc + v);
      i <- (i + 1);
    }
    return acc;
  }
  proc sz_none (key:W64.t) : W64.t = {
    
    key <@ spread (key);
    return key;
  }
  proc sz_loop (key:W64.t) : W64.t = {
    
    key <@ spread (key);
    return key;
  }
  proc sz_unrolled (key:W64.t) : W64.t = {
    
    key <@ spread (key);
    return key;
  }
}.
