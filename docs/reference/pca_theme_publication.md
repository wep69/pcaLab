# Publication theme used by pcaLab

Publication theme used by pcaLab

## Usage

``` r
pca_theme_publication(base_size = 11, base_family = "")
```

## Arguments

- base_size:

  Base font size.

- base_family:

  Font family; empty uses the graphics-device default.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width)) +
    ggplot2::geom_point() +
    pca_theme_publication(12)
}
```
