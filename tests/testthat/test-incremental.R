test_that("incremental covariance PCA matches full covariance eigenvalues", {
  X <- scale(as.matrix(iris[,1:4]),center=TRUE,scale=FALSE)
  st <- pca_incremental_init(4,center=TRUE,scale=FALSE)
  st <- pca_incremental_update(st,X[1:50,])
  st <- pca_incremental_update(st,X[51:100,])
  st <- pca_incremental_update(st,X[101:150,])
  f <- pca_incremental_finalize(st,ncomp=4)
  ref <- eigen(cov(X),symmetric=TRUE)$values
  expect_equal(f$eigenvalues,ref,tolerance=1e-8)
})

test_that("incremental uncentered PCA uses the second-moment matrix", {
  X <- as.matrix(iris[,1:4])
  st <- pca_incremental_init(4, center = FALSE, scale = FALSE)
  st <- pca_incremental_update(st, X[1:75, ])
  st <- pca_incremental_update(st, X[76:150, ])
  f <- pca_incremental_finalize(st, ncomp = 4)
  ref <- eigen(crossprod(X) / (nrow(X) - 1), symmetric = TRUE)$values
  expect_equal(f$eigenvalues, ref, tolerance = 1e-8)
})
