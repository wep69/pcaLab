# Evaluate clustering across multiple values of k

Computes internal validation indices for a range of k values using a
specified clustering method.

## Usage

``` r
pca_cluster_evaluate(
  x,
  method = c("kmeans", "pam", "hclust", "mclust"),
  k_range = 2:10,
  nstart = 25,
  B = 999,
  dims = NULL,
  ...
)
```

## Arguments

- x:

  A `pca_fit` object or a numeric matrix of scores/data.

- method:

  Clustering method: `"kmeans"`, `"pam"`, `"hclust"`, or `"mclust"`.

- k_range:

  Integer vector of candidate k values.

- nstart:

  Number of random starts for k-means.

- B:

  Number of bootstrap replicates for the gap statistic.

- dims:

  Integer vector of score/component indices to use.

- ...:

  Additional arguments passed to the clustering method.

## Value

A `pca_cluster_evaluate` object containing a data frame of evaluation
indices per k and the suggested best k.
