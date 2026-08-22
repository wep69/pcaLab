# Finalize an incremental PCA state

Finalize an incremental PCA state

## Usage

``` r
pca_incremental_finalize(state, ncomp = NULL)
```

## Arguments

- state:

  Incremental state.

- ncomp:

  Number of components.

## Value

A `pca_fit` object containing eigenvectors/eigenvalues; scores are not
available without replaying observations.

## Examples

``` r
st <- pca_incremental_init(3, center = TRUE)
st <- pca_incremental_update(st, matrix(rnorm(60), 20, 3))
fit <- pca_incremental_finalize(st, ncomp = 2)
fit$loadings
#>         [,1]       [,2]
#> V1 0.8302986 -0.1439366
#> V2 0.5088596 -0.1982191
#> V3 0.2273016  0.9695316
```
