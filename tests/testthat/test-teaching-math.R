test_that("rotation teaching equations preserve distances", {
  z <- pca_teach_rotation(angle = 37)
  X <- z$data$original
  Y <- z$data$rotated
  expect_equal(as.numeric(dist(X)), as.numeric(dist(Y)), tolerance = 1e-10)
  expect_equal(crossprod(z$data$rotation), diag(2), tolerance = 1e-12)
})

test_that("eigen teaching object satisfies the eigen equation", {
  z <- pca_teach_eigen(iris[, 1:4], scale = TRUE)
  expect_true(max(z$data$eigen_equation_residual) < 1e-8)
})

test_that("SVD teaching eigenvalues match classical PCA", {
  z <- pca_teach_svd(iris[, 1:4], scale = TRUE)
  f <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE)
  expect_equal(unname(z$data$eigenvalues[seq_len(f$ncomp)]), unname(f$eigenvalues), tolerance = 1e-8)
})
