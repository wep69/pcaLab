# Teach low-rank reconstruction

Teach low-rank reconstruction

## Usage

``` r
pca_teach_reconstruction(fit = NULL)
```

## Arguments

- fit:

  Optional PCA fit.

## Examples

``` r
t <- pca_teach_reconstruction()
t$data  # RMSE decreases with retained rank
#>   k      rmse
#> 1 1 0.5798114
#> 2 2 0.2724434
#> 3 3 0.2280226
#> 4 4 0.1786031
#> 5 5 0.1376677
```
