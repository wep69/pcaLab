# Clustering based on PCA scores -----------------------------------------------

# Internal: extract scores from fit or raw data
.pca_cluster_scores <- function(x, dims = NULL) {
  sc <- if (inherits(x, "pca_fit")) x$scores else as.matrix(x)
  if (!is.null(dims)) {
    if (any(dims > ncol(sc))) .pca_stop("dims exceed the ", ncol(sc), " available score dimensions.")
    sc <- sc[, dims, drop = FALSE]
  }
  sc
}

# Internal: silhouette wrapper
.pca_cluster_silhouette <- function(partition, sc) {
  if (!requireNamespace("cluster", quietly = TRUE)) return(rep(NA_real_, length(partition)))
  partition <- as.integer(partition)
  # Remove NAs from partition and sc
  valid <- !is.na(partition)
  if (!any(valid)) return(rep(NA_real_, length(partition)))
  sil <- tryCatch(cluster::silhouette(partition[valid], dist(sc[valid, , drop = FALSE]))[, 3], error = function(e) rep(NA_real_, sum(valid)))
  result <- rep(NA_real_, length(partition))
  result[valid] <- as.vector(sil)
  result
}

# Internal: Calinski-Harabasz index
.pca_cluster_ch <- function(partition, sc) {
  ng <- table(partition)
  k <- length(ng)
  if (k < 2 || any(ng < 2)) return(NA_real_)
  grand <- colMeans(sc)
  p <- ncol(sc)
  between <- as.numeric(sum(ng * vapply(unique(partition), function(g) {
    cm <- colMeans(sc[partition == g, , drop = FALSE])
    sum((cm - grand)^2)
  }, numeric(1))))
  within <- sum(vapply(unique(partition), function(g) {
    idx <- partition == g
    sum((sc[idx, , drop = FALSE] - matrix(colMeans(sc[idx, , drop = FALSE]), nrow = sum(idx), ncol = p, byrow = TRUE))^2)
  }, numeric(1)))
  if (within <= 0) return(NA_real_)
  ((nrow(sc) - k) / (k - 1)) * between / within
}


#' Evaluate clustering across multiple values of k
#'
#' @description Computes internal validation indices for a range of k values
#'   using a specified clustering method.
#'
#' @param x A \code{pca_fit} object or a numeric matrix of scores/data.
#' @param method Clustering method: \code{"kmeans"}, \code{"pam"},
#'   \code{"hclust"}, or \code{"mclust"}.
#' @param k_range Integer vector of candidate k values.
#' @param nstart Number of random starts for k-means.
#' @param B Number of bootstrap replicates for the gap statistic.
#' @param dims Integer vector of score/component indices to use.
#' @param ... Additional arguments passed to the clustering method.
#'
#' @return A \code{pca_cluster_evaluate} object containing a data frame of
#'   evaluation indices per k and the suggested best k.
#' @export
pca_cluster_evaluate <- function(x, method = c("kmeans", "pam", "hclust", "mclust"),
                                  k_range = 2:10, nstart = 25, B = 999,
                                  dims = NULL, ...) {
  method <- match.arg(method)
  sc <- .pca_cluster_scores(x, dims)
  k_range <- sort(unique(k_range[k_range >= 2L & k_range <= nrow(sc) - 1L]))
  if (!length(k_range)) .pca_stop("No valid k in k_range (need at least 2 and n-1).")

  kvals <- numeric(length(k_range))
  sil_vals <- numeric(length(k_range))
  ch_vals  <- numeric(length(k_range))
  wss_vals <- numeric(length(k_range))
  bic_vals <- if (method == "mclust") numeric(length(k_range)) else NULL

  d <- dist(sc)

  for (i in seq_along(k_range)) {
    k <- k_range[i]
    grp <- switch(method,
      kmeans  = kmeans(sc, k, nstart = nstart, ...)$cluster,
      pam     = { .pca_require("cluster", "PAM"); cluster::pam(d, k = k, ...)$clustering },
      hclust  = cutree(hclust(d, method = "ward.D2"), k = k),
      mclust  = { .pca_require("mclust", "model-based clustering"); tryCatch(
                    mclust::Mclust(sc, G = k, ...)$classification,
                    error = function(e) rep(NA_integer_, nrow(sc))) }
    )
    grp <- as.integer(grp)

    # WSS
    ng <- table(grp)
    ng <- ng[ng > 0L]
    wss_vals[i] <- sum(vapply(names(ng), function(g) {
      idx <- grp == as.integer(g)
      if (sum(idx) < 2L) return(0)
      sum((sc[idx, , drop = FALSE] - colMeans(sc[idx, , drop = FALSE]))^2)
    }, numeric(1)))

    # Silhouette
    sil_vals[i] <- mean(.pca_cluster_silhouette(grp, sc), na.rm = TRUE)

    # CH
    ch_vals[i] <- .pca_cluster_ch(grp, sc)

    # BIC for mclust
    if (method == "mclust" && requireNamespace("mclust", quietly = TRUE)) {
      mc <- try(mclust::Mclust(sc, G = k, ...), silent = TRUE)
      bic_vals[i] <- if (!inherits(mc, "try-error")) mc$bic else NA_real_
    }
  }

  tab <- data.frame(k = k_range, wss = round(wss_vals, 2), silhouette = round(sil_vals, 4),
                    ch = round(ch_vals, 2), stringsAsFactors = FALSE)
  if (!is.null(bic_vals)) tab$bic <- round(bic_vals, 2)

  # Gap statistic (always compute when cluster available)
  k_gap <- NA_integer_
  if (requireNamespace("cluster", quietly = TRUE)) {
    gk <- try(cluster::clusGap(sc, FUN = if (method == "kmeans") kmeans else {
      function(x, k) list(cluster = cluster::pam(x, k = k)$clustering)
    }, K.max = max(k_range), B = B, nstart = nstart), silent = TRUE)
    if (!inherits(gk, "try-error")) {
      gdf <- as.data.frame(gk$Tab)
      tab$gap <- round(gdf$gap[seq_along(k_range)], 4)
      tab$gap_se <- round(gdf$SE.sim[seq_along(k_range)], 4)
      if (nrow(gdf) > 1) {
        diff_gap <- gdf$gap[-nrow(gdf)] - gdf$gap[-1]
        diff_se  <- gdf$SE.sim[-nrow(gdf)]
        if (length(diff_gap)) k_gap <- k_range[which.max(diff_gap - diff_se)]
      }
    }
  }

  # Recommended k: max silhouette
  k_sil <- k_range[which.max(sil_vals)]
  # If gap statistic available, prefer gap-maximizer
  best_k <- if (!is.na(k_gap)) {
    .pca_warn("Cluster gap statistic selected k=", k_gap, "; silhouette suggests k=", k_sil, ".")
    k_gap
  } else k_sil

  structure(list(evaluation = tab, method = method, best_k = best_k,
                 k_range = k_range), class = "pca_cluster_evaluate")
}

#' @export
print.pca_cluster_evaluate <- function(x, ...) {
  cat("Cluster evaluation:", x$method, "
")
  print(x$evaluation, row.names = FALSE, ...)
  cat("Suggested k:", x$best_k, "
")
  invisible(x)
}

#' Cluster observations based on PCA scores
#'
#' @description Performs clustering on PCA scores (or any numeric matrix)
#'   using a specified method and optional pre-determined k.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param method Clustering method: \code{\"kmeans\"}, \code{\"pam\"},
#'   \code{\"hclust\"}, \code{\"mclust\"}, or \code{\"dbscan\"}.
#' @param k Number of clusters. If \code{NULL}, 3 is used.
#' @param dims Integer vector of score/component indices to use.
#' @param nstart Number of random starts for k-means.
#' @param ... Additional arguments passed to the method.
#' @return A \code{pca_cluster} object.
#' @examples
#' cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
#' cl
#' table(cl$cluster, iris$Species)
#' @export
# Phase A: Main clustering function ----

#' Cluster observations based on PCA scores
#'
#' @description Performs clustering on PCA scores (or any numeric matrix)
#'   using a specified method and optional pre-determined k.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param method Clustering method: \code{"kmeans"}, \code{"pam"},
#'   \code{"hclust"}, \code{"mclust"}, or \code{"dbscan"}.
#' @param k Number of clusters. If \code{NULL}, a default of 3 is used.
#' @param dims Integer vector of score/component indices to use.
#' @param nstart Number of random starts for k-means.
#' @param ... Additional arguments passed to the method.
#'
#' @return A \code{pca_cluster} object containing the partition, scores used,
#'   and reference to the PCA fit.
#' @export
pca_cluster <- function(x, method = c("kmeans", "pam", "hclust", "mclust", "dbscan"),
                         k = NULL, dims = NULL, nstart = 25, ...) {
  method <- match.arg(method)
  fit <- if (inherits(x, "pca_fit")) x else NULL
  sc <- .pca_cluster_scores(x, dims)

  if (is.null(k) || length(k) == 0L || is.na(k)) k <- 3L
  k <- as.integer(k)
  n <- nrow(sc)

  if (k >= n) .pca_stop("k must be less than the number of observations (", n, ").")

  partition <- switch(method,
    kmeans  = kmeans(sc, k, nstart = nstart, ...)$cluster,
    pam     = { .pca_require("cluster", "PAM"); cluster::pam(sc, k = k, ...)$clustering },
    hclust  = cutree(hclust(dist(sc), method = "ward.D2"), k = k),
    mclust  = { .pca_require("mclust", "model-based clustering");
                tryCatch(mclust::Mclust(sc, G = k, ...)$classification,
                         error = function(e) .pca_stop("mclust failed: ", conditionMessage(e))) },
    dbscan  = { .pca_require("dbscan", "density-based clustering");
                dbscan::dbscan(sc, eps = ...)$cluster }
  )
  partition <- as.integer(partition)

  # Silhouette per observation
  sil_per_obs <- .pca_cluster_silhouette(partition, sc)

  structure(list(
    method = method, k = k, cluster = partition,
    scores = sc, fit = fit, silhouette_per_obs = sil_per_obs,
    n = n, dims = if (!is.null(dims)) dims else seq_len(ncol(sc))
  ), class = "pca_cluster")
}

#' @export
print.pca_cluster <- function(x, ...) {
  cat("PCA-based clustering:", x$method, "with k =", x$k, "
")
  cat("Observations:", x$n, "
")
  cat("Silhouette (mean):", round(mean(x$silhouette_per_obs, na.rm = TRUE), 4), "
")
  cat("Cluster sizes:", paste(table(x$cluster), collapse = ", "), "
")
  invisible(x)
}

#' Compare clustering methods on PCA scores
#'
#' @description Runs multiple clustering methods and returns a comparison table
#'   of internal validation indices plus adjusted Rand index between pairs.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param methods Character vector of methods to compare.
#' @param k Number of clusters.
#' @param dims Integer vector of score/component indices.
#' @param nstart Number of random starts for k-means.
#' @param indices Character vector of indices to report.
#' @param ... Additional arguments.
#' @return A \code{pca_cluster_compare} object.
#' @examples
#' cmp <- pca_cluster_compare(iris[, 1:4], methods = c("kmeans", "pam", "hclust"), k = 3)
#' cmp
#' @export
# Phase B: Compare methods ----

#' Compare clustering methods on PCA scores
#'
#' @description Runs multiple clustering methods and returns a comparison table
#'   of internal validation indices.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param methods Character vector of methods to compare.
#' @param k Number of clusters (recycled to all methods).
#' @param dims Integer vector of score/component indices.
#' @param nstart Number of random starts for k-means.
#' @param indices Character vector of validation indices:
#'   \code{"silhouette"}, \code{"ch"}, \code{"dunn"}, \code{"wss"}, \code{"BIC"}.
#' @param ... Additional arguments passed to methods.
#'
#' @return A \code{pca_cluster_compare} object with comparison table.
#' @export
pca_cluster_compare <- function(x,
                                 methods = c("kmeans", "pam", "hclust"),
                                 k = NULL, dims = NULL, nstart = 25,
                                 indices = c("silhouette", "ch", "wss"),
                                 ...) {
  sc <- .pca_cluster_scores(x, dims)
  if (is.null(k) || length(k) == 0L || is.na(k)) k <- 3L

  results <- list()
  for (m in methods) {
    cl <- try(pca_cluster(sc, method = m, k = k, dims = NULL, nstart = nstart, ...),
              silent = TRUE)
    if (inherits(cl, "try-error")) {
      results[[m]] <- data.frame(method = m, silhouette = NA, ch = NA, wss = NA, stringsAsFactors = FALSE)
      next
    }
    sil <- mean(cl$silhouette_per_obs, na.rm = TRUE)
    ch  <- .pca_cluster_ch(cl$cluster, sc)
    wss <- sum(vapply(unique(cl$cluster), function(g) {
      idx <- cl$cluster == g; if (sum(idx) < 2) return(0)
      colSums((sc[idx, , drop = FALSE] - colMeans(sc[idx, , drop = FALSE]))^2)
    }, numeric(ncol(sc))))
    results[[m]] <- data.frame(method = m, silhouette = round(sil, 4), ch = round(ch, 2),
                                wss = round(wss, 2), stringsAsFactors = FALSE)
  }

  tab <- do.call(rbind, results)
  rownames(tab) <- NULL

  # Rand index between pairs
  rand_pairs <- list()
  for (i in seq_along(methods)) {
    for (j in seq(i + 1, length(methods))) {
      ci <- try(pca_cluster(sc, method = methods[i], k = k, dims = NULL, nstart = nstart, ...), silent = TRUE)
      cj <- try(pca_cluster(sc, method = methods[j], k = k, dims = NULL, nstart = nstart, ...), silent = TRUE)
      if (!inherits(ci, "try-error") && !inherits(cj, "try-error")) {
        n <- length(ci$cluster)
        tab1 <- table(ci$cluster, cj$cluster)
        p <- sum(tab1 * (tab1 - 1)) / 2
        g <- sum(choose(tab1, 2))
        i1 <- sum(choose(table(ci$cluster), 2))
        i2 <- sum(choose(table(cj$cluster), 2))
        n2 <- n * (n - 1) / 2
        rand_pairs[[paste(methods[i], "vs", methods[j])]] <- round((p + n2 - i1 - i2) / n2, 4)
      }
    }
  }

  structure(list(comparison = tab, k = k, rand_index = rand_pairs,
                 scores = sc), class = "pca_cluster_compare")
}

#' @export
print.pca_cluster_compare <- function(x, ...) {
  cat("Cluster comparison at k =", x$k, "

")
  print(x$comparison, row.names = FALSE)
  if (length(x$rand_index)) {
    cat("
Adjusted Rand index between methods:
")
    for (nm in names(x$rand_index)) cat("  ", nm, ":", x$rand_index[[nm]], "
")
  }
  invisible(x)
}

#' Bootstrap cluster stability assessment
#'
#' @description Assesses cluster stability by resampling observations and
#'   re-clustering to build a consensus matrix and measure membership stability.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param method Clustering method.
#' @param k Number of clusters.
#' @param dims Integer vector of score/component indices.
#' @param nboot Number of bootstrap resamples.
#' @param seed Optional random seed.
#' @param ... Additional arguments passed to clustering.
#' @return A \code{pca_cluster_stability} object.
#' @examples
#' st <- pca_cluster_stability(iris[, 1:4], method = "kmeans", k = 3,
#'                             nboot = 49, seed = 1)
#' st
#' @export
# Phase C: Bootstrap stability ----

#' Bootstrap cluster stability assessment
#'
#' @description Assesses cluster stability by resampling observations and
#'   re-clustering to build a consensus matrix and measure membership stability.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param method Clustering method.
#' @param k Number of clusters.
#' @param dims Integer vector of score/component indices.
#' @param nboot Number of bootstrap resamples.
#' @param seed Optional random seed.
#' @param ... Additional arguments passed to clustering.
#'
#' @return A \code{pca_cluster_stability} object with consensus matrix and
#'   stability metrics.
#' @export
pca_cluster_stability <- function(x, method = "kmeans", k = NULL,
                                   dims = NULL, nboot = 999, seed = NULL, ...) {
  if (!is.null(seed)) set.seed(seed)
  sc <- .pca_cluster_scores(x, dims)
  if (is.null(k) || length(k) == 0L || is.na(k)) k <- 3L
  n <- nrow(sc)
  p <- ncol(sc)

  # Reference clustering on full data
  ref <- pca_cluster(sc, method = method, k = k, dims = NULL, nstart = 25, ...)$cluster

  # Consensus matrix (n x n)
  consensus <- matrix(0L, n, n)
  boot_partitions <- matrix(NA_integer_, n, nboot)
  for (b in seq_len(nboot)) {
    idx <- sample.int(n, n, replace = TRUE)
    sb <- sc[idx, , drop = FALSE]
    cl_boot <- try(pca_cluster(sb, method = method, k = k, dims = NULL,
                                nstart = 25, ...)$cluster, silent = TRUE)
    if (inherits(cl_boot, "try-error")) next
    # Map back to original observation indices
    for (ii in seq_len(n)) {
      match_pos <- which(idx == ii)
      if (length(match_pos)) {
        for (jj in match_pos) {
          same <- which(idx == ii & cl_boot == cl_boot[jj])
          consensus[ii, same] <- consensus[ii, same] + 1L
        }
      }
    }
    boot_partitions[idx, b] <- cl_boot
  }

  # Normalize consensus matrix
  counts <- matrix(0L, n, n)
  for (i in seq_len(n)) {
    for (b in seq_len(nboot)) {
      if (!is.na(boot_partitions[i, b])) {
        matches <- which(boot_partitions[, b] == boot_partitions[i, b])
        counts[i, matches] <- counts[i, matches] + 1L
      }
    }
  }
  counts[counts == 0L] <- 1L  # avoid division by zero
  cons_norm <- consensus / counts
  diag(cons_norm) <- 1

  # Stability per observation: proportion of times in majority cluster
  membership_stab <- numeric(n)
  for (i in seq_len(n)) {
    freqs <- table(boot_partitions[i, ])
    membership_stab[i] <- max(freqs) / nboot
  }

  # Cophenetic correlation
  d_orig <- dist(sc)
  d_cons <- as.dist(1 - cons_norm)
  cophen <- try(cor(as.vector(d_orig), as.vector(d_cons), use = "complete.obs"), silent = TRUE)
  cophen <- if (inherits(cophen, "try-error")) NA_real_ else cophen

  # Average silhouette across bootstraps
  sil_means <- numeric(nboot)
  for (b in seq_len(nboot)) {
    valid <- !is.na(boot_partitions[, b])
    if (sum(valid) >= k) {
      sil_means[b] <- mean(.pca_cluster_silhouette(boot_partitions[valid, b], sc[valid, , drop = FALSE]))
    }
  }

  structure(list(
    method = method, k = k, n = n, nboot = nboot,
    consensus_matrix = cons_norm,
    membership_stability = membership_stab,
    mean_stability = mean(membership_stab, na.rm = TRUE),
    cophenetic_correlation = cophen,
    mean_silhouette = mean(sil_means, na.rm = TRUE),
    reference = ref
  ), class = "pca_cluster_stability")
}

#' @export
print.pca_cluster_stability <- function(x, ...) {
  cat("Cluster stability:", x$method, "k =", x$k, "
")
  cat("Bootstrap replicates:", x$nboot, "
")
  cat("Mean membership stability:", round(x$mean_stability, 4), "
")
  cat("Cophenetic correlation:", round(x$cophenetic_correlation, 4), "
")
  cat("Mean silhouette:", round(x$mean_silhouette, 4), "
")
  invisible(x)
}

#' Compute cluster boundaries for PCA score plots
#'
#' @description Computes visual cluster boundaries using Mahalanobis ellipses,
#'   convex hulls, or SVM decision surfaces.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param clustering Integer cluster membership vector.
#' @param method Boundary method: \code{\"ellipse\"}, \code{\"convex\"},
#'   or \code{\"svm\"}.
#' @param level Confidence level for Mahalanobis ellipses (default 0.95).
#' @param dims Integer vector of score/component indices (default 1:2).
#' @param npoints Number of points per ellipse curve.
#' @return A \code{pca_cluster_boundary} object.
#' @examples
#' cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
#' bd <- pca_cluster_boundary(iris[, 1:4], cl$cluster, method = "ellipse")
#' nrow(bd$boundaries)
#' @export
# Phase D: Cluster boundaries ----

#' Compute cluster boundaries for PCA score plots
#'
#' @description Computes visual cluster boundaries using Mahalanobis ellipses,
#'   convex hulls, or SVM decision surfaces.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param clustering Integer cluster membership vector.
#' @param method Boundary method: \code{"ellipse"}, \code{"convex"}, or
#'   \code{"svm"}.
#' @param level Confidence level for Mahalanobis ellipses (default 0.95).
#' @param dims Integer vector of score/component indices (default 1:2).
#' @param npoints Number of points per ellipse curve.
#'
#' @return A \code{pca_cluster_boundary} object with boundary data.
#' @export
pca_cluster_boundary <- function(x, clustering,
                                  method = c("ellipse", "convex", "svm"),
                                  level = 0.95, dims = 1:2, npoints = 200) {
  method <- match.arg(method)
  sc <- .pca_cluster_scores(x, dims)
  if (length(clustering) != nrow(sc)) .pca_stop("clustering length must match number of observations.")
  if (ncol(sc) < 2) .pca_stop("At least 2 score dimensions required for boundaries (dims=", paste(dims, collapse = ","), ").")
  clustering <- as.factor(clustering)
  lev <- levels(clustering)
  coords <- data.frame(x = sc[, 1], y = sc[, 2], cluster = as.character(clustering))

  boundaries <- list()
  for (lv in lev) {
    idx <- clustering == lv
    if (sum(idx) < 3) next
    pts <- sc[idx, 1:2, drop = FALSE]
    if (method == "ellipse") {
      cen <- colMeans(pts)
      S <- cov(pts) * (nrow(pts) - 1) / nrow(pts)
      eig <- eigen(S, symmetric = TRUE)
      A <- eig$vectors %*% diag(sqrt(pmax(eig$values, 0)), 2)
      rad <- sqrt(stats::qchisq(level, df = 2))
      th <- seq(0, 2 * pi, length.out = npoints + 1)[-1]
      circ <- cbind(cos(th), sin(th))
      boundary <- sweep(rad * circ %*% t(A), 2, cen, "+")
    } else if (method == "convex") {
      hull_idx <- chull(pts)
      boundary <- pts[hull_idx, , drop = FALSE]
      boundary <- rbind(boundary, boundary[1, , drop = FALSE])
    } else if (method == "svm") {
      if (!requireNamespace("e1071", quietly = TRUE))
        .pca_stop("SVM boundaries require package 'e1071'.")
      # Build binary SVM for each level vs rest
      for (lv2 in lev) {
        if (lv2 == lv) next
        class_1 <- sc[clustering == lv, 1:2, drop = FALSE]
        class_2 <- sc[clustering == lv2, 1:2, drop = FALSE]
        if (nrow(class_1) < 2 || nrow(class_2) < 2) next
        df <- data.frame(x = c(class_1[, 1], class_2[, 1]),
                         y = c(class_1[, 2], class_2[, 2]),
                         class = factor(c(rep(lv, nrow(class_1)), rep(lv2, nrow(class_2)))))
        fit_svm <- try(e1071::svm(class ~ ., data = df, kernel = "radial", cost = 1), silent = TRUE)
        if (inherits(fit_svm, "try-error")) next
        grid_seq <- expand.grid(x = seq(min(sc[, 1]), max(sc[, 1]), length.out = 80),
                                 y = seq(min(sc[, 2]), max(sc[, 2]), length.out = 80))
        pred <- predict(fit_svm, grid_seq)
        boundary_pts <- grid_seq[abs(as.numeric(pred) - as.numeric(lv)) < 0.5, ]
        if (nrow(boundary_pts) > 0) {
          # Order boundary points by angle
          ang <- atan2(boundary_pts$y - mean(boundary_pts$y),
                       boundary_pts$x - mean(boundary_pts$x))
          boundary_pts <- boundary_pts[order(ang), ]
          boundaries[[paste(lv, "vs", lv2)]] <- data.frame(
            x = boundary_pts$x, y = boundary_pts$y, type = "svm",
            label = paste(lv, "vs", lv2), stringsAsFactors = FALSE)
        }
      }
      next  # skip the main ellipse/hull assignment below
    }
    boundaries[[lv]] <- data.frame(x = boundary[, 1], y = boundary[, 2],
                                    type = method, label = lv, stringsAsFactors = FALSE)
  }

  structure(list(boundaries = do.call(rbind, boundaries), coordinates = coords,
                 method = method, level = level, dims = dims), class = "pca_cluster_boundary")
}

#' Generate observation labels for PCA score plots
#'
#' @description Creates labels for observations based on cluster assignments.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param clustering Integer cluster membership vector.
#' @param type Label type: \code{\"observation\"}, \code{\"mean\"},
#'   \code{\"group\"}, or \code{\"external\"}.
#' @param labels Custom labels (only for \code{type = "external"}).
#' @param dims Integer vector of score/component indices.
#' @return A character vector of labels.
#' @examples
#' cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
#' pca_cluster_labels(iris[, 1:4], cl$cluster, type = "group")
#' pca_cluster_labels(iris[, 1:4], cl$cluster, type = "mean")
#' @export
# Phase E: Labels ----

#' Generate observation labels for PCA score plots
#'
#' @description Creates labels for observations based on cluster assignments,
#'   either from observation names, cluster means, group titles, or a custom
#'   external list.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param clustering Integer cluster membership vector.
#' @param type Label type: \code{"observation"}, \code{"mean"}, \code{"group"},
#'   or \code{"external"}.
#' @param labels Character vector of custom labels (only used when
#'   \code{type = "external"}).
#' @param dims Integer vector of score/component indices used.
#'
#' @return A character vector of labels with one entry per observation.
#' @export
pca_cluster_labels <- function(x, clustering, type = c("observation", "mean", "group", "external"),
                                labels = NULL, dims = NULL) {
  type <- match.arg(type)
  sc <- .pca_cluster_scores(x, dims)
  n <- nrow(sc)
  if (length(clustering) != n) .pca_stop("clustering length (", length(clustering),
                                          ") must match the number of observations (", n, ").")
  clustering <- as.factor(clustering)

  if (type == "observation") {
    nm <- if (inherits(x, "pca_fit")) rownames(x$scores) else
          if (!is.null(rownames(sc))) rownames(sc) else paste0("Obs", seq_len(n))
    out <- nm

  } else if (type == "mean") {
    means_by_cluster <- tapply(seq_len(n), clustering, function(i) {
      m <- colMeans(sc[i, , drop = FALSE])
      paste0("Cluster ", clustering[i[1]], ": (",
             paste(round(m, 2), collapse = ", "), ")")
    }, simplify = FALSE)
    out <- unlist(means_by_cluster[as.character(clustering)])

  } else if (type == "group") {
    out <- paste0("Cluster ", as.character(clustering))

  } else if (type == "external") {
    if (is.null(labels) || length(labels) != n) .pca_stop("external labels must be a character vector of length ", n, ".")
    out <- labels
  }
  out
}

#' Generate a comprehensive clustering report
#'
#' @description Produces a multi-part summary combining clustering results,
#'   stability, boundaries, and comparison metrics.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param clustering Integer cluster membership vector (or NULL for default).
#' @param method Clustering method.
#' @param k_range Range of k for evaluation panel.
#' @param dims Integer vector of score/component indices.
#' @param k_eval_only If TRUE, only show the evaluation table.
#' @param ... Additional arguments.
#' @return A \code{pca_cluster_report} object.
#' @examples
#' rpt <- pca_cluster_report(iris[, 1:4], method = "kmeans", k_range = 2:3)
#' rpt
#' @export
# Phase F: Full report ----

#' Generate a comprehensive clustering report
#'
#' @description Produces a multi-part report combining clustering results,
#'   stability, boundaries, and comparison metrics.
#'
#' @param x A \code{pca_fit} object or numeric matrix.
#' @param clustering Integer cluster membership vector (if NULL, runs
#'   \code{pca_cluster} with \code{method="kmeans"} and \code{k=3}).
#' @param method Clustering method for comparison panel.
#' @param k_range Range of k for evaluation panel.
#' @param dims Integer vector of score/component indices.
#' @param k_eval_only Logical. If TRUE, only show the evaluation table.
#' @param ... Additional arguments.
#'
#' @return A \code{pca_cluster_report} object (list with table, metrics,
#'   and summary text).
#' @export
pca_cluster_report <- function(x, clustering = NULL, method = "kmeans",
                                k_range = 2:8, dims = NULL, k_eval_only = FALSE, ...) {
  sc <- .pca_cluster_scores(x, dims)
  fit <- if (inherits(x, "pca_fit")) x else NULL

  # Run clustering if not provided
  if (is.null(clustering)) clustering <- pca_cluster(x, method = method, k = 3, dims = dims, ...)$cluster
  clustering <- as.factor(clustering)
  k <- nlevels(clustering)
  n <- nrow(sc)
  p <- ncol(sc)

  # Evaluation
  eval <- pca_cluster_evaluate(x, method = method, k_range = k_range, dims = dims)
  ev <- eval$evaluation

  # Silhouette per observation
  sil <- .pca_cluster_silhouette(as.integer(clustering), sc)
  sil_by_cluster <- tapply(sil, clustering, mean, na.rm = TRUE)

  # Cluster sizes
  sizes <- as.integer(table(clustering))
  pve <- if (!is.null(fit) && !is.null(fit$variance_explained))
    round(sum(fit$variance_explained[seq_len(p)]) * 100, 2) else NA_real_

  # Summary text
  lines <- c(
    paste0("PCA Clustering Report"),
    paste0("---"),
    paste0("Method: ", method, " | k = ", k, " | n = ", n, " | dimensions used: ", p),
    paste0("Overall silhouette: ", round(mean(sil, na.rm = TRUE), 4)),
    paste0("Cluster sizes: ", paste(sizes, collapse = ", ")),
    paste0("Mean silhouette per cluster: ",
           paste(round(sil_by_cluster, 4), collapse = ", ")),
    paste0("PVE (used dimensions): ", pve, "%")
  )

  result <- list(
    evaluation = ev,
    best_k = eval$best_k,
    k_range = k_range,
    clustering = clustering,
    silhouette = sil,
    silhouette_by_cluster = sil_by_cluster,
    cluster_sizes = sizes,
    n = n,
    p = p,
    pve = pve,
    method = method,
    summary = lines
  )
  if (k_eval_only) result$summary <- c(lines, "
Note: k evaluation only.")
  structure(result, class = "pca_cluster_report")
}

#' @export
print.pca_cluster_report <- function(x, ...) {
  cat(paste(x$summary, collapse = "
"), "
")
  cat("
Evaluation table:
")
  print(x$evaluation, row.names = FALSE)
  invisible(x)
}
