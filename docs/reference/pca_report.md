# Generate a reproducible PCA report

Generate a reproducible PCA report

## Usage

``` r
pca_report(
  fit,
  file = NULL,
  include_diagnostics = TRUE,
  include_variable_table = TRUE,
  inference = NULL,
  selection = NULL,
  bootstrap = NULL
)
```

## Arguments

- fit:

  A `pca_fit` object.

- file:

  Optional output path. Markdown is always supported; `.html` requires
  rmarkdown.

- include_diagnostics:

  Include diagnostic table.

- include_variable_table:

  Include a variable summary for the first component.

- inference:

  Optional result from
  [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md).

- selection:

  Optional result from
  [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md).

- bootstrap:

  Optional result from
  [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md).

## Value

Markdown text invisibly, and optionally a written/rendered file.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
f <- tempfile(fileext = ".md")
pca_report(fit, f)
writeLines(head(readLines(f), 6))
#> # Principal Component Analysis Report
#> 
#> **Method:** `classical`  
#> **Engine:** `base::svd`  
#> **Observations:** 150  
#> **Variables:** 4  
```
