# Linear PCA engines -------------------------------------------------------

.pca_fit_classical <- function(X, prep, ncomp, call = NULL) {
  if (anyNA(X)) .pca_stop("Classical PCA requires complete data.")
  s <- svd(X, nu = min(nrow(X), ncomp), nv = ncomp)
  k <- min(ncomp, length(s$d), ncol(s$v))
  loadings <- s$v[, seq_len(k), drop = FALSE]
  scores <- X %*% loadings
  eig <- s$d[seq_len(k)]^2 / max(1, nrow(X) - 1)
  .new_pca_fit(prep$raw, X, scores, loadings, eig, "classical", prep, call, k,
               extra = list(engine = "base::svd", singular_values = s$d), orthogonal = TRUE)
}

.pca_fit_weighted <- function(X, prep, ncomp, call = NULL, weights = NULL, variable_weights = NULL) {
  if (anyNA(X)) .pca_stop("Weighted PCA currently requires complete data.")
  n <- nrow(X); p <- ncol(X)
  if (is.null(weights)) weights <- rep(1, n)
  weights <- as.numeric(weights)
  if (length(weights) != n || any(!is.finite(weights)) || any(weights < 0) || sum(weights) <= 0) {
    .pca_stop("weights must be a non-negative finite vector of length n with positive sum.")
  }
  w <- weights / sum(weights)
  prep_w <- prep
  Xw <- X
  weighted_center_processed <- rep(0, p)
  if (isTRUE(prep$center)) {
    weighted_center_processed <- colSums(X * w)
    Xw <- sweep(X, 2, weighted_center_processed, "-")
    sv <- prep$scale_vector %||% rep(1, p)
    prep_w$center_vector <- (prep$center_vector %||% rep(0,p)) + weighted_center_processed * sv
    prep_w$data <- Xw
  }
  if (is.null(variable_weights)) variable_weights <- rep(1, p)
  variable_weights <- as.numeric(variable_weights)
  if (length(variable_weights) != p || any(variable_weights <= 0) || any(!is.finite(variable_weights))) {
    .pca_stop("variable_weights must contain positive finite values, one per variable.")
  }
  Z <- sweep(Xw, 2, sqrt(variable_weights), "*")
  C <- crossprod(Z * sqrt(w), Z * sqrt(w))
  ee <- eigen(C, symmetric = TRUE)
  k <- min(ncomp, ncol(ee$vectors))
  Vz <- ee$vectors[, seq_len(k), drop = FALSE]
  # transform directions back to processed-variable coordinates, then normalize
  V <- sweep(Vz, 1, sqrt(variable_weights), "*")
  V <- apply(V, 2, function(v) v / sqrt(sum(v^2)))
  if (is.vector(V)) V <- matrix(V, ncol = 1)
  scores <- Xw %*% V
  eig <- apply(scores, 2, function(z) sum(w * (z - sum(w * z))^2))
  .new_pca_fit(prep$raw, Xw, scores, V, eig, "weighted", prep_w, call, k,
               extra = list(engine = "weighted-eigendecomposition", observation_weights = weights, variance_partition_valid = FALSE,
                            variable_weights = variable_weights, weighted_center_processed = weighted_center_processed), orthogonal = FALSE)
}

.pca_fit_nipals <- function(X, prep, ncomp, call = NULL, tol = 1e-8, max_iter = 1000) {
  E <- X
  n <- nrow(E); p <- ncol(E)
  k <- min(ncomp, .pca_rank_limit(E, centered = isTRUE(prep$center)))
  Tmat <- matrix(NA_real_, n, k)
  Pmat <- matrix(NA_real_, p, k)
  eig <- rep(NA_real_, k)
  iterations <- integer(k)

  for (h in seq_len(k)) {
    vars <- apply(E, 2, stats::var, na.rm = TRUE)
    start <- which.max(replace(vars, !is.finite(vars), -Inf))
    t <- E[, start]
    if (all(is.na(t))) t <- rep(0, n)
    t[is.na(t)] <- mean(t, na.rm = TRUE)
    if (!is.finite(sum(t^2)) || sum(t^2) == 0) break

    for (it in seq_len(max_iter)) {
      pvec <- numeric(p)
      for (j in seq_len(p)) {
        ok <- is.finite(E[, j]) & is.finite(t)
        den <- sum(t[ok]^2)
        pvec[j] <- if (sum(ok) && den > 0) sum(E[ok, j] * t[ok]) / den else 0
      }
      normp <- sqrt(sum(pvec^2))
      if (!is.finite(normp) || normp == 0) break
      pvec <- pvec / normp
      tnew <- numeric(n)
      for (i in seq_len(n)) {
        ok <- is.finite(E[i, ]) & is.finite(pvec)
        den <- sum(pvec[ok]^2)
        tnew[i] <- if (sum(ok) && den > 0) sum(E[i, ok] * pvec[ok]) / den else NA_real_
      }
      dif <- sqrt(sum((tnew - t)^2, na.rm = TRUE)) / (sqrt(sum(t^2, na.rm = TRUE)) + .Machine$double.eps)
      t <- tnew
      if (is.finite(dif) && dif < tol) { iterations[h] <- it; break }
      if (it == max_iter) iterations[h] <- it
    }
    Tmat[, h] <- t
    Pmat[, h] <- pvec
    eig[h] <- stats::var(t, na.rm = TRUE)
    for (i in seq_len(n)) for (j in seq_len(p)) if (is.finite(E[i, j]) && is.finite(t[i])) {
      E[i, j] <- E[i, j] - t[i] * pvec[j]
    }
  }
  keep <- which(is.finite(eig) & eig > 0)
  if (!length(keep)) .pca_stop("NIPALS failed to extract a component.")
  k <- max(keep)
  Tmat <- Tmat[, seq_len(k), drop = FALSE]
  Pmat <- Pmat[, seq_len(k), drop = FALSE]
  eig <- eig[seq_len(k)]
  .new_pca_fit(prep$raw, X, Tmat, Pmat, eig, "nipals", prep, call, k,
               extra = list(engine = "internal NIPALS", iterations = iterations[seq_len(k)], residual_matrix = E,
                            variance_partition_valid = !anyNA(X)),
               orthogonal = TRUE)
}

.pca_fit_em <- function(X, prep, ncomp, call = NULL, tol = 1e-7, max_iter = 500) {
  miss <- is.na(X)
  Ximp <- X
  if (any(miss)) {
    cm <- colMeans(Ximp, na.rm = TRUE)
    if (any(!is.finite(cm))) .pca_stop("A variable contains only missing values.")
    for (j in seq_len(ncol(Ximp))) Ximp[miss[, j], j] <- cm[j]
  }
  prev <- Inf
  converged <- FALSE
  for (it in seq_len(max_iter)) {
    s <- svd(Ximp, nu = min(nrow(Ximp), ncomp), nv = ncomp)
    k <- min(ncomp, length(s$d))
    rec <- s$u[, seq_len(k), drop = FALSE] %*%
      (diag(s$d[seq_len(k)], nrow = k) %*% t(s$v[, seq_len(k), drop = FALSE]))
    if (!any(miss)) { converged <- TRUE; break }
    change <- sqrt(mean((Ximp[miss] - rec[miss])^2))
    Ximp[miss] <- rec[miss]
    if (is.finite(prev) && abs(prev - change) < tol * (1 + prev)) { converged <- TRUE; break }
    prev <- change
  }
  s <- svd(Ximp, nu = min(nrow(Ximp), ncomp), nv = ncomp)
  k <- min(ncomp, length(s$d))
  V <- s$v[, seq_len(k), drop = FALSE]
  scores <- Ximp %*% V
  eig <- s$d[seq_len(k)]^2 / max(1, nrow(Ximp) - 1)
  out <- .new_pca_fit(prep$raw, Ximp, scores, V, eig, "em", prep, call, k,
                      extra = list(engine = "internal EM low-rank imputation", imputed_processed = Ximp,
                                   missing_mask = miss, converged = converged, iterations = it), orthogonal = TRUE)
  out$processed_data_original_missing <- X
  out
}

.pca_fit_ppca <- function(X, prep, ncomp, call = NULL, sigma_floor = 1e-10) {
  if (anyNA(X)) {
    # Use EM completion before estimating the PPCA maximum-likelihood model.
    em <- .pca_fit_em(X, prep, ncomp, call)
    Xc <- em$processed_data
  } else Xc <- X
  C <- crossprod(Xc) / max(1, nrow(Xc) - 1)
  ee <- eigen(C, symmetric = TRUE)
  q <- min(ncomp, ncol(Xc), length(ee$values))
  trailing <- if (q < length(ee$values)) ee$values[(q + 1L):length(ee$values)] else numeric()
  sigma2 <- if (length(trailing)) max(sigma_floor, mean(pmax(trailing, 0))) else sigma_floor
  Uq <- ee$vectors[, seq_len(q), drop = FALSE]
  W <- Uq %*% diag(sqrt(pmax(ee$values[seq_len(q)] - sigma2, 0)), nrow = q)
  M <- crossprod(W) + sigma2 * diag(q)
  Ez <- Xc %*% W %*% solve(M)
  scores <- Xc %*% Uq
  eig <- ee$values[seq_len(q)]
  .new_pca_fit(prep$raw, Xc, scores, Uq, eig, "ppca", prep, call, q,
               extra = list(engine = "internal PPCA MLE", sigma2 = sigma2, W = W,
                            posterior_scores = Ez, loglik = .pca_ppca_loglik(Xc, W, sigma2)),
               orthogonal = TRUE)
}

.pca_ppca_loglik <- function(X, W, sigma2) {
  C <- W %*% t(W) + sigma2 * diag(nrow(W))
  ev <- eigen(C, symmetric = TRUE, only.values = TRUE)$values
  if (any(ev <= 0)) return(NA_real_)
  invC <- solve(C)
  n <- nrow(X); p <- ncol(X)
  -0.5 * n * (p * log(2 * pi) + sum(log(ev)) + sum(diag(crossprod(X) %*% invC)) / n)
}

.pca_fit_bayesian <- function(X, prep, ncomp, call = NULL, maxSteps = 100, threshold = 1e-4, ...) {
  .pca_require("pcaMethods", "Bayesian PCA")
  res <- pcaMethods::pca(X, method = "bpca", nPcs = ncomp, center = FALSE, scale = "none",
                         maxSteps = maxSteps, threshold = threshold, ...)
  scores <- as.matrix(pcaMethods::scores(res))
  loadings <- as.matrix(pcaMethods::loadings(res))
  eig <- apply(scores, 2, stats::var, na.rm = TRUE)
  complete <- tryCatch(pcaMethods::completeObs(res), error = function(e) NULL)
  if (is.null(complete)) complete <- X
  out <- .new_pca_fit(prep$raw, complete, scores, loadings, eig, "bayesian", prep, call, ncomp,
                      extra = list(engine = "pcaMethods::bpca", backend_object = res, variance_partition_valid = FALSE,
                                   imputed_processed = complete),
                      orthogonal = FALSE)
  out$processed_data_original_missing <- X
  out
}
