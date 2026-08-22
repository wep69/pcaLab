# Preprocess data for PCA

Centers, scales, transforms, audits, and optionally retains missing
values.

## Usage

``` r
pca_preprocess(
  data,
  center = TRUE,
  scale = FALSE,
  transform = c("none", "log1p", "sqrt"),
  na_action = c("keep", "omit", "fail")
)
```

## Arguments

- data:

  Numeric matrix or data frame.

- center:

  Logical; subtract column means.

- scale:

  Scaling method: `FALSE`, `TRUE`, `"none"`, `"uv"`, `"pareto"`,
  `"range"`, or `"vast"`.

- transform:

  Optional `"none"`, `"log1p"`, or `"sqrt"` transformation.

- na_action:

  `"keep"`, `"omit"`, or `"fail"`.

## Value

A list with processed data and a complete preprocessing audit.

## Examples

``` r
prep <- pca_preprocess(iris[, 1:4], center = TRUE, scale = "uv")
head(prep$data)
#>      Sepal.Length Sepal.Width Petal.Length Petal.Width
#> Obs1   -0.8976739  1.01560199    -1.335752   -1.311052
#> Obs2   -1.1392005 -0.13153881    -1.335752   -1.311052
#> Obs3   -1.3807271  0.32731751    -1.392399   -1.311052
#> Obs4   -1.5014904  0.09788935    -1.279104   -1.311052
#> Obs5   -1.0184372  1.24503015    -1.335752   -1.311052
#> Obs6   -0.5353840  1.93331463    -1.165809   -1.048667
prep$audit
#>                  variable mean_raw    sd_raw missing unique zero_variance
#> Sepal.Length Sepal.Length 5.843333 0.8280661       0     35         FALSE
#> Sepal.Width   Sepal.Width 3.057333 0.4358663       0     23         FALSE
#> Petal.Length Petal.Length 3.758000 1.7652982       0     43         FALSE
#> Petal.Width   Petal.Width 1.199333 0.7622377       0     22         FALSE
```
