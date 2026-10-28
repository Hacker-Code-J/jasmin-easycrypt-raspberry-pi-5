require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

module M = {
  proc ct_select (c:W64.t, a:W64.t, b:W64.t) : W64.t = {
    var r:W64.t;
    var mask:W64.t;
    var t:W64.t;
    mask <- (W64.of_int 0);
    mask <- (mask - c);
    r <- (a `&` mask);
    t <- (b `&` (invw mask));
    r <- (r `|` t);
    return r;
  }
}.
