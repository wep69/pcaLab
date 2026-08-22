# Teach variance maximization over projection directions

Teach variance maximization over projection directions

## Usage

``` r
pca_teach_variance(data = NULL, angles = seq(0, 180, by = 1))
```

## Arguments

- data:

  Two-column numeric data.

- angles:

  Candidate angles in degrees.

## Examples

``` r
t <- pca_teach_variance()
head(t$data)
#>   angle projected_variance
#> 1     0           2.500000
#> 2     1           2.577817
#> 3     2           2.655872
#> 4     3           2.734069
#> 5     4           2.812312
#> 6     5           2.890507
t$data$angle[which.max(t$data$projected_variance)]
#> [1] 48
```
