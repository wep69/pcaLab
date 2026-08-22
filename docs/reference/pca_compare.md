# Compare PCA methods on common metrics

Compare PCA methods on common metrics

## Usage

``` r
pca_compare(
  fits,
  methods = c("classical", "robust", "sparse", "kernel"),
  ncomp = 2L,
  center = TRUE,
  scale = TRUE
)
```

## Arguments

- fits:

  Named list of `pca_fit` objects, or raw data plus `methods`.

- methods:

  Methods to fit when `fits` is raw data.

- ncomp:

  Number of retained components for new fits.

- center:

  Center variables for new fits.

- scale:

  Scale variables for new fits.

## Value

Method comparison table plus pairwise subspace-angle summaries.

## Examples

``` r
# Compare classical and weighted PCA on common metrics
pca_compare(iris[, 1:4], methods = c("classical", "weighted"))
#> $models
#> $models$classical
#> pcaLab fit
#>   Method: classical
#>   Observations: 150
#>   Variables: 4
#>   Components retained: 2
#>   Variance explained by retained components: 95.8%
#> 
#> $models$weighted
#> pcaLab fit
#>   Method: weighted
#>   Observations: 150
#>   Variables: 4
#>   Components retained: 2
#>   Variance partition: not defined for this engine
#> 
#> 
#> $metrics
#>       model    method ncomp retained_variance reconstruction_rmse
#> 1 classical classical     2         0.9581321           0.2039333
#> 2  weighted  weighted     2                NA           0.2039333
#>   loading_sparsity
#> 1                0
#> 2                0
#> 
#> $subspace_angles
#>     model_a  model_b k max_angle mean_angle
#> 1 classical weighted 2         0          0
#> 
```
