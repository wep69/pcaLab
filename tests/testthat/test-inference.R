test_that("permutation p-values are bounded and never zero", {
  s <- pca_simulate(n=80,p=6,rank=2,noise=.2,seed=9)
  f <- pca_fit(s$data,scale=TRUE,ncomp=4)
  z <- pca_test(f,nperm=19,seed=2)
  expect_true(all(z$global$p_value > 0 & z$global$p_value <= 1))
  expect_true(all(z$axes$p_value > 0 & z$axes$p_value <= 1))
})

test_that("bootstrap returns aligned uncertainty arrays", {
  f <- pca_fit(iris[,1:4],scale=TRUE,ncomp=3)
  b <- pca_boot(f,nboot=20,seed=1)
  expect_equal(dim(b$loading_ci),c(4,3,3))
  expect_true(all(b$sign_stability >= 0 & b$sign_stability <= 1,na.rm=TRUE))
  a <- pca_associate(f,boot=b)
  expect_equal(nrow(a),12)
})

test_that("PCAtest-style inference rejects nonclassical engine objects", {
  f <- pca_fit(iris[, 1:4], method = "kernel", scale = TRUE, ncomp = 2)
  expect_error(pca_test(f, nperm = 9), "standardized classical")
})

test_that("association synthesis respects axis-level significance", {
  f <- pca_fit(iris[, 1:4], scale = TRUE, ncomp = 2)
  z <- pca_test(f, nperm = 19, seed = 3)
  z$axes$significant[] <- FALSE
  a <- pca_associate(f, test = z)
  expect_false(any(a$combined_association))
  expect_true(all(a$axis_significant == FALSE))
})


test_that("unsupported same-engine bootstrap does not silently become classical PCA", {
  skip_if_not_installed("logisticPCA")
  set.seed(12)
  B <- matrix(rbinom(240, 1, 0.4), 40, 6)
  f <- pca_fit(B, method = "logistic", ncomp = 2)
  expect_error(pca_boot(f, nboot = 5, refit = "same"), "does not currently have a faithful same-engine")
})

test_that("weighted bootstrap resamples observation weights with rows", {
  X <- as.matrix(iris[, 1:4])
  w <- seq_len(nrow(X))
  f <- pca_fit(X, method = "weighted", scale = TRUE, ncomp = 2, weights = w)
  b <- pca_boot(f, nboot = 5, refit = "same", seed = 1)
  expect_equal(dim(b$loadings), c(5L, ncol(X), 2L))
})

test_that("Psi and Phi use the standardized PCAtest geometry, including p greater than n", {
  set.seed(77)
  X <- matrix(rnorm(8 * 12), nrow = 8, ncol = 12)
  z <- pca_test(X, nperm = 9, seed = 4)
  r <- min(ncol(X), nrow(X) - 1L)
  pc <- stats::prcomp(X, center = TRUE, scale. = TRUE)
  eig <- pc$sdev[seq_len(r)]^2
  psi_ref <- sum((eig - 1)^2)
  phi_ref <- sqrt(max(0, (sum(eig^2) - ncol(X)) / (ncol(X) * (ncol(X) - 1))))
  expect_equal(z$global$observed[z$global$statistic == "Psi"], psi_ref, tolerance = 1e-10)
  expect_equal(z$global$observed[z$global$statistic == "Phi"], phi_ref, tolerance = 1e-10)
})

test_that("PCAtest-style inference never ignores weighted geometry silently", {
  X <- as.matrix(iris[, 1:4])
  f <- pca_fit(X, method = "weighted", ncomp = 2, weights = seq_len(nrow(X)))
  expect_error(pca_test(f, nperm = 9), "standardized classical")
})
