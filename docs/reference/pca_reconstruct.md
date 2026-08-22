# Reconstruct observations from retained principal components

Reconstruct observations from retained principal components

## Usage

``` r
pca_reconstruct(fit, ncomp = fit$ncomp, original_scale = TRUE)
```

## Arguments

- fit:

  A `pca_fit` object.

- ncomp:

  Number of components to use.

- original_scale:

  Return reconstruction in original measurement scale.

## Value

Reconstructed matrix.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
rec <- pca_reconstruct(fit, ncomp = 2, original_scale = TRUE)
dim(rec)
#> [1] 150   4
# rank-2 approximation error in the processed space
sqrt(mean((fit$processed_data - pca_reconstruct(fit, 2, FALSE))^2))
#> [1] 0.2039333
```
