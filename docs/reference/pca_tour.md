# Explore high-dimensional data with projection tours anchored to PCA

Explore high-dimensional data with projection tours anchored to PCA

## Usage

``` r
pca_tour(
  fit,
  type = c("grand", "guided", "local", "radial", "history"),
  dims = c(1, 2),
  group = NULL,
  angle = pi/8,
  variable = 1L,
  max_frames = 60L,
  save_history = FALSE,
  gif_file = NULL,
  ...
)
```

## Arguments

- fit:

  A `pca_fit` object with explicit loadings.

- type:

  `"grand"`, `"guided"`, `"local"`, `"radial"`, or `"history"`.

- dims:

  Starting PCA dimensions, usually c(1,2).

- group:

  Optional point grouping for display.

- angle:

  Local-tour angular radius.

- variable:

  Variable index used by radial tour.

- max_frames:

  Maximum interactive frames.

- save_history:

  Return a saved basis history instead of animating.

- gif_file:

  Optional GIF destination; when supplied, render the saved tour history
  to a GIF.

- ...:

  Additional arguments passed to tourr animation/history functions.

## Examples

``` r
if (requireNamespace("tourr", quietly = TRUE)) {
  fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 4)
  # headless-safe form: save projection histories instead of animating
  h <- pca_tour(fit, type = "grand", max_frames = 20, save_history = TRUE)
  length(h)
  h <- pca_tour(fit, type = "local", max_frames = 20, save_history = TRUE)
  length(h)
  if (FALSE) { # \dontrun{
    pca_tour(fit, type = "guided")  # opens an interactive animation
  } # }
}
```
