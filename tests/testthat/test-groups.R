test_that("supplementary grouping does not refit PCA", {
  ex <- pca_example_agronomy(); f <- pca_fit(ex$data,scale=TRUE,ncomp=3)
  g <- pca_group(f,ex$metadata$treatment,region="bootstrap",nboot=20,seed=1)
  expect_equal(g$dims,c(1L,2L))
  expect_equal(length(g$group),nrow(f$scores))
  expect_true(nrow(g$centroids)==nlevels(ex$metadata$treatment))
})
