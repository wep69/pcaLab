# Advanced PCA engines -----------------------------------------------------

.pca_fit_robust <- function(X, prep, ncomp, call = NULL, alpha = 0.75, skew = FALSE, ...) {
  .pca_require("rospca", "ROBPCA")
  res <- rospca::robpca(X, k = ncomp, alpha = alpha, skew = skew, ...)
  out <- .new_pca_fit(prep$raw, X, res$scores, res$loadings, res$eigenvalues,
                      "robust", prep, call, ncomp,
                      extra = list(engine = "rospca::robpca", backend_object = res, variance_partition_valid = FALSE,
                                   robust_center = res$center,
                                   projection_center = res$center %||% rep(0,ncol(X)),
                                   reconstruction_intercept = res$center %||% rep(0,ncol(X)),
                                   od = res$od %||% res$OD %||% NULL, sd = res$sd %||% res$SD %||% NULL,
                                   cutoff_od = res$cutoff.od %||% res$cutoffOD %||% NULL,
                                   cutoff_sd = res$cutoff.sd %||% res$cutoffSD %||% NULL,
                                   H0 = res$H0 %||% NULL, H1 = res$H1 %||% NULL),
                      orthogonal = TRUE)
  out
}

.pca_fit_cellwise <- function(X, prep, ncomp, call = NULL, ...) {
  .pca_require("cellWise", "MacroPCA")
  # MacroPCA handles missing values, rowwise and cellwise contamination.
  res <- cellWise::MacroPCA(X, k = ncomp, ...)
  get_first <- function(obj, candidates) {
    for (nm in candidates) if (!is.null(obj[[nm]])) return(obj[[nm]])
    NULL
  }
  scores <- get_first(res, c("scores", "score"))
  loadings <- get_first(res, c("loadings", "loadings.all", "P"))
  eig <- get_first(res, c("eigenvalues", "eigenvalues.all", "eigenvals"))
  center <- get_first(res, c("center", "center.all"))
  if (is.null(scores) || is.null(loadings)) {
    .pca_stop("The installed cellWise::MacroPCA object layout was not recognized. Inspect the backend object and report its names().")
  }
  if (is.null(eig)) eig <- apply(scores, 2, stats::var, na.rm = TRUE)
  k <- min(ncomp, ncol(scores), ncol(loadings), length(eig))
  completed <- get_first(res, c("X.NAimp", "Ximp", "Xclean", "Xhat"))
  processed <- if (!is.null(completed) && all(dim(completed) == dim(X))) completed else X
  pred_fun <- function(Xnew) {
    pr <- cellWise::MacroPCApredict(Xnew, InitialMacroPCA = res)
    sc <- pr$scores %||% pr$score
    if (is.null(sc)) .pca_stop("cellWise::MacroPCApredict did not return scores.")
    as.matrix(sc)
  }
  .new_pca_fit(prep$raw, processed, scores[, seq_len(k), drop = FALSE],
               loadings[, seq_len(k), drop = FALSE], eig[seq_len(k)], "cellwise", prep, call, k,
               extra = list(engine = "cellWise::MacroPCA", backend_object = res, variance_partition_valid = FALSE,
                            robust_center = center,
                            projection_center = center %||% rep(0,ncol(processed)),
                            reconstruction_intercept = center %||% rep(0,ncol(processed)),
                            predict_function = pred_fun,
                            od = get_first(res, c("OD", "od")),
                            sd = get_first(res, c("SD", "sd")),
                            cutoff_od = get_first(res, c("cutoffOD", "cutoff.od")),
                            cutoff_sd = get_first(res, c("cutoffSD", "cutoff.sd")),
                            high_od = get_first(res, c("highOD", "high.od")),
                            high_sd = get_first(res, c("highSD", "high.sd")),
                            cellwise_map = get_first(res, c("indcells", "cellwiseOutliers", "W")),
                            rowwise_flags = get_first(res, c("flag", "rowwiseOutliers"))),
               orthogonal = TRUE)
}

.pca_fit_sparse <- function(X, prep, ncomp, call = NULL,
                            backend = c("sparsepca", "elasticnet"), alpha = 1e-4,
                            beta = 1e-4, cardinality = NULL, ...) {
  backend <- match.arg(backend)
  if (backend == "sparsepca") {
    .pca_require("sparsepca", "sparse PCA")
    res <- sparsepca::spca(X, k = ncomp, alpha = alpha, beta = beta,
                           center = FALSE, scale = FALSE, verbose = FALSE, ...)
    loadings <- as.matrix(res$loadings)
    scores <- as.matrix(res$scores)
    eig <- as.numeric(res$eigenvalues)
    inv <- res$transform %||% loadings
  } else {
    .pca_require("elasticnet", "sparse PCA")
    if (is.null(cardinality)) cardinality <- rep(max(1L, ceiling(sqrt(ncol(X)))), ncomp)
    if (length(cardinality) == 1L) cardinality <- rep(cardinality, ncomp)
    res <- elasticnet::spca(X, K = ncomp, para = cardinality,
                            type = "predictor", sparse = "varnum", use.corr = FALSE, ...)
    loadings <- as.matrix(res$loadings)
    scores <- X %*% loadings
    eig <- apply(scores, 2, stats::var)
    inv <- loadings
  }
  k <- min(ncomp, ncol(loadings), ncol(scores), length(eig))
  .new_pca_fit(prep$raw, X, scores[, seq_len(k), drop = FALSE],
               loadings[, seq_len(k), drop = FALSE], eig[seq_len(k)], "sparse", prep, call, k,
               extra = list(engine = paste0(backend, " sparse PCA"), backend_object = res, variance_partition_valid = FALSE,
                            inverse_loadings = inv[, seq_len(k), drop = FALSE],
                            sparsity = colMeans(abs(loadings[, seq_len(k), drop = FALSE]) < 1e-12)),
               orthogonal = FALSE)
}

.pca_fit_robust_sparse <- function(X, prep, ncomp, call = NULL,
                                   backend = c("rospca", "sparsepca"), lambda = 0.2,
                                   alpha = 0.75, grid = TRUE, para = NULL, ...) {
  backend <- match.arg(backend)
  if (backend == "rospca") {
    .pca_require("rospca", "robust sparse PCA")
    if (!isTRUE(grid) && is.null(para))
      .pca_stop("For rospca::rospca with grid = FALSE, supply the backend 'para' sparsity parameter.")
    args <- list(X = X, k = ncomp, lambda = lambda, alpha = alpha, stand = FALSE, grid = grid)
    if (!is.null(para)) args$para <- para
    args <- c(args, list(...))
    res <- do.call(rospca::rospca, args)
    loadings <- as.matrix(res$loadings)
    scores <- as.matrix(res$scores)
    eig <- as.numeric(res$eigenvalues)
    inverse <- loadings
    center <- res$center %||% rep(0, ncol(X))
  } else {
    .pca_require("sparsepca", "robust sparse PCA")
    res <- sparsepca::robspca(X, k = ncomp, alpha = lambda, center = FALSE, scale = FALSE,
                              verbose = FALSE, ...)
    loadings <- as.matrix(res$loadings)
    scores <- as.matrix(res$scores)
    eig <- as.numeric(res$eigenvalues)
    inverse <- res$transform %||% loadings
    center <- res$center %||% rep(0, ncol(X))
  }
  k <- min(ncomp, ncol(loadings), ncol(scores), length(eig))
  .new_pca_fit(prep$raw, X, scores[, seq_len(k), drop = FALSE],
               loadings[, seq_len(k), drop = FALSE], eig[seq_len(k)], "robust_sparse", prep, call, k,
               extra = list(engine = paste0(backend, " robust sparse PCA"), backend_object = res, variance_partition_valid = FALSE,
                            inverse_loadings = inverse[, seq_len(k), drop = FALSE],
                            projection_center = center, reconstruction_intercept = center, robust_center = center,
                            od = res$od %||% res$OD %||% NULL, sd = res$sd %||% res$SD %||% NULL,
                            cutoff_od = res$cutoff.od %||% res$cutoffOD %||% NULL,
                            cutoff_sd = res$cutoff.sd %||% res$cutoffSD %||% NULL,
                            sparse_error = res$sparse %||% NULL), orthogonal = FALSE)
}

.pca_fit_rpca <- function(X, prep, ncomp, call = NULL, lambda = NULL,
                          tol = 1e-7, max_iter = 1000, mu = NULL, rho = 1.5) {
  if (anyNA(X)) .pca_stop("Internal PCP/RPCA requires complete data.")
  m <- nrow(X); n <- ncol(X)
  if (is.null(lambda)) lambda <- 1 / sqrt(max(m, n))
  norm2 <- svd(X, nu = 0, nv = 0)$d[1]
  norminf <- max(abs(X)) / lambda
  dual_norm <- max(norm2, norminf)
  Y <- X / max(dual_norm, .Machine$double.eps)
  if (is.null(mu)) mu <- 1.25 / max(norm2, .Machine$double.eps)
  mu_bar <- mu * 1e7
  L <- matrix(0, m, n); S <- matrix(0, m, n)
  normX <- sqrt(sum(X^2))
  converged <- FALSE
  err <- Inf
  for (it in seq_len(max_iter)) {
    L <- .pca_svt(X - S + Y / mu, 1 / mu)
    S <- .pca_soft_threshold(X - L + Y / mu, lambda / mu)
    Z <- X - L - S
    Y <- Y + mu * Z
    mu <- min(mu * rho, mu_bar)
    err <- sqrt(sum(Z^2)) / max(normX, .Machine$double.eps)
    if (err < tol) { converged <- TRUE; break }
  }
  s <- svd(L, nu = min(nrow(L), ncomp), nv = ncomp)
  k <- min(ncomp, sum(s$d > max(s$d) * .Machine$double.eps), ncol(s$v))
  if (k < 1L) .pca_stop("PCP decomposition returned a zero-rank low-rank matrix.")
  V <- s$v[, seq_len(k), drop = FALSE]
  scores <- L %*% V
  eig <- s$d[seq_len(k)]^2 / max(1, nrow(L) - 1)
  .new_pca_fit(prep$raw, L, scores, V, eig, "rpca", prep, call, k,
               extra = list(engine = "internal Principal Component Pursuit (IALM)",
                            low_rank = L, total_variance = sum(apply(L,2,stats::var)), variance_partition_valid = TRUE, sparse = S, reconstruction_processed = L,
                            lambda = lambda, iterations = it, converged = converged,
                            relative_residual = err), orthogonal = TRUE)
}

.pca_kernel_matrix <- function(X, Y = NULL, kernel = "rbf", sigma = NULL,
                               degree = 2, coef0 = 1) {
  if (is.null(Y)) Y <- X
  if (kernel == "linear") return(X %*% t(Y))
  if (kernel == "poly") return((X %*% t(Y) + coef0)^degree)
  if (kernel == "rbf") {
    if (is.null(sigma)) {
      D <- as.matrix(stats::dist(X))
      med <- stats::median(D[D > 0], na.rm = TRUE)
      if (!is.finite(med) || med <= 0) med <- 1
      sigma <- 1 / (2 * med^2)
    }
    x2 <- rowSums(X^2); y2 <- rowSums(Y^2)
    D2 <- outer(x2, y2, "+") - 2 * X %*% t(Y)
    return(exp(-sigma * pmax(D2, 0)))
  }
  .pca_stop("Unknown kernel: ", kernel)
}

.pca_fit_kernel <- function(X, prep, ncomp, call = NULL,
                            kernel = c("rbf", "poly", "linear"), sigma = NULL,
                            degree = 2, coef0 = 1, eigen_tol = 1e-10) {
  kernel <- match.arg(kernel)
  K <- .pca_kernel_matrix(X, kernel = kernel, sigma = sigma, degree = degree, coef0 = coef0)
  if (kernel == "rbf" && is.null(sigma)) {
    D <- as.matrix(stats::dist(X)); med <- stats::median(D[D > 0], na.rm = TRUE)
    if (!is.finite(med) || med <= 0) med <- 1
    sigma <- 1 / (2 * med^2)
  }
  n <- nrow(K)
  one <- matrix(1 / n, n, n)
  Kc <- K - one %*% K - K %*% one + one %*% K %*% one
  ee <- eigen((Kc + t(Kc)) / 2, symmetric = TRUE)
  keep <- which(ee$values > eigen_tol * max(ee$values, 1))
  k <- min(ncomp, length(keep))
  if (k < 1L) .pca_stop("No positive kernel eigenvalues were retained.")
  vals <- ee$values[seq_len(k)]
  alpha <- ee$vectors[, seq_len(k), drop = FALSE] %*% diag(1 / sqrt(vals), nrow = k)
  scores <- Kc %*% alpha
  colnames(scores) <- .pca_component_names(k)
  K_colmean <- colMeans(K)
  K_grand <- mean(K)
  train <- X
  pred_fun <- function(Xnew) {
    Knew <- .pca_kernel_matrix(Xnew, train, kernel = kernel, sigma = sigma, degree = degree, coef0 = coef0)
    rowmean_new <- rowMeans(Knew)
    Knewc <- sweep(Knew, 2, K_colmean, "-")
    Knewc <- sweep(Knewc, 1, rowmean_new, "-") + K_grand
    Knewc %*% alpha
  }
  pseudo_loadings <- NULL
  .new_pca_fit(prep$raw, X, scores, pseudo_loadings, vals / max(1, n - 1), "kernel", prep, call, k,
               extra = list(engine = "internal kernel PCA", kernel = kernel, sigma = sigma,
                            total_variance = sum(pmax(ee$values,0))/max(1,n-1), variance_partition_valid = TRUE,
                            degree = degree, coef0 = coef0, alpha = alpha,
                            kernel_matrix = K, centered_kernel = Kc,
                            predict_function = pred_fun,
                            warning = "Kernel PCs live in feature space; ordinary variable loadings are not defined."),
               orthogonal = TRUE)
}

.pca_fit_randomized <- function(X, prep, ncomp, call = NULL,
                                backend = c("auto","irlba","internal"),
                                oversample = 10L, power = 2L, seed = NULL, ...) {
  if (!is.null(seed)) set.seed(seed)
  backend <- match.arg(backend)
  k <- min(ncomp, .pca_rank_limit(X, centered = isTRUE(prep$center)))
  if (backend == "auto") backend <- if (requireNamespace("irlba",quietly=TRUE)) "irlba" else "internal"
  if (backend == "irlba") {
    .pca_require("irlba","randomized/truncated SVD")
    dmin <- min(dim(X))
    # irlba warns when the requested rank is a large fraction of the smallest
    # dimension; in that regime a standard SVD is the statistically correct tool.
    if (k >= max(1L, floor(0.5 * dmin))) {
      sb <- svd(X, nu = k, nv = k)
      backend_label <- "base::svd (requested rank too large for truncated SVD)"
    } else {
      sb <- irlba::irlba(X,nv=k,nu=k,...)
      backend_label <- "irlba truncated/randomized SVD"
    }
    V <- sb$v[,seq_len(k),drop=FALSE]
    U <- sb$u[,seq_len(k),drop=FALSE]
    d <- sb$d[seq_len(k)]
  } else {
    l <- min(ncol(X), max(k, k + as.integer(oversample)))
    Omega <- matrix(stats::rnorm(ncol(X) * l), ncol(X), l)
    Y <- X %*% Omega
    for (q in seq_len(max(0L, as.integer(power)))) Y <- X %*% (crossprod(X, Y))
    Q <- qr.Q(qr(Y))
    B <- crossprod(Q, X)
    sb <- svd(B, nu = k, nv = k)
    U <- Q %*% sb$u[, seq_len(k), drop = FALSE]
    V <- sb$v[, seq_len(k), drop = FALSE]
    d <- sb$d[seq_len(k)]
    backend_label <- "internal truncated/randomized SVD"
  }
  scores <- X %*% V
  eig <- d^2 / max(1, nrow(X) - 1)
  .new_pca_fit(prep$raw, X, scores, V, eig, "randomized", prep, call, k,
               extra = list(engine = backend_label, left_vectors = U,
                            singular_values = d, oversample = oversample, power = power,
                            variance_partition_valid=TRUE),
               orthogonal = TRUE)
}

.pca_fit_logistic <- function(data, ncomp, call = NULL, m = 4, ...) {
  X <- .pca_as_numeric_matrix(data, allow_na = FALSE)
  if (!all(X %in% c(0, 1))) .pca_stop("Logistic PCA requires a binary 0/1 matrix.")
  if (ncol(X) < 2L) .pca_stop("Logistic PCA requires at least two variables.")
  logistic_rank <- min(nrow(X), ncol(X) - 1L)
  if (is.null(ncomp)) ncomp <- min(2L, logistic_rank)
  ncomp <- max(1L, min(as.integer(ncomp), logistic_rank))
  .pca_require("logisticPCA", "logistic PCA")
  res <- logisticPCA::logisticPCA(X, k = ncomp, m = m, ...)
  # logisticPCA documents U as the loading matrix and PCs as the fitted
  # component scores. Use those backend quantities directly rather than
  # reconstructing a surrogate Gaussian PCA score map.
  loadings <- as.matrix(res$U)
  scores <- as.matrix(res$PCs)
  if (is.null(loadings) || is.null(scores)) {
    .pca_stop("The logisticPCA backend object did not expose U loadings and PCs scores.")
  }
  k <- min(ncomp, ncol(loadings), ncol(scores))
  loadings <- loadings[, seq_len(k), drop = FALSE]
  scores <- scores[, seq_len(k), drop = FALSE]
  eig <- apply(scores, 2, stats::var)
  prep <- list(raw = X, data = X, center = FALSE, center_vector = NULL, scale_method = "none",
               scale_vector = NULL, transform = "none", variable_names = colnames(X),
               observation_names = rownames(X), audit = NULL)
  pred_fun <- function(Xnew) {
    as.matrix(stats::predict(res, newdata = Xnew, type = "PCs"))
  }
  fitted_fun <- function(type = c("response", "link"), ...) {
    type <- match.arg(type)
    as.matrix(stats::fitted(res, type = type, ...))
  }
  .new_pca_fit(X, X, scores, loadings, eig, "logistic", prep, call, k,
               extra = list(engine = "logisticPCA::logisticPCA", backend_object = res,
                            variance_partition_valid = FALSE, deviance_based = TRUE,
                            proportion_deviance_explained = res$prop_deviance_expl %||% NA_real_,
                            predict_function = pred_fun,
                            fitted_function = fitted_fun,
                            warning = paste(
                              "Logistic PCA minimizes binomial deviance in natural-parameter geometry.",
                              "Score variances are descriptive and must not be interpreted as ordinary Gaussian PCA explained variance."
                            )),
               orthogonal = TRUE)
}

.pca_fit_glmpca <- function(data, ncomp, call = NULL,
                            fam = c("poi", "nb", "nb2", "binom"), ...) {
  X <- .pca_as_numeric_matrix(data, allow_na = FALSE)
  fam <- match.arg(fam)
  if (any(X < 0)) .pca_stop("GLM-PCA requires non-negative count/binomial data.")
  if (fam == "binom" && any(abs(X - round(X)) > .Machine$double.eps^0.5)) {
    .pca_stop("Binomial GLM-PCA requires integer-valued counts.")
  }
  if (is.null(ncomp)) ncomp <- min(2L, .pca_rank_limit(X, centered = FALSE))
  ncomp <- max(1L, min(as.integer(ncomp), .pca_rank_limit(X, centered = FALSE)))
  .pca_require("glmpca", "GLM-PCA")
  # glmpca expects features in rows and observations in columns, while pcaLab
  # consistently stores observations in rows and variables/features in columns.
  res <- glmpca::glmpca(t(X), L = ncomp, fam = fam, ...)
  scores <- as.matrix(res$factors)
  loadings <- as.matrix(res$loadings)
  if (nrow(scores) != nrow(X) || nrow(loadings) != ncol(X)) {
    .pca_stop("The glmpca backend returned dimensions inconsistent with the pcaLab observation-by-variable convention.")
  }
  k <- min(ncomp, ncol(scores), ncol(loadings))
  scores <- scores[, seq_len(k), drop = FALSE]
  loadings <- loadings[, seq_len(k), drop = FALSE]
  eig <- apply(scores, 2, stats::var)
  rownames(loadings) <- colnames(X)
  rownames(scores) <- rownames(X)
  prep <- list(raw = X, data = X, center = FALSE, center_vector = NULL, scale_method = "none",
               scale_vector = NULL, transform = "none", variable_names = colnames(X),
               observation_names = rownames(X), audit = NULL)
  fitted_fun <- function(...) {
    # predict.glmpca returns features x observations; transpose back to pcaLab's
    # observations x variables convention.
    t(as.matrix(stats::predict(res, ...)))
  }
  .new_pca_fit(X, X, scores, loadings, eig, "glmpca", prep, call, k,
               extra = list(engine = "glmpca::glmpca", backend_object = res, family = fam,
                            variance_partition_valid = FALSE, fitted_function = fitted_fun,
                            predict_function = function(Xnew) {
                              .pca_stop("glmpca does not provide direct factor-score projection for arbitrary new observations; refit or use a dedicated out-of-sample latent-factor procedure.")
                            },
                            deviance_trace = res$dev %||% NULL,
                            deviance_smoothed = res$dev_smooth %||% NULL,
                            offsets = res$offsets %||% NULL,
                            warning = paste(
                              "GLM-PCA uses exponential-family likelihood/deviance geometry.",
                              "Gaussian PCA eigenvalue and explained-variance decision rules are not automatically applicable."
                            )),
               orthogonal = FALSE)
}

.pca_helmert_basis <- function(p) {
  H <- stats::contr.helmert(p)
  Q <- qr.Q(qr(H))
  Q[, seq_len(p - 1L), drop = FALSE]
}

.pca_fit_compositional <- function(data, center = TRUE, scale = FALSE, ncomp = NULL,
                                   call = NULL, coordinate = c("ilr", "clr"), pseudocount = NULL,
                                   transform = NULL) {
  X <- .pca_as_numeric_matrix(data, allow_na = FALSE)
  if (ncol(X) < 2L) .pca_stop("Compositional PCA requires at least two parts.")
  if (any(X < 0)) .pca_stop("Compositional PCA requires non-negative parts.")
  rs0 <- rowSums(X)
  if (any(!is.finite(rs0) | rs0 <= 0)) .pca_stop("Every composition must have a positive finite row sum.")
  if (!is.null(pseudocount) && (!is.numeric(pseudocount) || length(pseudocount) != 1L || !is.finite(pseudocount) || pseudocount <= 0))
    .pca_stop("pseudocount must be a single positive finite number.")
  if (!is.null(transform)) coordinate <- transform
  coordinate <- match.arg(coordinate, c("ilr","clr"))
  if (any(X <= 0)) {
    if (is.null(pseudocount)) .pca_stop("Zeros detected. Supply a scientifically justified pseudocount or replace zeros before compositional PCA.")
    X <- X + pseudocount
  }
  X <- X / rowSums(X)
  logX <- log(X)
  clr <- sweep(logX, 1, rowMeans(logX), "-")
  if (coordinate == "ilr") {
    basis <- .pca_helmert_basis(ncol(X))
    Z <- clr %*% basis
    colnames(Z) <- paste0("ilr", seq_len(ncol(Z)))
  } else {
    basis <- diag(ncol(X))
    Z <- clr
    colnames(Z) <- colnames(X)
  }
  # clr coordinates have one exact linear dependency (sum to zero), so at most
  # p-1 nonzero compositional directions are meaningful. ILR already has p-1 columns.
  max_comp <- min(nrow(Z) - 1L, if (coordinate == "clr") ncol(Z) - 1L else ncol(Z))
  if (is.null(ncomp)) ncomp <- max_comp else ncomp <- min(as.integer(ncomp), max_comp)
  fit <- pca_fit(Z, method = "classical", center = center, scale = scale, ncomp = ncomp)
  fit$method <- "compositional"
  fit$engine <- paste0("internal ", coordinate, " + PCA")
  fit$data <- X
  fit$extra$composition_transform <- coordinate
  fit$extra$coordinate <- coordinate
  fit$extra$ilr_basis <- basis
  fit$extra$pseudocount <- pseudocount
  fit$extra$part_loadings <- if (coordinate == "ilr") basis %*% fit$loadings else fit$loadings
  rownames(fit$extra$part_loadings) <- colnames(X)
  colnames(fit$extra$part_loadings) <- colnames(fit$loadings)
  part_names <- colnames(X)
  fit$extra$input_transform <- function(newdata) {
    A <- .pca_as_numeric_matrix(newdata, allow_na = FALSE)
    if (ncol(A) != ncol(X)) .pca_stop("New compositional data have the wrong number of parts.")
    if (any(A < 0)) .pca_stop("Compositional prediction requires non-negative parts.")
    if (any(A <= 0)) {
      if (is.null(pseudocount)) .pca_stop("Zeros detected in new compositional data; the fitted model did not use a pseudocount.")
      A <- A + pseudocount
    }
    rs <- rowSums(A)
    if (any(!is.finite(rs) | rs <= 0)) .pca_stop("Every composition must have a positive finite row sum.")
    A <- A / rs
    LA <- log(A)
    CA <- sweep(LA, 1, rowMeans(LA), "-")
    if (coordinate == "ilr") CA %*% basis else CA
  }
  fit$extra$original_scale_function <- function(coord) {
    C <- if (coordinate == "ilr") as.matrix(coord) %*% t(basis) else as.matrix(coord)
    A <- exp(C - apply(C, 1, max))
    A <- A / rowSums(A)
    colnames(A) <- part_names
    A
  }
  fit$call <- call
  fit
}

.pca_fit_nlpca <- function(X, prep, ncomp, call = NULL, ...) {
  .pca_require("pcaMethods", "nonlinear PCA")
  # pcaMethods implements inverse nonlinear PCA. The nonlinear score map is
  # retained as the authoritative representation; linear loadings, when the
  # backend exposes them, are provided only as auxiliary descriptors.
  res <- pcaMethods::pca(X, method = "nlpca", nPcs = ncomp,
                         center = FALSE, scale = "none", ...)
  scores <- as.matrix(pcaMethods::scores(res))
  backend_loadings <- tryCatch(as.matrix(pcaMethods::loadings(res)), error = function(e) NULL)
  eig <- apply(scores, 2, stats::var, na.rm = TRUE)
  k <- min(ncomp, ncol(scores), length(eig))
  out <- .new_pca_fit(prep$raw, X, scores[, seq_len(k), drop = FALSE],
                      NULL, eig[seq_len(k)], "nlpca", prep, call, k,
                      extra = list(engine = "pcaMethods::nlpca", backend_object = res, variance_partition_valid = FALSE,
                                   backend_loadings = backend_loadings,
                                   nonlinear = TRUE,
                                   note = "Nonlinear component scores are primary; ordinary linear-loading geometry does not generally apply."),
                      orthogonal = FALSE)
  out
}

.pca_fit_shrinkage <- function(X, prep, ncomp, call = NULL, lambda = NULL, ...) {
  .pca_require("corpcor", "shrinkage PCA")
  if (anyNA(X)) .pca_stop("Shrinkage PCA requires complete data.")
  # corpcor estimates a positive-definite shrinkage covariance matrix, useful
  # when p is large relative to n or the sample covariance is ill-conditioned.
  center_shrink <- colMeans(X)
  Xc <- sweep(X, 2, center_shrink, "-")
  S <- if (is.null(lambda)) {
    corpcor::cov.shrink(Xc, verbose = FALSE, ...)
  } else {
    if (!is.numeric(lambda) || length(lambda) != 1L || !is.finite(lambda) || lambda < 0 || lambda > 1)
      .pca_stop("lambda must be NULL or a scalar in [0, 1].")
    corpcor::cov.shrink(Xc, lambda = lambda, verbose = FALSE, ...)
  }
  ee <- eigen(S, symmetric = TRUE)
  # Although shrinkage can make the p x p covariance estimate full rank, the
  # centered observation score matrix contains at most min(p, n - 1)
  # independent directions. Do not report additional artificial score axes.
  score_rank <- min(ncol(X), max(1L, nrow(X) - 1L))
  k <- min(ncomp, score_rank, length(ee$values))
  V <- ee$vectors[, seq_len(k), drop = FALSE]
  rownames(V) <- colnames(X)
  scores <- Xc %*% V
  eig <- pmax(ee$values[seq_len(k)], 0)
  pred_fun <- function(Xnew) sweep(as.matrix(Xnew), 2, center_shrink, "-") %*% V
  .new_pca_fit(prep$raw, X, scores, V, eig, "shrinkage", prep, call, k,
               extra = list(engine = "corpcor::cov.shrink", shrinkage_covariance = S, total_variance = sum(diag(S)), variance_partition_valid = TRUE,
                            lambda = attr(S, "lambda"), lambda_var = attr(S, "lambda.var"),
                            projection_center = center_shrink, reconstruction_intercept = center_shrink,
                            predict_function = pred_fun,
                            note = "Eigenvectors are derived from a positive-definite shrinkage covariance estimate."),
               orthogonal = TRUE)
}
