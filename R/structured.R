# Structured, functional, dynamic, and streaming PCA -----------------------

.pca_fit_dynamic <- function(data, center = TRUE, scale = FALSE, ncomp = NULL, call = NULL,
                             lags = 1L, include_current = TRUE, robust = FALSE, transform = "none", ...) {
  X <- .pca_as_numeric_matrix(data, allow_na = FALSE)
  lags <- sort(unique(as.integer(lags)))
  if (any(lags < 1L)) .pca_stop("lags must contain positive integers.")
  maxlag <- max(lags)
  if (nrow(X) <= maxlag + 1L) .pca_stop("Not enough observations for the requested lags.")
  parts <- list()
  if (isTRUE(include_current)) parts[["lag0"]] <- X[(maxlag + 1L):nrow(X), , drop = FALSE]
  for (lag in lags) {
    part <- X[(maxlag + 1L - lag):(nrow(X) - lag), , drop = FALSE]
    colnames(part) <- paste0(colnames(X), "_lag", lag)
    parts[[paste0("lag", lag)]] <- part
  }
  Z <- do.call(cbind, parts)
  if (isTRUE(include_current)) colnames(Z)[seq_len(ncol(X))] <- paste0(colnames(X), "_lag0")
  base_method <- if (isTRUE(robust)) "robust" else "classical"
  fit <- pca_fit(Z, method = base_method, center = center, scale = scale, ncomp = ncomp, transform = transform, ...)
  fit$method <- "dynamic"
  fit$engine <- if (isTRUE(robust)) "lag-embedded robust dynamic PCA" else "lag-embedded dynamic PCA"
  fit$call <- call
  fit$extra$lags <- lags
  fit$extra$include_current <- include_current
  fit$extra$robust <- isTRUE(robust)
  fit$extra$original_time_index <- (maxlag + 1L):nrow(X)
  fit
}

.pca_fit_multilevel <- function(data, center = TRUE, scale = FALSE, ncomp = NULL, call = NULL,
                                subject, level = c("within", "between"), transform = "none") {
  X <- .pca_as_numeric_matrix(data, allow_na = FALSE)
  if (!identical(transform, "none")) {
    X <- pca_preprocess(X, center = FALSE, scale = FALSE, transform = transform, na_action = "fail")$data
  }
  if (missing(subject)) .pca_stop("multilevel PCA requires a subject/group identifier.")
  if (length(subject) != nrow(X)) .pca_stop("subject must have one value per observation.")
  level <- match.arg(level)
  f <- as.factor(subject)
  subject_means <- rowsum(X, f) / as.vector(table(f))
  between_rows <- subject_means[as.integer(f), , drop = FALSE]
  grand <- colMeans(X)
  if (level == "within") {
    Z <- X - between_rows
  } else {
    Z <- sweep(between_rows, 2, grand, "-")
  }
  fit <- pca_fit(Z, method = "classical", center = center, scale = scale, ncomp = ncomp)
  fit$method <- "multilevel"
  fit$engine <- paste0("internal multilevel PCA: ", level)
  fit$call <- call
  fit$extra$subject <- f
  fit$extra$level <- level
  fit$extra$subject_means <- subject_means
  fit
}

.pca_fit_functional <- function(data, center = TRUE, scale = FALSE, ncomp = NULL, call = NULL,
                                grid = NULL, smooth = FALSE, spar = NULL,
                                backend = c("dense", "MFPCA"), uniExpansions = NULL, ...) {
  backend <- match.arg(backend)
  if (backend == "MFPCA") {
    .pca_require("MFPCA", "multivariate functional PCA")
    if (is.null(uniExpansions))
      .pca_stop("backend='MFPCA' requires uniExpansions as specified by MFPCA::MFPCA().")
    if (is.null(ncomp)) ncomp <- 2L
    res <- MFPCA::MFPCA(data, M = as.integer(ncomp), uniExpansions = uniExpansions, ...)
    scores <- as.matrix(res$scores)
    eig <- as.numeric(res$values %||% apply(scores,2,stats::var))
    k <- min(as.integer(ncomp), ncol(scores), length(eig))
    if (k < 1L) .pca_stop("MFPCA did not return any usable component.")
    scores <- scores[, seq_len(k), drop = FALSE]
    eig <- eig[seq_len(k)]
    # Multivariate eigenfunctions cannot be represented as an ordinary p x k loading matrix.
    dummy <- matrix(NA_real_, nrow(scores), 1L, dimnames=list(rownames(scores),"functional_domain"))
    prep <- list(raw=data,data=dummy,center=center,center_vector=NULL,scale_method="functional",scale_vector=NULL,
                 transform="none",variable_names="functional_domain",observation_names=rownames(scores),audit=NULL)
    out <- .new_pca_fit(data,dummy,scores,NULL,eig,"functional",prep,call,k,
                        extra=list(engine="MFPCA::MFPCA",backend_object=res,eigenfunctions=res$functions %||% NULL,
                                   fitted_functions=res$fit %||% NULL,multivariate_functional=TRUE,
                                   variance_partition_valid=FALSE,
                                   warning="MFPCA eigenvalues are retained as component-scale summaries; pcaLab does not infer a full functional variance partition unless the backend exposes a verified complete spectrum."),orthogonal=TRUE)
    return(out)
  }
  X <- .pca_as_numeric_matrix(data, allow_na = FALSE)
  if (is.null(grid)) grid <- seq_len(ncol(X))
  if (length(grid) != ncol(X)) .pca_stop("grid length must equal the number of functional measurement points.")
  Z <- X
  if (isTRUE(smooth)) {
    for (i in seq_len(nrow(X))) {
      sm <- stats::smooth.spline(grid, X[i, ], spar = spar)
      Z[i, ] <- stats::predict(sm, grid)$y
    }
  }
  # Weighted discretized L2 inner product using trapezoidal-like point weights.
  dx <- diff(grid)
  if (any(dx <= 0)) .pca_stop("grid must be strictly increasing.")
  w <- numeric(length(grid))
  if (length(grid) == 2L) w[] <- dx[1] / 2 else {
    w[1] <- dx[1] / 2; w[length(w)] <- dx[length(dx)] / 2
    w[2:(length(w)-1)] <- (dx[-length(dx)] + dx[-1]) / 2
  }
  Zw <- sweep(Z, 2, sqrt(w), "*")
  fit <- pca_fit(Zw, method = "classical", center = center, scale = scale, ncomp = ncomp)
  fit$method <- "functional"
  fit$engine <- "internal dense-grid FPCA"
  fit$call <- call
  # Eigenfunctions on original grid scale.
  fit$extra$grid <- grid
  fit$extra$quadrature_weights <- w
  fit$extra$eigenfunctions <- sweep(fit$loadings, 1, sqrt(w), "/")
  fit$extra$smoothed_data <- Z
  fit$extra$smooth <- smooth
  fit$extra$spar <- spar
  fit$data <- Z
  fit$extra$input_transform <- function(newdata) {
    A <- .pca_as_numeric_matrix(newdata, allow_na = FALSE)
    if (ncol(A) != length(grid)) .pca_stop("New functional data have the wrong number of grid points.")
    if (isTRUE(smooth)) {
      for (ii in seq_len(nrow(A))) {
        sm <- stats::smooth.spline(grid, A[ii, ], spar = spar)
        A[ii, ] <- stats::predict(sm, grid)$y
      }
    }
    sweep(A, 2, sqrt(w), "*")
  }
  fit$extra$original_scale_function <- function(weighted_curve) {
    A <- sweep(as.matrix(weighted_curve), 2, sqrt(w), "/")
    colnames(A) <- colnames(Z)
    A
  }
  fit
}

#' ANOVA-Simultaneous Component Analysis (ASCA)
#'
#' Decomposes a multivariate response matrix into model-effect matrices using
#' linear-model projections, then applies PCA to each effect matrix.
#'
#' @param data Numeric response matrix (observations x variables).
#' @param formula Model formula using columns in `design`.
#' @param design Data frame containing experimental factors/covariates.
#' @param ncomp Components retained per effect.
#' @param scale Scale response variables before decomposition.
#' @param nperm Number of Freedman-Lane residual permutations for term-level sums of squares; 0 disables testing.
#' @param seed Optional random seed for permutations.
#' @return A list containing effect matrices, PCA fits, sums of squares, and design information.
#' @examples
#' set.seed(1)
#' design <- data.frame(A = factor(rep(1:2, each = 10)),
#'                      B = factor(rep(1:2, 10)))
#' Y <- cbind(y1 = rnorm(20) + 2 * as.numeric(design$A),
#'            y2 = rnorm(20) + as.numeric(design$B))
#' asca <- pca_asca(Y, ~ A + B, design, ncomp = 1, nperm = 19, seed = 1)
#' asca$effect_ss
#' asca$effect_p
#' @export
pca_asca <- function(data, formula, design, ncomp = 2L, scale = FALSE, nperm = 0L, seed = NULL) {
  Y <- .pca_as_numeric_matrix(data, allow_na = FALSE)
  if (nrow(design) != nrow(Y)) .pca_stop("design must have one row per observation.")
  prep <- pca_preprocess(Y, center = TRUE, scale = scale, na_action = "fail")
  Yp <- prep$data
  mm <- stats::model.matrix(formula, data = design)
  fit <- stats::lm.fit(mm, Yp)
  fitted_full <- mm %*% fit$coefficients
  assign <- attr(mm, "assign")
  term_labels <- attr(stats::terms(formula), "term.labels")
  effects <- list()
  fits <- list()
  ss <- numeric()
  for (idx in seq_along(term_labels)) {
    cols <- which(assign == idx)
    if (!length(cols)) next
    # Effect matrices are projections of the centered response onto the
    # mean-adjusted effect subspace, so that the ASCA decomposition
    # SS_total = sum(SS_effect) + SS_residual holds exactly for orthogonal
    # designs and each effect excludes the overall mean.
    Ecm <- sweep(mm[, cols, drop = FALSE], 2, colMeans(mm[, cols, drop = FALSE]), "-")
    E <- Ecm %*% qr.coef(qr(Ecm), Yp)
    effects[[term_labels[idx]]] <- E
    fits[[term_labels[idx]]] <- pca_fit(E, method = "classical", center = FALSE, scale = FALSE,
                                        ncomp = min(ncomp, .pca_rank_limit(E, centered = FALSE)))
    ss[term_labels[idx]] <- sum(E^2)
  }
  residuals <- Yp - fitted_full
  ss_res <- sum(residuals^2)
  nperm <- as.integer(nperm)
  perm_null <- NULL; effect_p <- setNames(rep(NA_real_,length(ss)),names(ss))
  if (nperm > 0L && length(ss)) {
    if (!is.null(seed)) set.seed(seed)
    perm_null <- matrix(NA_real_,nperm,length(ss),dimnames=list(NULL,names(ss)))
    for (idx in seq_along(term_labels)) {
      term <- term_labels[idx]
      if (!term %in% names(ss)) next
      cols <- which(assign == idx)
      keep_cols <- setdiff(seq_len(ncol(mm)), cols)
      mm_red <- mm[, keep_cols, drop=FALSE]
      red <- stats::lm.fit(mm_red,Yp)
      yhat_red <- mm_red %*% red$coefficients
      resid_red <- Yp-yhat_red
      Ecm <- sweep(mm[, cols, drop = FALSE], 2, colMeans(mm[, cols, drop = FALSE]), "-")
      for (b in seq_len(nperm)) {
        Yb <- yhat_red + resid_red[sample.int(nrow(Yp)),,drop=FALSE]
        Eb <- Ecm %*% qr.coef(qr(Ecm), Yb)
        perm_null[b,term] <- sum(Eb^2)
      }
      effect_p[term] <- (1+sum(perm_null[,term]>=ss[term],na.rm=TRUE))/(nperm+1)
    }
  }
  structure(list(effect_matrices = effects, pca = fits, effect_ss = ss,
       residuals = residuals, residual_ss = ss_res,
       total_ss = sum(Yp^2), formula = formula, design = design, preprocessing = prep,
       nperm=nperm, effect_p=effect_p, permutation_null=perm_null,
       permutation_note=if(nperm>0) "Term-level Freedman-Lane residual permutation using reduced models." else NULL),
       class = "pca_asca")
}

#' Multiblock PCA by block scaling and concatenation
#'
#' @param blocks Named list of numeric matrices sharing the same observations.
#' @param ncomp Number of consensus components.
#' @param block_scale `"frobenius"`, `"first_singular"`, or `"none"`.
#' @param center Center each block.
#' @param scale Variable scaling within each block.
#' @param transform Optional element-wise transformation applied within each block.
#' @return A `pca_fit` object augmented with block scores and block contributions.
#' @examples
#' set.seed(2)
#' soil <- matrix(rnorm(60 * 4), 60, 4)
#' climate <- matrix(rnorm(60 * 3), 60, 3)
#' mb <- pca_multiblock(list(soil = soil, climate = climate),
#'                      block_scale = "frobenius", ncomp = 2)
#' mb$extra$block_contributions
#' @export
pca_multiblock <- function(blocks, ncomp = NULL,
                           block_scale = c("frobenius", "first_singular", "none"),
                           center = TRUE, scale = FALSE, transform = "none") {
  if (!is.list(blocks) || length(blocks) < 2L) .pca_stop("blocks must be a list with at least two matrices.")
  block_scale <- match.arg(block_scale)
  mats <- lapply(blocks, .pca_as_numeric_matrix, allow_na = FALSE)
  nr <- vapply(mats, nrow, integer(1))
  if (length(unique(nr)) != 1L) .pca_stop("All blocks must have the same number of observations.")
  if (is.null(names(mats))) names(mats) <- paste0("Block", seq_along(mats))
  preps <- lapply(mats, pca_preprocess, center = center, scale = scale, transform = transform, na_action = "fail")
  Zs <- lapply(preps, `[[`, "data")
  bs <- vapply(Zs, function(Z) switch(block_scale,
    none = 1,
    frobenius = sqrt(sum(Z^2)),
    first_singular = svd(Z, nu = 0, nv = 0)$d[1]
  ), numeric(1))
  bs[!is.finite(bs) | bs <= 0] <- 1
  Zscaled <- Map(function(Z, s) Z / s, Zs, bs)
  for (i in seq_along(Zscaled)) colnames(Zscaled[[i]]) <- paste0(names(Zscaled)[i], "::", colnames(Zscaled[[i]]))
  Z <- do.call(cbind, Zscaled)
  fit <- pca_fit(Z, method = "classical", center = FALSE, scale = FALSE, ncomp = ncomp)
  fit$method <- "multiblock"
  fit$engine <- "block-scaled consensus PCA"
  fit$extra$block_scaling <- bs
  fit$extra$block_preprocessing <- preps
  fit$extra$blocks <- mats
  # contributions based on squared loadings within each block
  groups <- sub("::.*$", "", rownames(fit$loadings))
  bc <- sapply(unique(groups), function(g) colSums(fit$loadings[groups == g, , drop = FALSE]^2))
  fit$extra$block_contributions <- t(bc)
  fit
}

# Incremental covariance PCA ------------------------------------------------

#' Initialize an incremental PCA state
#' @param p Number of variables.
#' @param center Center data in the final model.
#' @param scale Scale data to unit variance in the final model.
#' @examples
#' # Streaming PCA over three chunks
#' set.seed(9)
#' X <- matrix(rnorm(600), 150, 4)
#' st <- pca_incremental_init(4, center = TRUE, scale = TRUE)
#' st <- pca_incremental_update(st, X[1:50, ])
#' st <- pca_incremental_update(st, X[51:100, ])
#' st <- pca_incremental_update(st, X[101:150, ])
#' fit <- pca_incremental_finalize(st, ncomp = 2)
#' fit$eigenvalues
#' @export
pca_incremental_init <- function(p, center = TRUE, scale = FALSE) {
  p <- as.integer(p)
  if (p < 1L) .pca_stop("p must be positive.")
  structure(list(n = 0L, mean = numeric(p), M2 = matrix(0, p, p),
                 sum_xx = matrix(0, p, p),
                 center = isTRUE(center), scale = isTRUE(scale),
                 variable_names = NULL), class = "pca_incremental_state")
}

#' Update an incremental PCA state with a batch
#' @param state Incremental state.
#' @param batch Numeric matrix with the same variables.
#' @examples
#' st <- pca_incremental_init(3, center = TRUE)
#' st <- pca_incremental_update(st, matrix(rnorm(30), 10, 3))
#' st$n
#' @export
pca_incremental_update <- function(state, batch) {
  if (!inherits(state, "pca_incremental_state")) .pca_stop("state must come from pca_incremental_init().")
  X <- .pca_as_numeric_matrix(batch, allow_na = FALSE)
  if (ncol(X) != length(state$mean)) .pca_stop("Batch has the wrong number of variables.")
  if (is.null(state$variable_names)) state$variable_names <- colnames(X)
  nb <- nrow(X)
  mb <- colMeans(X)
  Xc <- sweep(X, 2, mb, "-")
  M2b <- crossprod(Xc)
  XXb <- crossprod(X)
  if (state$n == 0L) {
    state$n <- nb; state$mean <- mb; state$M2 <- M2b; state$sum_xx <- XXb
    return(state)
  }
  delta <- mb - state$mean
  nt <- state$n + nb
  state$M2 <- state$M2 + M2b + tcrossprod(delta) * (state$n * nb / nt)
  state$sum_xx <- state$sum_xx + XXb
  state$mean <- state$mean + delta * nb / nt
  state$n <- nt
  state
}

#' Finalize an incremental PCA state
#' @param state Incremental state.
#' @param ncomp Number of components.
#' @return A `pca_fit` object containing eigenvectors/eigenvalues; scores are not available without replaying observations.
#' @examples
#' st <- pca_incremental_init(3, center = TRUE)
#' st <- pca_incremental_update(st, matrix(rnorm(60), 20, 3))
#' fit <- pca_incremental_finalize(st, ncomp = 2)
#' fit$loadings
#' @export
pca_incremental_finalize <- function(state, ncomp = NULL) {
  if (!inherits(state, "pca_incremental_state") || state$n < 2L) .pca_stop("Need at least two accumulated observations.")
  C_centered <- state$M2 / (state$n - 1)
  C <- if (state$center) C_centered else state$sum_xx / (state$n - 1)
  sc <- rep(1, nrow(C))
  if (state$scale) {
    sc <- sqrt(diag(C_centered)); sc[!is.finite(sc) | sc <= 0] <- 1
    C <- C / outer(sc, sc)
  }
  ee <- eigen((C + t(C)) / 2, symmetric = TRUE)
  ee$values <- pmax(ee$values, 0)
  if (is.null(ncomp)) ncomp <- min(length(ee$values), state$n - 1L)
  k <- min(as.integer(ncomp), length(ee$values))
  V <- ee$vectors[, seq_len(k), drop = FALSE]
  rownames(V) <- state$variable_names %||% paste0("V", seq_len(nrow(V)))
  dummy <- matrix(NA_real_, 0, nrow(V), dimnames = list(NULL, rownames(V)))
  prep <- list(raw = dummy, data = dummy, center = state$center,
               center_vector = if (state$center) state$mean else NULL,
               scale_method = if (state$scale) "uv" else "none",
               scale_vector = if (state$scale) sc else NULL,
               transform = "none", variable_names = rownames(V), observation_names = character(), audit = NULL)
  # Construct manually because no original scores are retained in streaming mode.
  total_eig <- sum(pmax(ee$values,0))
  pve <- if (is.finite(total_eig) && total_eig > 0) ee$values[seq_len(k)] / total_eig else rep(NA_real_, k)
  out <- list(call = match.call(), method = "incremental", engine = "online covariance aggregation",
              data = dummy, processed_data = dummy,
              preprocessing = prep, scores = matrix(numeric(), 0, k, dimnames = list(NULL, .pca_component_names(k))),
              loadings = V, eigenvalues = ee$values[seq_len(k)], sdev = sqrt(pmax(ee$values[seq_len(k)],0)),
              variance_explained = pve,
              cumulative_variance = if (all(is.finite(pve))) cumsum(pve) else rep(NA_real_, k),
              correlation_loadings = NULL, cos2 = NULL, contributions = NULL, communalities = NULL,
              ncomp = k, orthogonal = TRUE,
              extra = list(n = state$n, covariance = C, incremental_state = state),
              inference = NULL, bootstrap = NULL, stability = NULL, diagnostics = NULL,
              ncomp_selection = NULL, warnings = "Scores require replaying the data through predict().", version = "0.1.0")
  class(out) <- "pca_fit"
  out
}
