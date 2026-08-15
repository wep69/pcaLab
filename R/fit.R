#' Fit Principal Component Analysis and advanced variants
#'
#' A unified interface for classical and advanced PCA engines.
#'
#' @param data Numeric matrix/data frame, except where an engine documents a specialized input.
#' @param method PCA engine. See `pca_capabilities()`.
#' @param center Logical; center variables before fitting.
#' @param scale Scaling method accepted by `pca_preprocess()`.
#' @param ncomp Number of retained components. `NULL` uses the maximum meaningful rank for most engines.
#' @param transform Optional element-wise preprocessing transformation: `"none"`, `"log1p"`, or `"sqrt"`. Specialized data-type engines may require `"none"`.
#' @param weights Optional observation weights for weighted PCA.
#' @param ... Engine-specific arguments.
#' @return An object of class `pca_fit`.
#' @examples
#' # Classical standardized PCA on Fisher's iris measurements
#' fit <- pca_fit(iris[, 1:4], method = "classical", center = TRUE, scale = TRUE)
#' summary(fit)
#' head(predict(fit, iris[1:5, 1:4]))
#'
#' # Observation-weighted PCA
#' pca_fit(iris[, 1:4], method = "weighted", ncomp = 2,
#'         weights = seq_len(nrow(iris)))
#'
#' # Compositional PCA on a small parts matrix
#' parts <- matrix(c(1, 2, 3, 2, 5, 4, 4, 3, 2), nrow = 3, byrow = TRUE)
#' pca_fit(parts, method = "compositional", coordinate = "ilr", ncomp = 2)
#' @export
pca_fit <- function(data,
                    method = c("classical", "weighted", "nipals", "em", "ppca", "bayesian",
                               "robust", "cellwise", "sparse", "robust_sparse", "rpca",
                               "kernel", "nlpca", "shrinkage", "logistic", "glmpca", "compositional", "functional",
                               "dynamic", "multilevel", "multiblock", "randomized", "incremental"),
                    center = TRUE, scale = FALSE, ncomp = NULL,
                    transform = c("none", "log1p", "sqrt"), weights = NULL, ...) {
  method <- match.arg(method)
  transform <- match.arg(transform)
  call <- match.call()
  dots <- list(...)
  specialized_no_transform <- c("compositional", "functional", "logistic", "glmpca", "multilevel", "incremental")
  if (method %in% specialized_no_transform && transform != "none") {
    .pca_stop("method='", method, "' uses its own data geometry and currently requires transform='none'.")
  }
  if (method == "multiblock") return(do.call(pca_multiblock, c(list(blocks = data, ncomp = ncomp, center = center, scale = scale, transform = transform), dots)))
  if (method == "incremental") {
    scale_method <- .pca_scale_label(scale)
    if (!scale_method %in% c("none", "uv"))
      .pca_stop("Incremental PCA currently supports scale='none' or unit-variance scaling only.")
    state <- pca_incremental_init(ncol(.pca_as_numeric_matrix(data)), center = center, scale = identical(scale_method, "uv"))
    state <- pca_incremental_update(state, data)
    return(pca_incremental_finalize(state, ncomp = ncomp))
  }
  if (method == "functional") return(do.call(.pca_fit_functional, c(list(data = data, center = center, scale = scale, ncomp = ncomp, call = quote(force(call))), dots)))
  if (method == "multilevel") return(do.call(.pca_fit_multilevel, c(list(data = data, center = center, scale = scale, ncomp = ncomp, call = quote(force(call)), transform = transform), dots)))
  if (method == "dynamic") return(do.call(.pca_fit_dynamic, c(list(data = data, center = center, scale = scale, ncomp = ncomp, call = quote(force(call)), transform = transform), dots)))
  if (method == "compositional") return(do.call(.pca_fit_compositional, c(list(data = data, center = center, scale = scale, ncomp = ncomp, call = quote(force(call))), dots)))
  if (method == "logistic") return(do.call(.pca_fit_logistic, c(list(data = data, ncomp = ncomp, call = quote(force(call))), dots)))
  if (method == "glmpca") return(do.call(.pca_fit_glmpca, c(list(data = data, ncomp = ncomp, call = quote(force(call))), dots)))

  allow_na <- method %in% c("nipals", "em", "ppca", "bayesian", "cellwise")
  prep <- pca_preprocess(data, center = center, scale = scale, transform = transform,
                         na_action = if (allow_na) "keep" else "fail")
  X <- prep$data
  kmax <- .pca_rank_limit(X, centered = isTRUE(prep$center))
  if (is.null(ncomp)) ncomp <- kmax
  ncomp <- max(1L, min(as.integer(ncomp), kmax))

  fit <- switch(method,
    classical = .pca_fit_classical(X, prep, ncomp, call),
    weighted = .pca_fit_weighted(X, prep, ncomp, call, weights = weights, ...),
    nipals = .pca_fit_nipals(X, prep, ncomp, call, ...),
    em = .pca_fit_em(X, prep, ncomp, call, ...),
    ppca = .pca_fit_ppca(X, prep, ncomp, call, ...),
    bayesian = .pca_fit_bayesian(X, prep, ncomp, call, ...),
    robust = .pca_fit_robust(X, prep, ncomp, call, ...),
    cellwise = .pca_fit_cellwise(X, prep, ncomp, call, ...),
    sparse = .pca_fit_sparse(X, prep, ncomp, call, ...),
    robust_sparse = .pca_fit_robust_sparse(X, prep, ncomp, call, ...),
    rpca = .pca_fit_rpca(X, prep, ncomp, call, ...),
    kernel = .pca_fit_kernel(X, prep, ncomp, call, ...),
    nlpca = .pca_fit_nlpca(X, prep, ncomp, call, ...),
    shrinkage = .pca_fit_shrinkage(X, prep, ncomp, call, ...),
    randomized = .pca_fit_randomized(X, prep, ncomp, call, ...),
    .pca_stop("Unsupported method: ", method)
  )
  fit
}
