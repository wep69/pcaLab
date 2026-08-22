# Masked cross-validation for PCA dimensionality

Masked cross-validation for PCA dimensionality

## Usage

``` r
pca_cv(x, kmax = NULL, repeats = 20L, holdout = 0.1, seed = NULL)
```

## Arguments

- x:

  A `pca_fit` object or numeric data.

- kmax:

  Maximum number of candidate components.

- repeats:

  Number of random masking repeats.

- holdout:

  Fraction of matrix cells held out per repeat.

- seed:

  Optional random seed.

## Value

Cross-validation table and selected component number.

## Examples

``` r
cv <- pca_cv(iris[, 1:4], kmax = 4, repeats = 5, seed = 1)
cv$table
#>   k       mse         se
#> 1 1 0.3818113 0.06598434
#> 2 2 0.4746462 0.11285713
#> 3 3 0.4611719 0.07857604
#> 4 4 1.0148419 0.03170200
cv$k
#> [1] 1
```
