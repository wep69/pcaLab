# Start Here: An Integrated pcaLab Workflow from Data Audit to Scientific Reporting

## Start Here: An Integrated pcaLab Workflow from Data Audit to Scientific Reporting

**Package:** `pcaLab`\
**Target version:** `0.1.0`\
**Role in the vignette system:** An end-to-end entry point that links
the package blocks without duplicating the detailed theory reserved for
the focused vignettes.

> This source is intentionally instructional. It is not precompiled
> here. Code that requires an optional backend is guarded in the
> examples or should be run only after
> [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md)
> confirms availability.

### Learning objectives

After completing this vignette, the reader should be able to:

1.  recognize the main families of PCA available in `pcaLab`;
2.  begin every analysis with data geometry and preprocessing rather
    than with a biplot;
3.  fit a defensible classical reference model;
4.  select dimensionality using multiple sources of evidence;
5.  add inference, bootstrap, stability, diagnostics, and supplementary
    groups in the correct order;
6.  escalate to robust, sparse, high-dimensional, or nonlinear PCA only
    when the data require it;
7.  export publication-ready figures, tables, and a reproducible report;
8.  locate the focused vignette that develops each advanced topic.

### Scope and relationship to the other vignettes

This vignette is intentionally focused. It develops the topics below in
depth and avoids reproducing material assigned to other blocks.

**Developed here:** An end-to-end entry point that links the package
blocks without duplicating the detailed theory reserved for the focused
vignettes.

**Not developed here:** The algebraic derivation of PCA, detailed robust
algorithms, generalized data geometries, and the mechanics of tours are
handled in dedicated vignettes.

### 1. Why this tutorial exists

Principal Component Analysis is often introduced through a short recipe:

1.  standardize the variables;
2.  run PCA;
3.  retain two components;
4.  draw a biplot;
5.  interpret the longest arrows.

That recipe is convenient, but it hides nearly every decision that
determines whether the analysis is scientifically meaningful.

A complete PCA workflow must answer several different questions:

- What geometry is appropriate for the data?
- Should the analysis use covariance or correlation structure?
- What exactly is an eigenvalue?
- Why are eigenvectors the principal directions?
- How are singular values related to PCA?
- What do scores and loadings represent?
- How should the number of components be chosen?
- When is a component stronger than expected under a null reference?
- Which variables are genuinely associated with a component?
- Are loadings stable under resampling?
- What happens when eigenvalues are nearly tied?
- Are observations influential or contaminated?
- Should PCA be robust, sparse, probabilistic, nonlinear, generalized,
  compositional, functional, dynamic, multilevel, or multiblock?
- Can new observations be projected without refitting?
- Are group labels being used only for interpretation, or are they
  accidentally making an unsupervised analysis supervised?
- How should results be reported in a reproducible and publication-ready
  way?

`pcaLab` is organized around these questions.

The central rule of this tutorial is:

**Understand the data geometry first. Fit the simplest PCA that answers
the scientific question. Select dimensionality deliberately. Diagnose
and resample before over-interpreting individual axes. Escalate to
advanced PCA only when the data structure requires it.**

The tutorial begins with rotation and variance, proceeds to eigenvalues,
eigenvectors, scores, loadings, dimensionality, inference, bootstrap,
and diagnostics, and then extends the same reasoning to robust, sparse,
missing-data, high-dimensional, nonlinear, generalized, compositional,
functional, dynamic, multilevel, multiblock, ASCA, incremental, and
touring workflows.

Most examples use synthetic agronomic or environmental data so that the
expected structure is known. They are suitable for teaching and software
validation, but they are not empirical field evidence.

------------------------------------------------------------------------

### 2. Learning objectives

After working through this tutorial, the reader should be able to:

1.  explain PCA geometrically as a rotation and projection problem;
2.  connect variance maximization to the Rayleigh quotient;
3.  explain why PCA leads to an eigenvalue-eigenvector problem;
4.  interpret eigenvalues as component variances in ordinary linear PCA;
5.  derive the relationship between eigendecomposition and singular
    value decomposition;
6.  distinguish scores, eigenvector loadings, correlation loadings,
    contributions, cos², and communalities;
7.  explain why component signs are arbitrary;
8.  explain why uncorrelated components are not necessarily
    statistically independent;
9.  understand why nearly equal eigenvalues can destabilize individual
    eigenvectors while leaving the joint subspace stable;
10. decide whether to center, unit-variance scale, Pareto scale, range
    scale, or avoid scaling;
11. audit missingness, zero variance, high dimensionality, possible
    outliers, and nonlinear structure before fitting PCA;
12. fit classical PCA through the unified
    [`pca_fit()`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
    interface;
13. select the number of components using several complementary
    criteria;
14. distinguish descriptive PCA from permutation-based inference;
15. quantify uncertainty in eigenvalues, loadings, correlations, and
    component stability using bootstrap resampling;
16. associate variables with components using effect size,
    representation quality, inference, and stability together;
17. diagnose high score distance, orthogonal distance, and leverage;
18. distinguish casewise robust PCA, cellwise robust PCA, sparse PCA,
    robust sparse PCA, and low-rank plus sparse RPCA;
19. handle missing values with NIPALS, EM-style PCA, probabilistic PCA,
    or Bayesian PCA when appropriate;
20. work with `p > n` settings using shrinkage or randomized approaches;
21. compare linear PCA with kernel and nonlinear alternatives;
22. use logistic PCA for binary data and GLM-PCA for exponential-family
    data without transferring Gaussian PCA rules blindly;
23. analyze compositions using log-ratio geometry;
24. analyze curves with functional PCA;
25. analyze lagged multivariate processes with dynamic PCA;
26. separate within-subject and between-subject variation with
    multilevel PCA;
27. decompose designed multivariate experiments with ASCA;
28. integrate multiple measurement blocks with multiblock PCA;
29. update covariance structure incrementally for streaming or very
    large datasets;
30. project supplementary observations and variables without refitting
    when the engine supports it;
31. use treatment, cultivar, environment, or class labels only as
    supplementary information in an unsupervised PCA;
32. explore nearby and alternative projections using local, guided,
    radial, and grand tours;
33. create publication-ready tables and figures;
34. export vector and high-resolution raster graphics;
35. generate a reproducible Markdown or HTML report;
36. navigate all 44 implementation blocks without having to learn the
    entire package at once.

------------------------------------------------------------------------

### 3. The package in one map

#### 3.1 Instructional stages

| Blocks | Instructional stage | Main functions and interfaces |
|---:|----|----|
| 1-5 | Scope, geometry, and mathematical foundations | [`pca_teach_rotation()`](https://wep69.github.io/pcaLab/reference/pca_teach_rotation.md), [`pca_teach_variance()`](https://wep69.github.io/pcaLab/reference/pca_teach_variance.md), [`pca_teach_eigen()`](https://wep69.github.io/pcaLab/reference/pca_teach_eigen.md), [`pca_teach_svd()`](https://wep69.github.io/pcaLab/reference/pca_teach_svd.md) |
| 6-9 | Data audit, preprocessing, architecture, and classical PCA | [`pca_doctor()`](https://wep69.github.io/pcaLab/reference/pca_doctor.md), [`pca_preprocess()`](https://wep69.github.io/pcaLab/reference/pca_preprocess.md), [`pca_fit()`](https://wep69.github.io/pcaLab/reference/pca_fit.md), [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md) |
| 10-11 | Scores, loadings, interpretation, and reconstruction | [`summary()`](https://rdrr.io/r/base/summary.html), [`pca_teach_scores()`](https://wep69.github.io/pcaLab/reference/pca_teach_scores.md), [`pca_teach_loadings()`](https://wep69.github.io/pcaLab/reference/pca_teach_loadings.md), [`pca_reconstruct()`](https://wep69.github.io/pcaLab/reference/pca_reconstruct.md) |
| 12 | Number of components | [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md), [`pca_parallel()`](https://wep69.github.io/pcaLab/reference/pca_parallel.md), [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md), [`pca_broken_stick()`](https://wep69.github.io/pcaLab/reference/pca_broken_stick.md) |
| 13-17 | Inference, bootstrap, and stability | [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md), [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md), [`pca_stability()`](https://wep69.github.io/pcaLab/reference/pca_stability.md), [`pca_associate()`](https://wep69.github.io/pcaLab/reference/pca_associate.md) |
| 18 | Diagnostics and influence | [`pca_diagnose()`](https://wep69.github.io/pcaLab/reference/pca_diagnose.md) |
| 19-23 | Robust and sparse PCA families | `pca_fit(method = "robust")`, `"cellwise"`, `"rpca"`, `"sparse"`, `"robust_sparse"` |
| 24-27 | High-dimensional, missing-data, probabilistic, and Bayesian PCA | `"shrinkage"`, `"randomized"`, `"nipals"`, `"em"`, `"ppca"`, `"bayesian"` |
| 28-30 | Kernel, nonlinear, and generalized PCA | `"kernel"`, `"nlpca"`, `"logistic"`, `"glmpca"` |
| 31-35 | Compositional, functional, dynamic, multilevel, ASCA, multiblock, and incremental PCA | `"compositional"`, `"functional"`, `"dynamic"`, `"multilevel"`, [`pca_asca()`](https://wep69.github.io/pcaLab/reference/pca_asca.md), [`pca_multiblock()`](https://wep69.github.io/pcaLab/reference/pca_multiblock.md), `pca_incremental_*()` |
| 36-38 | Validation, comparison, supplementary information, and groups | [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md), [`pca_compare()`](https://wep69.github.io/pcaLab/reference/pca_compare.md), [`pca_supplementary()`](https://wep69.github.io/pcaLab/reference/pca_supplementary.md), [`pca_group()`](https://wep69.github.io/pcaLab/reference/pca_group.md) |
| 39-41 | Figures, tours, tables, and reports | [`pca_plot()`](https://wep69.github.io/pcaLab/reference/pca_plot.md), [`pca_export_plot()`](https://wep69.github.io/pcaLab/reference/pca_export_plot.md), [`pca_tour()`](https://wep69.github.io/pcaLab/reference/pca_tour.md), [`pca_tour_compare()`](https://wep69.github.io/pcaLab/reference/pca_tour_compare.md), [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md), [`pca_export_table()`](https://wep69.github.io/pcaLab/reference/pca_export_table.md), [`pca_report()`](https://wep69.github.io/pcaLab/reference/pca_report.md) |
| 42 | Expanded teaching module | `pca_teach_*()`, [`pca_teach_app()`](https://wep69.github.io/pcaLab/reference/pca_teach_app.md) |
| 43-44 | Validation and release infrastructure | package tests, validation scripts, vignettes, local validation guide |

The progression is deliberate. The existence of an advanced engine is
not a reason to use it. A kernel PCA should solve a nonlinear structure
problem. A robust PCA should solve a contamination problem. A
compositional PCA should solve a compositional geometry problem. A
generalized PCA should solve a distributional geometry problem.

#### 3.2 Inspect the package programmatically

``` r

library(pcaLab)

# Which PCA engines are available on this computer?
caps <- pca_capabilities()
caps

# Only optional engines currently available.
subset(caps, available)
```

[`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md)
reports all 23 engine labels and the backend required by each one.
Several engines use only base R and are therefore always available.
Others require packages such as `rospca`, `cellWise`, `pcaMethods`,
`logisticPCA`, `glmpca`, `corpcor`, `MFPCA`, `sparsepca`, `elasticnet`,
or `irlba`.

A useful first rule is:

**Never build a scientific workflow around an optional engine before
checking that the backend is installed and before understanding what
geometry that engine optimizes.**

------------------------------------------------------------------------

### 4. Teaching datasets and realistic examples used in this tutorial

The package provides two core synthetic generators:

``` r

# Agronomy-oriented multivariate example.
ex <- pca_example_agronomy(seed = 42)
str(ex$data)
str(ex$metadata)

# Known-rank simulation with optional contamination and nonlinearity.
sim <- pca_simulate(
  n = 200,
  p = 10,
  rank = 3,
  noise = 0.30,
  seed = 42
)
```

The agronomy generator produces seven correlated variables measured on
72 synthetic plots:

| Variable               | Teaching interpretation  |
|------------------------|--------------------------|
| `plant_height`         | canopy structural growth |
| `leaf_area`            | leaf development         |
| `chlorophyll`          | pigment status           |
| `photosynthesis`       | carbon assimilation      |
| `stomatal_conductance` | gas-exchange response    |
| `biomass`              | accumulated dry matter   |
| `yield`                | harvested production     |

The supplementary metadata contain six synthetic treatments and four
blocks. Treatment is not part of the PCA fit unless the analyst
explicitly uses it later as supplementary information.

The generator intentionally contains two latent dimensions. A
treatment-linked latent gradient contributes positively to all seven
traits, while a second latent factor affects traits with different signs
and strengths. Consequently, a standardized classical PCA should usually
recover a dominant common plant-performance direction and a secondary
physiological contrast. The exact signs of those directions can reverse
without changing the model because eigenvectors have arbitrary
orientation.

Other examples are generated inside the tutorial so that specific PCA
families can be illustrated:

| Example | Data structure | PCA family |
|----|----|----|
| contaminated agronomic traits | rowwise outliers | ROBPCA |
| isolated corrupted measurements | cellwise contamination | MacroPCA |
| sparse trait signature | many weak variables | sparse PCA |
| low-rank matrix plus sparse corruption | additive sparse errors | RPCA/PCP |
| missing agronomic observations | incomplete matrix | NIPALS, EM, PPCA, BPCA |
| hyperspectral profile | hundreds of correlated wavelengths | randomized/shrinkage PCA |
| curved synthetic physiology | nonlinear manifold | kernel PCA, NLPCA |
| disease-presence indicators | binary 0/1 matrix | logistic PCA |
| species or taxon counts | non-negative counts | GLM-PCA |
| nutrient fractions | positive parts summing to a whole | compositional PCA |
| spectral or growth curves | functions on a dense grid | functional PCA |
| daily climate-physiology series | lagged dependence | dynamic PCA |
| repeated plant measurements | within and between structure | multilevel PCA |
| factorial multivariate experiment | designed effects | ASCA |
| soil + plant + spectral blocks | multiple data blocks | multiblock PCA |
| sequential sensor batches | streaming matrix | incremental PCA |

------------------------------------------------------------------------

## Integrated workflow I: agronomic PCA from audit to report

### 47. Basic integrated workflow: agronomic PCA from audit to report

This is the recommended first analysis for a new user.

#### Step 1. Load data and metadata

``` r

library(pcaLab)

ex <- pca_example_agronomy(seed = 42)
X <- ex$data
meta <- ex$metadata
```

#### Step 2. Audit the data

``` r

doc <- pca_doctor(
  X,
  scale = TRUE
)

doc$warnings
doc$suggestions
```

#### Step 3. Compare scaling choices

``` r

scaling <- pca_teach_scaling(X)
scaling$steps
```

#### Step 4. Fit a centered standardized classical PCA

``` r

fit <- pca_fit(
  X,
  method = "classical",
  center = TRUE,
  scale = TRUE
)
```

#### Step 5. Inspect the spectrum

``` r

pca_table(fit, "eigenvalues")
pca_plot(fit, "scree")
pca_plot(fit, "cumulative")
```

#### Step 6. Select dimensionality

``` r

selection <- pca_ncomp(
  fit,
  methods = "all",
  nperm = 499,
  nboot = 250,
  seed = 42
)

selection$recommendations
selection$consensus
```

#### Step 7. Inspect scores and groups descriptively

``` r

pca_plot(
  fit,
  type = "scores",
  group = meta$treatment
)
```

#### Step 8. Inspect variable interpretation

``` r

pca_plot(fit, "correlation_circle")
pca_plot(fit, "contributions", component = 1)
pca_plot(fit, "cos2", component = 1)
pca_table(fit, "variables", component = 1)
```

#### Step 9. Test whether the standardized PCA structure exceeds a permutation null

``` r

ptest <- pca_test(
  fit,
  nperm = 999,
  seed = 42
)
```

#### Step 10. Bootstrap uncertainty

``` r

boot <- pca_boot(
  fit,
  nboot = 1999,
  seed = 42
)
```

#### Step 11. Evaluate subspace stability

``` r

stab <- pca_stability(
  fit,
  nboot = 999,
  seed = 42
)

stab$summary
```

#### Step 12. Build variable associations

``` r

assoc <- pca_associate(
  fit,
  test = ptest,
  boot = boot
)

subset(assoc, combined_association)
```

#### Step 13. Diagnose observations

``` r

diag <- pca_diagnose(fit)
subset(diag, outlier_flag)

pca_plot(fit, "diagnostics")
```

#### Step 14. Add treatment centroids and bootstrap regions

``` r

grp <- pca_group(
  fit,
  meta$treatment,
  region = "bootstrap",
  nboot = 999,
  seed = 42
)

pca_plot(
  fit,
  "scores",
  group = meta$treatment,
  group_region = grp
)
```

#### Step 15. Export the main outputs

``` r

pca_export_plot(
  pca_plot(fit, "scree"),
  "Figure_1_scree.pdf"
)

pca_export_plot(
  pca_plot(fit, "correlation_circle"),
  "Figure_2_correlation_circle.pdf"
)

pca_export_table(
  pca_table(fit, "eigenvalues"),
  "Table_1_eigenvalues.csv"
)
```

#### Step 16. Create a reproducible report

``` r

pca_report(
  fit,
  "agronomy_pca_report.md",
  inference = ptest,
  selection = selection,
  bootstrap = boot
)
```

#### Basic interpretation template

A concise scientific interpretation should report:

1.  why variables were centered and scaled;
2.  how many components were retained and which criteria supported that
    choice;
3.  the amount of variance represented by the retained components;
4.  which variables were strongly and stably associated with each
    interpreted axis;
5.  whether the standardized correlation structure exceeded the
    permutation null reference;
6.  whether individual loadings and the joint subspace were stable under
    bootstrap resampling;
7.  whether influential observations were present;
8.  how supplementary treatment groups occupied the PC space;
9.  that treatment labels were not used to construct the unsupervised
    axes;
10. the limitations of interpreting only a two-dimensional projection.

------------------------------------------------------------------------

### 48. Advanced integrated workflow: contamination, sparsity, and sensitivity

## Integrated workflow II: contamination, sparsity, and sensitivity

### 48. Advanced integrated workflow: contamination, sparsity, and sensitivity

#### Stage A. Simulate a difficult matrix

``` r

hard <- pca_simulate(
  n = 220,
  p = 30,
  rank = 3,
  eigenvalues = c(6, 3.5, 1.5),
  noise = 0.40,
  casewise = 0.06,
  cellwise = 0.015,
  seed = 7001
)

Xhard <- hard$data
```

#### Stage B. Audit

``` r

pca_doctor(
  Xhard,
  scale = TRUE
)
```

#### Stage C. Classical reference

``` r

m_classical <- pca_fit(
  Xhard,
  method = "classical",
  center = TRUE,
  scale = TRUE,
  ncomp = 3
)
```

#### Stage D. Casewise robust alternative

``` r

if (requireNamespace("rospca", quietly = TRUE)) {
  m_robust <- pca_fit(
    Xhard,
    method = "robust",
    center = TRUE,
    scale = TRUE,
    ncomp = 3
  )
}
```

#### Stage E. Cellwise alternative

``` r

if (requireNamespace("cellWise", quietly = TRUE)) {
  m_cellwise <- pca_fit(
    Xhard,
    method = "cellwise",
    center = TRUE,
    scale = TRUE,
    ncomp = 3
  )
}
```

#### Stage F. Sparse alternative

``` r

if (requireNamespace("sparsepca", quietly = TRUE)) {
  m_sparse <- pca_fit(
    Xhard,
    method = "sparse",
    center = TRUE,
    scale = TRUE,
    ncomp = 3
  )
}
```

#### Stage G. Low-rank plus sparse decomposition

``` r

m_rpca <- pca_fit(
  Xhard,
  method = "rpca",
  center = TRUE,
  scale = TRUE,
  ncomp = 3
)
```

#### Stage H. Compare only defensible common metrics

``` r

mods <- list(classical = m_classical, rpca = m_rpca)

if (exists("m_robust")) mods$robust <- m_robust
if (exists("m_cellwise")) mods$cellwise <- m_cellwise
if (exists("m_sparse")) mods$sparse <- m_sparse

cmp_hard <- pca_compare(
  mods,
  ncomp = 3
)

cmp_hard$metrics
cmp_hard$subspace_angles
```

#### Advanced interpretation template

Frame this as a sensitivity study, not a contest:

- Does the classical subspace move materially under casewise resistance?
- Are isolated corrupted cells the dominant problem?
- Does sparsity improve interpretability at acceptable cost in
  reconstruction?
- Does the low-rank plus sparse decomposition recover the known signal
  more cleanly?
- Which variables remain important across defensible methods?
- Are conclusions stable enough to report, or method-dependent enough
  that sensitivity must be emphasized?

------------------------------------------------------------------------

## Integrated workflow III: high-dimensional and nonlinear screening

### 49. Advanced integrated workflow: high-dimensional and nonlinear screening

#### Stage A. Generate a high-dimensional nonlinear problem

``` r

hdnl <- pca_simulate(
  n = 100,
  p = 300,
  rank = 4,
  eigenvalues = c(8, 5, 3, 2),
  noise = 0.60,
  nonlinear = TRUE,
  seed = 7002
)

Xhdnl <- hdnl$data
```

#### Stage B. Diagnose geometry

``` r

pca_doctor(
  Xhdnl,
  scale = TRUE,
  nonlinear_check = TRUE
)
```

#### Stage C. Randomized linear PCA

``` r

hd_linear <- pca_fit(
  Xhdnl,
  method = "randomized",
  center = TRUE,
  scale = TRUE,
  ncomp = 8,
  seed = 7002
)
```

#### Stage D. Select linear rank using appropriate evidence

``` r

hd_sel <- pca_ncomp(
  pca_fit(Xhdnl, method = "classical", center = TRUE, scale = TRUE),
  methods = c("scree", "parallel", "rmt", "cv"),
  nperm = 299,
  seed = 7002
)

hd_sel$recommendations
```

#### Stage E. Fit kernel PCA to test nonlinear structure

``` r

hd_kernel <- pca_fit(
  Xhdnl,
  method = "kernel",
  center = TRUE,
  scale = TRUE,
  ncomp = 3,
  kernel = "rbf"
)
```

#### Stage F. Compare visual structure rather than forcing one metric

``` r

pca_plot(hd_linear, type = "scores")
pca_plot(hd_kernel, type = "scores")
```

#### Interpretation

If the kernel representation reveals a coherent curved organization that
ordinary PCA compresses poorly, that supports investigating nonlinear
geometry. It does not automatically mean the kernel solution is
preferable for every purpose. Linear PCA remains easier to interpret,
project, reconstruct, and connect to original variables.

------------------------------------------------------------------------

## Compact function-selection guide

## Part XIX. Compact function-selection guide

| Scientific question | Start with | Escalate when needed |
|----|----|----|
| Are my variables suitable for ordinary PCA? | [`pca_doctor()`](https://wep69.github.io/pcaLab/reference/pca_doctor.md) | inspect preprocessing, nonlinear, missing, or contamination alternatives |
| Should variables be scaled? | [`pca_teach_scaling()`](https://wep69.github.io/pcaLab/reference/pca_teach_scaling.md) | [`pca_preprocess()`](https://wep69.github.io/pcaLab/reference/pca_preprocess.md) with `uv`, Pareto, range, or VAST |
| How does PCA arise mathematically? | [`pca_teach_rotation()`](https://wep69.github.io/pcaLab/reference/pca_teach_rotation.md) | [`pca_teach_eigen()`](https://wep69.github.io/pcaLab/reference/pca_teach_eigen.md), [`pca_teach_svd()`](https://wep69.github.io/pcaLab/reference/pca_teach_svd.md) |
| I need ordinary linear PCA | `pca_fit(method="classical")` | weighted, shrinkage, randomized |
| How many PCs should I keep? | [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md) | inspect parallel analysis, CV, stability, PPCA-BIC separately |
| Is the standardized PCA structure stronger than a null? | [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md) | inspect global, axis, and variable-level evidence |
| Are loadings stable? | [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md) | [`pca_stability()`](https://wep69.github.io/pcaLab/reference/pca_stability.md) for subspaces |
| Which variables characterize a PC? | [`pca_associate()`](https://wep69.github.io/pcaLab/reference/pca_associate.md) | inspect `pca_table(...,"variables")` and bootstrap plots |
| Are observations influential? | [`pca_diagnose()`](https://wep69.github.io/pcaLab/reference/pca_diagnose.md) | compare robust or cellwise robust PCA |
| Whole rows are contaminated | `method="robust"` | robust sparse PCA if simple loadings are also required |
| Individual cells are corrupted | `method="cellwise"` | compare with RPCA when sparse additive corruption is plausible |
| I need a low-rank + sparse decomposition | `method="rpca"` | inspect sparse matrix and convergence |
| I need simpler loadings | `method="sparse"` | `method="robust_sparse"` under contamination |
| Data contain missing values | `method="nipals"` | `em`, `ppca`, `bayesian`, or `cellwise` |
| `p > n` | `method="randomized"` | shrinkage, sparse, PPCA, RMT screening |
| Structure is nonlinear | `method="kernel"` | `nlpca`, tours, or another nonlinear manifold method |
| Variables are binary | `method="logistic"` | use backend-specific rank validation |
| Variables are counts | `method="glmpca"` | choose family and rank by deviance/likelihood validation |
| Variables are proportions summing to a whole | `method="compositional"` | inspect ILR vs CLR and zero handling |
| Each observation is a curve | `method="functional"` | MFPCA for multivariate functional data |
| Data are multivariate time series | `method="dynamic"` | robust dynamic PCA if rowwise contamination is present |
| Repeated measurements mix levels | `method="multilevel"` | compare within and between PCA |
| Designed experiment has multivariate responses | [`pca_asca()`](https://wep69.github.io/pcaLab/reference/pca_asca.md) | add permutation testing |
| Several measurement blocks describe the same observations | [`pca_multiblock()`](https://wep69.github.io/pcaLab/reference/pca_multiblock.md) | compare block-scaling strategies |
| Data arrive in batches | `pca_incremental_*()` | replay observations for scores after finalization |
| I have new observations | [`predict()`](https://rdrr.io/r/stats/predict.html) | [`pca_supplementary()`](https://wep69.github.io/pcaLab/reference/pca_supplementary.md) |
| I have external variables | [`pca_supplementary()`](https://wep69.github.io/pcaLab/reference/pca_supplementary.md) | inspect correlations with fitted scores |
| I have treatment labels | [`pca_group()`](https://wep69.github.io/pcaLab/reference/pca_group.md) | ASCA if the inferential target is the treatment effect |
| I want publication figures | [`pca_plot()`](https://wep69.github.io/pcaLab/reference/pca_plot.md) | [`pca_export_plot()`](https://wep69.github.io/pcaLab/reference/pca_export_plot.md) |
| I want publication tables | [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md) | [`pca_export_table()`](https://wep69.github.io/pcaLab/reference/pca_export_table.md) |
| I want a reproducible report | [`pca_report()`](https://wep69.github.io/pcaLab/reference/pca_report.md) | render HTML locally if needed |
| I want alternative projections | [`pca_tour()`](https://wep69.github.io/pcaLab/reference/pca_tour.md) | [`pca_tour_compare()`](https://wep69.github.io/pcaLab/reference/pca_tour_compare.md) |
| I want to teach the method | `pca_teach_*()` | [`pca_teach_app()`](https://wep69.github.io/pcaLab/reference/pca_teach_app.md) |

------------------------------------------------------------------------

## Minimum reporting checklist

## Part XX. Minimum reporting checklist

Before a PCA result leaves the analysis notebook, thesis, report, or
manuscript, document:

scientific objective of the PCA;

number of observations and variables;

variable names and measurement units;

missing-data pattern;

transformations applied;

centering strategy;

scaling strategy;

whether covariance or correlation geometry was targeted;

PCA engine and backend;

number of retained components;

criteria used to select dimensionality;

disagreement among criteria;

eigenvalues and explained variance when valid for the engine;

score interpretation;

loading interpretation;

correlation loadings where used;

contributions and cos² where used;

whether loading sign indeterminacy was considered;

whether near-equal eigenvalues were present;

bootstrap replication count and seed, when used;

component matching and sign alignment strategy;

subspace stability results when appropriate;

null reference and permutation count for inferential PCA;

multiplicity adjustment for variable-level tests;

influence and orthogonal-distance diagnostics;

reason for using a robust PCA, if applicable;

whether contamination was casewise or cellwise;

reason for using sparse PCA, if applicable;

sparse-PCA tuning choices;

missing-data PCA method and assumptions;

nonlinear kernel and tuning parameters, if applicable;

generalized PCA family and rank-selection rule, if applicable;

compositional log-ratio coordinate and zero handling, if applicable;

functional grid and smoothing, if applicable;

dynamic lags, if applicable;

multilevel level definition, if applicable;

ASCA design formula and permutation strategy, if applicable;

multiblock scaling rule, if applicable;

whether group labels were supplementary or part of a designed-effect
model;

whether new observations were projected with training preprocessing;

observed scores shown together with group summaries where possible;

figure export format, dimensions, and resolution;

package and backend versions;

random seeds for stochastic procedures;

session information and reproducibility details;

limitations of interpreting only the displayed PC plane.

------------------------------------------------------------------------

## Complete exported-function map

## Appendix B. Complete exported-function map

The current package namespace exports the following user-facing
functions.

| Function | Primary role |
|----|----|
| [`pca_fit()`](https://wep69.github.io/pcaLab/reference/pca_fit.md) | unified PCA fitting interface |
| [`pca_preprocess()`](https://wep69.github.io/pcaLab/reference/pca_preprocess.md) | centering, scaling, transformation, and data audit |
| [`pca_reconstruct()`](https://wep69.github.io/pcaLab/reference/pca_reconstruct.md) | low-rank reconstruction |
| [`pca_doctor()`](https://wep69.github.io/pcaLab/reference/pca_doctor.md) | geometry and data-problem screening |
| [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md) | integrated component-number selection |
| [`pca_parallel()`](https://wep69.github.io/pcaLab/reference/pca_parallel.md) | parallel analysis |
| [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md) | masked reconstruction cross-validation |
| [`pca_broken_stick()`](https://wep69.github.io/pcaLab/reference/pca_broken_stick.md) | broken-stick reference proportions |
| [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md) | permutation-based PCA inference |
| [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md) | bootstrap uncertainty with component alignment |
| [`pca_stability()`](https://wep69.github.io/pcaLab/reference/pca_stability.md) | component and subspace stability |
| [`pca_associate()`](https://wep69.github.io/pcaLab/reference/pca_associate.md) | variable-component association synthesis |
| [`pca_diagnose()`](https://wep69.github.io/pcaLab/reference/pca_diagnose.md) | score-distance, orthogonal-distance, and leverage diagnostics |
| [`pca_compare()`](https://wep69.github.io/pcaLab/reference/pca_compare.md) | method comparison and subspace angles |
| [`pca_group()`](https://wep69.github.io/pcaLab/reference/pca_group.md) | supplementary group centroids and regions |
| [`pca_supplementary()`](https://wep69.github.io/pcaLab/reference/pca_supplementary.md) | supplementary observations and variables |
| [`pca_plot()`](https://wep69.github.io/pcaLab/reference/pca_plot.md) | principal publication-figure interface |
| [`pca_export_plot()`](https://wep69.github.io/pcaLab/reference/pca_export_plot.md) | figure export |
| [`pca_theme_publication()`](https://wep69.github.io/pcaLab/reference/pca_theme_publication.md) | publication theme |
| [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md) | structured PCA tables |
| [`pca_export_table()`](https://wep69.github.io/pcaLab/reference/pca_export_table.md) | table export |
| [`pca_report()`](https://wep69.github.io/pcaLab/reference/pca_report.md) | reproducible report generation |
| [`pca_tour()`](https://wep69.github.io/pcaLab/reference/pca_tour.md) | PCA-anchored projection tours |
| [`pca_tour_compare()`](https://wep69.github.io/pcaLab/reference/pca_tour_compare.md) | local, guided, and grand tour histories |
| [`pca_teach_rotation()`](https://wep69.github.io/pcaLab/reference/pca_teach_rotation.md) | teach planar rotation |
| [`pca_teach_variance()`](https://wep69.github.io/pcaLab/reference/pca_teach_variance.md) | teach variance maximization |
| [`pca_teach_eigen()`](https://wep69.github.io/pcaLab/reference/pca_teach_eigen.md) | teach eigenvalues and eigenvectors |
| [`pca_teach_svd()`](https://wep69.github.io/pcaLab/reference/pca_teach_svd.md) | teach SVD equivalence |
| [`pca_teach_scores()`](https://wep69.github.io/pcaLab/reference/pca_teach_scores.md) | teach observation scores |
| [`pca_teach_loadings()`](https://wep69.github.io/pcaLab/reference/pca_teach_loadings.md) | teach loading and variable metrics |
| [`pca_teach_reconstruction()`](https://wep69.github.io/pcaLab/reference/pca_teach_reconstruction.md) | teach low-rank approximation |
| [`pca_teach_scaling()`](https://wep69.github.io/pcaLab/reference/pca_teach_scaling.md) | compare covariance and correlation PCA |
| [`pca_teach_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_teach_ncomp.md) | teach dimensionality selection |
| [`pca_teach_biplot()`](https://wep69.github.io/pcaLab/reference/pca_teach_biplot.md) | teach biplot geometry |
| [`pca_teach_app()`](https://wep69.github.io/pcaLab/reference/pca_teach_app.md) | launch the Shiny teaching laboratory |
| [`pca_asca()`](https://wep69.github.io/pcaLab/reference/pca_asca.md) | ANOVA-Simultaneous Component Analysis |
| [`pca_multiblock()`](https://wep69.github.io/pcaLab/reference/pca_multiblock.md) | block-scaled consensus PCA |
| [`pca_incremental_init()`](https://wep69.github.io/pcaLab/reference/pca_incremental_init.md) | initialize streaming PCA state |
| [`pca_incremental_update()`](https://wep69.github.io/pcaLab/reference/pca_incremental_update.md) | update streaming covariance state |
| [`pca_incremental_finalize()`](https://wep69.github.io/pcaLab/reference/pca_incremental_finalize.md) | finalize incremental PCA |
| [`pca_simulate()`](https://wep69.github.io/pcaLab/reference/pca_simulate.md) | known-truth PCA simulation |
| [`pca_example_agronomy()`](https://wep69.github.io/pcaLab/reference/pca_example_agronomy.md) | synthetic agronomic teaching dataset |
| [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md) | report optional engine availability |

S3 methods also provide:

``` r

print(fit)
summary(fit)
plot(fit)
predict(fit, newdata = new_data)
fitted(fit)
residuals(fit)
```

------------------------------------------------------------------------

## A single starter script

## Appendix C. A single starter script

The following script is intentionally compact. It is suitable as the
first file a new user creates after installing `pcaLab`.

``` r

library(pcaLab)

# 1. Check available engines.
pca_capabilities()

# 2. Load the synthetic agronomic example.
ex <- pca_example_agronomy(seed = 42)
X <- ex$data
meta <- ex$metadata

# 3. Audit the geometry before fitting.
doc <- pca_doctor(
  X,
  scale = TRUE
)
print(doc$warnings)
print(doc$suggestions)

# 4. Fit standardized classical PCA.
fit <- pca_fit(
  X,
  method = "classical",
  center = TRUE,
  scale = TRUE
)

print(fit)
summary(fit)

# 5. Select dimensionality.
selection <- pca_ncomp(
  fit,
  methods = "all",
  nperm = 499,
  nboot = 200,
  seed = 42
)
print(selection$recommendations)

# 6. Descriptive visualization.
print(
  pca_plot(
    fit,
    type = "scores",
    group = meta$treatment
  )
)

print(
  pca_plot(
    fit,
    type = "correlation_circle"
  )
)

# 7. Permutation inference for standardized PCA structure.
ptest <- pca_test(
  fit,
  nperm = 999,
  seed = 42
)
print(ptest$global)
print(ptest$axes)

# 8. Bootstrap uncertainty and stability.
boot <- pca_boot(
  fit,
  nboot = 999,
  seed = 42
)

stab <- pca_stability(
  fit,
  nboot = 500,
  seed = 42
)
print(stab$summary)

# 9. Variable-component interpretation.
assoc <- pca_associate(
  fit,
  test = ptest,
  boot = boot
)
print(subset(assoc, combined_association))

# 10. Observation diagnostics.
diag <- pca_diagnose(fit)
print(subset(diag, outlier_flag))

# 11. Supplementary treatment regions.
grp <- pca_group(
  fit,
  meta$treatment,
  region = "bootstrap",
  nboot = 999,
  seed = 42
)

print(
  pca_plot(
    fit,
    type = "scores",
    group = meta$treatment,
    group_region = grp
  )
)

# 12. Scientific tables.
eigen_table <- pca_table(
  fit,
  type = "eigenvalues"
)

variable_table <- pca_table(
  fit,
  type = "associations",
  inference = ptest,
  bootstrap = boot,
  association = assoc
)

print(eigen_table)
print(variable_table)

# 13. Export one vector figure and one table.
pca_export_plot(
  pca_plot(fit, "scree"),
  "pca_scree.pdf",
  width = 7,
  height = 5,
  dpi = 600
)

pca_export_table(
  eigen_table,
  "pca_eigenvalues.csv"
)

# 14. Generate the reproducible Markdown report.
pca_report(
  fit,
  file = "pcaLab_starter_report.md",
  inference = ptest,
  selection = selection,
  bootstrap = boot
)
```

------------------------------------------------------------------------

## Appendix D. Advanced engine starter catalog

The following short examples are intended as syntax reminders. Each
should be used only when its data assumptions are appropriate.

### Classical

``` r

pca_fit(X, method = "classical", center = TRUE, scale = TRUE)
```

### Weighted

``` r

w <- rep(1, nrow(X))
w[1:5] <- 0.5

pca_fit(
  X,
  method = "weighted",
  center = TRUE,
  scale = TRUE,
  weights = w
)
```

### NIPALS

``` r

pca_fit(
  Xmiss,
  method = "nipals",
  center = TRUE,
  scale = TRUE,
  ncomp = 3
)
```

### EM-style PCA

``` r

pca_fit(
  Xmiss,
  method = "em",
  center = TRUE,
  scale = TRUE,
  ncomp = 3
)
```

### PPCA

``` r

pca_fit(
  X,
  method = "ppca",
  center = TRUE,
  scale = TRUE,
  ncomp = 3
)
```

### Bayesian PCA

``` r

if (requireNamespace("pcaMethods", quietly = TRUE)) {
  pca_fit(
    Xmiss,
    method = "bayesian",
    center = TRUE,
    scale = TRUE,
    ncomp = 3
  )
}
```

### ROBPCA

``` r

if (requireNamespace("rospca", quietly = TRUE)) {
  pca_fit(
    sim_case$data,
    method = "robust",
    center = TRUE,
    scale = TRUE,
    ncomp = 3
  )
}
```

### Cellwise MacroPCA

``` r

if (requireNamespace("cellWise", quietly = TRUE)) {
  pca_fit(
    sim_cell$data,
    method = "cellwise",
    center = TRUE,
    scale = TRUE,
    ncomp = 3
  )
}
```

### Sparse PCA

``` r

if (requireNamespace("sparsepca", quietly = TRUE)) {
  pca_fit(
    sim_sparse$data,
    method = "sparse",
    center = TRUE,
    scale = TRUE,
    ncomp = 3,
    backend = "sparsepca"
  )
}
```

### Robust sparse PCA

``` r

if (requireNamespace("rospca", quietly = TRUE)) {
  pca_fit(
    sim_rs$data,
    method = "robust_sparse",
    center = TRUE,
    scale = TRUE,
    ncomp = 3
  )
}
```

### RPCA/PCP

``` r

pca_fit(
  sim_rpca$data,
  method = "rpca",
  center = TRUE,
  scale = FALSE,
  ncomp = 3
)
```

### Kernel PCA

``` r

pca_fit(
  Xnl,
  method = "kernel",
  center = TRUE,
  scale = TRUE,
  ncomp = 2,
  kernel = "rbf"
)
```

### NLPCA

``` r

if (requireNamespace("pcaMethods", quietly = TRUE)) {
  pca_fit(
    Xnl,
    method = "nlpca",
    center = TRUE,
    scale = TRUE,
    ncomp = 2
  )
}
```

### Shrinkage PCA

``` r

if (requireNamespace("corpcor", quietly = TRUE)) {
  pca_fit(
    Xspec,
    method = "shrinkage",
    center = TRUE,
    scale = TRUE,
    ncomp = 5
  )
}
```

### Logistic PCA

``` r

if (requireNamespace("logisticPCA", quietly = TRUE)) {
  pca_fit(
    Xbin,
    method = "logistic",
    ncomp = 2
  )
}
```

### GLM-PCA

``` r

if (requireNamespace("glmpca", quietly = TRUE)) {
  pca_fit(
    Xcount,
    method = "glmpca",
    ncomp = 2,
    fam = "poi"
  )
}
```

### Compositional PCA

``` r

pca_fit(
  comp,
  method = "compositional",
  coordinate = "ilr",
  ncomp = 3
)
```

### Functional PCA

``` r

pca_fit(
  curve_mat,
  method = "functional",
  grid = wave,
  smooth = TRUE,
  ncomp = 4
)
```

### Dynamic PCA

``` r

pca_fit(
  Xtime,
  method = "dynamic",
  lags = 1:3,
  center = TRUE,
  scale = TRUE,
  ncomp = 4
)
```

### Multilevel PCA

``` r

pca_fit(
  Xml,
  method = "multilevel",
  subject = subject,
  level = "within",
  center = TRUE,
  scale = TRUE,
  ncomp = 3
)
```

### Multiblock PCA

``` r

pca_multiblock(
  list(
    soil = soil,
    plant = plant,
    spectral = spectral_block
  ),
  ncomp = 3,
  block_scale = "frobenius",
  center = TRUE,
  scale = TRUE
)
```

### Randomized PCA

``` r

pca_fit(
  Xspec,
  method = "randomized",
  center = TRUE,
  scale = TRUE,
  ncomp = 8,
  seed = 3001
)
```

### Incremental PCA

``` r

state <- pca_incremental_init(
  p = ncol(Xstream),
  center = TRUE,
  scale = TRUE
)

state <- pca_incremental_update(
  state,
  Xstream[1:500, ]
)

state <- pca_incremental_update(
  state,
  Xstream[501:1000, ]
)

pca_incremental_finalize(
  state,
  ncomp = 5
)
```

------------------------------------------------------------------------

## Final perspective

The most useful way to learn PCA is not to memorize a sequence of
software commands. It is to understand a sequence of questions.

For a beginner, the recommended path is:

**data audit -\> centering and scaling -\> rotation -\>
eigenvalues/eigenvectors -\> SVD -\> scores/loadings -\> scree and
reconstruction -\> biplot -\> careful interpretation.**

For an intermediate analyst, the path becomes:

**classical PCA -\> dimensionality criteria -\> permutation inference
-\> bootstrap -\> subspace stability -\> variable association -\>
diagnostics -\> publication outputs.**

For an advanced analyst, the path becomes:

**data geometry -\> ordinary linear reference -\>
contamination/missingness/high dimensionality/nonlinearity assessment
-\> method-specific PCA family -\> method-appropriate validation -\>
stability and sensitivity -\> supplementary interpretation -\> tours -\>
reproducible reporting.**

The 44 package blocks are therefore not 44 unrelated features. They form
one progressive analysis grammar.

The key ideas are:

1.  PCA is a geometric and statistical model, not only a plot.
2.  Eigenvalues and eigenvectors follow directly from maximizing
    projected variance under a unit-length constraint.
3.  SVD is the practical computational representation of the same
    ordinary PCA geometry.
4.  Scaling changes the scientific question.
5.  Scores describe observations; loadings define axes; correlation
    loadings, contributions, and cos² answer different interpretive
    questions.
6.  The number of components should not be chosen by one arbitrary rule.
7.  Descriptive PCA and inferential PCA are different layers of
    analysis.
8.  Bootstrap PCA requires component matching and sign alignment.
9.  Near-equal eigenvalues make subspace interpretation more defensible
    than rigid single-axis interpretation.
10. Robust, cellwise robust, sparse, RPCA, probabilistic, kernel,
    generalized, compositional, functional, dynamic, multilevel, and
    multiblock methods solve different problems.
11. Group labels should remain supplementary in an unsupervised PCA
    unless a designed method such as ASCA is intentionally used.
12. Publication-ready output should report uncertainty, preprocessing,
    dimensionality decisions, diagnostics, and limitations, not only a
    colorful biplot.

The purpose of `pcaLab` is to keep those ideas visible while allowing
the analyst to move from the first rotation of a two-dimensional point
cloud to advanced modern PCA workflows without losing the mathematical
meaning of the method.

### Where to continue

Continue with `01-foundations-eigen-svd-and-reconstruction.Rmd` for the
mathematical core, then `02-classical-preprocessing-interpretation.Rmd`
for the ordinary scientific workflow. Readers already comfortable with
PCA can move directly to the focused advanced vignette relevant to their
data.

### Reproducibility note

The examples use package-generated or explicitly simulated teaching
data. They demonstrate workflow and interpretation, not empirical
evidence. For stochastic procedures, set and report a seed. For optional
engines, record backend versions with
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) and preserve
the preprocessing specification used to create the fitted object.
