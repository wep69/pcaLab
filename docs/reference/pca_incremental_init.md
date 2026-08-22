# Initialize an incremental PCA state

Initialize an incremental PCA state

## Usage

``` r
pca_incremental_init(p, center = TRUE, scale = FALSE)
```

## Arguments

- p:

  Number of variables.

- center:

  Center data in the final model.

- scale:

  Scale data to unit variance in the final model.

## Examples

``` r
# Streaming PCA over three chunks
set.seed(9)
X <- matrix(rnorm(600), 150, 4)
st <- pca_incremental_init(4, center = TRUE, scale = TRUE)
st <- pca_incremental_update(st, X[1:50, ])
st <- pca_incremental_update(st, X[51:100, ])
st <- pca_incremental_update(st, X[101:150, ])
fit <- pca_incremental_finalize(st, ncomp = 2)
fit$eigenvalues
#> [1] 1.319716 1.016553
```
