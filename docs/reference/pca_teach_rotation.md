# Teach planar rotation and weighted linear combinations

Teach planar rotation and weighted linear combinations

## Usage

``` r
pca_teach_rotation(data = NULL, angle = 45)
```

## Arguments

- data:

  Two-column numeric data; a simple example is generated when NULL.

- angle:

  Rotation angle in degrees.

## Examples

``` r
t <- pca_teach_rotation(angle = 37)
t$data$rotation
#>           [,1]       [,2]
#> [1,] 0.7986355 -0.6018150
#> [2,] 0.6018150  0.7986355
# pairwise distances are preserved under rotation
as.matrix(dist(t$data$original))
#>          A        B        C
#> A 0.000000 1.414214 2.828427
#> B 1.414214 0.000000 1.414214
#> C 2.828427 1.414214 0.000000
as.matrix(dist(t$data$rotated))
#>          A        B        C
#> A 0.000000 1.414214 2.828427
#> B 1.414214 0.000000 1.414214
#> C 2.828427 1.414214 0.000000
```
