test_that("broken stick proportions sum to one", {
  expect_equal(sum(pca_broken_stick(8)),1,tolerance=1e-12)
})

test_that("parallel analysis and component selection return valid dimensions", {
  s <- pca_simulate(n=120,p=8,rank=2,noise=.15,seed=10)
  f <- pca_fit(s$data,scale=TRUE)
  pa <- pca_parallel(f,nperm=19,seed=1)
  expect_true(pa$k >= 0 && pa$k <= f$ncomp)
  ns <- pca_ncomp(f,methods=c("scree","broken_stick","parallel","rmt"),nperm=19,nboot=10,seed=1)
  expect_true(is.data.frame(ns$recommendations))
  expect_true(ns$consensus >= 0)
})

test_that("kernel dimensionality selection does not silently use Gaussian null rules", {
  f <- pca_fit(iris[, 1:4], method = "kernel", ncomp = 3, scale = TRUE)
  sel <- pca_ncomp(f, methods = "all")
  expect_true(all(sel$recommendations$method %in% c("scree", "cumulative")))
})

test_that("parallel analysis and transferred selection rules respect PCA geometry", {
  set.seed(101)
  X <- matrix(rnorm(90), 15, 6)
  unc <- pca_fit(X, method = "classical", center = FALSE, scale = FALSE, ncomp = 4)
  expect_error(pca_parallel(unc, nperm = 9), "requires centered")
  nc <- pca_ncomp(unc, methods = "all", nperm = 9, nboot = 9)
  expect_false(any(nc$recommendations$method %in% c("kaiser", "parallel", "permutation", "rmt", "ppca_bic")))

  if (requireNamespace("rospca", quietly = TRUE)) {
    rb <- pca_fit(X, method = "robust", ncomp = 2)
    expect_error(pca_parallel(rb, nperm = 9), "classical Euclidean")
  }
})
