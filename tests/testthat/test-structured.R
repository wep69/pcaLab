test_that("multilevel PCA separates within and between matrices", {
  X <- as.matrix(iris[,1:4]); subject <- rep(1:30,length.out=nrow(X))
  w <- pca_fit(X,method="multilevel",subject=subject,level="within",ncomp=2,scale=TRUE)
  b <- pca_fit(X,method="multilevel",subject=subject,level="between",ncomp=2,scale=TRUE)
  expect_equal(w$method,"multilevel")
  expect_equal(b$method,"multilevel")
})

test_that("dynamic PCA creates lag-embedded variables", {
  X <- matrix(rnorm(200),50,4)
  f <- pca_fit(X,method="dynamic",lags=c(1,2),ncomp=2)
  expect_equal(nrow(f$processed_data),48)
  expect_equal(ncol(f$processed_data),12)
})

test_that("ASCA returns effect matrices", {
  set.seed(1); design <- data.frame(A=factor(rep(1:2,each=10)),B=factor(rep(1:2,10)))
  Y <- cbind(y1=rnorm(20)+as.numeric(design$A),y2=rnorm(20)+2*as.numeric(design$B))
  z <- pca_asca(Y,~A+B,design,ncomp=1,nperm=9,seed=1)
  expect_true(all(c("A","B") %in% names(z$effect_matrices)))
  expect_true(all(z$effect_p > 0 & z$effect_p <= 1,na.rm=TRUE))
})
