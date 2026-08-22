# Expanded teaching module -------------------------------------------------

.pca_teach_result <- function(title,concept,equations,data=NULL,plot=NULL,steps=NULL) {
  structure(list(title=title,concept=concept,equations=equations,steps=steps,data=data,plot=plot),class="pca_teaching")
}

#' Teach planar rotation and weighted linear combinations
#' @param data Two-column numeric data; a simple example is generated when NULL.
#' @param angle Rotation angle in degrees.
#' @examples
#' t <- pca_teach_rotation(angle = 37)
#' t$data$rotation
#' # pairwise distances are preserved under rotation
#' as.matrix(dist(t$data$original))
#' as.matrix(dist(t$data$rotated))
#' @export
pca_teach_rotation <- function(data=NULL,angle=45) {
  if(is.null(data))data<-rbind(A=c(1,1),B=c(2,2),C=c(3,3))
  X<-.pca_as_numeric_matrix(data,allow_na=FALSE);if(ncol(X)!=2L).pca_stop("Rotation demonstration requires exactly two variables.")
  th<-angle*pi/180;R<-matrix(c(cos(th),sin(th),-sin(th),cos(th)),2,2)
  Y<-X%*%R
  .pca_teach_result("Rotation as a linear combination",
    "A rotation preserves Euclidean distances while redistributing variance across coordinate axes.",
    c("x' = x cos(theta) + y sin(theta)","y' = -x sin(theta) + y cos(theta)"),
    data=list(original=X,rotated=Y,rotation=R,angle=angle),
    steps=c("Represent each observation as a point.","Rotate the coordinate system.","Verify that pairwise distances are preserved.","Compare variances before and after rotation."))
}

#' Teach variance maximization over projection directions
#' @param data Two-column numeric data.
#' @param angles Candidate angles in degrees.
#' @examples
#' t <- pca_teach_variance()
#' head(t$data)
#' t$data$angle[which.max(t$data$projected_variance)]
#' @export
pca_teach_variance <- function(data=NULL,angles=seq(0,180,by=1)) {
  if(is.null(data))data<-rbind(c(1,.5),c(2,4),c(4,3.5),c(5,5.2),c(3,2.8))
  X<-scale(.pca_as_numeric_matrix(data,allow_na=FALSE),center=TRUE,scale=FALSE)
  vals<-vapply(angles,function(a){v<-c(cos(a*pi/180),sin(a*pi/180));stats::var(drop(X%*%v))},numeric(1))
  best<-angles[which.max(vals)]
  .pca_teach_result("Variance as information along a projection",
    "PCA chooses the unit direction whose projected coordinates have maximum sample variance.",
    c("maximize v' S v subject to v'v = 1","Var(Xv) = v'Sv"),
    data=data.frame(angle=angles,projected_variance=vals),steps=c(paste0("Maximum occurs near ",best," degrees."),"Relate this direction to the first eigenvector of the covariance matrix."))
}

#' Teach eigenvalues and eigenvectors in PCA
#' @param data Numeric data.
#' @param scale Standardize before building the covariance/correlation matrix.
#' @examples
#' t <- pca_teach_eigen(iris[, 1:4], scale = TRUE)
#' t$data$eigenvalues
#' max(t$data$eigen_equation_residual)
#' @export
pca_teach_eigen <- function(data=NULL,scale=FALSE) {
  if(is.null(data))data<-rbind(c(1,.5),c(2,4),c(4,3.5),c(5,5.2),c(3,2.8))
  prep<-pca_preprocess(data,center=TRUE,scale=scale,na_action="fail");S<-stats::cov(prep$data);ee<-eigen(S,symmetric=TRUE)
  residuals<-vapply(seq_along(ee$values),function(j)sqrt(sum((S%*%ee$vectors[,j]-ee$values[j]*ee$vectors[,j])^2)),numeric(1))
  .pca_teach_result("Eigenvalues and eigenvectors",
    "An eigenvector is a direction that a covariance matrix maps onto itself up to a scalar multiplier. In PCA, eigenvectors are loading directions and eigenvalues are variances along those directions.",
    c("S v_k = lambda_k v_k","lambda_k = Var(PC_k)","PVE_k = lambda_k / sum_j lambda_j"),
    data=list(covariance=S,eigenvalues=ee$values,eigenvectors=ee$vectors,eigen_equation_residual=residuals),
    steps=c("Center the data.","Form the covariance or correlation matrix.","Find unit eigenvectors.","Order them by decreasing eigenvalue.","Interpret each eigenvalue as component variance.","Remember that v and -v define the same axis."))
}

#' Teach singular value decomposition and its equivalence to PCA
#' @param data Numeric data.
#' @param scale Standardize variables.
#' @examples
#' t <- pca_teach_svd(iris[, 1:4], scale = TRUE)
#' head(t$data$V)
#' t$data$eigenvalues
#' @export
pca_teach_svd <- function(data=NULL,scale=FALSE) {
  if(is.null(data))data<-pca_example_agronomy()$data
  prep<-pca_preprocess(data,center=TRUE,scale=scale,na_action="fail");s<-svd(prep$data)
  eig<-s$d^2/(nrow(prep$data)-1)
  .pca_teach_result("SVD formulation of PCA",
    "SVD computes PCA without explicitly forming X'X, which is often numerically preferable and efficient for rectangular matrices.",
    c("X = U D V'","scores = U D = X V","loadings = V","lambda_k = d_k^2/(n-1)"),
    data=list(U=s$u,D=s$d,V=s$v,eigenvalues=eig),steps=c("Center/scale X.","Compute the SVD.","Use V as loading directions.","Use U D as scores.","Square singular values and divide by n-1 to obtain eigenvalues."))
}

#' Teach scores
#' @param fit Optional PCA fit.
#' @examples
#' t <- pca_teach_scores()
#' head(t$data)
#' @export
pca_teach_scores <- function(fit=NULL) {
  if(is.null(fit)){ex<-pca_example_agronomy();fit<-pca_fit(ex$data,scale=TRUE,ncomp=3)}
  .pca_teach_result("Scores",
    "Scores are observation coordinates in the principal-component coordinate system.",
    c("T = X V","t_ik = sum_j x_ij v_jk"),data=fit$scores,
    steps=c("Take one centered/scaled observation.","Multiply its variables by the loading weights.","Sum the weighted values to obtain its score on each component."))
}

#' Teach loadings and variable-component relationships
#' @param fit Optional PCA fit.
#' @examples
#' t <- pca_teach_loadings()
#' t$data$loadings[, 1:2]
#' t$data$cos2[, 1:2]
#' @export
pca_teach_loadings <- function(fit=NULL) {
  if(is.null(fit)){ex<-pca_example_agronomy();fit<-pca_fit(ex$data,scale=TRUE,ncomp=3)}
  .pca_teach_result("Loadings, correlation loadings, contributions, and cos2",
    "Raw eigenvector loadings define directions. Correlation loadings quantify variable-PC correlation. Contributions describe how strongly variables build a component, while cos2 describes quality of representation.",
    c("loading_jk = v_jk","cor(X_j,PC_k) = sqrt(lambda_k) v_jk for correlation PCA","cos2_jk = cor(X_j,PC_k)^2"),
    data=list(loadings=fit$loadings,correlations=fit$correlation_loadings,contributions=fit$contributions,cos2=fit$cos2),
    steps=c("Do not use a universal absolute-loading cutoff as the sole criterion.","Combine effect magnitude, contribution/cos2, inference, and bootstrap stability."))
}

#' Teach low-rank reconstruction
#' @param fit Optional PCA fit.
#' @examples
#' t <- pca_teach_reconstruction()
#' t$data  # RMSE decreases with retained rank
#' @export
pca_teach_reconstruction <- function(fit=NULL) {
  if(is.null(fit)){ex<-pca_example_agronomy();fit<-pca_fit(ex$data,scale=TRUE,ncomp=5)}
  errs<-vapply(seq_len(fit$ncomp),function(k){r<-pca_reconstruct(fit,k,original_scale=FALSE);sqrt(mean((fit$processed_data-r)^2))},numeric(1))
  .pca_teach_result("Dimensionality reduction as reconstruction",
    "Keeping k components replaces the data by its rank-k orthogonal approximation in classical PCA.",
    c("X_hat_k = T_k V_k'","E_k = X - X_hat_k"),data=data.frame(k=seq_along(errs),rmse=errs),
    steps=c("Fit all meaningful components.","Reconstruct with increasing k.","Observe decreasing reconstruction error.","Balance fidelity against parsimony and stability."))
}

#' Teach the effects of scaling
#' @param data Optional numeric data.
#' @examples
#' t <- pca_teach_scaling()
#' t$data$covariance_pca$eigenvalues
#' t$data$correlation_pca$eigenvalues
#' @export
pca_teach_scaling <- function(data=NULL) {
  if(is.null(data))data<-pca_example_agronomy()$data
  a<-pca_fit(data,scale=FALSE,ncomp=2);b<-pca_fit(data,scale=TRUE,ncomp=2)
  .pca_teach_result("Covariance PCA versus correlation PCA",
    "Variables with large measurement variance dominate covariance PCA. Unit-variance scaling gives each variable equal marginal variance before PCA but changes the scientific question.",
    c("z_j = (x_j - mean_j)/sd_j"),data=list(covariance_pca=a,correlation_pca=b),
    steps=c("Inspect units and scientific meaning.","Compare unscaled and standardized solutions.","Document the chosen preprocessing because it changes the PCA model."))
}

#' Teach component-number selection
#' @param data Optional numeric data.
#' @param nperm Number of reference datasets for the demonstration.
#' @examples
#' t <- pca_teach_ncomp(nperm = 19)
#' t$data$recommendations
#' @export
pca_teach_ncomp <- function(data=NULL,nperm=99L) {
  if(is.null(data))data<-pca_example_agronomy()$data
  fit<-pca_fit(data,scale=TRUE);sel<-pca_ncomp(fit,methods=c("scree","cumulative","broken_stick","parallel","permutation"),nperm=nperm,nboot=30)
  .pca_teach_result("How many components?",
    "There is no universally correct single rule. Dimensionality should be supported by several criteria, scientific interpretability, out-of-sample reconstruction, and stability.",
    c("PVE_k = lambda_k / sum(lambda)","retain signal eigenvalues exceeding an appropriate null reference"),data=sel,
    steps=c("Inspect the eigenspectrum.","Compare cumulative information with null-based criteria.","Use validation/stability where possible.","Report disagreements instead of hiding them."))
}

#' Teach biplot geometry
#' @param fit Optional PCA fit.
#' @param dims Two components.
#' @examples
#' t <- pca_teach_biplot()
#' dim(t$data$scores)
#' dim(t$data$loadings)
#' @export
pca_teach_biplot <- function(fit=NULL,dims=c(1,2)) {
  if(is.null(fit)){ex<-pca_example_agronomy();fit<-pca_fit(ex$data,scale=TRUE,ncomp=3)}
  .pca_teach_result("Biplots",
    "A biplot overlays observation scores and variable directions, but score and loading scalings differ. Angles approximate variable relationships only under the corresponding biplot geometry.",
    c("X approximately equals T_k V_k'"),data=list(scores=fit$scores[,dims,drop=FALSE],loadings=fit$loadings[,dims,drop=FALSE],correlation_loadings=fit$correlation_loadings[,dims,drop=FALSE]),
    steps=c("Check which biplot scaling is being used.","Interpret nearby observations as similar in retained PC space.","Interpret variable arrows through direction, length, and correlation geometry, not only visual proximity."))
}
