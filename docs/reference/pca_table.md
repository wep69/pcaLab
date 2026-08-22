# Create publication-ready PCA tables

Create publication-ready PCA tables

## Usage

``` r
pca_table(
  fit,
  type = c("eigenvalues", "loadings", "scores", "variables", "diagnostics",
    "preprocessing", "ncomp", "inference_global", "inference_axes",
    "bootstrap_eigenvalues", "associations"),
  component = 1L,
  selection = NULL,
  inference = NULL,
  bootstrap = NULL,
  association = NULL,
  format = c("data.frame", "gt")
)
```

## Arguments

- fit:

  A `pca_fit` object.

- type:

  `"eigenvalues"`, `"loadings"`, `"scores"`, `"variables"`,
  `"diagnostics"`, `"preprocessing"`, `"ncomp"`, `"inference_global"`,
  `"inference_axes"`, `"bootstrap_eigenvalues"`, or `"associations"`.

- component:

  Optional component for variable summaries.

- selection:

  Optional result from
  [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md)
  used by `type = "ncomp"`.

- inference:

  Optional result from
  [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md).

- bootstrap:

  Optional result from
  [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md).

- association:

  Optional result from
  [`pca_associate()`](https://wep69.github.io/pcaLab/reference/pca_associate.md).

- format:

  `"data.frame"` or `"gt"`.

## Value

A data frame or gt table.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
pca_table(fit, type = "eigenvalues")
#>     component eigenvalue explained_variance cumulative_variance
#> PC1       PC1  2.9184978         0.72962445           0.7296245
#> PC2       PC2  0.9140305         0.22850762           0.9581321
#> PC3       PC3  0.1467569         0.03668922           0.9948213
pca_table(fit, type = "variables", component = 1)
#>                  variable    loading correlation      cos2 contribution
#> Sepal.Length Sepal.Length  0.5210659   0.8901688 0.7924004   0.27150969
#> Sepal.Width   Sepal.Width -0.2693474  -0.4601427 0.2117313   0.07254804
#> Petal.Length Petal.Length  0.5804131   0.9915552 0.9831817   0.33687936
#> Petal.Width   Petal.Width  0.5648565   0.9649790 0.9311844   0.31906291
```
