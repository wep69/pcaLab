# Multiblock PCA by block scaling and concatenation

Multiblock PCA by block scaling and concatenation

## Usage

``` r
pca_multiblock(
  blocks,
  ncomp = NULL,
  block_scale = c("frobenius", "first_singular", "none"),
  center = TRUE,
  scale = FALSE,
  transform = "none"
)
```

## Arguments

- blocks:

  Named list of numeric matrices sharing the same observations.

- ncomp:

  Number of consensus components.

- block_scale:

  `"frobenius"`, `"first_singular"`, or `"none"`.

- center:

  Center each block.

- scale:

  Variable scaling within each block.

- transform:

  Optional element-wise transformation applied within each block.

## Value

A `pca_fit` object augmented with block scores and block contributions.

## Examples

``` r
set.seed(2)
soil <- matrix(rnorm(60 * 4), 60, 4)
climate <- matrix(rnorm(60 * 3), 60, 3)
mb <- pca_multiblock(list(soil = soil, climate = climate),
                     block_scale = "frobenius", ncomp = 2)
mb$extra$block_contributions
#>               PC1       PC2
#> soil    0.1207441 0.2523923
#> climate 0.8792559 0.7476077
```
