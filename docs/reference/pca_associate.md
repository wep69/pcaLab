# Associate original variables with principal components

Associate original variables with principal components

## Usage

``` r
pca_associate(
  fit,
  test = NULL,
  boot = NULL,
  alpha = 0.05,
  min_sign_stability = 0.8
)
```

## Arguments

- fit:

  A `pca_fit` object.

- test:

  Optional result from
  [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md).

- boot:

  Optional result from
  [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md).

- alpha:

  FDR threshold.

- min_sign_stability:

  Minimum bootstrap sign stability for the combined flag.

## Value

Long-form variable-by-component table combining effect size,
representation, inference, and stability.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 2)
bt <- pca_boot(fit, nboot = 30, seed = 1)
head(pca_associate(fit, boot = bt))
#>       variable component    loading correlation      cos2 contribution
#> 1 Sepal.Length       PC1  0.5210659   0.8901688 0.7924004   0.27150969
#> 2  Sepal.Width       PC1 -0.2693474  -0.4601427 0.2117313   0.07254804
#> 3 Petal.Length       PC1  0.5804131   0.9915552 0.9831817   0.33687936
#> 4  Petal.Width       PC1  0.5648565   0.9649790 0.9311844   0.31906291
#> 5 Sepal.Length       PC2 -0.3774176  -0.3608299 0.1301982   0.14244406
#> 6  Sepal.Width       PC2 -0.9232957  -0.8827163 0.7791880   0.85247487
#>   loading_ci_low loading_ci_high sign_stability axis_significant
#> 1      0.4420949       0.5868469              1               NA
#> 2     -0.4387680      -0.1312671              1               NA
#> 3      0.5697414       0.5934696              1               NA
#> 4      0.5295662       0.5924752              1               NA
#> 5     -0.5183564      -0.2841604              1               NA
#> 6     -0.9578751      -0.8424952              1               NA
#>   loading_index_q correlation_q above_average_contribution combined_association
#> 1              NA            NA                       TRUE                 TRUE
#> 2              NA            NA                      FALSE                FALSE
#> 3              NA            NA                       TRUE                 TRUE
#> 4              NA            NA                       TRUE                 TRUE
#> 5              NA            NA                      FALSE                FALSE
#> 6              NA            NA                       TRUE                 TRUE
```
