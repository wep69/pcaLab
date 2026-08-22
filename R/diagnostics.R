# Diagnostics, comparison, supplementary information ----------------------

#' PCA influence and outlier diagnostics
#'
#' @param fit A `pca_fit` object.
#' @param level Reference probability for score-distance and orthogonal-distance cutoffs.
#' @return Observation-level diagnostic table.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' head(pca_diagnose(fit))
#' @export
pca_diagnose <- function(fit, level=.975) {
  stopifnot(inherits(fit,"pca_fit"))
  if(!nrow(fit$scores)) .pca_stop("This fit does not contain observation scores.")
  k<-fit$ncomp; n<-nrow(fit$scores)
  ev<-pmax(fit$eigenvalues,.Machine$double.eps)
  sd2<-rowSums(sweep(fit$scores^2,2,ev,"/"),na.rm=TRUE)
  backend_sd <- fit$extra$sd
  score_distance <- if (!is.null(backend_sd) && length(backend_sd) == n) as.numeric(backend_sd) else sqrt(sd2)
  backend_sd_cut <- fit$extra$cutoff_sd
  euclidean_reference <- !fit$method %in% c("kernel", "nlpca", "logistic", "glmpca")
  score_cutoff <- if (!is.null(backend_sd_cut) && length(backend_sd_cut) == 1L && is.finite(backend_sd_cut))
    as.numeric(backend_sd_cut) else if (euclidean_reference) sqrt(stats::qchisq(level,df=max(1,k))) else NA_real_

  backend_od <- fit$extra$od
  if (!is.null(backend_od) && length(backend_od) == n) {
    od <- as.numeric(backend_od)
  } else {
    rec<-try(pca_reconstruct(fit,original_scale=FALSE),silent=TRUE)
    if(inherits(rec,"try-error")) od<-rep(NA_real_,n) else od<-sqrt(rowSums((fit$processed_data-rec)^2,na.rm=TRUE))
  }
  backend_od_cut <- fit$extra$cutoff_od
  if (!is.null(backend_od_cut) && length(backend_od_cut) == 1L && is.finite(backend_od_cut)) {
    od_cutoff <- as.numeric(backend_od_cut)
  } else if(all(!is.finite(od))||all(od<=0,na.rm=TRUE)) od_cutoff<-NA_real_ else {
    lod<-log(pmax(od,.Machine$double.eps)); med<-stats::median(lod,na.rm=TRUE)
    sc<-stats::mad(lod,constant=1,na.rm=TRUE)
    od_cutoff<-exp(med+stats::qnorm(level)*max(sc,.Machine$double.eps))
  }
  leverage<-sd2/max(1,n-1)
  d<-data.frame(observation=rownames(fit$scores)%||%paste0("Obs",seq_len(n)),
                score_distance=score_distance,score_cutoff=score_cutoff,
                orthogonal_distance=od,orthogonal_cutoff=od_cutoff,
                leverage=leverage,
                score_outlier=if(is.finite(score_cutoff)) score_distance>score_cutoff else FALSE,
                orthogonal_outlier=if(is.finite(od_cutoff)) od>od_cutoff else FALSE)
  d$outlier_flag<-d$score_outlier|d$orthogonal_outlier
  attr(d,"distance_source") <- if (!is.null(backend_sd) || !is.null(backend_od)) "backend_when_available" else "pcaLab_generic"
  attr(d,"reference_note") <- if (euclidean_reference || !is.null(backend_sd_cut))
    "Distance cutoffs are backend-specific when available; otherwise a generic Euclidean PCA reference is used." else
    "No generic chi-square score cutoff is imposed because this engine does not use ordinary Euclidean PCA geometry."
  fit$diagnostics<-d
  d
}

#' Compare PCA methods on common metrics
#'
#' @param fits Named list of `pca_fit` objects, or raw data plus `methods`.
#' @param methods Methods to fit when `fits` is raw data.
#' @param ncomp Number of retained components for new fits.
#' @param center Center variables for new fits.
#' @param scale Scale variables for new fits.
#' @return Method comparison table plus pairwise subspace-angle summaries.
#' @examples
#' # Compare classical and weighted PCA on common metrics
#' pca_compare(iris[, 1:4], methods = c("classical", "weighted"))
#' @export
pca_compare <- function(fits, methods=c("classical","robust","sparse","kernel"),
                        ncomp=2L, center=TRUE, scale=TRUE) {
  if(!is.list(fits)||inherits(fits,"data.frame")||is.matrix(fits)||!all(vapply(fits,inherits,logical(1),"pca_fit"))) {
    X<-fits
    objs<-list()
    for(m in methods) objs[[m]]<-try(pca_fit(X,method=m,center=center,scale=scale,ncomp=ncomp),silent=TRUE)
    objs<-objs[!vapply(objs,inherits,logical(1),"try-error")]
  } else objs<-fits
  if(!length(objs)) .pca_stop("No comparable models were successfully fitted.")
  tab<-do.call(rbind,lapply(names(objs),function(nm){
    f<-objs[[nm]]
    rec<-try(pca_reconstruct(f,original_scale=FALSE),silent=TRUE)
    rmse<-if(inherits(rec,"try-error")||anyNA(f$processed_data)) NA_real_ else sqrt(mean((f$processed_data-rec)^2))
    rv <- if (all(!is.finite(f$variance_explained))) NA_real_ else sum(f$variance_explained,na.rm=TRUE)
    data.frame(model=nm,method=f$method,ncomp=f$ncomp,
               retained_variance=rv,reconstruction_rmse=rmse,
               loading_sparsity=if(is.null(f$loadings)) NA_real_ else mean(abs(f$loadings)<1e-10),
               stringsAsFactors=FALSE)
  }))
  pairs<-utils::combn(names(objs),2,simplify=FALSE)
  ang<-do.call(rbind,lapply(pairs,function(pr){
    a<-objs[[pr[1]]];b<-objs[[pr[2]]]
    if(is.null(a$loadings)||is.null(b$loadings)||nrow(a$loadings)!=nrow(b$loadings)) return(NULL)
    k<-min(ncol(a$loadings),ncol(b$loadings),ncomp)
    aa<-.pca_subspace_angles(a$loadings[,seq_len(k),drop=FALSE],b$loadings[,seq_len(k),drop=FALSE])
    data.frame(model_a=pr[1],model_b=pr[2],k=k,max_angle=max(aa),mean_angle=mean(aa))
  }))
  list(models=objs,metrics=tab,subspace_angles=ang)
}

#' Project supplementary observations or variables without refitting PCA
#'
#' @param fit A linear `pca_fit` object.
#' @param observations Optional new observations with original variables.
#' @param variables Optional matrix of supplementary variables measured on the original observations.
#' @return Supplementary scores and/or correlations.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 2)
#' sup <- pca_supplementary(fit,
#'         observations = iris[1:3, 1:4],
#'         variables = cbind(ratio = iris$Petal.Length / iris$Petal.Width))
#' sup$observation_scores
#' sup$variable_correlations
#' @export
pca_supplementary <- function(fit, observations=NULL, variables=NULL) {
  stopifnot(inherits(fit,"pca_fit"))
  out<-list()
  if(!is.null(observations)) out$observation_scores<-predict(fit,observations)
  if(!is.null(variables)) {
    V<-.pca_as_numeric_matrix(variables,allow_na=TRUE)
    if(nrow(V)!=nrow(fit$scores)) .pca_stop("Supplementary variables must have one value per fitted observation.")
    out$variable_correlations<-.pca_safe_cor(V,fit$scores)
  }
  out
}
