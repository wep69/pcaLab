# Teach loadings and variable-component relationships

Teach loadings and variable-component relationships

## Usage

``` r
pca_teach_loadings(fit = NULL)
```

## Arguments

- fit:

  Optional PCA fit.

## Examples

``` r
t <- pca_teach_loadings()
t$data$loadings[, 1:2]
#>                            PC1        PC2
#> plant_height         0.4204449 -0.2733221
#> leaf_area            0.3858783 -0.3431109
#> chlorophyll          0.3212896  0.4901351
#> photosynthesis       0.3879062  0.3412994
#> stomatal_conductance 0.2613484  0.5834029
#> biomass              0.4251483 -0.2001550
#> yield                0.4142122 -0.2653890
t$data$cos2[, 1:2]
#>                            PC1        PC2
#> plant_height         0.8155618 0.13891519
#> leaf_area            0.6869726 0.21891189
#> chlorophyll          0.4762469 0.44671634
#> photosynthesis       0.6942119 0.21660634
#> stomatal_conductance 0.3151218 0.63290332
#> biomass              0.8339107 0.07449602
#> yield                0.7915612 0.13096829
```
