test_that("NIPALS and EM produce scores with missing data", {
  X <- as.matrix(iris[,1:4]); X[cbind(c(1,5,10),c(1,2,4))] <- NA
  n <- pca_fit(X,method="nipals",scale=TRUE,ncomp=2)
  e <- pca_fit(X,method="em",scale=TRUE,ncomp=2)
  expect_equal(ncol(n$scores),2)
  expect_equal(ncol(e$scores),2)
  expect_false(anyNA(e$processed_data))
})
