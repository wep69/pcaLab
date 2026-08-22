# Clustering on PCA Scores

## 1. Why this tutorial exists

PCA reduces high-dimensional data to a small number of principal
components. Once the most informative low-dimensional representation is
available, clustering on those scores reveals structure that
variable-level clustering might obscure.

The central rule is simple:

**Decide the clustering method, the number of clusters, and the degree
of stability before interpreting individual groups.**

This tutorial follows that rule from a basic PCA through k-selection,
multiple-method comparison, bootstrap stability assessment, cluster
boundary computation, custom labelling, and a structured summary.

------------------------------------------------------------------------

## 2. Learning objectives

After working through this tutorial, the reader should be able to:

1.  extract PCA scores and decide how many components to keep;
2.  evaluate the number of clusters using silhouette, Calinski-Harabasz,
    gap statistic, and WSS;
3.  compare k-means, PAM, hierarchical clustering, and MCLUST at a fixed
    k;
4.  perform bootstrap resampling to build a consensus matrix and measure
    membership stability;
5.  compute cluster boundaries using Mahalanobis ellipses, convex hulls,
    or SVM decision surfaces;
6.  generate observation, mean, group, and external custom labels for
    PCA score plots;
7.  produce a compact structured report that integrates evaluation,
    stability, and silhouette;
8.  recognize when cluster boundaries are fragile and report that fact
    clearly.

------------------------------------------------------------------------

## 3. Package map: clustering functions in pcaLab

| Function | Instructional role | Key arguments |
|----|----|----|
| [`pca_cluster_evaluate()`](https://wep69.github.io/pcaLab/reference/pca_cluster_evaluate.md) | Evaluate multiple k values across multiple indices | method, k_range, B, dims |
| [`pca_cluster()`](https://wep69.github.io/pcaLab/reference/pca_cluster.md) | Cluster observations using one method at a chosen k | method, k, dims, nstart |
| [`pca_cluster_compare()`](https://wep69.github.io/pcaLab/reference/pca_cluster_compare.md) | Compare multiple methods at the same k | methods, k, dims |
| [`pca_cluster_stability()`](https://wep69.github.io/pcaLab/reference/pca_cluster_stability.md) | Bootstrap resampling for consensus matrix and membership stability | method, k, nboot, dims, seed |
| [`pca_cluster_boundary()`](https://wep69.github.io/pcaLab/reference/pca_cluster_boundary.md) | Compute Mahalanobis, convex-hull, or SVM boundaries | method, level, dims |
| [`pca_cluster_labels()`](https://wep69.github.io/pcaLab/reference/pca_cluster_labels.md) | Generate observation, mean, group, or external labels | type, labels, dims |
| [`pca_cluster_report()`](https://wep69.github.io/pcaLab/reference/pca_cluster_report.md) | Compact multi-part summary integrating all components | method, k_range, dims |

The progression is deliberate. The evaluation panel decides k; the
comparison panel decides which method; the stability panel documents how
confident the assignment is; the boundary and label panels prepare the
final figure; the report brings everything together.

Every function accepts either a `pca_fit` object or a raw numeric
matrix. All optional backends (cluster, mclust, dbscan, e1071) are
guarded with
[`requireNamespace()`](https://rdrr.io/r/base/ns-load.html); missing
packages produce informative errors.

------------------------------------------------------------------------

## 4. The dataset: Fisher’s iris measurements

The iris dataset contains 150 observations of 4 morphological
measurements from 3 species of iris.

| Species    |   n | Sepal.Length | Sepal.Width | Petal.Length | Petal.Width |
|:-----------|----:|-------------:|------------:|-------------:|------------:|
| setosa     |  50 |         5.01 |        3.43 |         1.46 |        0.25 |
| versicolor |  50 |         5.94 |        2.77 |         4.26 |        1.33 |
| virginica  |  50 |         6.59 |        2.97 |         5.55 |        2.03 |

The three species form visually distinct clusters in the first two PCA
dimensions – a good starting point for method comparison. For a more
challenging case, add noise or reduce sample size.

------------------------------------------------------------------------

## 5. Step 1: Fit PCA and select the number of components

``` r

library(pcaLab)
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 4)
summary(fit)
#> pcaLab summary
#> Method: classical
#>  component eigenvalue    variance cumulative
#>        PC1 2.91849782 0.729624454  0.7296245
#>        PC2 0.91403047 0.228507618  0.9581321
#>        PC3 0.14675688 0.036689219  0.9948213
#>        PC4 0.02071484 0.005178709  1.0000000
fit$variance_explained[1:2]
#>       PC1       PC2 
#> 0.7296245 0.2285076
```

The first two components capture over 95% of the total standardized
variance. The `dims` argument in every clustering function lets us use
any subset.

### 5.1 How many PCs to retain?

``` r

sel <- pca_ncomp(fit, methods = c("parallel", "cv"), nperm = 49, seed = 1)
sel$recommendations
#>     method suggested_k
#> 1 parallel           1
#> 2       cv           1
```

Parallel analysis and cross-validation both suggest 2 components –
consistent with the clear two-dimensional scatter in the score plot.

------------------------------------------------------------------------

## 6. Step 2: Evaluate the number of clusters

[`pca_cluster_evaluate()`](https://wep69.github.io/pcaLab/reference/pca_cluster_evaluate.md)
computes WSS, silhouette, Calinski-Harabasz, and the gap statistic for
each candidate k.

``` r

ev <- pca_cluster_evaluate(iris[, 1:4], method = "kmeans", k_range = 2:6, B = 499)
#> Warning: Cluster gap statistic selected k=5; silhouette suggests k=2.
ev
#> Cluster evaluation: kmeans 
#>  k     wss silhouette     ch    gap gap_se
#>  2 3899.41     0.6810 707.46 0.0857 0.0302
#>  3 3924.73     0.5528 633.90 0.3819 0.0238
#>  4 3921.50     0.4981 483.89 0.4893 0.0213
#>  5 3837.83     0.4887 647.08 0.5408 0.0210
#>  6 3861.99     0.3648 497.78 0.5457 0.0200
#> Suggested k: 5
```

**Interpretation caution:** The gap statistic and silhouette sometimes
disagree. Disagreement is informative, not a failure. Report both values
and explain why you chose a particular k.

------------------------------------------------------------------------

## 7. Step 3: Cluster the data

[`pca_cluster()`](https://wep69.github.io/pcaLab/reference/pca_cluster.md)
accepts any supported method and returns a structured object that all
downstream functions can consume.

``` r

cl <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3, dims = 1:2)
cl
#> PCA-based clustering: kmeans with k = 3 
#> Observations: 150 
#> Silhouette (mean): 0.4451 
#> Cluster sizes: 53, 50, 47
```

Available methods: kmeans (base R, fast spherical), pam (cluster,
robust), hclust (base R, hierarchical), mclust (model-based), dbscan
(density-based).

Restrict to a subspace of principal components:

``` r

cl2 <- pca_cluster(iris[, 1:4], method = "kmeans", k = 3, dims = 1:3)
table(cl2$cluster, iris$Species)
#>    
#>     setosa versicolor virginica
#>   1      0          5        37
#>   2     50          0         0
#>   3      0         45        13
```

------------------------------------------------------------------------

## 8. Step 4: Compare clustering methods

[`pca_cluster_compare()`](https://wep69.github.io/pcaLab/reference/pca_cluster_compare.md)
runs each method and returns a table of internal validation indices plus
the adjusted Rand index between every pair.

``` r

cmp <- pca_cluster_compare(iris[, 1:4], methods = c("kmeans", "pam", "hclust"), k = 3)
cmp
#> Cluster comparison at k = 3 
#> 
#>  method silhouette     ch     wss
#>  kmeans     0.5528 561.63 3924.73
#>     pam     0.5528 561.63 3924.73
#>  hclust     0.5543 558.06 3895.77
#> 
#> Adjusted Rand index between methods:
#>    kmeans vs pam : 0.6583 
#>    kmeans vs hclust : 0.6472 
#>    pam vs hclust : 0.6472 
#>    hclust vs hclust : 0.6536
```

The Rand index measures how much two clusterings agree beyond chance. A
value close to 1 means near-perfect agreement; near 0 means random
overlap.

------------------------------------------------------------------------

## 9. Step 5: Assess bootstrap stability

[`pca_cluster_stability()`](https://wep69.github.io/pcaLab/reference/pca_cluster_stability.md)
draws nboot bootstrap samples, clusters each sample, and constructs a
consensus matrix.

``` r

st <- pca_cluster_stability(iris[, 1:4], method = "kmeans", k = 3, nboot = 199, seed = 1)
st
#> Cluster stability: kmeans k = 3 
#> Bootstrap replicates: 199 
#> Mean membership stability: 0.2382 
#> Cophenetic correlation: -0.4618 
#> Mean silhouette: 0.5516
```

| Diagnostic | Good range | Meaning |
|----|----|----|
| mean stability | \> 0.85 | Most observations are consistently assigned |
| cophenetic correlation | \> 0.75 | Consensus distances resemble original distances |
| mean silhouette | \> 0.50 | Average separation between clusters |

If mean stability is below 0.70, the cluster boundaries are fragile.
This is not a reason to hide the fact – it is a scientific finding about
the data.

------------------------------------------------------------------------

## 10. Step 6: Compute cluster boundaries

[`pca_cluster_boundary()`](https://wep69.github.io/pcaLab/reference/pca_cluster_boundary.md)
computes one of several options.

**Mahalanobis confidence ellipse (default):**

``` r

bd <- pca_cluster_boundary(iris[, 1:4], cl$cluster, method = "ellipse", level = 0.95)
nrow(bd$boundaries)
#> [1] 600
```

**Convex hull:**

``` r

bd_hull <- pca_cluster_boundary(iris[, 1:4], cl$cluster, method = "convex")
nrow(bd_hull$boundaries)
#> [1] 26
```

**SVM decision surface (requires e1071):**

``` r

if (requireNamespace("e1071", quietly = TRUE)) {
  bd_svm <- pca_cluster_boundary(iris[, 1:4], cl$cluster, method = "svm")
  nrow(bd_svm$boundaries)
}
#> [1] 12194
```

------------------------------------------------------------------------

## 11. Step 7: Generate observation labels

[`pca_cluster_labels()`](https://wep69.github.io/pcaLab/reference/pca_cluster_labels.md)
provides four modes: group, mean, observation, and external.

``` r

head(pca_cluster_labels(iris[, 1:4], cl$cluster, type = "group"), 10)
#>  [1] "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2"
#>  [7] "Cluster 2" "Cluster 2" "Cluster 2" "Cluster 2"
head(pca_cluster_labels(iris[, 1:4], cl$cluster, type = "mean"), 3)
#>                                     2                                     2 
#> "Cluster 2: (5.01, 3.43, 1.46, 0.25)" "Cluster 2: (5.01, 3.43, 1.46, 0.25)" 
#>                                     2 
#> "Cluster 2: (5.01, 3.43, 1.46, 0.25)"
head(pca_cluster_labels(iris[, 1:4], cl$cluster, type = "observation"), 5)
#> [1] "Obs1" "Obs2" "Obs3" "Obs4" "Obs5"
ext_lab <- c(rep("Setosa", 50), rep("Vers", 50), rep("Virgin", 50))
head(pca_cluster_labels(iris[, 1:4], cl$cluster, type = "external", labels = ext_lab), 5)
#> [1] "Setosa" "Setosa" "Setosa" "Setosa" "Setosa"
```

------------------------------------------------------------------------

## 12. Step 8: Generate the full report

[`pca_cluster_report()`](https://wep69.github.io/pcaLab/reference/pca_cluster_report.md)
gathers evaluation, stability, silhouette, and cluster sizes into a
single printable summary.

``` r

rpt <- pca_cluster_report(iris[, 1:4], method = "kmeans", k_range = 2:3)
#> Warning: Cluster gap statistic selected k=3; silhouette suggests k=2.
print(rpt)
#> PCA Clustering Report
#> ---
#> Method: kmeans | k = 3 | n = 150 | dimensions used: 4
#> Overall silhouette: 0.5528
#> Cluster sizes: 62, 50, 38
#> Mean silhouette per cluster: 0.4173, 0.7981, 0.4511
#> PVE (used dimensions): NA% 
#> 
#> Evaluation table:
#>  k     wss silhouette     ch    gap gap_se
#>  2 3899.41     0.6810 513.92 0.0898 0.0297
#>  3 3924.73     0.5528 546.99 0.3831 0.0232
```

------------------------------------------------------------------------

## 13. Interpretation safeguards

1.  **PCA orientation is arbitrary.** Cluster boundaries depend on which
    PCs you keep.
2.  **Stability is not validation.** High bootstrap stability does not
    prove that groups exist in the population.
3.  **Silhouette and CH are relative indices.** They rank candidate k
    values, not absolute quality.
4.  **Boundaries are visual aids.** Report the method and level, not
    just the figure.
5.  **Labels are descriptive.** A cluster name based on external biology
    is a hypothesis, not a conclusion.

------------------------------------------------------------------------

## 14. Putting it all together

``` r

fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE)
ev <- pca_cluster_evaluate(fit, k_range = 2:5, B = 499)
#> Warning: Cluster gap statistic selected k=4; silhouette suggests k=2.
cl <- pca_cluster(fit, method = "kmeans", k = ev$best_k, dims = 1:2)
st <- pca_cluster_stability(fit, method = "kmeans", k = ev$best_k, nboot = 199, seed = 1)
bd <- pca_cluster_boundary(fit, cl$cluster, method = "ellipse", level = 0.95)
lb <- pca_cluster_labels(fit, cl$cluster, type = "group")
rpt <- pca_cluster_report(fit, clustering = cl$cluster, k_range = 2:3)
#> Warning: Cluster gap statistic selected k=3; silhouette suggests k=2.
cat(sprintf("k = %d | mean silhouette = %.3f | stability = %.3f | PVE = %.1f%%\n",
            cl$k, mean(cl$silhouette_per_obs, na.rm = TRUE),
            st$mean_stability, sum(fit$variance_explained[1:2]) * 100))
#> k = 4 | mean silhouette = 0.441 | stability = 0.182 | PVE = 95.8%
```

------------------------------------------------------------------------

## 15. Notes

- All clustering functions accept either a pca_fit object or a raw
  numeric matrix.
- Optional engines (cluster, mclust, dbscan, e1071) are guarded with
  requireNamespace().
- The dims argument lets you restrict clustering to a chosen subspace.
- Bootstrap cluster stability is not a substitute for replicate study
  design.
