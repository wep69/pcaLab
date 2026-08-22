# Generate observation labels for PCA score plots

Creates labels for observations based on cluster assignments.

Creates labels for observations based on cluster assignments, either
from observation names, cluster means, group titles, or a custom
external list.

## Usage

``` r
pca_cluster_labels(
  x,
  clustering,
  type = c("observation", "mean", "group", "external"),
  labels = NULL,
  dims = NULL
)
```

## Arguments

- x:

  A `pca_fit` object or numeric matrix.

- clustering:

  Integer cluster membership vector.

- type:

  Label type: `"observation"`, `"mean"`, `"group"`, or `"external"`.

- labels:

  Character vector of custom labels (only used when
  `type = "external"`).

- dims:

  Integer vector of score/component indices used.

## Value

A character vector of labels.

A character vector of labels with one entry per observation.

## Examples

``` r
cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3)
pca_cluster_labels(iris[, 1:4], cl$cluster, type = "group")
#>   [1] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>   [7] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>  [13] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>  [19] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>  [25] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>  [31] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>  [37] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>  [43] "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3" "Cluster 3"
#>  [49] "Cluster 3" "Cluster 3" "Cluster 1" "Cluster 1" "Cluster 2" "Cluster 1"
#>  [55] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1"
#>  [61] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1"
#>  [67] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1"
#>  [73] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 2"
#>  [79] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1"
#>  [85] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1"
#>  [91] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1"
#>  [97] "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 1" "Cluster 2" "Cluster 1"
#> [103] "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 1" "Cluster 2"
#> [109] "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 1"
#> [115] "Cluster 1" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 1"
#> [121] "Cluster 2" "Cluster 1" "Cluster 2" "Cluster 1" "Cluster 2" "Cluster 2"
#> [127] "Cluster 1" "Cluster 1" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2"
#> [133] "Cluster 2" "Cluster 1" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2"
#> [139] "Cluster 1" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 1" "Cluster 2"
#> [145] "Cluster 2" "Cluster 2" "Cluster 1" "Cluster 2" "Cluster 2" "Cluster 1"
pca_cluster_labels(iris[, 1:4], cl$cluster, type = "mean")
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     3                                     3 
#> "Cluster 3: (5.01, 3.43, 1.46, 0.25)" "Cluster 3: (5.01, 3.43, 1.46, 0.25)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     2 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     1                                     2 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     1                                     2 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     1                                     1 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     1                                     2 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     1                                     2 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     2 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     1                                     2 
#>  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" "Cluster 2: (6.85, 3.07, 5.74, 2.07)" 
#>                                     2                                     1 
#> "Cluster 2: (6.85, 3.07, 5.74, 2.07)"  "Cluster 1: (5.9, 2.75, 4.39, 1.43)" 
```
