# Compare PCA view with local and guided tour histories

Compare PCA view with local and guided tour histories

## Usage

``` r
pca_tour_compare(fit, dims = c(1, 2), max_bases = 50L, angle = pi/8)
```

## Arguments

- fit:

  A `pca_fit` object.

- dims:

  PCA dimensions used as the reference projection.

- max_bases:

  Number of saved bases per tour.

- angle:

  Local-tour radius.

## Examples

``` r
if (requireNamespace("tourr", quietly = TRUE)) {
  fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 4)
  tc <- pca_tour_compare(fit, max_bases = 10)
  length(tc$local)
  length(tc$grand)
}
#> No better bases found after 25 tries.  Giving up.
#> Final projection: 
#>  0.521  -0.377  
#> -0.269  -0.923  
#>  0.580  -0.024  
#>  0.565  -0.067  
#> [1] 10
```
