# PCA influence and outlier diagnostics

PCA influence and outlier diagnostics

## Usage

``` r
pca_diagnose(fit, level = 0.975)
```

## Arguments

- fit:

  A `pca_fit` object.

- level:

  Reference probability for score-distance and orthogonal-distance
  cutoffs.

## Value

Observation-level diagnostic table.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
head(pca_diagnose(fit))
#>      observation score_distance score_cutoff orthogonal_distance
#> Obs1        Obs1       1.451364     3.057516         0.024087508
#> Obs2        Obs2       1.529811     3.057516         0.102662845
#> Obs3        Obs3       1.429239     3.057516         0.028282305
#> Obs4        Obs4       1.497925     3.057516         0.065735340
#> Obs5        Obs5       1.549282     3.057516         0.035802870
#> Obs6        Obs6       1.970108     3.057516         0.006586116
#>      orthogonal_cutoff   leverage score_outlier orthogonal_outlier outlier_flag
#> Obs1         0.3991005 0.01413731         FALSE              FALSE        FALSE
#> Obs2         0.3991005 0.01570685         FALSE              FALSE        FALSE
#> Obs3         0.3991005 0.01370956         FALSE              FALSE        FALSE
#> Obs4         0.3991005 0.01505893         FALSE              FALSE        FALSE
#> Obs5         0.3991005 0.01610922         FALSE              FALSE        FALSE
#> Obs6         0.3991005 0.02604915         FALSE              FALSE        FALSE
```
