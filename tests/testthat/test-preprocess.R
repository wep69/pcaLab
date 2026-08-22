test_that("unit-variance scaling produces centered unit variance variables", {
  p <- pca_preprocess(iris[,1:4],center=TRUE,scale=TRUE,na_action="fail")
  expect_lt(max(abs(colMeans(p$data))),1e-12)
  expect_equal(unname(apply(p$data,2,sd)),rep(1,4),tolerance=1e-10)
})

test_that("missing values are retained when requested", {
  X <- as.matrix(iris[1:20,1:4]); X[1,1] <- NA
  p <- pca_preprocess(X,na_action="keep")
  expect_true(is.na(p$data[1,1]))
  expect_error(pca_preprocess(X,na_action="fail"))
})
