# Launch the interactive PCA teaching laboratory

The application connects geometric rotation, projected variance,
eigenvalues/eigenvectors, scores, loadings, dimensionality selection,
and low-rank reconstruction. It uses only synthetic demonstration data
and is intended for teaching rather than inferential analysis.

## Usage

``` r
pca_teach_app(launch.browser = TRUE, ...)
```

## Arguments

- launch.browser:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Examples

``` r
if (FALSE) { # \dontrun{
  pca_teach_app(launch.browser = FALSE)
} # }
```
