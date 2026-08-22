# Structured PCA: ASCA, Multiblock Integration, and Incremental Workflows

## Structured PCA: ASCA, Multiblock Integration, and Incremental Workflows

**Package:** `pcaLab`\
**Target version:** `0.1.0`\
**Role in the vignette system:** PCA extensions that explicitly preserve
experimental design, measurement blocks, or streaming data structure.

> This source is intentionally instructional. It is not precompiled
> here. Code that requires an optional backend is guarded in the
> examples or should be run only after
> [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md)
> confirms availability.

### Learning objectives

The reader will learn to:

1.  use ASCA for designed multivariate experiments rather than applying
    an undifferentiated PCA to all observations;
2.  interpret effect-specific component spaces;
3.  integrate multiple variable blocks with defensible block scaling;
4.  separate block dominance from shared latent structure;
5.  update PCA state incrementally as data arrive;
6.  validate incremental results against an ordinary batch PCA;
7.  recognize where multilevel PCA belongs in the broader
    structured-data family.

### Scope and relationship to the other vignettes

This vignette is intentionally focused. It develops the topics below in
depth and avoids reproducing material assigned to other blocks.

**Developed here:** PCA extensions that explicitly preserve experimental
design, measurement blocks, or streaming data structure.

**Not developed here:** General nonlinear geometry and robust
contamination algorithms are not repeated here.

## Part XI. Structured experimental PCA

### 36. ASCA for factorial multivariate experiments

PCA is unsupervised. When the scientific question concerns designed
treatment effects on a multivariate response, ANOVA-Simultaneous
Component Analysis can decompose the response into effect matrices
before applying PCA.

Create a two-factor agronomic design:

``` r

set.seed(6001)
design <- expand.grid(
  cultivar = factor(c("C1", "C2", "C3")),
  nitrogen = factor(c("N0", "N80", "N160")),
  block = factor(1:5)
)

n_asca <- nrow(design)
cv_eff <- c(C1 = -0.6, C2 = 0.2, C3 = 0.8)[design$cultivar]
n_eff <- c(N0 = -1.0, N80 = 0.2, N160 = 0.9)[design$nitrogen]
int_eff <- ifelse(
  design$cultivar == "C3" & design$nitrogen == "N160",
  0.8,
  0
)

Yasca <- cbind(
  height = 100 + 8 * cv_eff + 10 * n_eff + 3 * int_eff + rnorm(n_asca, 0, 3),
  biomass = 2.0 + 0.25 * cv_eff + 0.45 * n_eff + 0.18 * int_eff + rnorm(n_asca, 0, 0.15),
  yield = 3.5 + 0.35 * cv_eff + 0.60 * n_eff + 0.30 * int_eff + rnorm(n_asca, 0, 0.20),
  chlorophyll = 42 + 2 * cv_eff + 4 * n_eff - 1.5 * int_eff + rnorm(n_asca, 0, 1.2),
  protein = 11 + 0.5 * cv_eff + 0.9 * n_eff + rnorm(n_asca, 0, 0.5)
)
```

Fit ASCA with permutation testing:

``` r

asca <- pca_asca(
  data = Yasca,
  formula = ~ cultivar * nitrogen + block,
  design = design,
  ncomp = 2,
  scale = TRUE,
  nperm = 999,
  seed = 6001
)

asca$effect_ss
asca$residual_ss
asca$effect_p
```

Inspect the PCA of the nitrogen effect matrix:

``` r

nitrogen_asca_pca <- asca$pca[["nitrogen"]]

pca_plot(
  nitrogen_asca_pca,
  type = "loadings",
  component = 1
)
```

#### Interpretation

ASCA first uses the experimental design to partition the multivariate
response into model-effect matrices. PCA then summarizes each effect
matrix.

This is fundamentally different from coloring an unsupervised score plot
by treatment and calling the visible groups “significant.”

The permutation test is performed at the term level using a
reduced-model residual-permutation strategy in the package
implementation.

------------------------------------------------------------------------

### 37. Multiblock PCA: soil, plant, and spectral information in one consensus space

Suppose every plot has three measurement blocks.

``` r

set.seed(6002)
n_block <- 90
latent_block <- rnorm(n_block)

soil <- cbind(
  pH = 6.0 + 0.25 * latent_block + rnorm(n_block, 0, 0.15),
  organic_matter = 25 + 4 * latent_block + rnorm(n_block, 0, 2),
  available_P = 18 + 5 * latent_block + rnorm(n_block, 0, 3),
  exchangeable_K = 0.35 + 0.05 * latent_block + rnorm(n_block, 0, 0.03)
)

plant <- cbind(
  height = 100 + 12 * latent_block + rnorm(n_block, 0, 5),
  biomass = 2.2 + 0.35 * latent_block + rnorm(n_block, 0, 0.18),
  yield = 3.8 + 0.50 * latent_block + rnorm(n_block, 0, 0.25)
)

spectral_block <- cbind(
  NDVI = 0.65 + 0.06 * latent_block + rnorm(n_block, 0, 0.025),
  PRI = 0.04 - 0.01 * latent_block + rnorm(n_block, 0, 0.006),
  red_edge = 715 + 5 * latent_block + rnorm(n_block, 0, 2)
)
```

Fit block-scaled consensus PCA:

``` r

fit_mb <- pca_multiblock(
  blocks = list(
    soil = soil,
    plant = plant,
    spectral = spectral_block
  ),
  ncomp = 3,
  block_scale = "frobenius",
  center = TRUE,
  scale = TRUE
)

fit_mb
fit_mb$extra$block_scaling
fit_mb$extra$block_contributions
```

Visualize consensus scores:

``` r

pca_plot(
  fit_mb,
  type = "scores",
  dims = c(1, 2)
)
```

#### Interpretation

Without block scaling, a block with many variables or large total
variance can dominate the concatenated PCA. Block scaling changes the
target from “variance of all columns pooled” to a more balanced
consensus across blocks.

Report the chosen block-scaling rule because it changes the scientific
weighting of data sources.

------------------------------------------------------------------------

### 38. Incremental PCA for streaming or very large datasets

When all rows cannot be held or processed at once, the package can
accumulate means and cross-products batch by batch.

``` r

set.seed(6003)
stream_sim <- pca_simulate(
  n = 1000,
  p = 20,
  rank = 4,
  noise = 0.40,
  seed = 6003
)

Xstream <- stream_sim$data
```

Initialize:

``` r

state <- pca_incremental_init(
  p = ncol(Xstream),
  center = TRUE,
  scale = TRUE
)
```

Update in batches:

``` r

batch_id <- split(
  seq_len(nrow(Xstream)),
  ceiling(seq_len(nrow(Xstream)) / 100)
)

for (ii in batch_id) {
  state <- pca_incremental_update(
    state,
    Xstream[ii, , drop = FALSE]
  )
}
```

Finalize:

``` r

fit_inc <- pca_incremental_finalize(
  state,
  ncomp = 5
)

fit_inc
pca_table(fit_inc, type = "loadings")
```

#### Important limitation

The incremental state stores aggregated covariance information, not the
historical observation scores. Therefore the finalized object cannot
contain retrospective scores unless the data are replayed through
[`predict()`](https://rdrr.io/r/stats/predict.html) or otherwise
projected from the original observations.

#### Validation against full PCA

``` r

fit_full_stream <- pca_fit(
  Xstream,
  method = "classical",
  center = TRUE,
  scale = TRUE,
  ncomp = 5
)

cmp_stream <- pca_compare(
  list(
    batch = fit_full_stream,
    incremental = fit_inc
  ),
  ncomp = 5
)

cmp_stream$subspace_angles
```

For the same covariance target, the incremental and batch eigenspaces
should agree to numerical precision apart from sign orientation and
potential rotations within tied eigenspaces.

------------------------------------------------------------------------

## Part XII. Supplementary information, groups, prediction, and projection

### Connecting structured PCA to experimental questions

Structured extensions should preserve the design logic that generated
the matrix. In designed experiments, ASCA decomposes multivariate
variation according to specified model terms before component analysis
of effect matrices. In multiblock problems, the analyst must define what
constitutes a block and whether each block should be scaled before
concatenation. In streaming problems, incremental updates are
computational devices and should be validated against a batch fit
whenever feasible.

A useful pre-analysis table is:

| Question | Structure to preserve | Suitable pcaLab route |
|----|----|----|
| Which multivariate treatment effects dominate a factorial experiment? | design matrix and effect terms | [`pca_asca()`](https://wep69.github.io/pcaLab/reference/pca_asca.md) |
| How do soil, plant, and spectral blocks contribute to a common latent space? | block identity and block scaling | [`pca_multiblock()`](https://wep69.github.io/pcaLab/reference/pca_multiblock.md) |
| How do repeated observations separate within and between subjects? | subject identity | `pca_fit(method = "multilevel")` |
| How can a very large dataset be processed batch by batch? | running covariance/mean state | `pca_incremental_*()` |

### Where to continue

Continue to `08-tours-publication-reporting.Rmd` for exploratory
projection and scientific communication.

### Reproducibility note

The examples use package-generated or explicitly simulated teaching
data. They demonstrate workflow and interpretation, not empirical
evidence. For stochastic procedures, set and report a seed. For optional
engines, record backend versions with
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) and preserve
the preprocessing specification used to create the fitted object.
