# PCA inference, bootstrap, stability, and associations --------------------

.pca_standardized_geometry <- function(X) {
  prep <- pca_preprocess(X, center = TRUE, scale = TRUE, na_action = "fail")
  Z <- prep$data
  s <- svd(Z, nu = min(nrow(Z), ncol(Z)), nv = min(nrow(Z), ncol(Z)))
  r <- min(.pca_rank_limit(Z), length(s$d), ncol(s$v))
  eig <- s$d[seq_len(r)]^2 / max(1, nrow(Z)-1)
  V <- s$v[, seq_len(r), drop=FALSE]
  scores <- Z %*% V
  list(Z=Z, eigenvalues=eig, loadings=V, scores=scores)
}

#' Permutation tests for global PCA structure, axes, and variable contributions
#'
#' Implements PCAtest-style Psi, Phi, rank-of-roots, loading-index, and
#' variable-PC correlation null distributions. Monte Carlo p-values use the
#' `(b + 1)/(B + 1)` correction so they are never zero.
#'
#' @param x A `pca_fit` object or numeric data.
#' @param nperm Number of column-wise random permutations.
#' @param alpha Significance level.
#' @param variable_tests Test loading indices and variable-PC correlations.
#' @param adjust Multiple-testing method for variable-level p-values.
#' @param seed Optional seed.
#' @return A structured permutation-inference object.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' tst <- pca_test(fit, nperm = 49, seed = 1)
#' tst$global
#' tst$axes
#' @export
pca_test <- function(x, nperm = 999L, alpha = 0.05, variable_tests = TRUE,
                     adjust = "BH", seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  if (inherits(x, "pca_fit")) {
    if (!identical(x$method, "classical"))
      .pca_stop("pca_test() implements standardized classical PCAtest-style inference. For advanced PCA engines, use a method-specific inferential procedure or explicitly pass the numeric matrix if standardized classical PCA is the intended target.")
    X <- x$data
  } else X <- x
  X <- .pca_as_numeric_matrix(X, allow_na = FALSE)
  if (ncol(X) < 2L) .pca_stop("pca_test() requires at least two variables.")
  emp <- .pca_standardized_geometry(X)
  eig <- emp$eigenvalues; V <- emp$loadings; p <- ncol(X); r <- length(eig)
  psi_obs <- sum((eig - 1)^2)
  phi_obs <- sqrt(max(0, (sum(eig^2) - p) / max(.Machine$double.eps, p * (p - 1))))
  pve_obs <- eig / sum(eig)
  idx_obs <- t(t(V^2) * eig^2)
  cor_obs <- t(t(V) * sqrt(eig))
  psi_null <- phi_null <- numeric(nperm)
  eig_null <- matrix(NA_real_, nperm, r)
  idx_null <- if (variable_tests) array(NA_real_, dim=c(nperm,p,r)) else NULL
  cor_null <- if (variable_tests) array(NA_real_, dim=c(nperm,p,r)) else NULL
  for (b in seq_len(nperm)) {
    P <- apply(X, 2, sample)
    g <- .pca_standardized_geometry(P)
    e <- g$eigenvalues[seq_len(r)]; vv <- g$loadings[,seq_len(r),drop=FALSE]
    psi_null[b] <- sum((e - 1)^2)
    phi_null[b] <- sqrt(max(0, (sum(e^2) - p) / max(.Machine$double.eps, p*(p-1))))
    eig_null[b,] <- e
    if (variable_tests) {
      idx_null[b,,] <- t(t(vv^2) * e^2)
      cor_null[b,,] <- abs(t(t(vv) * sqrt(e)))
    }
  }
  p_psi <- .pca_pvalue_upper(psi_obs, psi_null)
  p_phi <- .pca_pvalue_upper(phi_obs, phi_null)
  p_axis <- vapply(seq_len(r), function(j) .pca_pvalue_upper(eig[j], eig_null[,j]), numeric(1))
  axis_sig <- (p_psi < alpha && p_phi < alpha) & p_axis < alpha
  var_index_p <- var_cor_p <- matrix(NA_real_, p, r, dimnames=list(colnames(X), .pca_component_names(r)))
  var_index_q <- var_cor_q <- var_index_p
  if (variable_tests) {
    for (j in seq_len(r)) for (v in seq_len(p)) {
      var_index_p[v,j] <- .pca_pvalue_upper(idx_obs[v,j], idx_null[,v,j])
      var_cor_p[v,j] <- .pca_pvalue_upper(abs(cor_obs[v,j]), cor_null[,v,j])
    }
    for (j in seq_len(r)) {
      var_index_q[,j] <- stats::p.adjust(var_index_p[,j], method=adjust)
      var_cor_q[,j] <- stats::p.adjust(var_cor_p[,j], method=adjust)
    }
  }
  out <- list(
    standardized = TRUE, alpha = alpha, nperm = nperm,
    global = data.frame(statistic=c("Psi","Phi"), observed=c(psi_obs,phi_obs),
                        p_value=c(p_psi,p_phi), significant=c(p_psi<alpha,p_phi<alpha)),
    axes = data.frame(component=.pca_component_names(r), eigenvalue=eig,
                      pve=pve_obs, p_value=p_axis, significant=axis_sig),
    loadings = V, correlations = cor_obs, loading_index = idx_obs,
    variable_index_p = var_index_p, variable_index_q = var_index_q,
    variable_correlation_p = var_cor_p, variable_correlation_q = var_cor_q,
    null = list(psi=psi_null, phi=phi_null, eigenvalues=eig_null,
                loading_index=idx_null, abs_correlations=cor_null),
    note = "Global Psi/Phi and rank-of-roots inference follows the standardized PCAtest logic; variable p-values are Monte Carlo upper-tail tests with multiplicity adjustment."
  )
  class(out) <- "pca_test"
  out
}

.pca_boot_refit <- function(fit, Xb, method, idx = NULL) {
  k <- fit$ncomp
  if (method == "same") {
    method <- fit$method
    allowed_same <- c("classical", "weighted", "nipals", "em", "ppca", "robust", "sparse",
                      "robust_sparse", "rpca", "shrinkage", "randomized")
    if (!method %in% allowed_same) {
      .pca_stop("Method='", fit$method,
                "' does not currently have a faithful same-engine row-bootstrap refit in pcaLab. ",
                "Use refit='classical' only if a local Euclidean-PCA sensitivity analysis is scientifically intended.")
    }
  } else {
    method <- "classical"
  }
  # Resampling a centered matrix does not guarantee a zero bootstrap mean.
  # Recenter when the original analysis was centered, while retaining the
  # original variable scaling already encoded in Xb.
  if (method == "weighted") {
    if (is.null(idx)) .pca_stop("Weighted bootstrap refitting requires the resampled row indices.")
    w <- fit$extra$observation_weights
    vw <- fit$extra$variable_weights
    if (is.null(w) || length(w) < max(idx)) .pca_stop("The fitted weighted PCA does not retain usable observation weights.")
    return(pca_fit(Xb, method = "weighted", center = isTRUE(fit$preprocessing$center),
                   scale = FALSE, ncomp = k, weights = w[idx], variable_weights = vw))
  }
  pca_fit(Xb, method=method, center=isTRUE(fit$preprocessing$center), scale=FALSE, ncomp=k)
}

#' Bootstrap PCA uncertainty with component alignment
#'
#' @param fit A fitted `pca_fit` object with loadings.
#' @param nboot Number of bootstrap resamples.
#' @param refit `"same"` attempts the same linear engine; `"classical"` evaluates stability of the local PCA geometry.
#' @param conf Confidence level.
#' @param seed Optional seed.
#' @return Bootstrap distributions and confidence intervals for eigenvalues, PVE, loadings, and correlations.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 2)
#' bt <- pca_boot(fit, nboot = 50, seed = 1)
#' bt$eigenvalue_ci
#' bt$sign_stability
#' @export
pca_boot <- function(fit, nboot = 999L, refit = c("same","classical"), conf = 0.95, seed = NULL) {
  stopifnot(inherits(fit,"pca_fit"))
  if (is.null(fit$loadings)) .pca_stop("Bootstrap loading inference requires a model with explicit variable loadings.")
  refit <- match.arg(refit)
  allowed_same <- c("classical", "weighted", "nipals", "em", "ppca", "robust", "sparse",
                    "robust_sparse", "rpca", "shrinkage", "randomized")
  if (refit == "same" && !fit$method %in% allowed_same) {
    .pca_stop("Method='", fit$method,
              "' does not currently have a faithful same-engine row-bootstrap refit in pcaLab. ",
              "Use refit='classical' only if a local Euclidean-PCA sensitivity analysis is scientifically intended.")
  }
  if (!is.null(seed)) set.seed(seed)
  X <- fit$processed_data
  if (anyNA(X)) .pca_stop("pca_boot currently requires a complete processed data matrix.")
  n <- nrow(X); p <- ncol(X); k <- fit$ncomp
  eig <- matrix(NA_real_, nboot, k)
  pve <- matrix(NA_real_, nboot, k)
  L <- array(NA_real_, dim=c(nboot,p,k), dimnames=list(NULL,rownames(fit$loadings),colnames(fit$loadings)))
  C <- array(NA_real_, dim=c(nboot,p,k), dimnames=dimnames(L))
  sim <- matrix(NA_real_, nboot, k)
  perm <- matrix(NA_integer_, nboot, k)
  for (b in seq_len(nboot)) {
    idx <- sample.int(n, n, replace=TRUE)
    fb <- try(.pca_boot_refit(fit, X[idx,,drop=FALSE], refit, idx = idx), silent=TRUE)
    if (inherits(fb,"try-error") || is.null(fb$loadings) || ncol(fb$loadings)<k) next
    al <- .pca_align_components(fit$loadings[,seq_len(k),drop=FALSE], fb$loadings[,seq_len(k),drop=FALSE])
    lb <- al$loadings
    # align eigenvalues and scores by the same matched permutation
    eb <- fb$eigenvalues[al$permutation]
    eig[b,] <- eb
    pve_b <- fb$variance_explained[al$permutation]
    pve[b,] <- if (length(pve_b) >= k) pve_b[seq_len(k)] else NA_real_
    L[b,,] <- lb
    perm[b,] <- al$permutation
    for (j in seq_len(k)) sim[b,j] <- abs(sum(fit$loadings[,j]*lb[,j]))
    sb <- fb$scores[,al$permutation,drop=FALSE]
    for (j in seq_len(k)) {
      sgn <- sign(sum(fit$loadings[,j]*lb[,j])); if(!is.finite(sgn)||sgn==0) sgn<-1
      sb[,j] <- sb[,j]*sgn
    }
    C[b,,] <- .pca_safe_cor(X[idx,,drop=FALSE], sb)
  }
  a <- (1-conf)/2
  qfun <- function(v) stats::quantile(v,c(a,0.5,1-a),na.rm=TRUE,names=FALSE,type=8)
  eig_ci <- t(apply(eig,2,qfun)); colnames(eig_ci)<-c("lower","median","upper")
  pve_ci <- t(apply(pve,2,qfun)); colnames(pve_ci)<-c("lower","median","upper")
  loading_ci <- array(NA_real_, c(p,k,3), dimnames=list(rownames(fit$loadings),colnames(fit$loadings),c("lower","median","upper")))
  cor_ci <- loading_ci
  sign_stability <- matrix(NA_real_,p,k,dimnames=dimnames(fit$loadings))
  for(v in seq_len(p)) for(j in seq_len(k)) {
    loading_ci[v,j,] <- qfun(L[,v,j]); cor_ci[v,j,] <- qfun(C[,v,j])
    obs_sign <- sign(fit$loadings[v,j]); z<-L[,v,j]
    sign_stability[v,j] <- mean(sign(z)==obs_sign,na.rm=TRUE)
  }
  out <- list(nboot=nboot, conf=conf, eigenvalues=eig, pve=pve, loadings=L, correlations=C,
              similarity=sim, permutations=perm, eigenvalue_ci=eig_ci, pve_ci=pve_ci,
              loading_ci=loading_ci, correlation_ci=cor_ci, sign_stability=sign_stability,
              refit=refit)
  fit$bootstrap <- out
  class(out)<-"pca_boot"
  out
}

#' Assess component and subspace stability
#'
#' @param fit A `pca_fit` object.
#' @param nboot Number of bootstrap resamples.
#' @param kmax Largest nested subspace dimension assessed.
#' @param seed Optional seed.
#' @param refit Bootstrap refit target: `"same"` for supported engines or `"classical"`
#'   for an explicitly requested local Euclidean-PCA sensitivity analysis.
#' @return Stability summaries based on aligned loading similarity and principal angles.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' st <- pca_stability(fit, nboot = 40, seed = 1)
#' st$summary
#' @export
pca_stability <- function(fit, nboot=500L, kmax=min(fit$ncomp,10L), seed=NULL,
                          refit=c("same", "classical")) {
  if (!is.null(seed)) set.seed(seed)
  refit <- match.arg(refit)
  boot <- pca_boot(fit,nboot=nboot,refit=refit,seed=seed)
  kmax <- min(as.integer(kmax),fit$ncomp)
  maxang <- medang <- matrix(NA_real_,nboot,kmax)
  for(b in seq_len(nboot)) {
    Lb <- boot$loadings[b,,,drop=FALSE]
    Lb <- matrix(Lb,nrow=nrow(fit$loadings),ncol=fit$ncomp)
    if(any(!is.finite(Lb))) next
    for(k in seq_len(kmax)) {
      ang <- .pca_subspace_angles(fit$loadings[,seq_len(k),drop=FALSE],Lb[,seq_len(k),drop=FALSE])
      maxang[b,k]<-max(ang); medang[b,k]<-stats::median(ang)
    }
  }
  sm <- data.frame(k=seq_len(kmax),
                   median_max_angle=apply(maxang,2,stats::median,na.rm=TRUE),
                   upper95_max_angle=apply(maxang,2,stats::quantile,probs=.95,na.rm=TRUE,names=FALSE),
                   median_similarity=vapply(seq_len(kmax),function(k) stats::median(rowMeans(boot$similarity[,seq_len(k),drop=FALSE],na.rm=TRUE),na.rm=TRUE),numeric(1)))
  out<-list(summary=sm,max_angles=maxang,median_angles=medang,component_similarity=boot$similarity,bootstrap=boot)
  class(out)<-"pca_stability"
  out
}

#' Associate original variables with principal components
#'
#' @param fit A `pca_fit` object.
#' @param test Optional result from `pca_test()`.
#' @param alpha FDR threshold.
#' @param boot Optional result from `pca_boot()`.
#' @param min_sign_stability Minimum bootstrap sign stability for the combined flag.
#' @return Long-form variable-by-component table combining effect size, representation, inference, and stability.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 2)
#' bt <- pca_boot(fit, nboot = 30, seed = 1)
#' head(pca_associate(fit, boot = bt))
#' @export
pca_associate <- function(fit, test=NULL, boot=NULL, alpha=.05, min_sign_stability=.80) {
  stopifnot(inherits(fit,"pca_fit"))
  if(is.null(fit$loadings)) .pca_stop("Variable-component associations are not defined for this engine.")
  p<-nrow(fit$loadings); k<-fit$ncomp
  if (is.null(boot)) boot <- fit$bootstrap
  if (!is.null(test) && (!identical(fit$preprocessing$scale_method, "uv") || !isTRUE(fit$preprocessing$center))) {
    .pca_warn("The supplied PCAtest-style inference targets standardized correlation PCA, while this fit is not centered UV-scaled. Inferential q-values and descriptive fit metrics therefore refer to different PCA geometries.")
  }
  out<-vector("list",p*k); z<-1L
  for(j in seq_len(k)) for(v in seq_len(p)) {
    qidx<-qcor<-NA_real_
    if(!is.null(test)) {
      if(v<=nrow(test$variable_index_q)&&j<=ncol(test$variable_index_q)) qidx<-test$variable_index_q[v,j]
      if(v<=nrow(test$variable_correlation_q)&&j<=ncol(test$variable_correlation_q)) qcor<-test$variable_correlation_q[v,j]
    }
    lo<-hi<-signstab<-NA_real_
    if(!is.null(boot)) {
      lo<-boot$loading_ci[v,j,"lower"]; hi<-boot$loading_ci[v,j,"upper"]
      signstab<-boot$sign_stability[v,j]
    }
    contrib<-if(!is.null(fit$contributions)) fit$contributions[v,j] else NA_real_
    cos2<-if(!is.null(fit$cos2)) fit$cos2[v,j] else NA_real_
    corv<-if(!is.null(fit$correlation_loadings)) fit$correlation_loadings[v,j] else NA_real_
    effect_flag<-is.finite(contrib)&&contrib>1/p
    axis_sig <- NA
    if (!is.null(test) && j <= nrow(test$axes)) axis_sig <- isTRUE(test$axes$significant[j])
    infer_flag<-if(is.null(test)) NA else (is.finite(qidx)&&qidx<alpha)||(is.finite(qcor)&&qcor<alpha)
    stable_flag<-if(is.na(signstab)) NA else signstab>=min_sign_stability
    combined<-effect_flag && (is.na(axis_sig)||axis_sig) && (is.na(infer_flag)||infer_flag) && (is.na(stable_flag)||stable_flag)
    out[[z]]<-data.frame(variable=rownames(fit$loadings)[v],component=colnames(fit$loadings)[j],
                         loading=fit$loadings[v,j],correlation=corv,cos2=cos2,contribution=contrib,
                         loading_ci_low=lo,loading_ci_high=hi,sign_stability=signstab,
                         axis_significant=axis_sig,loading_index_q=qidx,correlation_q=qcor,
                         above_average_contribution=effect_flag,combined_association=combined)
    z<-z+1L
  }
  do.call(rbind,out)
}
