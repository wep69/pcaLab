# Publication-ready PCA figures

Publication-ready PCA figures

## Usage

``` r
pca_plot(
  fit,
  type = c("scree", "cumulative", "scores", "loadings", "correlation_circle",
    "contributions", "cos2", "biplot", "diagnostics", "bootstrap_loadings", "eigen_ci",
    "inference_axes", "dimension_selection", "trajectory", "eigenfunctions",
    "reconstruction", "scores3d"),
  dims = c(1, 2),
  component = 1L,
  group = NULL,
  labels = FALSE,
  group_region = NULL,
  bootstrap = NULL,
  selection = NULL,
  inference = NULL,
  base_size = 11
)
```

## Arguments

- fit:

  A `pca_fit` object.

- type:

  Figure type: scree, cumulative, scores, loadings, correlation_circle,
  contributions, cos2, biplot, diagnostics, bootstrap_loadings,
  eigen_ci, inference_axes, dimension_selection, trajectory,
  eigenfunctions, reconstruction, or scores3d.

- dims:

  Component indices used by two-dimensional figures.

- component:

  Component used by one-dimensional variable summaries.

- group:

  Optional supplementary group labels for score plots.

- labels:

  Label observations/variables where meaningful.

- group_region:

  Optional result from
  [`pca_group()`](https://wep69.github.io/pcaLab/reference/pca_group.md).

- bootstrap:

  Optional result from
  [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md)
  for bootstrap-based plots.

- selection:

  Optional result from
  [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md)
  for dimensionality-selection plots.

- inference:

  Optional result from
  [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md)
  for inferential plots.

- base_size:

  Publication-theme base font size.

## Value

A ggplot object.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
  pca_plot(fit, type = "scree")
  pca_plot(fit, type = "scores", group = iris$Species)
  pca_plot(fit, type = "loadings", component = 1)
  pca_plot(fit, type = "correlation_circle")
}
```
