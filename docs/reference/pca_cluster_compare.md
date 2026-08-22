# Compare clustering methods on PCA scores

Runs multiple clustering methods and returns a comparison table of
internal validation indices plus adjusted Rand index between pairs.

Runs multiple clustering methods and returns a comparison table of
internal validation indices.

## Usage

``` r
pca_cluster_compare(
  x,
  methods = c("kmeans", "pam", "hclust"),
  k = NULL,
  dims = NULL,
  nstart = 25,
  indices = c("silhouette", "ch", "wss"),
  ...
)
```

## Arguments

- x:

  A `pca_fit` object or numeric matrix.

- methods:

  Character vector of methods to compare.

- k:

  Number of clusters (recycled to all methods).

- dims:

  Integer vector of score/component indices.

- nstart:

  Number of random starts for k-means.

- indices:

  Character vector of validation indices: `"silhouette"`, `"ch"`,
  `"dunn"`, `"wss"`, `"BIC"`.

- ...:

  Additional arguments passed to methods.

## Value

A `pca_cluster_compare` object.

A `pca_cluster_compare` object with comparison table.

## Examples

``` r
cmp <- pca_cluster_compare(iris[, 1:4], methods = c("kmeans", "pam", "hclust"), k = 3)
cmp
#> Cluster comparison at k = 3 
#> 
#>  method silhouette     ch     wss
#>  kmeans     0.5528 676.89 3924.73
#>     pam     0.5528 561.63 3924.73
#>  hclust     0.5543 558.06 3895.77
#> 
#> Adjusted Rand index between methods:
#>    kmeans vs pam : 0.6583 
#>    kmeans vs hclust : 0.6472 
#>    pam vs hclust : 0.6472 
#>    hclust vs hclust : 0.6536 
```
