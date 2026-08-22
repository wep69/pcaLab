# Assess component and subspace stability

Assess component and subspace stability

## Usage

``` r
pca_stability(
  fit,
  nboot = 500L,
  kmax = min(fit$ncomp, 10L),
  seed = NULL,
  refit = c("same", "classical")
)
```

## Arguments

- fit:

  A `pca_fit` object.

- nboot:

  Number of bootstrap resamples.

- kmax:

  Largest nested subspace dimension assessed.

- seed:

  Optional seed.

- refit:

  Bootstrap refit target: `"same"` for supported engines or
  `"classical"` for an explicitly requested local Euclidean-PCA
  sensitivity analysis.

## Value

Stability summaries based on aligned loading similarity and principal
angles.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
st <- pca_stability(fit, nboot = 40, seed = 1)
st$summary
#>   k median_max_angle upper95_max_angle median_similarity
#> 1 1         3.531237          7.893402         0.9981012
#> 2 2         2.258416          4.378246         0.9978624
#> 3 3         2.012355          3.718852         0.9978045
```
