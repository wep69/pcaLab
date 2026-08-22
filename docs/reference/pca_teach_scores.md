# Teach scores

Teach scores

## Usage

``` r
pca_teach_scores(fit = NULL)
```

## Arguments

- fit:

  Optional PCA fit.

## Examples

``` r
t <- pca_teach_scores()
head(t$data)
#>             PC1        PC2         PC3
#> Plot1 -1.999183 -1.5165266  0.07906854
#> Plot2 -3.243621  0.9939534  0.33222789
#> Plot3 -2.895690  0.8802641  0.09838486
#> Plot4 -2.484173 -0.3241728  0.43105956
#> Plot5 -2.861676 -1.5535935 -0.13354204
#> Plot6 -2.878620 -0.0128753  0.36241407
```
