# pca_fit class ------------------------------------------------------------

.new_pca_fit <- function(raw_data, processed_data, scores, loadings, eigenvalues,
                         method, preprocessing, call = NULL, ncomp = NULL,
                         extra = list(), orthogonal = TRUE) {
  scores <- as.matrix(scores)
  loadings <- if (is.null(loadings)) NULL else as.matrix(loadings)
  eigenvalues <- as.numeric(eigenvalues)
  k <- min(length(eigenvalues), ncol(scores))
  if (!is.null(ncomp)) k <- min(k, as.integer(ncomp))
  if (k < 1L) .pca_stop("The fitted model contains no retained components.")
  scores <- scores[, seq_len(k), drop = FALSE]
  eigenvalues <- eigenvalues[seq_len(k)]
  if (!is.null(loadings) && ncol(loadings) >= k) loadings <- loadings[, seq_len(k), drop = FALSE]
  cn <- .pca_component_names(k)
  colnames(scores) <- cn
  if (!is.null(loadings)) {
    colnames(loadings) <- cn
    if (is.null(rownames(loadings))) rownames(loadings) <- colnames(processed_data)
  }
  names(eigenvalues) <- cn
  metrics <- .pca_metric_tables(processed_data, scores, loadings, eigenvalues)
  partition_valid <- extra$variance_partition_valid %||% orthogonal
  total_variance <- extra$total_variance %||% NA_real_
  if (!is.finite(total_variance) && isTRUE(partition_valid) && nrow(processed_data) > 1L && !anyNA(processed_data)) {
    total_variance <- .pca_total_inertia(processed_data, centered = isTRUE(preprocessing$center))
  }
  if (is.finite(total_variance) && total_variance > 0) {
    metrics$pve <- eigenvalues / total_variance
    metrics$cumulative <- if (isTRUE(partition_valid)) cumsum(metrics$pve) else rep(NA_real_, length(eigenvalues))
  } else if (!isTRUE(partition_valid)) {
    metrics$pve <- rep(NA_real_, length(eigenvalues))
    metrics$cumulative <- rep(NA_real_, length(eigenvalues))
  }
  extra$total_variance <- total_variance
  extra$variance_partition_valid <- isTRUE(partition_valid)
  object <- list(
    call = call,
    method = method,
    engine = extra$engine %||% method,
    data = raw_data,
    processed_data = processed_data,
    preprocessing = preprocessing,
    scores = scores,
    loadings = loadings,
    eigenvalues = eigenvalues,
    sdev = sqrt(pmax(eigenvalues, 0)),
    variance_explained = metrics$pve,
    cumulative_variance = metrics$cumulative,
    correlation_loadings = metrics$correlation_loadings,
    cos2 = metrics$cos2,
    contributions = metrics$contributions,
    communalities = metrics$communalities,
    ncomp = k,
    orthogonal = orthogonal,
    extra = extra,
    inference = NULL,
    bootstrap = NULL,
    stability = NULL,
    diagnostics = NULL,
    ncomp_selection = NULL,
    warnings = character(),
    version = "0.1.0"
  )
  class(object) <- "pca_fit"
  object
}

`%||%` <- function(x, y) if (is.null(x)) y else x

#' @export
#' @method print pca_fit
#' @rdname pca_fit
#' @param x A \code{pca_fit} object.
print.pca_fit <- function(x, ...) {
  cat("pcaLab fit\n")
  cat("  Method: ", x$method, "\n", sep = "")
  cat("  Observations: ", nrow(x$processed_data), "\n", sep = "")
  cat("  Variables: ", ncol(x$processed_data), "\n", sep = "")
  cat("  Components retained: ", x$ncomp, "\n", sep = "")
  if (length(x$variance_explained) && any(is.finite(x$variance_explained))) {
    cat("  Variance explained by retained components: ",
        sprintf("%.1f%%", 100 * sum(x$variance_explained, na.rm = TRUE)), "\n", sep = "")
  } else {
    cat("  Variance partition: not defined for this engine\n")
  }
  invisible(x)
}

#' @export
#' @method summary pca_fit
#' @rdname pca_fit
#' @param object A \code{pca_fit} object.
summary.pca_fit <- function(object, ...) {
  tab <- data.frame(
    component = .pca_component_names(object$ncomp),
    eigenvalue = object$eigenvalues,
    variance = object$variance_explained,
    cumulative = object$cumulative_variance,
    stringsAsFactors = FALSE
  )
  out <- list(method = object$method, dimensions = dim(object$processed_data), components = tab,
              diagnostics = object$diagnostics, inference = object$inference)
  class(out) <- "summary.pca_fit"
  out
}

#' @export
#' @method print summary.pca_fit
#' @rdname pca_fit
#' @param x A \code{summary.pca_fit} object.
print.summary.pca_fit <- function(x, ...) {
  cat("pcaLab summary\n")
  cat("Method: ", x$method, "\n", sep = "")
  print(x$components, row.names = FALSE)
  invisible(x)
}

#' Reconstruct observations from retained principal components
#'
#' @param fit A `pca_fit` object.
#' @param ncomp Number of components to use.
#' @param original_scale Return reconstruction in original measurement scale.
#' @return Reconstructed matrix.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' rec <- pca_reconstruct(fit, ncomp = 2, original_scale = TRUE)
#' dim(rec)
#' # rank-2 approximation error in the processed space
#' sqrt(mean((fit$processed_data - pca_reconstruct(fit, 2, FALSE))^2))
#' @export
pca_reconstruct <- function(fit, ncomp = fit$ncomp, original_scale = TRUE) {
  stopifnot(inherits(fit, "pca_fit"))
  k <- min(as.integer(ncomp), fit$ncomp)
  if (fit$method %in% c("logistic", "glmpca") && !is.null(fit$extra$fitted_function)) {
    if (k != fit$ncomp)
      .pca_stop("Generalized PCA reconstruction is available only at the fitted latent rank for this backend.")
    R <- as.matrix(fit$extra$fitted_function())
    colnames(R) <- colnames(fit$processed_data)
    rownames(R) <- rownames(fit$processed_data)
    return(R)
  }
  if (!is.null(fit$extra$reconstruction_function)) {
    R <- fit$extra$reconstruction_function(k)
  } else if (!is.null(fit$extra$reconstruction_processed) && k == fit$ncomp) {
    R <- fit$extra$reconstruction_processed
  } else if (fit$method %in% c("kernel","nlpca","logistic","glmpca")) {
    .pca_stop("This engine has no ordinary linear reconstruction in the original measurement space. Use its backend-specific fitted values or latent-scale output.")
  } else if (!is.null(fit$extra$inverse_loadings)) {
    R <- fit$scores[, seq_len(k), drop = FALSE] %*%
      t(fit$extra$inverse_loadings[, seq_len(k), drop = FALSE])
  } else if (!is.null(fit$loadings)) {
    R <- fit$scores[, seq_len(k), drop = FALSE] %*% t(fit$loadings[, seq_len(k), drop = FALSE])
  } else {
    .pca_stop("This engine does not expose a linear reconstruction map.")
  }
  if (!is.null(fit$extra$reconstruction_intercept))
    R <- sweep(R, 2, fit$extra$reconstruction_intercept, "+")
  colnames(R) <- colnames(fit$processed_data)
  rownames(R) <- rownames(fit$processed_data)
  if (isTRUE(original_scale)) {
    R <- .pca_unprocess(R, fit$preprocessing)
    if (!is.null(fit$extra$original_scale_function)) R <- fit$extra$original_scale_function(R)
  }
  R
}

#' @export
#' @method fitted pca_fit
#' @rdname pca_fit
#' @param object A \code{pca_fit} object.
fitted.pca_fit <- function(object, ...) {
  if (!is.null(object$extra$fitted_function)) return(object$extra$fitted_function(...))
  pca_reconstruct(object, ...)
}

#' @export
#' @method residuals pca_fit
#' @rdname pca_fit
#' @param object A \code{pca_fit} object.
#' @param original_scale Return residuals in the original measurement scale.
residuals.pca_fit <- function(object, original_scale = TRUE, ...) {
  target <- if (isTRUE(original_scale)) object$data else object$processed_data
  rec <- pca_reconstruct(object, original_scale = original_scale)
  target - rec
}

#' @export
#' @method predict pca_fit
#' @rdname pca_fit
#' @param object A \code{pca_fit} object.
#' @param newdata New observations with the original variables.
predict.pca_fit <- function(object, newdata, ncomp = object$ncomp, ...) {
  stopifnot(inherits(object, "pca_fit"))
  Xin <- newdata
  if (!is.null(object$extra$input_transform)) Xin <- object$extra$input_transform(newdata)
  X <- .pca_process_newdata(Xin, object$preprocessing)
  k <- min(as.integer(ncomp), object$ncomp)
  if (!is.null(object$extra$predict_function)) {
    projected <- as.matrix(object$extra$predict_function(X))
    if (ncol(projected) < k) .pca_stop("Backend prediction returned fewer components than requested.")
    return(projected[, seq_len(k), drop = FALSE])
  }
  if (is.null(object$loadings)) .pca_stop("This engine does not expose a projection matrix for new observations.")
  if (!is.null(object$extra$projection_center)) X <- sweep(X, 2, object$extra$projection_center, "-")
  X %*% object$loadings[, seq_len(k), drop = FALSE]
}

#' @export
#' @method plot pca_fit
#' @rdname pca_fit
#' @param x A \code{pca_fit} object.
plot.pca_fit <- function(x, ...) pca_plot(x, ...)
