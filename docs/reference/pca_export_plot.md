# Export a publication-ready PCA figure

Export a publication-ready PCA figure

## Usage

``` r
pca_export_plot(plot, filename, width = 7, height = 5, dpi = 600)
```

## Arguments

- plot:

  ggplot object.

- filename:

  Output file; extension determines format.

- width:

  Width in inches.

- height:

  Height in inches.

- dpi:

  Resolution for raster formats.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
  f <- tempfile(fileext = ".png")
  pca_export_plot(pca_plot(fit, type = "scree"), f,
                  width = 5, height = 4, dpi = 150)
  file.exists(f)
}
#> [1] TRUE
```
