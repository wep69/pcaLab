# Diagnose whether standard PCA assumptions and data geometry are suitable

Diagnose whether standard PCA assumptions and data geometry are suitable

## Usage

``` r
pca_doctor(data, scale = TRUE, nonlinear_check = TRUE)
```

## Arguments

- data:

  Numeric matrix or data frame.

- scale:

  Whether to standardize for the diagnostic PCA.

- nonlinear_check:

  Logical; calculate simple squared-correlation curvature diagnostics.

## Value

A structured diagnostic object with findings and suggested PCA families.

## Examples

``` r
pca_doctor(iris[, 1:4])
#> $n
#> [1] 150
#> 
#> $p
#> [1] 4
#> 
#> $missing_rate
#> [1] 0
#> 
#> $mean_abs_correlation
#> [1] 0.594116
#> 
#> $max_abs_correlation
#> [1] 0.9628654
#> 
#> $curvature_score
#> [1] 0.02576176
#> 
#> $condition_number
#> [1] 249.1249
#> 
#> $p_greater_than_n
#> [1] FALSE
#> 
#> $warnings
#> character(0)
#> 
#> $suggestions
#> [1] "Investigate robust or cellwise-robust PCA because influential observations are present."
#> 
#> $audit
#>                  variable mean_raw    sd_raw missing unique zero_variance
#> Sepal.Length Sepal.Length 5.843333 0.8280661       0     35         FALSE
#> Sepal.Width   Sepal.Width 3.057333 0.4358663       0     23         FALSE
#> Petal.Length Petal.Length 3.758000 1.7652982       0     43         FALSE
#> Petal.Width   Petal.Width 1.199333 0.7622377       0     22         FALSE
#> 
```
