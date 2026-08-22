# Bootstrap cluster stability assessment

Assesses cluster stability by resampling observations and re-clustering
to build a consensus matrix and measure membership stability.

Assesses cluster stability by resampling observations and re-clustering
to build a consensus matrix and measure membership stability.

## Usage

``` r
pca_cluster_stability(
  x,
  method = "kmeans",
  k = NULL,
  dims = NULL,
  nboot = 999,
  seed = NULL,
  ...
)
```

## Arguments

- x:

  A `pca_fit` object or numeric matrix.

- method:

  Clustering method.

- k:

  Number of clusters.

- dims:

  Integer vector of score/component indices.

- nboot:

  Number of bootstrap resamples.

- seed:

  Optional random seed.

- ...:

  Additional arguments passed to clustering.

## Value

A `pca_cluster_stability` object.

A `pca_cluster_stability` object with consensus matrix and stability
metrics.

## Examples

``` r
st <- pca_cluster_stability(iris[, 1:4], method = "kmeans", k = 3,
                            nboot = 49, seed = 1)
st
#> Cluster stability: kmeans k = 3 
#> Bootstrap replicates: 49 
#> Mean membership stability: 0.2626 
#> Cophenetic correlation: -0.2268 
#> Mean silhouette: 0.5499 
```
