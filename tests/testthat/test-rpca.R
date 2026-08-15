test_that("low-rank plus sparse RPCA approximately decomposes input", {
  set.seed(1)
  L <- matrix(rnorm(60),20,3) %*% matrix(rnorm(24),3,8)
  S <- matrix(0,20,8); S[cbind(c(2,5,11),c(1,4,7))] <- c(12,-10,15)
  X <- L+S
  f <- pca_fit(X,method="rpca",center=FALSE,scale=FALSE,ncomp=3,max_iter=500)
  rec <- f$extra$low_rank + f$extra$sparse
  expect_lt(sqrt(mean((X-rec)^2)),1e-3)
})
