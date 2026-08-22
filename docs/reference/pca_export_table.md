# Export a PCA table

Export a PCA table

## Usage

``` r
pca_export_table(table, filename, digits = 4L)
```

## Arguments

- table:

  A data frame, or an object returned by
  `pca_table(..., format="data.frame")`.

- filename:

  Destination. Supported extensions are csv, tsv, md, tex, xlsx, html,
  and docx.

- digits:

  Numeric display precision for text formats.

## Value

The output path invisibly.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
f <- tempfile(fileext = ".csv")
pca_export_table(pca_table(fit, type = "eigenvalues"), f)
utils::read.csv(f)
#>   component eigenvalue explained_variance cumulative_variance
#> 1       PC1  2.9184978         0.72962445           0.7296245
#> 2       PC2  0.9140305         0.22850762           0.9581321
#> 3       PC3  0.1467569         0.03668922           0.9948213
```
