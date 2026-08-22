# Compute cluster boundaries for PCA score plots

Computes visual cluster boundaries using Mahalanobis ellipses, convex
hulls, or SVM decision surfaces.

Computes visual cluster boundaries using Mahalanobis ellipses, convex
hulls, or SVM decision surfaces.

## Usage

``` r
pca_cluster_boundary(
  x,
  clustering,
  method = c("ellipse", "convex", "svm"),
  level = 0.95,
  dims = 1:2,
  npoints = 200
)
```

## Arguments

- x:

  A `pca_fit` object or numeric matrix.

- clustering:

  Integer cluster membership vector.

- method:

  Boundary method: `"ellipse"`, `"convex"`, or `"svm"`.

- level:

  Confidence level for Mahalanobis ellipses (default 0.95).

- dims:

  Integer vector of score/component indices (default 1:2).

- npoints:

  Number of points per ellipse curve.

## Value

A `pca_cluster_boundary` object.

A `pca_cluster_boundary` object with boundary data.

## Examples

``` r
cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
bd <- pca_cluster_boundary(iris[, 1:4], cl$cluster, method = "ellipse")
nrow(bd$boundaries)
#> [1] 600
```
