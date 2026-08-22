# Teach eigenvalues and eigenvectors in PCA

Teach eigenvalues and eigenvectors in PCA

## Usage

``` r
pca_teach_eigen(data = NULL, scale = FALSE)
```

## Arguments

- data:

  Numeric data.

- scale:

  Standardize before building the covariance/correlation matrix.

## Examples

``` r
t <- pca_teach_eigen(iris[, 1:4], scale = TRUE)
t$data$eigenvalues
#> [1] 2.91849782 0.91403047 0.14675688 0.02071484
max(t$data$eigen_equation_residual)
#> [1] 2.071094e-15
```
