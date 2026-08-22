# Teach the effects of scaling

Teach the effects of scaling

## Usage

``` r
pca_teach_scaling(data = NULL)
```

## Arguments

- data:

  Optional numeric data.

## Examples

``` r
t <- pca_teach_scaling()
t$data$covariance_pca$eigenvalues
#>       PC1       PC2 
#> 399.24880  27.63805 
t$data$correlation_pca$eigenvalues
#>      PC1      PC2 
#> 4.613587 1.859517 
```
