# Core mathematical and differential validation for pcaLab -----------------
# Run after installing/loading the package from a local R environment.

library(pcaLab)

assert <- function(cond, msg) if (!isTRUE(cond)) stop(msg, call. = FALSE)
cat("pcaLab core validation\n")
cat("R version:", R.version.string, "\n\n")

# 1. Differential validation against stats::prcomp -------------------------
X <- as.matrix(USArrests)
f <- pca_fit(X, method = "classical", center = TRUE, scale = TRUE)
r <- stats::prcomp(X, center = TRUE, scale. = TRUE)
k <- min(f$ncomp, ncol(r$rotation))
assert(max(abs(f$eigenvalues[1:k] - r$sdev[1:k]^2)) < 1e-8,
       "Classical eigenvalues differ from prcomp().")
loading_similarity <- abs(diag(crossprod(f$loadings[,1:k,drop=FALSE], r$rotation[,1:k,drop=FALSE])))
assert(min(loading_similarity) > 1 - 1e-7,
       "Classical loading subspace differs from prcomp().")
cat("[OK] Classical PCA agrees with prcomp up to signs.\n")

# 2. SVD/eigenvalue identity ------------------------------------------------
Z <- f$processed_data
sv <- svd(Z)
lambda <- sv$d^2/(nrow(Z)-1)
assert(max(abs(lambda[1:k]-f$eigenvalues[1:k])) < 1e-8,
       "SVD eigenvalue identity failed.")
assert(max(abs(colMeans(Z))) < 1e-10, "Processed standardized data are not centered.")
cat("[OK] SVD/eigenvalue identity.\n")

# 3. Full-rank reconstruction ----------------------------------------------
R <- pca_reconstruct(f, ncomp=f$ncomp, original_scale=FALSE)
assert(sqrt(mean((Z-R)^2)) < 1e-7, "Full-rank reconstruction is inaccurate.")
cat("[OK] Full-rank reconstruction.\n")

# 4. Sign invariance --------------------------------------------------------
g <- f
g$loadings[,1] <- -g$loadings[,1]
g$scores[,1] <- -g$scores[,1]
Rg <- pca_reconstruct(g, ncomp=g$ncomp, original_scale=FALSE)
assert(max(abs(R-Rg)) < 1e-10, "Component sign invariance failed.")
cat("[OK] Eigenvector sign invariance.\n")

# 5. PVE denominator for truncated fits ------------------------------------
f2 <- pca_fit(X, center=TRUE, scale=TRUE, ncomp=2)
assert(abs(sum(f2$variance_explained) - sum(r$sdev[1:2]^2)/sum(r$sdev^2)) < 1e-8,
       "Truncated-fit explained variance denominator is incorrect.")
cat("[OK] Truncated-fit explained variance uses total variance.\n")

# 6. Known-rank simulation --------------------------------------------------
s <- pca_simulate(n=300,p=12,rank=3,eigenvalues=c(6,4,2),noise=.12,seed=123)
fs <- pca_fit(s$data,scale=FALSE)
ang <- acos(pmin(1,svd(crossprod(qr.Q(qr(s$loadings)), qr.Q(qr(fs$loadings[,1:3]))),nu=0,nv=0)$d))*180/pi
assert(max(ang) < 15, "Known-rank leading subspace recovery is unexpectedly poor.")
cat("[OK] Known-rank leading subspace recovery.\n")

# 7. Incremental covariance equivalence ------------------------------------
set.seed(99)
Xi <- matrix(rnorm(600),150,4)
st <- pca_incremental_init(4,center=TRUE,scale=FALSE)
st <- pca_incremental_update(st,Xi[1:40,])
st <- pca_incremental_update(st,Xi[41:110,])
st <- pca_incremental_update(st,Xi[111:150,])
fi <- pca_incremental_finalize(st,ncomp=4)
ref <- eigen(cov(Xi),symmetric=TRUE)
assert(max(abs(fi$eigenvalues-ref$values)) < 1e-8,
       "Incremental covariance eigenvalues differ from batch covariance eigenvalues.")
cat("[OK] Incremental covariance matches batch covariance.\n")

# 8. Missing-data engines ---------------------------------------------------
Xm <- as.matrix(iris[,1:4]); Xm[cbind(c(1,20,50,100),c(1,2,3,4))] <- NA
fn <- pca_fit(Xm,method="nipals",scale=TRUE,ncomp=2)
fe <- pca_fit(Xm,method="em",scale=TRUE,ncomp=2)
assert(all(is.finite(fe$processed_data)), "EM completion retains missing entries.")
assert(ncol(fn$scores)==2 && ncol(fe$scores)==2, "Missing-data engines did not extract requested components.")
cat("[OK] NIPALS and EM missing-data smoke tests.\n")

# 9. RPCA decomposition -----------------------------------------------------
set.seed(3)
L <- matrix(rnorm(180),60,3)%*%matrix(rnorm(30),3,10)
S <- matrix(0,60,10); id <- sample(length(S),15); S[id] <- rnorm(15,12,2)
fr <- pca_fit(L+S,method="rpca",center=FALSE,scale=FALSE,ncomp=3,max_iter=1000)
rr <- sqrt(mean(((L+S)-fr$extra$low_rank-fr$extra$sparse)^2))
assert(rr < 1e-3, "RPCA decomposition residual too large.")
cat("[OK] Low-rank plus sparse decomposition.\n")

# 10. Permutation p-values --------------------------------------------------
pt <- pca_test(fs,nperm=99,seed=17)
all_p <- c(pt$global$p_value,pt$axes$p_value,as.vector(pt$variable_index_p),as.vector(pt$variable_correlation_p))
all_p <- all_p[is.finite(all_p)]
assert(all(all_p > 0 & all_p <= 1), "Permutation p-values are outside (0,1].")
cat("[OK] Monte Carlo p-value bounds.\n")

# 11. Bootstrap component alignment ----------------------------------------
bt <- pca_boot(f2,nboot=50,seed=19)
assert(all(dim(bt$loading_ci)==c(ncol(X),2,3)), "Bootstrap loading interval dimensions are wrong.")
assert(all(bt$sign_stability>=0 & bt$sign_stability<=1,na.rm=TRUE), "Invalid sign stability values.")
cat("[OK] Bootstrap alignment and interval dimensions.\n")

# 12. ASCA term permutation -------------------------------------------------
set.seed(1)
d <- data.frame(A=factor(rep(1:2,each=15)),B=factor(rep(1:3,10)))
Y <- cbind(y1=rnorm(30)+2*as.numeric(d$A),y2=rnorm(30)+as.numeric(d$B),y3=rnorm(30))
a <- pca_asca(Y,~A+B,d,ncomp=2,nperm=49,seed=1)
assert(all(a$effect_p>0 & a$effect_p<=1,na.rm=TRUE), "ASCA permutation p-values invalid.")
cat("[OK] ASCA Freedman-Lane permutation smoke test.\n")

cat("\nAll core validation checks passed.\n")
print(sessionInfo())
