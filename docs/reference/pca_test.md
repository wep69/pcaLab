# Permutation tests for global PCA structure, axes, and variable contributions

Implements PCAtest-style Psi, Phi, rank-of-roots, loading-index, and
variable-PC correlation null distributions. Monte Carlo p-values use the
`(b + 1)/(B + 1)` correction so they are never zero.

## Usage

``` r
pca_test(
  x,
  nperm = 999L,
  alpha = 0.05,
  variable_tests = TRUE,
  adjust = "BH",
  seed = NULL
)
```

## Arguments

- x:

  A `pca_fit` object or numeric data.

- nperm:

  Number of column-wise random permutations.

- alpha:

  Significance level.

- variable_tests:

  Test loading indices and variable-PC correlations.

- adjust:

  Multiple-testing method for variable-level p-values.

- seed:

  Optional seed.

## Value

A structured permutation-inference object.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
tst <- pca_test(fit, nperm = 49, seed = 1)
tst$global
#>   statistic  observed p_value significant
#> 1       Psi 5.3750479    0.02        TRUE
#> 2       Phi 0.6692687    0.02        TRUE
tst$axes
#>   component eigenvalue         pve p_value significant
#> 1       PC1 2.91849782 0.729624454    0.02        TRUE
#> 2       PC2 0.91403047 0.228507618    1.00       FALSE
#> 3       PC3 0.14675688 0.036689219    1.00       FALSE
#> 4       PC4 0.02071484 0.005178709    1.00       FALSE
```
