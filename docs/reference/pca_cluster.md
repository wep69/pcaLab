# Cluster observations based on PCA scores

Performs clustering on PCA scores (or any numeric matrix) using a
specified method and optional pre-determined k.

Performs clustering on PCA scores (or any numeric matrix) using a
specified method and optional pre-determined k.

## Usage

``` r
pca_cluster(
  x,
  method = c("kmeans", "pam", "hclust", "mclust", "dbscan"),
  k = NULL,
  dims = NULL,
  nstart = 25,
  ...
)
```

## Arguments

- x:

  A `pca_fit` object or numeric matrix.

- method:

  Clustering method: `"kmeans"`, `"pam"`, `"hclust"`, `"mclust"`, or
  `"dbscan"`.

- k:

  Number of clusters. If `NULL`, a default of 3 is used.

- dims:

  Integer vector of score/component indices to use.

- nstart:

  Number of random starts for k-means.

- ...:

  Additional arguments passed to the method.

## Value

A `pca_cluster` object.

A `pca_cluster` object containing the partition, scores used, and
reference to the PCA fit.

## Examples

``` r
cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
cl
#> PCA-based clustering: kmeans with k = 3 
#> Observations: 150 
#> Silhouette (mean): 0.5528 
#> Cluster sizes: 50, 38, 62 
table(cl$cluster, iris$Species)
#>    
#>     setosa versicolor virginica
#>   1     50          0         0
#>   2      0          2        36
#>   3      0         48        14
```
