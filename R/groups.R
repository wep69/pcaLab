# Group overlays and confidence regions ------------------------------------

.pca_ellipse_points <- function(center, covmat, level=.95, npoints=200L) {
  ee <- eigen((covmat+t(covmat))/2,symmetric=TRUE)
  ee$values <- pmax(ee$values,0)
  A <- ee$vectors %*% diag(sqrt(ee$values),2)
  th <- seq(0,2*pi,length.out=npoints)
  circle <- rbind(cos(th),sin(th))
  rad <- sqrt(stats::qchisq(level,df=2))
  pts <- t(matrix(center,2,npoints)+rad*A%*%circle)
  colnames(pts)<-c("x","y")
  pts
}

#' Add external group summaries and confidence regions to PCA scores
#'
#' PCA itself remains unsupervised; group labels are used only after fitting.
#'
#' @param fit A `pca_fit` object.
#' @param group Group/treatment label with one value per fitted observation.
#' @param dims Two principal-component indices.
#' @param region `"mean_chisq"`, `"data_chisq"`, `"bootstrap"`, `"circle_chisq"`, or `"none"`.
#' @param level Confidence/content level.
#' @param nboot Bootstrap replicates for centroid regions.
#' @param npoints Number of points per region curve.
#' @param seed Optional seed.
#' @return Group centroids, sizes, and region coordinates.
#' @examples
#' fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
#' grp <- pca_group(fit, iris$Species, region = "data_chisq")
#' grp$centroids
#' head(grp$regions)
#' # group labels remain supplementary to the unsupervised fit
#' @export
pca_group <- function(fit, group, dims=c(1,2),
                      region=c("mean_chisq","data_chisq","bootstrap","circle_chisq","none"),
                      level=.95,nboot=999L,npoints=200L,seed=NULL) {
  stopifnot(inherits(fit,"pca_fit"))
  if(length(group)!=nrow(fit$scores)) .pca_stop("group must have one value per observation.")
  dims<-as.integer(dims); if(length(dims)!=2L||any(dims<1|dims>fit$ncomp)) .pca_stop("dims must identify two retained PCs.")
  region<-match.arg(region); if(!is.null(seed)) set.seed(seed)
  S<-fit$scores[,dims,drop=FALSE]; g<-as.factor(group)
  cents<-do.call(rbind,lapply(levels(g),function(lev){
    z<-S[g==lev,,drop=FALSE]
    data.frame(group=lev,n=nrow(z),x=mean(z[,1]),y=mean(z[,2]))
  }))
  regions<-list()
  if(region!="none") for(lev in levels(g)) {
    z<-S[g==lev,,drop=FALSE]; ng<-nrow(z); cen<-colMeans(z)
    if(ng<2L) next
    if(region=="bootstrap") {
      bc<-matrix(NA_real_,nboot,2)
      for(b in seq_len(nboot)) bc[b,]<-colMeans(z[sample.int(ng,ng,replace=TRUE),,drop=FALSE])
      C<-stats::cov(bc); c0<-colMeans(bc)
      pts<-.pca_ellipse_points(c0,C,level,npoints)
    } else if(region=="circle_chisq") {
      v<-mean(diag(stats::cov(z)))/ng
      th<-seq(0,2*pi,length.out=npoints)
      rad<-sqrt(stats::qchisq(level,2)*v)
      pts<-cbind(cen[1]+rad*cos(th),cen[2]+rad*sin(th));colnames(pts)<-c("x","y")
    } else {
      C<-stats::cov(z)
      if(region=="mean_chisq") C<-C/ng
      pts<-.pca_ellipse_points(cen,C,level,npoints)
    }
    regions[[lev]]<-data.frame(group=lev,x=pts[,1],y=pts[,2])
  }
  list(dims=dims,group=g,centroids=cents,regions=if(length(regions))do.call(rbind,regions)else NULL,
       region=region,level=level,
       note="Group information is supplementary and does not enter the PCA fit.")
}
