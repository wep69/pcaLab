test_that("classical PCA agrees with prcomp up to loading signs", {
  X <- scale(USArrests, center = TRUE, scale = TRUE)
  f <- pca_fit(USArrests, method="classical", center=TRUE, scale=TRUE)
  r <- prcomp(USArrests, center=TRUE, scale.=TRUE)
  k <- min(f$ncomp, ncol(r$rotation))
  expect_equal(unname(f$eigenvalues[1:k]), unname(r$sdev[1:k]^2), tolerance=1e-8)
  cc <- abs(diag(crossprod(f$loadings[,1:k,drop=FALSE], r$rotation[,1:k,drop=FALSE])))
  expect_true(all(cc > 1-1e-7))
})

test_that("scores and reconstruction satisfy PCA identities", {
  X <- iris[,1:4]
  f <- pca_fit(X, scale=TRUE)
  expect_equal(unname(f$scores), unname(f$processed_data %*% f$loadings), tolerance=1e-8)
  full <- pca_reconstruct(f, ncomp=f$ncomp, original_scale=FALSE)
  expect_lt(sqrt(mean((f$processed_data-full)^2)), 1e-7)
})

test_that("sign inversion does not change a component reconstruction", {
  f <- pca_fit(iris[,1:4], scale=TRUE, ncomp=2)
  R1 <- pca_reconstruct(f,2,FALSE)
  g <- f; g$loadings[,1] <- -g$loadings[,1]; g$scores[,1] <- -g$scores[,1]
  R2 <- pca_reconstruct(g,2,FALSE)
  expect_equal(R1,R2,tolerance=1e-12)
})

test_that("uncentered PCA can retain min(n, p) directions while centered PCA loses one row-rank", {
  set.seed(91)
  X <- matrix(rnorm(5 * 8), nrow = 5, ncol = 8)
  fu <- pca_fit(X, method = "classical", center = FALSE, scale = FALSE)
  fc <- pca_fit(X, method = "classical", center = TRUE, scale = FALSE)
  expect_equal(fu$ncomp, 5L)
  expect_equal(fc$ncomp, 4L)
})
