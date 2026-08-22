# Select the number of PCA components using multiple criteria

Select the number of PCA components using multiple criteria

## Usage

``` r
pca_ncomp(
  x,
  methods = "all",
  cumulative_threshold = 0.9,
  nperm = 199L,
  nboot = 100L,
  cv_folds = 5L,
  seed = NULL
)
```

## Arguments

- x:

  A `pca_fit` object or numeric data.

- methods:

  Any subset of `"scree"`, `"cumulative"`, `"kaiser"`, `"broken_stick"`,
  `"parallel"`, `"permutation"`, `"rmt"`, `"cv"`, `"stability"`,
  `"ppca_bic"`, and `"engine_cv"`, or `"all"`. `"engine_cv"` is
  currently implemented for logistic PCA.

- cumulative_threshold:

  Variance threshold for the cumulative criterion.

- nperm:

  Number of permutations/reference datasets for stochastic criteria.

- nboot:

  Bootstrap resamples for stability criterion.

- cv_folds:

  Number of folds for engine-specific cross-validation when available.

- seed:

  Optional seed.

## Value

A consensus object with all recommendations and explicit disagreements.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE)
sel <- pca_ncomp(fit, methods = c("scree", "cumulative", "broken_stick"),
                 nperm = 19, nboot = 20, seed = 1)
sel$recommendations
#>         method suggested_k
#> 1        scree           2
#> 2   cumulative           2
#> 3 broken_stick           1
sel$consensus
#> [1] 2
```
