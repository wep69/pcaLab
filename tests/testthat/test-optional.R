test_that("optional robust engine works when installed", {
  skip_if_not_installed("rospca")
  f <- pca_fit(iris[,1:4],method="robust",scale=TRUE,ncomp=2)
  expect_s3_class(f,"pca_fit")
})

test_that("optional shrinkage engine works when installed", {
  skip_if_not_installed("corpcor")
  f <- pca_fit(iris[,1:4],method="shrinkage",scale=TRUE,ncomp=2)
  expect_s3_class(f,"pca_fit")
})

test_that("optional randomized engine works when installed", {
  skip_if_not_installed("irlba")
  f <- pca_fit(as.matrix(USArrests),method="randomized",scale=TRUE,ncomp=2)
  expect_s3_class(f,"pca_fit")
})

test_that("logisticPCA adapter uses documented scores and supports fitted/predict", {
  skip_if_not_installed("logisticPCA")
  set.seed(11)
  X <- matrix(rbinom(240, 1, .45), 40, 6)
  f <- pca_fit(X, method = "logistic", ncomp = 2)
  expect_equal(unname(f$scores), unname(as.matrix(f$extra$backend_object$PCs)), tolerance = 1e-10)
  expect_equal(dim(fitted(f)), dim(X))
  expect_equal(dim(predict(f, X[1:3, , drop = FALSE])), c(3, 2))
  sel <- pca_ncomp(f, methods = "engine_cv", cv_folds = 2, seed = 1)
  expect_true(sel$consensus >= 1)
})

test_that("glmpca adapter respects pcaLab observation-by-variable orientation", {
  skip_if_not_installed("glmpca")
  set.seed(12)
  X <- matrix(rpois(300, 4), 50, 6)
  f <- pca_fit(X, method = "glmpca", ncomp = 2, fam = "poi", ctl = list(maxIter = 40, minIter = 5))
  expect_equal(dim(f$scores), c(nrow(X), 2))
  expect_equal(dim(f$loadings), c(ncol(X), 2))
  expect_equal(dim(fitted(f)), dim(X))
  expect_error(predict(f, X[1:2, , drop = FALSE]), "does not provide direct factor-score projection")
})
