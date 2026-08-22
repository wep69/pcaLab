# Optional-engine smoke tests for pcaLab -----------------------------------
library(pcaLab)
X <- as.matrix(iris[, 1:4])
cap <- pca_capabilities()
print(cap)

try_engine <- function(method, ...) {
  cat("\n---", method, "---\n")
  z <- try(pca_fit(X, method = method, scale = TRUE, ncomp = 2, ...), silent = TRUE)
  if (inherits(z, "try-error")) cat(as.character(z), "\n") else {
    print(z)
    stopifnot(inherits(z, "pca_fit"), nrow(z$scores) == nrow(X))
  }
  invisible(z)
}

if (requireNamespace("rospca", quietly = TRUE)) try_engine("robust")
if (requireNamespace("cellWise", quietly = TRUE)) try_engine("cellwise")
if (requireNamespace("sparsepca", quietly = TRUE)) try_engine("sparse", backend = "sparsepca")
if (requireNamespace("rospca", quietly = TRUE)) try_engine("robust_sparse", backend = "rospca")
if (requireNamespace("irlba", quietly = TRUE)) try_engine("randomized")
if (requireNamespace("pcaMethods", quietly = TRUE)) try_engine("bayesian")

if (requireNamespace("corpcor", quietly = TRUE)) {
  cat("\n--- shrinkage ---\n")
  sh <- pca_fit(X, method = "shrinkage", scale = TRUE, ncomp = 2)
  stopifnot(inherits(sh, "pca_fit"), ncol(predict(sh, X)) == 2L)
  rsh <- pca_reconstruct(sh, ncomp = 2)
  stopifnot(all(dim(rsh) == dim(X)))
  print(sh)
}

if (requireNamespace("logisticPCA", quietly = TRUE)) {
  cat("\n--- logistic ---\n")
  set.seed(1)
  B <- matrix(rbinom(600, 1, .4), 100, 6)
  lb <- pca_fit(B, method = "logistic", ncomp = 2, m = 4)
  stopifnot(all(dim(lb$scores) == c(100L, 2L)))
  stopifnot(all(dim(lb$loadings) == c(6L, 2L)))
  stopifnot(all(dim(fitted(lb)) == dim(B)))
  stopifnot(nrow(predict(lb, B[1:5, , drop = FALSE])) == 5L)
  lcv <- pca_ncomp(lb, methods = "engine_cv", cv_folds = 3, seed = 1)
  stopifnot(is.finite(lcv$recommendations$suggested_k[1]))
  print(lb)
}

if (requireNamespace("glmpca", quietly = TRUE)) {
  cat("\n--- glmpca ---\n")
  set.seed(1)
  C <- matrix(rpois(600, 5), 100, 6)
  gc <- pca_fit(C, method = "glmpca", ncomp = 2, fam = "poi")
  stopifnot(all(dim(gc$scores) == c(100L, 2L)))
  stopifnot(all(dim(gc$loadings) == c(6L, 2L)))
  stopifnot(all(dim(fitted(gc)) == dim(C)))
  bad_pred <- try(predict(gc, C[1:2, , drop = FALSE]), silent = TRUE)
  stopifnot(inherits(bad_pred, "try-error"))
  print(gc)
}

cat("\nOptional-engine validation script completed.\n")
