# Report optional engine capabilities

Report optional engine capabilities

## Usage

``` r
pca_capabilities()
```

## Value

A data frame describing engines and whether their optional backend is
installed.

## Examples

``` r
pca_capabilities()
#> Registered S3 method overwritten by 'sparsepca':
#>   method     from      
#>   print.spca elasticnet
#>           method              backend available
#> 1      classical                 base      TRUE
#> 2       weighted                 base      TRUE
#> 3         nipals                 base      TRUE
#> 4             em                 base      TRUE
#> 5           ppca                 base      TRUE
#> 6       bayesian           pcaMethods      TRUE
#> 7         robust               rospca      TRUE
#> 8       cellwise             cellWise      TRUE
#> 9         sparse sparsepca/elasticnet      TRUE
#> 10 robust_sparse     rospca/sparsepca      TRUE
#> 11          rpca                 base      TRUE
#> 12        kernel                 base      TRUE
#> 13         nlpca           pcaMethods      TRUE
#> 14     shrinkage              corpcor      TRUE
#> 15      logistic          logisticPCA      TRUE
#> 16        glmpca               glmpca      TRUE
#> 17 compositional                 base      TRUE
#> 18    functional           base/MFPCA      TRUE
#> 19       dynamic                 base      TRUE
#> 20    multilevel                 base      TRUE
#> 21    multiblock                 base      TRUE
#> 22    randomized           base/irlba      TRUE
#> 23   incremental                 base      TRUE
```
