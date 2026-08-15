test_that("original-scale reconstruction reverses preprocessing transforms", {
  X <- matrix(seq(0.2, 6, length.out = 60), nrow = 15, ncol = 4)
  f <- pca_fit(X, method = "classical", center = TRUE, scale = TRUE, transform = "log1p")
  rec <- pca_reconstruct(f, original_scale = TRUE)
  expect_equal(unname(rec), unname(X), tolerance = 1e-7)

  f2 <- pca_fit(X, method = "classical", center = TRUE, scale = TRUE, transform = "sqrt")
  rec2 <- pca_reconstruct(f2, original_scale = TRUE)
  expect_equal(unname(rec2), unname(X), tolerance = 1e-7)
})

test_that("PPCA accepts missing values through internal completion", {
  set.seed(1)
  X <- matrix(rnorm(120), 30, 4)
  X[cbind(c(2, 10, 19), c(1, 3, 4))] <- NA_real_
  f <- pca_fit(X, method = "ppca", center = TRUE, scale = TRUE, ncomp = 2)
  expect_equal(f$method, "ppca")
  expect_false(anyNA(f$processed_data))
})

test_that("all-missing variables fail with an explicit message", {
  X <- cbind(a = 1:6, b = rep(NA_real_, 6))
  expect_error(pca_preprocess(X, na_action = "keep"), "only missing values")
})

test_that("compositional PCA reconstructs and predicts in composition space", {
  X <- rbind(c(1, 2, 3), c(2, 5, 4), c(4, 3, 2), c(3, 1, 6), c(5, 2, 4))
  colnames(X) <- c("A", "B", "C")
  f <- pca_fit(X, method = "compositional", coordinate = "ilr", ncomp = 2)
  rec <- pca_reconstruct(f, original_scale = TRUE)
  expect_equal(unname(rowSums(rec)), rep(1, nrow(X)), tolerance = 1e-10)
  sc <- predict(f, X[1:2, , drop = FALSE])
  expect_equal(dim(sc), c(2, 2))
})

test_that("dense functional PCA can project new curves", {
  grid <- seq(0, 1, length.out = 20)
  X <- outer(seq(0, 2*pi, length.out = 12), grid, function(a, t) sin(2*pi*t + a))
  f <- pca_fit(X, method = "functional", grid = grid, ncomp = 2)
  sc <- predict(f, X[1:3, , drop = FALSE])
  expect_equal(dim(sc), c(3, 2))
  rec <- pca_reconstruct(f, original_scale = TRUE)
  expect_equal(dim(rec), dim(X))
})
