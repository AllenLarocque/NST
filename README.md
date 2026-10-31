# NST, cl-arg fork

This is a fork of NST 3.1.10 (GPL-2) by Daliang Ning, whose repository is https://github.com/DaliangNing/NST. It adds one optional argument, `cl`, to `tNST`, `pNST` and `nst.boot`. A caller can supply its own `parallel` cluster, so it can set the workers' library, seed them with `parallel::clusterSetRNGStream()`, and stop the cluster itself. When `cl` is omitted, computation is unchanged. The changes are on the `cl-arg` branch (compare with tag 3.1.10: https://github.com/AllenLarocque/NST/compare/3.1.10...cl-arg).
