test_that("kernel PCA returns finite scores and can project new observations", {
  s <- pca_simulate(n=80,p=4,rank=2,nonlinear=TRUE,seed=4)
  f <- pca_fit(s$data,method="kernel",scale=TRUE,ncomp=2,kernel="rbf")
  expect_true(all(is.finite(f$scores)))
  pr <- predict(f,s$data[1:3,,drop=FALSE])
  expect_equal(dim(pr),c(3,2))
})
