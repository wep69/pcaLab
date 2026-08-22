#' Preprocess data for PCA
#'
#' Centers, scales, transforms, audits, and optionally retains missing values.
#'
#' @param data Numeric matrix or data frame.
#' @param center Logical; subtract column means.
#' @param scale Scaling method: `FALSE`, `TRUE`, `"none"`, `"uv"`, `"pareto"`,
#'   `"range"`, or `"vast"`.
#' @param transform Optional `"none"`, `"log1p"`, or `"sqrt"` transformation.
#' @param na_action `"keep"`, `"omit"`, or `"fail"`.
#' @return A list with processed data and a complete preprocessing audit.
#' @examples
#' prep <- pca_preprocess(iris[, 1:4], center = TRUE, scale = "uv")
#' head(prep$data)
#' prep$audit
#' @export
pca_preprocess <- function(data, center = TRUE, scale = FALSE,
                           transform = c("none", "log1p", "sqrt"),
                           na_action = c("keep", "omit", "fail")) {
  X <- .pca_as_numeric_matrix(data, allow_na = TRUE)
  transform <- match.arg(transform)
  na_action <- match.arg(na_action)
  raw <- X
  if (na_action == "fail" && anyNA(X)) .pca_stop("Missing values detected and na_action='fail'.")
  if (na_action == "omit" && anyNA(X)) X <- X[stats::complete.cases(X), , drop = FALSE]
  all_missing <- colSums(is.finite(X)) == 0L
  if (any(all_missing)) {
    .pca_stop("Variables containing only missing values cannot be analyzed: ",
              paste(colnames(X)[all_missing], collapse = ", "))
  }

  if (transform == "log1p") {
    if (any(X < -1, na.rm = TRUE)) .pca_stop("log1p transformation requires all values >= -1.")
    X <- log1p(X)
  } else if (transform == "sqrt") {
    if (any(X < 0, na.rm = TRUE)) .pca_stop("sqrt transformation requires non-negative data.")
    X <- sqrt(X)
  }

  scale_method <- .pca_scale_label(scale)
  center_vector <- if (isTRUE(center)) colMeans(X, na.rm = TRUE) else rep(0, ncol(X))
  Xc <- sweep(X, 2, center_vector, "-")
  sds <- apply(Xc, 2, stats::sd, na.rm = TRUE)
  means_abs <- abs(colMeans(X, na.rm = TRUE))
  ranges <- apply(X, 2, function(z) diff(range(z, na.rm = TRUE)))

  scale_vector <- switch(scale_method,
    none = rep(1, ncol(X)),
    uv = sds,
    pareto = sqrt(sds),
    range = ranges,
    vast = sds^2 / pmax(means_abs, .Machine$double.eps)
  )
  bad <- !is.finite(scale_vector) | scale_vector <= .Machine$double.eps
  if (any(bad)) {
    .pca_warn("Zero or undefined scaling factors were replaced by 1 for: ",
              paste(colnames(X)[bad], collapse = ", "))
    scale_vector[bad] <- 1
  }
  Xp <- sweep(Xc, 2, scale_vector, "/")
  rownames(Xp) <- rownames(X)
  colnames(Xp) <- colnames(X)

  audit <- data.frame(
    variable = colnames(X),
    mean_raw = colMeans(raw, na.rm = TRUE),
    sd_raw = apply(raw, 2, stats::sd, na.rm = TRUE),
    missing = colSums(is.na(raw)),
    unique = vapply(seq_len(ncol(raw)), function(j) length(unique(raw[!is.na(raw[, j]), j])), integer(1)),
    zero_variance = vapply(seq_len(ncol(raw)), function(j) {
      z <- raw[, j]; z <- z[is.finite(z)]; length(z) < 2L || stats::sd(z) <= .Machine$double.eps
    }, logical(1)),
    stringsAsFactors = FALSE
  )

  list(
    data = Xp,
    raw = raw,
    center = isTRUE(center),
    center_vector = if (isTRUE(center)) center_vector else NULL,
    scale_method = scale_method,
    scale_vector = if (scale_method == "none") NULL else scale_vector,
    transform = transform,
    na_action = na_action,
    variable_names = colnames(X),
    observation_names = rownames(Xp),
    audit = audit
  )
}

#' Diagnose whether standard PCA assumptions and data geometry are suitable
#'
#' @param data Numeric matrix or data frame.
#' @param scale Whether to standardize for the diagnostic PCA.
#' @param nonlinear_check Logical; calculate simple squared-correlation curvature diagnostics.
#' @return A structured diagnostic object with findings and suggested PCA families.
#' @examples
#' pca_doctor(iris[, 1:4])
#' @export
pca_doctor <- function(data, scale = TRUE, nonlinear_check = TRUE) {
  X <- .pca_as_numeric_matrix(data, allow_na = TRUE)
  complete <- X[stats::complete.cases(X), , drop = FALSE]
  if (nrow(complete) < 3L) .pca_stop("At least three complete rows are required for pca_doctor().")
  C <- stats::cor(complete)
  off <- C[upper.tri(C)]
  mean_abs_cor <- if (length(off)) mean(abs(off)) else 0
  max_abs_cor <- if (length(off)) max(abs(off)) else 0
  p <- ncol(X); n <- nrow(X)
  missing_rate <- mean(is.na(X))
  warnings <- character()
  suggestions <- character()
  if (mean_abs_cor < 0.15) warnings <- c(warnings, "Weak average linear correlation; classical PCA may not concentrate variance strongly.")
  if (p > n) warnings <- c(warnings, "High-dimensional setting (p > n); regularized, sparse, randomized, or probabilistic approaches may be preferable.")
  if (missing_rate > 0) suggestions <- c(suggestions, "Use NIPALS, EM-PCA, PPCA/BPCA, or MacroPCA rather than complete-case PCA.")

  classical <- pca_fit(complete, method = "classical", center = TRUE, scale = scale)
  d <- pca_diagnose(classical)
  if (sum(d$outlier_flag, na.rm = TRUE) > 0) suggestions <- c(suggestions, "Investigate robust or cellwise-robust PCA because influential observations are present.")

  curve_score <- NA_real_
  if (nonlinear_check && ncol(complete) >= 2L) {
    vals <- numeric()
    for (j in seq_len(ncol(complete) - 1L)) for (k in (j + 1L):ncol(complete)) {
      x <- complete[, j]; y <- complete[, k]
      r1 <- suppressWarnings(abs(stats::cor(x, y)))
      r2 <- suppressWarnings(max(abs(stats::cor(x^2, y)), abs(stats::cor(x, y^2))))
      if (is.finite(r1) && is.finite(r2)) vals <- c(vals, pmax(0, r2 - r1))
    }
    if (length(vals)) curve_score <- max(vals)
    if (is.finite(curve_score) && curve_score > 0.25) suggestions <- c(suggestions, "Possible nonlinear structure detected; compare linear PCA with kernel or nonlinear alternatives.")
  }
  list(
    n = n, p = p, missing_rate = missing_rate,
    mean_abs_correlation = mean_abs_cor,
    max_abs_correlation = max_abs_cor,
    curvature_score = curve_score,
    condition_number = kappa(stats::cov(complete)),
    p_greater_than_n = p > n,
    warnings = unique(warnings),
    suggestions = unique(suggestions),
    audit = pca_preprocess(X, center = TRUE, scale = scale, na_action = "keep")$audit
  )
}
