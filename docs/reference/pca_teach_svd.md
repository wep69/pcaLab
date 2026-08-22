# Teach singular value decomposition and its equivalence to PCA

Teach singular value decomposition and its equivalence to PCA

## Usage

``` r
pca_teach_svd(data = NULL, scale = FALSE)
```

## Arguments

- data:

  Numeric data.

- scale:

  Standardize variables.

## Examples

``` r
t <- pca_teach_svd(iris[, 1:4], scale = TRUE)
head(t$data$V)
#>            [,1]        [,2]       [,3]       [,4]
#> [1,]  0.5210659 -0.37741762  0.7195664  0.2612863
#> [2,] -0.2693474 -0.92329566 -0.2443818 -0.1235096
#> [3,]  0.5804131 -0.02449161 -0.1421264 -0.8014492
#> [4,]  0.5648565 -0.06694199 -0.6342727  0.5235971
t$data$eigenvalues
#> [1] 2.91849782 0.91403047 0.14675688 0.02071484
```
