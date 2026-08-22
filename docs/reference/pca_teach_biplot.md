# Teach biplot geometry

Teach biplot geometry

## Usage

``` r
pca_teach_biplot(fit = NULL, dims = c(1, 2))
```

## Arguments

- fit:

  Optional PCA fit.

- dims:

  Two components.

## Examples

``` r
t <- pca_teach_biplot()
dim(t$data$scores)
#> [1] 72  2
dim(t$data$loadings)
#> [1] 7 2
```
