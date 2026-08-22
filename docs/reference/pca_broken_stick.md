# Broken-stick expected proportions

Broken-stick expected proportions

## Usage

``` r
pca_broken_stick(p)
```

## Arguments

- p:

  Number of components/dimensions.

## Value

Expected variance proportions under the broken-stick model.

## Examples

``` r
bs <- pca_broken_stick(8)
bs
#> [1] 0.33973214 0.21473214 0.15223214 0.11056548 0.07931548 0.05431548 0.03348214
#> [8] 0.01562500
sum(bs)  # proportions sum to one
#> [1] 1
```
