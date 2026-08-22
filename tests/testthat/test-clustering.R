test_that("pca_cluster_evaluate works with kmeans", {
  ev <- pca_cluster_evaluate(iris[, 1:4], method = "kmeans", k_range = 2:4)
  expect_s3_class(ev, "pca_cluster_evaluate")
  expect_true(is.numeric(ev$best_k))
  expect_true(!is.na(ev$best_k) && ev$best_k >= 2 && ev$best_k <= 4)
  expect_true(nrow(ev$evaluation) == 3)
  if (!all(is.na(ev$evaluation$silhouette))) {
    if (!all(is.na(ev$evaluation$silhouette))) {
    expect_true(all(ev$evaluation$silhouette >= -1 & ev$evaluation$silhouette <= 1, na.rm = TRUE))
  }
  }
})

test_that("pca_cluster_evaluate works with pam", {
  skip_if_not_installed("cluster")
  ev <- pca_cluster_evaluate(iris[, 1:4], method = "pam", k_range = 2:4)
  expect_s3_class(ev, "pca_cluster_evaluate")
  expect_true(nrow(ev$evaluation) == 3)
})

test_that("pca_cluster_evaluate works with hclust", {
  ev <- pca_cluster_evaluate(iris[, 1:4], method = "hclust", k_range = 2:4)
  expect_s3_class(ev, "pca_cluster_evaluate")
})

test_that("pca_cluster_evaluate works with mclust", {
  skip_if_not_installed("mclust")
  ev <- pca_cluster_evaluate(iris[, 1:4], method = "mclust", k_range = 2:4)
  expect_s3_class(ev, "pca_cluster_evaluate")
  expect_true("bic" %in% names(ev$evaluation))
})

test_that("pca_cluster returns correct structure", {
  cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
  expect_s3_class(cl, "pca_cluster")
  expect_equal(cl$k, 3)
  expect_equal(length(cl$cluster), 150)
  expect_equal(length(cl$silhouette_per_obs), 150)
  expect_true(is.matrix(cl$scores))
})

test_that("pca_cluster with pca_fit input", {
  fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 2)
  cl <- pca_cluster(fit, method = "kmeans", k = 2)
  expect_s3_class(cl, "pca_cluster")
  expect_false(is.null(cl$fit))
})

test_that("pca_cluster_compare produces correct table", {
  cmp <- pca_cluster_compare(iris[, 1:4], methods = c("kmeans", "hclust"), k = 3)
  expect_s3_class(cmp, "pca_cluster_compare")
  expect_true(nrow(cmp$comparison) == 2)
  expect_true(length(cmp$rand_index) >= 1)
})

test_that("pca_cluster_stability works", {
  st <- pca_cluster_stability(iris[, 1:4], method = "kmeans", k = 3, nboot = 19, seed = 1)
  expect_s3_class(st, "pca_cluster_stability")
  expect_equal(dim(st$consensus_matrix), c(150, 150))
  expect_true(all(st$membership_stability >= 0 & st$membership_stability <= 1))
  expect_true(is.finite(st$cophenetic_correlation))
})

test_that("pca_cluster_boundary with ellipse", {
  cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
  bd <- pca_cluster_boundary(iris[, 1:4], cl$cluster, method = "ellipse")
  expect_s3_class(bd, "pca_cluster_boundary")
  expect_true(nrow(bd$boundaries) > 0)
})

test_that("pca_cluster_boundary with convex", {
  cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
  bd <- pca_cluster_boundary(iris[, 1:4], cl$cluster, method = "convex")
  expect_s3_class(bd, "pca_cluster_boundary")
})

test_that("pca_cluster_labels types", {
  cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
  lab1 <- pca_cluster_labels(iris[, 1:4], cl$cluster, type = "group")
  lab2 <- pca_cluster_labels(iris[, 1:4], cl$cluster, type = "mean")
  lab3 <- pca_cluster_labels(iris[, 1:4], cl$cluster, type = "observation")
  lab4 <- pca_cluster_labels(iris[, 1:4], cl$cluster, type = "external",
                             labels = paste0("L", 1:150))
  expect_equal(length(lab1), 150)
  expect_true(all(grepl("Cluster", lab1)))
  expect_true(all(grepl("Cluster", lab2)))
  expect_equal(lab4[1], "L1")
})

test_that("pca_cluster_report works", {
  rpt <- pca_cluster_report(iris[, 1:4], method = "kmeans", k_range = 2:4)
  expect_s3_class(rpt, "pca_cluster_report")
  expect_true(length(rpt$summary) >= 4)
  expect_true(is.data.frame(rpt$evaluation))
  expect_true(is.numeric(rpt$silhouette))
})

test_that("pca_cluster_report k_eval_only", {
  rpt <- pca_cluster_report(iris[, 1:4], k_eval_only = TRUE)
  expect_true(grepl("k evaluation only", rpt$summary[length(rpt$summary)]))
})
