test_that("compositional PCA requires positive components unless pseudocount supplied", {
  X <- matrix(c(.2,.3,.5,.1,.4,.5,.25,.25,.5,.3,.2,.5),ncol=3,byrow=TRUE)
  f <- pca_fit(X,method="compositional",ncomp=2,coordinate="clr")
  expect_equal(f$method,"compositional")
  X[1,1] <- 0
  expect_error(pca_fit(X,method="compositional",ncomp=2,coordinate="clr"))
  expect_s3_class(pca_fit(X,method="compositional",ncomp=2,coordinate="clr",pseudocount=1e-4),"pca_fit")
})

test_that("compositional PCA enforces valid closure geometry", {
  expect_error(pca_fit(matrix(1:5, ncol = 1), method = "compositional"), "at least two parts")
  X <- rbind(c(0, 0, 0), c(1, 2, 3))
  expect_error(pca_fit(X, method = "compositional", pseudocount = NULL), "positive finite row sum")
  Y <- rbind(c(1, 2, 3), c(2, 4, 5), c(3, 5, 7), c(4, 6, 8))
  expect_error(pca_fit(Y, method = "compositional", pseudocount = -1), "pseudocount")
  f <- pca_fit(Y, method = "compositional", coordinate = "clr", ncomp = 3)
  expect_lte(f$ncomp, ncol(Y) - 1L)
})
