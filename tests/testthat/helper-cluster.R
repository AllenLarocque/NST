# Test helpers for the `cl` argument.

# A PSOCK cluster whose workers see the parent's library paths.
newTestCluster <- function(n) {
  parallel::makeCluster(n, rscript_args = c("-e", shQuote(sprintf(
    ".libPaths(%s, include.site = FALSE)", deparse1(.libPaths())))))
}

# For the rest of the calling test, any attempt to create or stop a cluster
# fails. Create the test's own clusters, and defer their stopCluster(), BEFORE
# calling this: deferred actions run last-in-first-out, so the mocks are removed
# before the test's clusters are stopped.
localNoNewClusters <- function(.env = parent.frame()) {
  testthat::local_mocked_bindings(
    makeCluster = function(...) stop("created a cluster"),
    stopCluster = function(...) stop("stopped a cluster"),
    .package = "parallel", .env = .env)
}

# Evaluate `code` (a cl = NULL run) with workers that see the parent's library
# paths: the function under test still creates its own cluster, through the
# original code path.
withLibWorkers <- function(code) {
  real <- parallel::makeCluster
  libs <- c("-e", shQuote(sprintf(".libPaths(%s, include.site = FALSE)",
                                  deparse1(.libPaths()))))
  testthat::with_mocked_bindings(
    code,
    makeCluster = function(...) real(..., rscript_args = libs),
    .package = "parallel")
}

# NST imports iCAMP, so the iCAMP fork (with `cl =`) must be loaded BEFORE
# test_local() runs load_all() on NST. Run the suite from /workspace as:
#   Rscript -e 'pkgload::load_all("scratch/forks/iCAMP"); testthat::test_local("scratch/forks/NST")'
# If it was not preloaded, load it here (best effort).
if (as.character(utils::packageVersion("iCAMP")) != "1.9.1.9001") {
  pkgload::load_all("../../../iCAMP", quiet = TRUE)
}
