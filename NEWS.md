# NST 3.1.10.9001

* `tNST()`, `pNST()` and `nst.boot()` gain a `cl` argument: an optional,
  caller-supplied cluster from `parallel::makeCluster()`. When given, it is used
  instead of creating a cluster, `nworker` is taken from `length(cl)`, and the
  cluster is not stopped. `pNST()` also forwards `cl` to `iCAMP::pdist.big()`.
  With `cl = NULL` (the default) behaviour is unchanged.
* Requires iCAMP (>= 1.9.1.9001), which adds the same `cl` argument.
