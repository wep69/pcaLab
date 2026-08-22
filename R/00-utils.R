# Internal utilities --------------------------------------------------------

.pca_stop <- function(...) stop(..., call. = FALSE)
.pca_warn <- function(...) warning(..., call. = FALSE)

.pca_require <- function(pkg, feature = pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    .pca_stop(
      "Feature '", feature, "' requires optional package '", pkg,
      "'. Install it before using this engine."
    )
  }
  invisible(TRUE)
}

.pca_as_numeric_matrix <- function(x, allow_na = TRUE) {
  if (is.data.frame(x)) {
    ok <- vapply(x, is.numeric, logical(1))
    if (!all(ok)) {
      .pca_stop("All PCA input columns must be numeric. Non-numeric columns: ",
                paste(names(x)[!ok], collapse = ", "))
    }
    x <- as.matrix(x)
  } else {
    x <- as.matrix(x)
  }
  storage.mode(x) <- "double"
  if (length(dim(x)) != 2L || nrow(x) < 2L || ncol(x) < 1L) {
    .pca_stop("Input must be a two-dimensional numeric matrix with at least two rows.")
  }
  if (any(!is.finite(x) & !is.na(x))) .pca_stop("Input contains Inf or -Inf values.")
  if (!allow_na && anyNA(x)) .pca_stop("Missing values are not supported by this engine.")
  if (is.null(colnames(x))) colnames(x) <- paste0("V", seq_len(ncol(x)))
  if (is.null(rownames(x))) rownames(x) <- paste0("Obs", seq_len(nrow(x)))
  x
}

.pca_scale_label <- function(scale) {
  if (isTRUE(scale)) return("uv")
  if (isFALSE(scale) || is.null(scale)) return("none")
  match.arg(tolower(as.character(scale)), c("none", "uv", "pareto", "range", "vast"))
}

.pca_sign_anchor <- function(loadings) {
  if (is.null(loadings) || !length(loadings)) return(loadings)
  L <- as.matrix(loadings)
  for (j in seq_len(ncol(L))) {
    idx <- which.max(abs(L[, j]))
    if (length(idx) && is.finite(L[idx, j]) && L[idx, j] < 0) L[, j] <- -L[, j]
  }
  L
}

.pca_align_components <- function(reference, target) {
  reference <- as.matrix(reference)
  target <- as.matrix(target)
  k <- min(ncol(reference), ncol(target))
  reference <- reference[, seq_len(k), drop = FALSE]
  target <- target[, seq_len(k), drop = FALSE]
  C <- abs(crossprod(reference, target))
  perm <- integer(k)
  used <- rep(FALSE, k)
  for (i in seq_len(k)) {
    candidates <- order(C[i, ], decreasing = TRUE)
    pick <- candidates[which(!used[candidates])[1L]]
    perm[i] <- pick
    used[pick] <- TRUE
  }
  target <- target[, perm, drop = FALSE]
  for (i in seq_len(k)) {
    s <- sign(sum(reference[, i] * target[, i], na.rm = TRUE))
    if (!is.finite(s) || s == 0) s <- 1
    target[, i] <- target[, i] * s
  }
  list(loadings = target, permutation = perm)
}

.pca_subspace_angles <- function(A, B) {
  A <- qr.Q(qr(as.matrix(A)))
  B <- qr.Q(qr(as.matrix(B)))
  s <- svd(crossprod(A, B), nu = 0, nv = 0)$d
  s <- pmin(1, pmax(0, s))
  acos(s) * 180 / pi
}

.pca_pvalue_upper <- function(obs, null) {
  null <- null[is.finite(null)]
  if (!length(null)) return(NA_real_)
  (1 + sum(null >= obs)) / (length(null) + 1)
}

.pca_quantile <- function(x, probs = c(.025, .5, .975)) {
  stats::quantile(x, probs = probs, na.rm = TRUE, names = FALSE, type = 8)
}

.pca_rank_limit <- function(X, centered = TRUE) {
  loss <- if (isTRUE(centered)) 1L else 0L
  min(ncol(X), max(1L, nrow(X) - loss))
}

.pca_total_inertia <- function(X, centered = TRUE) {
  X <- as.matrix(X)
  if (nrow(X) < 2L || anyNA(X)) return(NA_real_)
  if (isTRUE(centered)) return(sum(apply(X, 2, stats::var)))
  sum(X^2) / max(1, nrow(X) - 1)
}

.pca_component_names <- function(k) paste0("PC", seq_len(k))

.pca_varnames <- function(X) {
  nm <- colnames(X)
  if (is.null(nm)) paste0("V", seq_len(ncol(X))) else nm
}

.pca_safe_cor <- function(X, scores) {
  if (is.null(scores) || !ncol(scores)) return(NULL)
  out <- matrix(NA_real_, ncol(X), ncol(scores),
                dimnames = list(.pca_varnames(X), colnames(scores)))
  for (j in seq_len(ncol(X))) {
    for (h in seq_len(ncol(scores))) {
      ok <- is.finite(X[, j]) & is.finite(scores[, h])
      if (sum(ok) >= 3L && stats::sd(X[ok, j]) > 0 && stats::sd(scores[ok, h]) > 0) {
        out[j, h] <- stats::cor(X[ok, j], scores[ok, h])
      }
    }
  }
  out
}

.pca_metric_tables <- function(X_processed, scores, loadings, eigenvalues) {
  k <- length(eigenvalues)
  p <- ncol(X_processed)
  total <- sum(eigenvalues, na.rm = TRUE)
  pve <- if (is.finite(total) && total > 0) eigenvalues / total else rep(NA_real_, k)
  corr <- .pca_safe_cor(X_processed, scores)
  if (!is.null(corr)) {
    cos2 <- corr^2
    contrib <- matrix(NA_real_, p, k, dimnames = dimnames(corr))
    for (h in seq_len(k)) {
      # Axis-construction contribution is based on squared loading weights
      # when an explicit linear loading vector exists. This remains valid for
      # covariance PCA where normalized squared correlations would answer a
      # different question. For engines without ordinary loadings, normalized
      # squared variable-score correlations are used only as a descriptive
      # association share.
      if (!is.null(loadings) && nrow(loadings) == p && ncol(loadings) >= h) {
        z <- loadings[, h]^2
      } else z <- cos2[, h]
      s <- sum(z, na.rm = TRUE)
      if (s > 0) contrib[, h] <- z / s
    }
    communalities <- t(apply(cos2, 1, cumsum))
    if (k == 1L) communalities <- t(communalities)
    colnames(communalities) <- colnames(corr)
    rownames(communalities) <- rownames(corr)
  } else {
    cos2 <- contrib <- communalities <- NULL
  }
  list(pve = pve, cumulative = cumsum(pve), correlation_loadings = corr,
       cos2 = cos2, contributions = contrib, communalities = communalities)
}

.pca_unprocess <- function(Z, preprocessing) {
  out <- Z
  sc <- preprocessing$scale_vector
  ce <- preprocessing$center_vector
  if (!is.null(sc)) out <- sweep(out, 2, sc, "*")
  if (!is.null(ce)) out <- sweep(out, 2, ce, "+")
  tr <- preprocessing$transform %||% "none"
  if (identical(tr, "log1p")) out <- expm1(out)
  if (identical(tr, "sqrt")) out <- out^2
  out
}

.pca_process_newdata <- function(newdata, preprocessing) {
  X <- .pca_as_numeric_matrix(newdata, allow_na = FALSE)
  if (ncol(X) != length(preprocessing$variable_names)) .pca_stop("newdata has the wrong number of variables.")
  if (!is.null(colnames(X)) && !identical(colnames(X), preprocessing$variable_names)) {
    if (all(preprocessing$variable_names %in% colnames(X))) X <- X[, preprocessing$variable_names, drop = FALSE]
  }
  tr <- preprocessing$transform
  if (identical(tr, "log1p")) X <- log1p(X)
  if (identical(tr, "sqrt")) X <- sqrt(X)
  if (!is.null(preprocessing$center_vector)) X <- sweep(X, 2, preprocessing$center_vector, "-")
  if (!is.null(preprocessing$scale_vector)) X <- sweep(X, 2, preprocessing$scale_vector, "/")
  X
}

.pca_soft_threshold <- function(X, tau) sign(X) * pmax(abs(X) - tau, 0)

.pca_svt <- function(X, tau) {
  d <- svd(X)
  keep <- d$d > tau
  if (!any(keep)) return(matrix(0, nrow(X), ncol(X)))
  d$u[, keep, drop = FALSE] %*% (diag(d$d[keep] - tau, nrow = sum(keep)) %*% t(d$v[, keep, drop = FALSE]))
}

.pca_has_ggplot2 <- function() requireNamespace("ggplot2", quietly = TRUE)

# Data-masked columns used inside ggplot2/plotly aesthetics and tidy evaluation.
utils::globalVariables(c(
  "PC", "cum", "component", "eigenvalue", "estimate", "index", "loading",
  "lower", "method", "observation", "observed", "orthogonal_distance",
  "outlier_flag", "p_value", "reconstructed", "score_distance",
  "significant", "suggested_k", "upper", "value", "variable", "x", "y",
  "group", "grid", "z"
))

#' Report optional engine capabilities
#'
#' @return A data frame describing engines and whether their optional backend is installed.
#' @examples
#' pca_capabilities()
#' @export
pca_capabilities <- function() {
  spec <- data.frame(
    method = c("classical","weighted","nipals","em","ppca","bayesian","robust",
               "cellwise","sparse","robust_sparse","rpca","kernel","nlpca","shrinkage","logistic",
               "glmpca","compositional","functional","dynamic","multilevel",
               "multiblock","randomized","incremental"),
    backend = c("base","base","base","base","base","pcaMethods","rospca",
                "cellWise","sparsepca/elasticnet","rospca/sparsepca","base",
                "base","pcaMethods","corpcor","logisticPCA","glmpca","base","base/MFPCA",
                "base","base","base","base/irlba","base"),
    stringsAsFactors = FALSE
  )
  spec$available <- vapply(seq_len(nrow(spec)), function(i) {
    b <- spec$backend[i]
    if (grepl("base", b, fixed = TRUE)) return(TRUE)
    pkgs <- strsplit(b, "/", fixed = TRUE)[[1L]]
    any(vapply(pkgs, requireNamespace, logical(1), quietly = TRUE))
  }, logical(1))
  spec
}
