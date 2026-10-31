set.seed(1)
tree <- ape::rtree(40)
tree$tip.label <- paste0("sp", 1:40)
comm <- matrix(rpois(12 * 40, lambda = 3), nrow = 12,
               dimnames = list(paste0("s", 1:12), tree$tip.label))
group <- data.frame(g = rep(c("A", "B"), each = 6), row.names = rownames(comm))

workerSeeds <- function(cl) {
  parallel::clusterEvalQ(cl, get(".Random.seed", envir = globalenv()))
}

test_that("tNST / nst.boot reseeding reproduces", {
  cl <- newTestCluster(2)
  withr::defer(parallel::stopCluster(cl))
  localNoNewClusters()
  run <- function(stream) {
    parallel::clusterSetRNGStream(cl, stream)
    withr::with_seed(7, NST::tNST(comm, group, rand = 20, nworker = 2, LB = FALSE,
                                  output.rand = TRUE, cl = cl))
  }
  a <- run(7)
  expect_identical(run(7)$index.grp, a$index.grp)
  expect_false(identical(run(8)$index.grp, a$index.grp))
  runBoot <- function(stream) {
    parallel::clusterSetRNGStream(cl, stream)
    # tiny rand gives ties in the internal rank test
    suppressWarnings(withr::with_seed(7, NST::nst.boot(a, rand = 20, nworker = 2, cl = cl)))
  }
  b <- runBoot(7)
  expect_identical(runBoot(7), b)
  expect_false(identical(runBoot(8), b))
})

test_that("pNST tree-only path forwards cl to pdist.big", {
  cl <- newTestCluster(2)
  withr::defer(parallel::stopCluster(cl))
  localNoNewClusters()
  res <- NST::pNST(comm, tree = tree, group = group, pd.wd = withr::local_tempdir(),
                   rand = 20, nworker = 2, LB = FALSE, cl = cl)
  expect_true(is.list(res))
})

test_that("pNST uses the supplied cluster", {
  cl <- newTestCluster(2)
  withr::defer(parallel::stopCluster(cl))
  pd <- iCAMP::pdist.big(tree, wd = withr::local_tempdir(), nworker = 2, cl = cl)
  args <- list(comm, group = group, pd.desc = pd$pd.file, pd.wd = pd$pd.wd,
               pd.spname = pd$tip.label, rand = 20, nworker = 2, LB = FALSE)
  ref <- withLibWorkers(withr::with_seed(7, do.call(NST::pNST, args)))
  localNoNewClusters()
  got <- withr::with_seed(7, do.call(NST::pNST, c(args, list(cl = cl))))
  expect_equal(got, ref)
})

test_that("nworker follows the cluster", {
  cl2 <- newTestCluster(2)
  withr::defer(parallel::stopCluster(cl2))
  parallel::clusterSetRNGStream(cl2, 7)
  before <- workerSeeds(cl2)
  localNoNewClusters()
  NST::tNST(comm, group, rand = 20, nworker = 1, LB = FALSE, cl = cl2)
  after <- workerSeeds(cl2)
  expect_length(after, 2)
  for (i in 1:2) expect_false(identical(after[[i]], before[[i]]))
})
