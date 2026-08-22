# ANOVA-Simultaneous Component Analysis (ASCA)

Decomposes a multivariate response matrix into model-effect matrices
using linear-model projections, then applies PCA to each effect matrix.

## Usage

``` r
pca_asca(
  data,
  formula,
  design,
  ncomp = 2L,
  scale = FALSE,
  nperm = 0L,
  seed = NULL
)
```

## Arguments

- data:

  Numeric response matrix (observations x variables).

- formula:

  Model formula using columns in `design`.

- design:

  Data frame containing experimental factors/covariates.

- ncomp:

  Components retained per effect.

- scale:

  Scale response variables before decomposition.

- nperm:

  Number of Freedman-Lane residual permutations for term-level sums of
  squares; 0 disables testing.

- seed:

  Optional random seed for permutations.

## Value

A list containing effect matrices, PCA fits, sums of squares, and design
information.

## Examples

``` r
set.seed(1)
design <- data.frame(A = factor(rep(1:2, each = 10)),
                     B = factor(rep(1:2, 10)))
Y <- cbind(y1 = rnorm(20) + 2 * as.numeric(design$A),
           y2 = rnorm(20) + as.numeric(design$B))
asca <- pca_asca(Y, ~ A + B, design, ncomp = 1, nperm = 19, seed = 1)
asca$effect_ss
#>         A         B 
#> 22.724476  1.802952 
asca$effect_p
#>    A    B 
#> 0.05 0.60 
```
