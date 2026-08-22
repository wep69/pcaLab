# Component-number selection ------------------------------------------------

#' Broken-stick expected proportions
#' @param p Number of components/dimensions.
#' @return Expected variance proportions under the broken-stick model.
#' @examples
#' bs <- pca_broken_stick(8)
#' bs
#' sum(bs)  # proportions sum to one
#' @export
pca_broken_stick <- function(p) {
  p <- as.integer(p)
  if (p < 1L) .pca_stop("p must be positive.")
  vapply(seq_len(p), function(k) sum(1 / (k:p)) / p, numeric(1))
}

#' Parallel analysis for PCA
#'
#' @param x A `pca_fit` object or numeric data.
#' @param nperm Number of random reference datasets.
#' @param quantile Reference quantile, usually 0.95.
#' @param null `"permutation"` preserves marginal distributions; `"normal"` simulates independent Gaussian variables.
#' @param seed Optional random seed.
#' @return List with observed eigenvalues, null envelopes, and selected dimensionality.
#' @examples
#' # Horn parallel analysis with independent Gaussian reference variables
#' pa <- pca_parallel(iris[, 1:4], nperm = 49, null = "normal", seed = 1)
#' pa$k
#' # Column-wise permutation parallel analysis
#' pa <- pca_parallel(iris[, 1:4], nperm = 49, null = "permutation", seed = 1)
#' pa$k
#' @export
pca_parallel <- function(x, nperm = 499L, quantile = 0.95,
                         null = c("permutation", "normal"), seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  null <- match.arg(null)
  if (inherits(x, "pca_fit")) {
    if (!x$method %in% c("classical", "randomized"))
      .pca_stop("pca_parallel() currently defines a classical Euclidean PCA null reference. Pass a classical/randomized PCA fit, or explicitly pass a numeric matrix representing the geometry to be tested.")
    if (!isTRUE(x$preprocessing$center))
      .pca_stop("pca_parallel() requires centered PCA geometry so that the observed and null eigenspectra are comparable.")
    X <- x$processed_data
    centered <- TRUE
  } else {
    prep <- pca_preprocess(x, center = TRUE, scale = TRUE, na_action = "fail")
    X <- prep$data
    centered <- TRUE
  }
  X <- .pca_as_numeric_matrix(X, allow_na = FALSE)
  obs <- svd(X, nu = 0, nv = 0)$d^2 / max(1, nrow(X) - 1)
  r <- min(length(obs), .pca_rank_limit(X, centered = centered))
  obs <- obs[seq_len(r)]
  null_eigs <- matrix(NA_real_, nperm, r)
  sdx <- apply(X,2,stats::sd)
  sdx[!is.finite(sdx) | sdx <= 0] <- 1
  for (b in seq_len(nperm)) {
    Z <- if (null == "permutation") {
      apply(X, 2, sample)
    } else {
      sweep(matrix(stats::rnorm(length(X)), nrow(X), ncol(X)), 2, sdx, "*")
    }
    Z <- sweep(Z,2,colMeans(Z),"-")
    d <- svd(Z, nu = 0, nv = 0)$d^2 / max(1, nrow(Z) - 1)
    null_eigs[b, ] <- d[seq_len(r)]
  }
  upper <- apply(null_eigs, 2, stats::quantile, probs = quantile, names = FALSE, type = 8)
  mean_null <- colMeans(null_eigs)
  pass <- obs > upper
  k <- if (length(pass) && pass[1]) {
    bad <- which(!pass)
    if (length(bad)) bad[1] - 1L else length(pass)
  } else 0L
  list(k = k, observed = obs, null_mean = mean_null, null_upper = upper,
       null_eigenvalues = null_eigs, quantile = quantile, null = null)
}

.pca_em_masked_mse <- function(X, mask, k, max_iter = 200L, tol = 1e-6) {
  Xin <- X; Xin[mask] <- NA_real_
  cm <- colMeans(Xin, na.rm = TRUE)
  if (any(!is.finite(cm))) return(NA_real_)
  Ximp <- Xin
  for (j in seq_len(ncol(Ximp))) Ximp[is.na(Ximp[, j]), j] <- cm[j]
  old <- Inf
  for (it in seq_len(max_iter)) {
    s <- svd(Ximp, nu = k, nv = k)
    rec <- s$u[, seq_len(k), drop = FALSE] %*% (diag(s$d[seq_len(k)], nrow = k) %*% t(s$v[, seq_len(k), drop = FALSE]))
    change <- sqrt(mean((Ximp[mask] - rec[mask])^2))
    Ximp[mask] <- rec[mask]
    if (is.finite(old) && abs(old - change) < tol * (1 + old)) break
    old <- change
  }
  mean((X[mask] - rec[mask])^2)
}

#' Masked cross-validation for PCA dimensionality
#'
#' @param x A `pca_fit` object or numeric data.
#' @param kmax Maximum number of candidate components.
#' @param repeats Number of random masking repeats.
#' @param holdout Fraction of matrix cells held out per repeat.
#' @param seed Optional random seed.
#' @return Cross-validation table and selected component number.
#' @examples
#' cv <- pca_cv(iris[, 1:4], kmax = 4, repeats = 5, seed = 1)
#' cv$table
#' cv$k
#' @export
pca_cv <- function(x, kmax = NULL, repeats = 20L, holdout = 0.1, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  if (inherits(x, "pca_fit")) {
    if (!x$method %in% c("classical", "randomized"))
      .pca_stop("pca_cv() is a masked-reconstruction criterion for ordinary Euclidean PCA. Advanced engines require an engine-specific validation criterion.")
    X <- x$processed_data
    centered <- isTRUE(x$preprocessing$center)
  } else {
    X <- pca_preprocess(x, center = TRUE, scale = TRUE, na_action = "fail")$data
    centered <- TRUE
  }
  X <- .pca_as_numeric_matrix(X, allow_na = FALSE)
  if (is.null(kmax)) kmax <- min(10L, .pca_rank_limit(X, centered = centered))
  kmax <- min(as.integer(kmax), .pca_rank_limit(X, centered = centered))
  mse <- matrix(NA_real_, repeats, kmax)
  nmask <- max(1L, floor(length(X) * holdout))
  for (b in seq_len(repeats)) {
    idx <- sample.int(length(X), nmask)
    mask <- matrix(FALSE, nrow(X), ncol(X)); mask[idx] <- TRUE
    # Guard against masking an entire row or column.
    if (any(rowSums(!mask) == 0) || any(colSums(!mask) == 0)) next
    for (k in seq_len(kmax)) mse[b, k] <- .pca_em_masked_mse(X, mask, k)
  }
  means <- colMeans(mse, na.rm = TRUE)
  ses <- apply(mse, 2, stats::sd, na.rm = TRUE) / sqrt(pmax(1, colSums(is.finite(mse))))
  kmin <- which.min(means)
  # one-standard-error rule prefers simpler models
  threshold <- means[kmin] + ses[kmin]
  eligible <- which(means <= threshold)
  k1se <- if (length(eligible)) min(eligible) else kmin
  list(k = k1se, k_min = kmin,
       table = data.frame(k = seq_len(kmax), mse = means, se = ses),
       replicate_mse = mse, holdout = holdout, repeats = repeats)
}

.pca_scree_elbow <- function(eig) {
  eig <- as.numeric(eig)
  if (length(eig) <= 2L) return(length(eig))
  x <- seq_along(eig); y <- eig
  x1 <- x[1]; y1 <- y[1]; x2 <- x[length(x)]; y2 <- y[length(y)]
  den <- sqrt((y2-y1)^2 + (x2-x1)^2)
  if (den == 0) return(1L)
  dist <- abs((y2-y1)*x - (x2-x1)*y + x2*y1 - y2*x1) / den
  which.max(dist)
}

.pca_ppca_bic_sequence <- function(X, kmax) {
  X <- as.matrix(X); n <- nrow(X); p <- ncol(X)
  ee <- eigen(crossprod(X) / max(1, n - 1), symmetric = TRUE)$values
  out <- rep(NA_real_, kmax)
  for (q in seq_len(kmax)) {
    trailing <- if (q < p) ee[(q+1L):p] else numeric()
    sigma2 <- if (length(trailing)) max(mean(pmax(trailing, 0)), 1e-10) else 1e-10
    U <- eigen(crossprod(X) / max(1,n-1), symmetric=TRUE)$vectors[, seq_len(q), drop=FALSE]
    W <- U %*% diag(sqrt(pmax(ee[seq_len(q)] - sigma2, 0)), nrow=q)
    ll <- .pca_ppca_loglik(X, W, sigma2)
    df <- p*q - q*(q-1)/2 + 1
    out[q] <- -2*ll + df*log(n)
  }
  out
}

#' Select the number of PCA components using multiple criteria
#'
#' @param x A `pca_fit` object or numeric data.
#' @param methods Any subset of `"scree"`, `"cumulative"`, `"kaiser"`, `"broken_stick"`,
#'   `"parallel"`, `"permutation"`, `"rmt"`, `"cv"`, `"stability"`, `"ppca_bic"`,
#'   and `"engine_cv"`, or `"all"`. `"engine_cv"` is currently implemented for logistic PCA.
#' @param cumulative_threshold Variance threshold for the cumulative criterion.
#' @param nperm Number of permutations/reference datasets for stochastic criteria.
#' @param nboot Bootstrap resamples for stability criterion.
#' @param cv_folds Number of folds for engine-specific cross-validation when available.
#' @param seed Optional seed.
#' @return A consensus object with all recommendations and explicit disagreements.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE)
#' sel <- pca_ncomp(fit, methods = c("scree", "cumulative", "broken_stick"),
#'                  nperm = 19, nboot = 20, seed = 1)
#' sel$recommendations
#' sel$consensus
#' @export
pca_ncomp <- function(x, methods = "all", cumulative_threshold = 0.90,
                      nperm = 199L, nboot = 100L, cv_folds = 5L, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  fit <- if (inherits(x, "pca_fit")) x else pca_fit(x, method = "classical", center = TRUE, scale = TRUE)
  all_methods <- c("scree", "cumulative", "kaiser", "broken_stick", "parallel", "permutation", "rmt", "cv", "stability", "ppca_bic", "engine_cv")
  requested_all <- length(methods) == 1L && methods == "all"
  if (requested_all) methods <- all_methods
  methods <- intersect(methods, all_methods)
  # Component-number criteria answer geometry-specific questions.  Restrict
  # the automatic menu to criteria that are defensible for the fitted engine
  # rather than silently transferring correlation-PCA rules across models.
  allowed <- switch(fit$method,
    classical = setdiff(all_methods, "engine_cv"),
    randomized = setdiff(all_methods, "engine_cv"),
    ppca = c("scree", "cumulative", "ppca_bic"),
    weighted = c("scree", "stability"),
    nipals = c("scree", "cumulative", "stability"),
    em = c("scree", "cumulative", "stability"),
    bayesian = "scree",
    robust = c("scree", "stability"),
    cellwise = "scree",
    sparse = c("scree", "stability"),
    robust_sparse = c("scree", "stability"),
    rpca = c("scree", "cumulative", "stability"),
    shrinkage = c("scree", "cumulative", "stability"),
    kernel = c("scree", "cumulative"),
    logistic = "engine_cv",
    glmpca = character(),
    nlpca = character(),
    compositional = c("scree", "cumulative"),
    functional = c("scree", "cumulative"),
    dynamic = c("scree", "cumulative"),
    multilevel = c("scree", "cumulative"),
    multiblock = c("scree", "cumulative"),
    c("scree", "cumulative")
  )
  if (!isTRUE(fit$extra$variance_partition_valid))
    allowed <- setdiff(allowed, c("cumulative", "kaiser", "broken_stick", "parallel", "permutation", "rmt", "cv", "ppca_bic"))
  if (!isTRUE(fit$preprocessing$center))
    allowed <- setdiff(allowed, c("kaiser", "parallel", "permutation", "rmt", "ppca_bic"))
  if (fit$method %in% c("glmpca", "nlpca")) {
    .pca_stop("No universal Gaussian-PCA component-number rule is valid for method='", fit$method, "'. Use likelihood/deviance or method-specific validation for candidate latent ranks.")
  }
  methods <- if (requested_all) allowed else intersect(methods, allowed)
  if (!length(methods)) {
    .pca_stop("None of the requested component-number criteria are validated for method='", fit$method, "'. Allowed criteria: ",
              if (length(allowed)) paste(allowed, collapse = ", ") else "method-specific validation only", ".")
  }
  eig <- fit$eigenvalues
  pve <- fit$variance_explained
  spectrum_note <- "Fitted eigenspectrum used."
  full_rank <- .pca_rank_limit(fit$processed_data, centered = isTRUE(fit$preprocessing$center))
  # A user may deliberately retain only a few PCs in the fit. For ordinary
  # Euclidean SVD PCA, dimensionality criteria should still see the complete
  # available eigenspectrum rather than treating the retained subset as 100%.
  if (fit$method %in% c("classical", "randomized") && !anyNA(fit$processed_data) && length(eig) < full_rank) {
    dd <- svd(fit$processed_data, nu = 0, nv = 0)$d
    eig <- dd[seq_len(min(full_rank, length(dd)))]^2 / max(1, nrow(fit$processed_data) - 1)
    total <- .pca_total_inertia(fit$processed_data, centered = isTRUE(fit$preprocessing$center))
    pve <- if (is.finite(total) && total > 0) eig / total else eig / sum(eig)
    spectrum_note <- "Full classical eigenspectrum recomputed from the processed data because the supplied fit was truncated."
  } else if (length(pve) != length(eig) || !any(is.finite(pve))) {
    pve <- eig / sum(eig)
    spectrum_note <- paste(spectrum_note, "Explained proportions were normalized over the available fitted eigenvalues because a full variance partition was unavailable.")
  }
  recs <- list()
  details <- list()

  if ("scree" %in% methods) recs$scree <- .pca_scree_elbow(eig)
  if ("cumulative" %in% methods) recs$cumulative <- which(cumsum(pve) >= cumulative_threshold)[1]
  if ("kaiser" %in% methods) {
    # Kaiser is meaningful for a correlation/UV-scaled PCA.
    if (identical(fit$preprocessing$scale_method, "uv") && isTRUE(fit$preprocessing$center)) recs$kaiser <- sum(eig > 1) else recs$kaiser <- NA_integer_
  }
  if ("broken_stick" %in% methods) {
    bs <- pca_broken_stick(length(eig)); pass <- pve > bs
    recs$broken_stick <- if (any(pass)) max(which(pass)) else 0L
    details$broken_stick <- bs
  }
  if ("parallel" %in% methods) {
    pa <- pca_parallel(fit, nperm = nperm, null = "normal")
    recs$parallel <- pa$k; details$parallel <- pa
  }
  if ("permutation" %in% methods) {
    pp <- pca_parallel(fit, nperm = nperm, null = "permutation")
    recs$permutation <- pp$k; details$permutation <- pp
  }
  if ("rmt" %in% methods) {
    # Marchenko-Pastur upper edge for unit-variance, independent-noise PCA.
    # This is a screening criterion, not a universal decision rule.
    if (identical(fit$preprocessing$scale_method, "uv") && isTRUE(fit$preprocessing$center)) {
      n_eff <- max(1, nrow(fit$processed_data) - 1)
      q <- ncol(fit$processed_data) / n_eff
      upper <- (1 + sqrt(q))^2
      recs$rmt <- sum(eig > upper)
      details$rmt <- list(q = q, marchenko_pastur_upper = upper,
                          assumption = "Unit-variance independent-noise reference; finite-sample and dependence effects can alter the edge.")
    } else recs$rmt <- NA_integer_
  }
  if ("cv" %in% methods) {
    cv <- pca_cv(fit, kmax = min(10L, length(eig)), repeats = max(10L, ceiling(nperm/20)))
    recs$cv <- cv$k; details$cv <- cv
  }
  if ("stability" %in% methods && !is.null(fit$loadings)) {
    st <- try(pca_stability(fit, nboot = nboot, kmax = min(fit$ncomp, 10L), seed = seed, refit = "same"), silent = TRUE)
    if (inherits(st, "try-error")) {
      recs$stability <- NA_integer_
      details$stability <- list(error = as.character(st), note = "No faithful same-engine bootstrap stability refit is currently available for this fitted engine.")
    } else {
      ok <- which(st$summary$median_max_angle <= 20 & st$summary$median_similarity >= 0.90)
      recs$stability <- if (length(ok)) max(ok) else 0L
      details$stability <- st
    }
  }
  if ("ppca_bic" %in% methods && !anyNA(fit$processed_data)) {
    kmax <- min(length(eig), 10L, ncol(fit$processed_data)-1L)
    if (kmax >= 1L) {
      bic <- .pca_ppca_bic_sequence(fit$processed_data, kmax)
      recs$ppca_bic <- which.min(bic); details$ppca_bic <- bic
    }
  }
  if ("engine_cv" %in% methods) {
    if (fit$method == "logistic") {
      .pca_require("logisticPCA", "logistic PCA cross-validation")
      kmax <- min(ncol(fit$data) - 1L, max(fit$ncomp, min(10L, ncol(fit$data) - 1L)))
      ks <- seq_len(max(1L, kmax))
      mfit <- fit$extra$backend_object$m %||% 4
      cvmat <- logisticPCA::cv.lpca(fit$data, ks = ks, ms = mfit, folds = as.integer(cv_folds), quiet = TRUE)
      cvmat <- as.matrix(cvmat)
      if (!any(is.finite(cvmat))) .pca_stop("logisticPCA::cv.lpca() returned no finite cross-validation criterion.")
      ij <- which(cvmat == min(cvmat, na.rm = TRUE), arr.ind = TRUE)[1L, , drop = FALSE]
      recs$engine_cv <- ks[ij[1,1]]
      details$engine_cv <- list(negative_log_likelihood = cvmat, ks = ks, m = mfit, folds = cv_folds,
                                criterion = "Minimum cross-validated negative log likelihood from logisticPCA::cv.lpca().")
    } else recs$engine_cv <- NA_integer_
  }
  vals <- as.integer(unlist(recs)); valid <- vals[is.finite(vals) & vals >= 0]
  consensus <- if (length(valid)) as.integer(round(stats::median(valid))) else NA_integer_
  tab <- data.frame(method = names(recs), suggested_k = vals, stringsAsFactors = FALSE)
  out <- list(consensus = consensus, recommendations = tab, details = details,
              disagreement_range = if (length(valid)) range(valid) else c(NA_integer_, NA_integer_),
              fit_method = fit$method, spectrum_note = spectrum_note,
              caution = "Component-number criteria answer different questions and are geometry-specific. Consensus is a transparent summary, not a formal universal optimum.")
  fit$ncomp_selection <- out
  out
}
