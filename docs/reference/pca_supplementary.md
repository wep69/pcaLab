# Project supplementary observations or variables without refitting PCA

Project supplementary observations or variables without refitting PCA

## Usage

``` r
pca_supplementary(fit, observations = NULL, variables = NULL)
```

## Arguments

- fit:

  A linear `pca_fit` object.

- observations:

  Optional new observations with original variables.

- variables:

  Optional matrix of supplementary variables measured on the original
  observations.

## Value

Supplementary scores and/or correlations.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 2)
sup <- pca_supplementary(fit,
        observations = iris[1:3, 1:4],
        variables = cbind(ratio = iris$Petal.Length / iris$Petal.Width))
sup$observation_scores
#>         PC1        PC2
#> 1 -2.257141 -0.4784238
#> 2 -2.074013  0.6718827
#> 3 -2.356335  0.3407664
sup$variable_correlations
#>              PC1         PC2
#> ratio -0.7185486 -0.05803567
```
