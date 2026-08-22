# Teach component-number selection

Teach component-number selection

## Usage

``` r
pca_teach_ncomp(data = NULL, nperm = 99L)
```

## Arguments

- data:

  Optional numeric data.

- nperm:

  Number of reference datasets for the demonstration.

## Examples

``` r
t <- pca_teach_ncomp(nperm = 19)
t$data$recommendations
#>         method suggested_k
#> 1        scree           3
#> 2   cumulative           2
#> 3 broken_stick           2
#> 4     parallel           2
#> 5  permutation           2
```
