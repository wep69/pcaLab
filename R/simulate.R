# Simulation and examples --------------------------------------------------

#' Simulate PCA data with known latent structure and optional contamination
#'
#' @param n Number of observations.
#' @param p Number of variables.
#' @param rank Latent rank.
#' @param eigenvalues Latent signal variances.
#' @param noise Standard deviation of isotropic noise.
#' @param casewise Fraction of rows contaminated.
#' @param cellwise Fraction of individual cells contaminated.
#' @param nonlinear If TRUE, append a curved relationship to the first variables.
#' @param seed Random seed.
#' @return List with observed data and known truth.
#' @examples
#' s <- pca_simulate(n = 150, p = 8, rank = 3,
#'                    eigenvalues = c(6, 4, 2), noise = 0.2, seed = 1)
#' dim(s$data)
#' s$eigenvalues
#' # recover the planted subspace with classical PCA
#' fit <- pca_fit(s$data, scale = FALSE)
#' fit$eigenvalues[1:3]
#' @export
pca_simulate <- function(n=200L,p=10L,rank=3L,eigenvalues=NULL,noise=.3,
                         casewise=0,cellwise=0,nonlinear=FALSE,seed=1L) {
  set.seed(seed);n<-as.integer(n);p<-as.integer(p);rank<-min(as.integer(rank),p,n-1L)
  if(is.null(eigenvalues))eigenvalues<-seq(rank,1,length.out=rank)
  eigenvalues<-rep_len(eigenvalues,rank)
  Q<-qr.Q(qr(matrix(stats::rnorm(p*rank),p,rank)))
  Z<-matrix(stats::rnorm(n*rank),n,rank)%*%diag(sqrt(eigenvalues),rank)
  X0<-Z%*%t(Q);X<-X0+matrix(stats::rnorm(n*p,sd=noise),n,p)
  if(isTRUE(nonlinear)&&p>=2){u<-seq(-2,2,length.out=n)+stats::rnorm(n,sd=.05);X[,1]<-u;X[,2]<-u^2+stats::rnorm(n,sd=noise)}
  row_out<-integer();cell_out<-matrix(integer(),ncol=2)
  if(casewise>0){m<-max(1L,round(n*casewise));row_out<-sample.int(n,m);X[row_out,]<-X[row_out,]+matrix(stats::rnorm(m*p,mean=8,sd=2),m,p)}
  if(cellwise>0){m<-max(1L,round(n*p*cellwise));idx<-sample.int(n*p,m);X[idx]<-X[idx]+stats::rnorm(m,mean=10,sd=3);cell_out<-arrayInd(idx,dim(X))}
  colnames(X)<-paste0("V",seq_len(p));rownames(X)<-paste0("Obs",seq_len(n))
  list(data=X,clean=X0,loadings=Q,scores=Z,eigenvalues=eigenvalues,
       casewise_outliers=row_out,cellwise_outliers=cell_out,noise=noise)
}

#' Synthetic agronomy dataset for examples and teaching
#'
#' This function returns simulated, not empirical, measurements. It is intended
#' for demonstrations and software tests only.
#'
#' @param seed Random seed.
#' @return List with numeric traits and supplementary treatment/block metadata.
#' @examples
#' ex <- pca_example_agronomy(seed = 1)
#' head(ex$data)
#' table(ex$metadata$treatment)
#' @export
pca_example_agronomy <- function(seed=42L) {
  set.seed(seed)
  treatment<-factor(rep(paste0("T",1:6),each=12));block<-factor(rep(1:4,length.out=72))
  tr<-as.numeric(treatment);latent1<-scale(tr+stats::rnorm(72,sd=.8))[,1];latent2<-stats::rnorm(72)
  X<-cbind(
    plant_height=100+18*latent1+8*latent2+stats::rnorm(72,sd=5),
    leaf_area=35+7*latent1+4*latent2+stats::rnorm(72,sd=3),
    chlorophyll=42+3*latent1-4*latent2+stats::rnorm(72,sd=2),
    photosynthesis=18+2.5*latent1-1.5*latent2+stats::rnorm(72,sd=1.2),
    stomatal_conductance=.35+.04*latent1-.08*latent2+stats::rnorm(72,sd=.03),
    biomass=1.8+.45*latent1+.10*latent2+stats::rnorm(72,sd=.15),
    yield=3.2+.60*latent1+.18*latent2+stats::rnorm(72,sd=.20)
  )
  rownames(X)<-paste0("Plot",seq_len(nrow(X)))
  list(data=as.data.frame(X),metadata=data.frame(plot=rownames(X),treatment=treatment,block=block),
       note="Fully synthetic agronomy example; not suitable as empirical evidence.")
}
