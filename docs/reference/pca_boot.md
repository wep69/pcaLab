# Bootstrap PCA uncertainty with component alignment

Bootstrap PCA uncertainty with component alignment

## Usage

``` r
pca_boot(
  fit,
  nboot = 999L,
  refit = c("same", "classical"),
  conf = 0.95,
  seed = NULL
)
```

## Arguments

- fit:

  A fitted `pca_fit` object with loadings.

- nboot:

  Number of bootstrap resamples.

- refit:

  `"same"` attempts the same linear engine; `"classical"` evaluates
  stability of the local PCA geometry.

- conf:

  Confidence level.

- seed:

  Optional seed.

## Value

Bootstrap distributions and confidence intervals for eigenvalues, PVE,
loadings, and correlations.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 2)
bt <- pca_boot(fit, nboot = 50, seed = 1)
bt$eigenvalue_ci
#>          lower    median   upper
#> [1,] 2.5676573 2.9120562 3.28570
#> [2,] 0.7224925 0.8923729 1.14563
bt$sign_stability
#>              PC1  PC2
#> Sepal.Length   1 1.00
#> Sepal.Width    1 1.00
#> Petal.Length   1 0.68
#> Petal.Width    1 0.92
```
