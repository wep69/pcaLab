# Parallel analysis for PCA

Parallel analysis for PCA

## Usage

``` r
pca_parallel(
  x,
  nperm = 499L,
  quantile = 0.95,
  null = c("permutation", "normal"),
  seed = NULL
)
```

## Arguments

- x:

  A `pca_fit` object or numeric data.

- nperm:

  Number of random reference datasets.

- quantile:

  Reference quantile, usually 0.95.

- null:

  `"permutation"` preserves marginal distributions; `"normal"` simulates
  independent Gaussian variables.

- seed:

  Optional random seed.

## Value

List with observed eigenvalues, null envelopes, and selected
dimensionality.

## Examples

``` r
# Horn parallel analysis with independent Gaussian reference variables
pa <- pca_parallel(iris[, 1:4], nperm = 49, null = "normal", seed = 1)
pa$k
#> [1] 1
# Column-wise permutation parallel analysis
pa <- pca_parallel(iris[, 1:4], nperm = 49, null = "permutation", seed = 1)
pa$k
#> [1] 1
```
