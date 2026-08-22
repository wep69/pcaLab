# Generate a comprehensive clustering report

Produces a multi-part summary combining clustering results, stability,
boundaries, and comparison metrics.

Produces a multi-part report combining clustering results, stability,
boundaries, and comparison metrics.

## Usage

``` r
pca_cluster_report(
  x,
  clustering = NULL,
  method = "kmeans",
  k_range = 2:8,
  dims = NULL,
  k_eval_only = FALSE,
  ...
)
```

## Arguments

- x:

  A `pca_fit` object or numeric matrix.

- clustering:

  Integer cluster membership vector (if NULL, runs `pca_cluster` with
  `method="kmeans"` and `k=3`).

- method:

  Clustering method for comparison panel.

- k_range:

  Range of k for evaluation panel.

- dims:

  Integer vector of score/component indices.

- k_eval_only:

  Logical. If TRUE, only show the evaluation table.

- ...:

  Additional arguments.

## Value

A `pca_cluster_report` object.

A `pca_cluster_report` object (list with table, metrics, and summary
text).

## Examples

``` r
rpt <- pca_cluster_report(iris[, 1:4], method = "kmeans", k_range = 2:3)
#> Warning: Cluster gap statistic selected k=3; silhouette suggests k=2.
rpt
#> PCA Clustering Report
#> ---
#> Method: kmeans | k = 3 | n = 150 | dimensions used: 4
#> Overall silhouette: 0.5528
#> Cluster sizes: 50, 62, 38
#> Mean silhouette per cluster: 0.7981, 0.4173, 0.4511
#> PVE (used dimensions): NA% 
#> 
#> Evaluation table:
#>  k     wss silhouette     ch    gap gap_se
#>  2 3899.41     0.6810 513.92 0.0897 0.0282
#>  3 3924.73     0.5528 561.63 0.3834 0.0228
```
