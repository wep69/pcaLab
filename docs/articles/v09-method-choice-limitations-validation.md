# Choosing the Right PCA: Method Comparison, Failure Modes, State of the Art, and Validation

## Choosing the Right PCA: Method Comparison, Failure Modes, State of the Art, and Validation

**Package:** `pcaLab`\
**Target version:** `0.1.0`\
**Role in the vignette system:** Decision-oriented guidance for
comparing methods, recognizing when PCA is inappropriate, positioning
pcaLab scientifically, and validating analyses and releases.

> This source is intentionally instructional. It is not precompiled
> here. Code that requires an optional backend is guarded in the
> examples or should be run only after
> [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md)
> confirms availability.

### Learning objectives

The reader will learn to:

1.  compare candidate PCA methods on quantities that are genuinely
    comparable;
2.  avoid ranking methods by a metric that has different meanings across
    geometries;
3.  recognize weak-correlation, isotropic, curved, discrete,
    compositional, repeated, temporal, functional, and supervised
    problems where ordinary PCA is inadequate;
4.  distinguish exploratory separation from supervised discrimination;
5.  use
    [`pca_doctor()`](https://wep69.github.io/pcaLab/reference/pca_doctor.md)
    as a diagnostic aid rather than an automatic method selector;
6.  recognize common interpretation errors involving scaling, signs,
    loading thresholds, retention rules, and flagged observations;
7.  understand the integration gap that motivates `pcaLab`;
8.  validate statistical invariances, optional backends, documentation,
    vignettes, and final package archives before release.

### Scope and relationship to the other vignettes

This vignette is intentionally focused. It develops the topics below in
depth and avoids reproducing material assigned to other blocks.

**Developed here:** Decision-oriented guidance for comparing methods,
recognizing when PCA is inappropriate, positioning pcaLab
scientifically, and validating analyses and releases.

**Not developed here:** Detailed algebra and individual engine tutorials
are located in the preceding vignettes.

## Part XV. Comparing methods without turning PCA into a leaderboard

### 46. Compare candidate methods on common quantities

A comparison can be generated from raw data:

``` r

cmp_auto <- pca_compare(
  X,
  methods = c("classical", "rpca"),
  ncomp = 2,
  center = TRUE,
  scale = TRUE
)

cmp_auto$metrics
cmp_auto$subspace_angles
```

Or from already fitted models:

``` r

fit_classic2 <- pca_fit(
  X,
  method = "classical",
  center = TRUE,
  scale = TRUE,
  ncomp = 2
)

fit_ppca2 <- pca_fit(
  X,
  method = "ppca",
  center = TRUE,
  scale = TRUE,
  ncomp = 2
)

cmp_fitted <- pca_compare(
  list(
    classical = fit_classic2,
    ppca = fit_ppca2
  ),
  ncomp = 2
)

cmp_fitted$metrics
```

The common comparison table can contain:

- retained variance where defined;
- reconstruction RMSE where reconstruction is defined;
- loading sparsity;
- component count;
- pairwise subspace angles when explicit compatible loading matrices
  exist.

#### Interpretation

The smallest reconstruction error is not automatically the best method.
Kernel PCA, generalized PCA, sparse PCA, robust PCA, and ordinary PCA
can optimize different targets.

Compare methods only on metrics that are meaningful for both methods,
and keep the scientific reason for each candidate visible.

------------------------------------------------------------------------

## Part XVI. Three complete workflows

## Part XVIII. Common mistakes and the functions that help prevent them

### 51. Standardizing automatically without considering units

Use:

``` r

pca_preprocess()
pca_teach_scaling()
pca_doctor()
```

Unit-variance scaling is often sensible when variables are measured in
different units, but it changes the scientific weighting of the
variables.

------------------------------------------------------------------------

### 52. Treating eigenvalues as mysterious software output

Use:

``` r

pca_teach_variance()
pca_teach_eigen()
pca_teach_svd()
```

Remember:

``` math
\lambda_k = \operatorname{Var}(PC_k)
```

for ordinary linear PCA, and

``` math
\lambda_k = d_k^2/(n-1).
```

------------------------------------------------------------------------

### 53. Interpreting PC signs as absolute biological directions

Use:

``` r

pca_boot()
pca_stability()
```

A sign reversal of every loading and score on one component leaves the
PCA unchanged.

------------------------------------------------------------------------

### 54. Assuming uncorrelated means independent

PCA components are constructed to be uncorrelated in ordinary PCA.
Statistical independence is stronger and generally does not follow
unless additional distributional conditions hold.

------------------------------------------------------------------------

### 55. Selecting components only because cumulative variance exceeds 80% or 90%

Use:

``` r

pca_ncomp()
pca_parallel()
pca_cv()
pca_stability()
```

Report disagreement among criteria.

------------------------------------------------------------------------

### 56. Declaring treatment separation significant from a score plot

Use group labels only as supplementary overlays:

``` r

pca_group()
pca_plot()
```

For designed multivariate effects, consider:

``` r

pca_asca()
```

------------------------------------------------------------------------

### 57. Calling every large loading important

Use:

``` r

pca_associate()
pca_table(type = "variables")
pca_plot(type = "contributions")
pca_plot(type = "cos2")
```

Combine effect magnitude, representation, inference, and stability.

------------------------------------------------------------------------

### 58. Ignoring nearly tied eigenvalues

Use:

``` r

pca_stability()
```

Interpret the stable subspace if individual axes are unstable.

------------------------------------------------------------------------

### 59. Deleting observations only because diagnostics flag them

Use:

``` r

pca_diagnose()
pca_compare()
pca_fit(method = "robust")
pca_fit(method = "cellwise")
```

Investigate provenance and perform sensitivity analysis.

------------------------------------------------------------------------

### 60. Using ROBPCA for cellwise corruption

Casewise and cellwise contamination are different problems.

Use:

``` r

pca_fit(method = "robust")
pca_fit(method = "cellwise")
```

according to the contamination mechanism.

------------------------------------------------------------------------

### 61. Calling RPCA/PCP and ROBPCA the same method

They solve different mathematical problems.

``` r

pca_fit(method = "rpca")
pca_fit(method = "robust")
```

The first decomposes a matrix into low-rank and sparse parts. The second
estimates a resistant principal subspace under rowwise contamination.

------------------------------------------------------------------------

### 62. Using ordinary PCA on binary or count matrices without thinking about geometry

Consider:

``` r

pca_fit(method = "logistic")
pca_fit(method = "glmpca")
```

Do not automatically transfer Gaussian eigenvalue rules to generalized
PCA.

------------------------------------------------------------------------

### 63. Using ordinary PCA directly on compositions

Use:

``` r

pca_fit(method = "compositional")
```

and report the log-ratio coordinate system and any zero replacement.

------------------------------------------------------------------------

### 64. Treating time-lagged observations as independent columns without documenting the lag embedding

Use:

``` r

pca_fit(method = "dynamic")
```

and report `lags`, `include_current`, scaling, and the interpretation of
lagged variables.

------------------------------------------------------------------------

### 65. Mixing within-subject and between-subject covariance

Use:

``` r

pca_fit(method = "multilevel", level = "within")
pca_fit(method = "multilevel", level = "between")
```

when repeated measures create distinct covariance levels.

------------------------------------------------------------------------

### 66. Using advanced methods simply because they are available

Use:

``` r

pca_capabilities()
pca_doctor()
pca_compare()
```

The correct engine is the one whose assumptions match the scientific
structure, not the one with the most elaborate name.

------------------------------------------------------------------------

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

## Part XXI. Suggested focused vignettes after this tutorial

After completing this tutorial, use the focused package material
approximately in this order:

1.  `01-intuition.Rmd`
2.  `02-eigen-svd.Rmd`
3.  `03-preprocessing.Rmd`
4.  `04-interpretation.Rmd`
5.  `05-number-components.Rmd`
6.  `06-inference.Rmd`
7.  `07-bootstrap-stability.Rmd`
8.  `08-missing-data.Rmd`
9.  `09-robust.Rmd`
10. `10-cellwise.Rmd`
11. `11-sparse.Rmd`
12. `12-rpca.Rmd`
13. `13-high-dimensional.Rmd`
14. `14-probabilistic.Rmd`
15. `15-nonlinear.Rmd`
16. `16-generalized.Rmd`
17. `17-compositional.Rmd`
18. `18-functional.Rmd`
19. `19-dynamic.Rmd`
20. `20-structured.Rmd`
21. `21-touring.Rmd`
22. `22-publication.Rmd`
23. `23-state-of-the-art.Rmd`
24. `24-when-not-pca.Rmd`

This additional tutorial is intentionally broader than those focused
vignettes. It is designed to be the first long-form entry point into the
entire package ecosystem.

------------------------------------------------------------------------

## Appendix A. Complete 44-block registry

| Block | Requirement | Main implementation | Principal public interface |
|---:|----|----|----|
| 1 | State of the art | dedicated vignette and references | state-of-the-art documentation |
| 2 | Gap analysis | competitor matrix and rationale | state-of-the-art documentation |
| 3 | Scope and taxonomy | separation of PCA families and neighboring embeddings | README and method vignettes |
| 4 | Mathematical foundations | rotation, variance, covariance, projections | [`pca_teach_rotation()`](https://wep69.github.io/pcaLab/reference/pca_teach_rotation.md), [`pca_teach_variance()`](https://wep69.github.io/pcaLab/reference/pca_teach_variance.md) |
| 5 | Eigenvalues, eigenvectors, SVD | eigen problem, SVD, sign ambiguity | [`pca_teach_eigen()`](https://wep69.github.io/pcaLab/reference/pca_teach_eigen.md), [`pca_teach_svd()`](https://wep69.github.io/pcaLab/reference/pca_teach_svd.md) |
| 6 | Audit and preprocessing | missingness, scales, transformations, zero variance | [`pca_preprocess()`](https://wep69.github.io/pcaLab/reference/pca_preprocess.md), [`pca_doctor()`](https://wep69.github.io/pcaLab/reference/pca_doctor.md) |
| 7 | Package architecture | unified fit object and engine registry | [`pca_fit()`](https://wep69.github.io/pcaLab/reference/pca_fit.md), [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md) |
| 8 | Classical PCA | SVD PCA | `pca_fit(method="classical")` |
| 9 | Weighted and scaled PCA | observation weighting and scaling strategies | `pca_fit(method="weighted")` |
| 10 | Scores and loadings | common score/loading metrics | [`summary()`](https://rdrr.io/r/base/summary.html), [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md) |
| 11 | Representation quality | cos², contributions, communalities, reconstruction | [`pca_reconstruct()`](https://wep69.github.io/pcaLab/reference/pca_reconstruct.md), [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md) |
| 12 | Number of components | scree, cumulative, Kaiser, broken-stick, parallel, RMT, CV, stability, PPCA-BIC | [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md), [`pca_parallel()`](https://wep69.github.io/pcaLab/reference/pca_parallel.md), [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md) |
| 13 | Global PCA significance | permutation Psi/Phi | [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md) |
| 14 | Axis inference | permuted eigenvalue/rank-of-roots evidence | [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md) |
| 15 | Variable-PC association | effect, cos², contribution, FDR, stability | [`pca_associate()`](https://wep69.github.io/pcaLab/reference/pca_associate.md) |
| 16 | Bootstrap | eigenvalue, PVE, loading, correlation intervals | [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md) |
| 17 | Stability | matching, sign alignment, principal angles | [`pca_stability()`](https://wep69.github.io/pcaLab/reference/pca_stability.md) |
| 18 | Diagnostics and influence | score distance, orthogonal distance, leverage | [`pca_diagnose()`](https://wep69.github.io/pcaLab/reference/pca_diagnose.md) |
| 19 | Casewise robust PCA | ROBPCA adapter | `pca_fit(method="robust")` |
| 20 | Cellwise robust PCA | MacroPCA adapter | `pca_fit(method="cellwise")` |
| 21 | Low-rank + sparse RPCA | internal PCP/IALM | `pca_fit(method="rpca")` |
| 22 | Sparse PCA | sparsepca/elasticnet adapters | `pca_fit(method="sparse")` |
| 23 | Robust sparse PCA | rospca/sparsepca adapters | `pca_fit(method="robust_sparse")` |
| 24 | High-dimensional PCA | shrinkage, randomized SVD, RMT screening | `method="shrinkage"`, `method="randomized"` |
| 25 | Missing-data PCA | NIPALS, EM, Bayesian backend | `method="nipals"`, `"em"`, `"bayesian"` |
| 26 | Probabilistic PCA | closed-form PPCA workflow | `method="ppca"` |
| 27 | Bayesian PCA | pcaMethods BPCA adapter | `method="bayesian"` |
| 28 | Kernel PCA | internal RBF, polynomial, linear kernels | `method="kernel"` |
| 29 | Nonlinear PCA | inverse NLPCA adapter | `method="nlpca"` |
| 30 | Generalized PCA | logistic and exponential-family PCA | `method="logistic"`, `method="glmpca"` |
| 31 | Compositional PCA | CLR/ILR geometry | `method="compositional"` |
| 32 | Functional PCA | dense-grid FPCA and MFPCA adapter | `method="functional"` |
| 33 | Dynamic PCA | lag embedding, optional robust base | `method="dynamic"` |
| 34 | Structured PCA | multilevel, ASCA, multiblock | `method="multilevel"`, [`pca_asca()`](https://wep69.github.io/pcaLab/reference/pca_asca.md), [`pca_multiblock()`](https://wep69.github.io/pcaLab/reference/pca_multiblock.md) |
| 35 | Incremental PCA | online mean/covariance aggregation | [`pca_incremental_init()`](https://wep69.github.io/pcaLab/reference/pca_incremental_init.md), [`pca_incremental_update()`](https://wep69.github.io/pcaLab/reference/pca_incremental_update.md), [`pca_incremental_finalize()`](https://wep69.github.io/pcaLab/reference/pca_incremental_finalize.md) |
| 36 | Tuning and validation | masked CV and engine-aware criteria | [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md), [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md) |
| 37 | Method comparison | reconstruction and subspace metrics | [`pca_compare()`](https://wep69.github.io/pcaLab/reference/pca_compare.md) |
| 38 | Supplementary information | new observations, variables, post-hoc groups | [`pca_supplementary()`](https://wep69.github.io/pcaLab/reference/pca_supplementary.md), [`pca_group()`](https://wep69.github.io/pcaLab/reference/pca_group.md) |
| 39 | Static publication graphics | ggplot2 figure system | [`pca_plot()`](https://wep69.github.io/pcaLab/reference/pca_plot.md), [`pca_export_plot()`](https://wep69.github.io/pcaLab/reference/pca_export_plot.md) |
| 40 | 3D, interactivity, and touring | Plotly and tourr integration | `pca_plot(type="scores3d")`, [`pca_tour()`](https://wep69.github.io/pcaLab/reference/pca_tour.md) |
| 41 | Tables and reporting | structured tables and export | [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md), [`pca_export_table()`](https://wep69.github.io/pcaLab/reference/pca_export_table.md), [`pca_report()`](https://wep69.github.io/pcaLab/reference/pca_report.md) |
| 42 | Expanded teaching module | ten teaching functions plus Shiny app | `pca_teach_*()`, [`pca_teach_app()`](https://wep69.github.io/pcaLab/reference/pca_teach_app.md) |
| 43 | Scientific/computational validation | tests and known-truth simulations | `tests/`, `inst/validation/` |
| 44 | Documentation and release | vignettes, README, citations, validation guide | package documentation |

------------------------------------------------------------------------

## Scientific positioning and ecosystem gap

### Scientific positioning

pcaLab does not claim that existing PCA software lacks advanced
algorithms. Its contribution is a unified workflow that links pedagogy,
dimensionality selection, inferential reference models,
bootstrap/subspace stability, robust/nonlinear/structured extensions,
tours, diagnostics, and publication outputs.

Important neighboring packages include base R `prcomp`,
FactoMineR/factoextra for conventional exploration, PCAtools for
high-quality PCA workflows, pcaMethods for missing-data and
Bayesian/nonlinear methods, rospca/rrcov for robust methods, cellWise
for cellwise robustness, sparsepca/elasticnet for sparse methods,
logisticPCA and glmpca for generalized low-rank models, MFPCA for
multivariate functional PCA, irlba for truncated SVD, and tourr for
projection tours.

### Design gap

The gap is the lack of a single auditable path from “what is an
eigenvector?” to “is this axis stronger than a null reference?”, “is
this loading stable under resampling?”, “would robust PCA change the
subspace?”, and “can the final figure/table be exported for
publication?”

### Reference basis

The teaching sequence is inspired by Saccenti (2024), while permutation
inference follows the conceptual organization of Camargo’s PCAtest. The
package source bibliography also records foundational and advanced PCA
references.

See `STATE_OF_ART.md` and `inst/references/REFERENCES.bib` in the source
package for the maintained reference list.

## When PCA is not the right tool

### Weak correlation or isotropic structure

If variables are nearly uncorrelated and have similar standardized
variance, no small set of linear directions may dominate. A flat
eigenspectrum is an informative result rather than a software failure.

### Curved manifolds

Linear PCA may miss nonlinear dependence. Compare kernel or nonlinear
methods only when the scientific objective supports nonlinear
coordinates.

### Discrete outcomes

Binary/count data can require logistic or generalized PCA rather than
Gaussian covariance PCA.

### Compositions

Closed proportions should usually be analyzed in log-ratio geometry
rather than directly.

### Repeated, temporal, functional, and multiblock data

Ignoring data structure can produce misleading uncertainty and component
interpretation. Use the corresponding structured methods when the design
requires them.

### Supervised separation is a different objective

PCA is not a classifier and does not seek group separation. Coloring
score plots by treatment after fitting is descriptive. If the scientific
question is a treatment effect, use a design-based multivariate
inferential model, ASCA/permutation design, discriminant method, mixed
model, or other approach appropriate to the experiment.

``` r

ex <- pca_example_agronomy()
d <- pca_doctor(ex$data)
d$warnings
d$suggestions
```

### A practical decision rule

Use PCA when the scientific question concerns dominant
variance/covariance structure and a linear low-dimensional
representation is meaningful. Select another method because its estimand
matches the scientific question, not because it gives a visually cleaner
plot.

### Local validation sequence before release

The documentation layer should be tested as part of the package, not as
an afterthought. A release-oriented local run should include, at
minimum:

1.  install all mandatory dependencies;
2.  install the development package into a clean library;
3.  run `testthat` tests;
4.  execute `inst/validation/validate_core.R`;
5.  execute optional-engine validation only for installed backends;
6.  build all R Markdown vignettes;
7.  inspect every warning about missing optional dependencies;
8.  run `R CMD build`;
9.  install the generated tarball into another clean library;
10. run `R CMD check --as-cran` on that exact tarball;
11. inspect examples, documentation aliases, URLs, package size, and
    undeclared globals;
12. verify deterministic outputs under frozen seeds and numerical
    tolerances;
13. render publication figures at their final dimensions;
14. verify that tables and reports preserve labels, units, and component
    numbering;
15. archive [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html),
    test logs, and checksums with the release candidate.

The package-level file `LOCAL_VALIDATION.md` remains the authoritative
operational checklist. This vignette explains the statistical logic
behind those checks rather than duplicating every shell command.

### Where to continue

Return to `00-start-here-integrated-workflow.Rmd` for a complete
end-to-end analysis, or use `10-teaching-lab-course-sequence.Rmd` to
teach PCA progressively.

### Reproducibility note

The examples use package-generated or explicitly simulated teaching
data. They demonstrate workflow and interpretation, not empirical
evidence. For stochastic procedures, set and report a seed. For optional
engines, record backend versions with
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) and preserve
the preprocessing specification used to create the fitted object.
