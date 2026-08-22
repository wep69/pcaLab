# pcaLab 44-Block Implementation Matrix

This document maps the complete 44-block specification to concrete
package components. All blocks are implemented either as executable
functions, optional engine adapters, documentation, tests, or
validation/reporting infrastructure.

| Block | Requirement | Implementation | Main public interfaces | Validation focus |
|---:|----|----|----|----|
| 1 | State of the art | Dedicated vignette and reference inventory | `vignette("state-of-the-art")` | Metadata/reference review |
| 2 | Gap analysis | Competitor matrix and design rationale | state-of-the-art vignette | Feature-by-feature comparison |
| 3 | Scope and taxonomy | Explicit separation of PCA and neighboring embeddings | README, advanced-method vignettes | Terminology audit |
| 4 | Mathematical foundations | Centering, variance, covariance, correlation, projections, rotations | [`pca_teach_rotation()`](https://wep69.github.io/pcaLab/reference/pca_teach_rotation.md), [`pca_teach_variance()`](https://wep69.github.io/pcaLab/reference/pca_teach_variance.md) | Analytic examples |
| 5 | Eigenvalues/eigenvectors/SVD | Rayleigh problem, eigensystem, SVD equivalence, sign ambiguity | [`pca_teach_eigen()`](https://wep69.github.io/pcaLab/reference/pca_teach_eigen.md), [`pca_teach_svd()`](https://wep69.github.io/pcaLab/reference/pca_teach_svd.md) | Eigen-equation residuals; SVD equivalence |
| 6 | Audit/preprocessing | Units/scales, missingness, zero variance, transformations, scaling | [`pca_preprocess()`](https://wep69.github.io/pcaLab/reference/pca_preprocess.md), [`pca_doctor()`](https://wep69.github.io/pcaLab/reference/pca_doctor.md) | Scaling and NA tests |
| 7 | Package architecture | Unified `pca_fit` class and engine registry | [`pca_fit()`](https://wep69.github.io/pcaLab/reference/pca_fit.md), [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md) | Class invariants |
| 8 | Classical PCA | SVD PCA | `pca_fit(method="classical")` | Differential test against [`prcomp()`](https://rdrr.io/r/stats/prcomp.html) |
| 9 | Weighted/scaled PCA | Observation weights and multiple scaling strategies | `pca_fit(method="weighted")` | Weighted covariance checks |
| 10 | Scores/loadings | Scores, loading directions, correlation loadings | [`summary()`](https://rdrr.io/r/base/summary.html), [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md) | Projection identities |
| 11 | Representation quality | cos², contribution, communalities, reconstruction | [`pca_reconstruct()`](https://wep69.github.io/pcaLab/reference/pca_reconstruct.md), `pca_table(type="variables")` | Reconstruction monotonicity |
| 12 | Number of components | Geometry-gated Euclidean criteria + engine-specific validation + consensus | [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md), [`pca_parallel()`](https://wep69.github.io/pcaLab/reference/pca_parallel.md), [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md) | Known-rank simulations |
| 13 | Global PCA significance | Permutation Psi/Phi | [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md) | Null simulation calibration |
| 14 | Axis inference | Permuted eigenvalue/rank-of-roots evidence | [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md) | Signal/noise simulations |
| 15 | Variable-PC association | Effect + representation + FDR + stability | [`pca_associate()`](https://wep69.github.io/pcaLab/reference/pca_associate.md) | Planted loading simulations |
| 16 | Bootstrap | Eigenvalue/PVE/loading/correlation CIs | [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md) | Coverage simulations |
| 17 | Stability | Component matching, sign alignment, principal angles | [`pca_stability()`](https://wep69.github.io/pcaLab/reference/pca_stability.md) | Degenerate-eigenvalue scenarios |
| 18 | Diagnostics/influence | Score distance, orthogonal distance, leverage | [`pca_diagnose()`](https://wep69.github.io/pcaLab/reference/pca_diagnose.md) | Injected outliers |
| 19 | Casewise robust PCA | ROBPCA adapter | `pca_fit(method="robust")` | Contaminated simulations |
| 20 | Cellwise robust PCA | MacroPCA adapter | `pca_fit(method="cellwise")` | Cellwise contamination |
| 21 | Low-rank + sparse RPCA | Internal PCP/inexact ALM | `pca_fit(method="rpca")` | Low-rank+sparse recovery |
| 22 | Sparse PCA | `sparsepca`/`elasticnet` adapters | `pca_fit(method="sparse")` | Sparsity and reconstruction |
| 23 | Robust sparse PCA | `rospca`/`sparsepca` adapters | `pca_fit(method="robust_sparse")` | Outlier+sparsity simulations |
| 24 | High-dimensional PCA | Shrinkage, randomized SVD, Marchenko-Pastur criterion | `method="shrinkage"`, `method="randomized"`, `pca_ncomp(...,"rmt")` | p \>\> n tests |
| 25 | Missing-data PCA | NIPALS, EM, Bayesian backend | `method="nipals"`, `"em"`, `"bayesian"` | MCAR masking |
| 26 | Probabilistic PCA | Closed-form PPCA MLE | `pca_fit(method="ppca")` | Likelihood/reconstruction tests |
| 27 | Bayesian PCA | `pcaMethods` BPCA adapter | `pca_fit(method="bayesian")` | Optional backend tests |
| 28 | Kernel PCA | Internal RBF/polynomial/linear kernel PCA | `pca_fit(method="kernel")` | Kernel-centering and projection tests |
| 29 | Nonlinear PCA | Inverse NLPCA adapter | `pca_fit(method="nlpca")` | Optional backend tests |
| 30 | Generalized PCA | Binary logistic PCA and exponential-family GLM-PCA | `method="logistic"`, `"glmpca"` | Binary/count simulation tests |
| 31 | Compositional PCA | clr/ilr coordinates with explicit zero handling | `method="compositional"` | Closure/ratio invariance checks |
| 32 | Functional PCA | Dense-grid FPCA + MFPCA adapter | `method="functional"` | Known eigenfunction simulations |
| 33 | Dynamic PCA | Lag embedding + robust option | `method="dynamic"` | Time-series lag simulation |
| 34 | Structured PCA | Multilevel, ASCA, multiblock | `method="multilevel"`, [`pca_asca()`](https://wep69.github.io/pcaLab/reference/pca_asca.md), [`pca_multiblock()`](https://wep69.github.io/pcaLab/reference/pca_multiblock.md) | Designed-effect simulations |
| 35 | Incremental/streaming PCA | Online mean/covariance aggregation | `pca_incremental_*()` | Batch vs full covariance equivalence |
| 36 | Tuning/validation | Masked CV, reconstruction error, engine tuning hooks | [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md) + engine args | Out-of-sample masking |
| 37 | Method comparison | Reconstruction and subspace comparisons | [`pca_compare()`](https://wep69.github.io/pcaLab/reference/pca_compare.md) | Known-truth benchmarking |
| 38 | Supplementary information | New observations/variables and post-hoc groups | [`pca_supplementary()`](https://wep69.github.io/pcaLab/reference/pca_supplementary.md), [`pca_group()`](https://wep69.github.io/pcaLab/reference/pca_group.md) | Projection consistency |
| 39 | Static publication graphics | Comprehensive ggplot2 system | [`pca_plot()`](https://wep69.github.io/pcaLab/reference/pca_plot.md), [`pca_export_plot()`](https://wep69.github.io/pcaLab/reference/pca_export_plot.md) | Device/export checks |
| 40 | 3D/interactivity/touring | Plotly 3D + grand/guided/local/radial tours + GIF history | `pca_plot(type="scores3d")`, [`pca_tour()`](https://wep69.github.io/pcaLab/reference/pca_tour.md) | Projection basis checks |
| 41 | Tables/reporting | Structured tables + multiple export formats + report | [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md), [`pca_export_table()`](https://wep69.github.io/pcaLab/reference/pca_export_table.md), [`pca_report()`](https://wep69.github.io/pcaLab/reference/pca_report.md) | Round-trip/export checks |
| 42 | Expanded teaching module | 10 teaching functions + interactive Shiny lab | `pca_teach_*()`, [`pca_teach_app()`](https://wep69.github.io/pcaLab/reference/pca_teach_app.md) | Mathematical unit tests |
| 43 | Scientific/computational validation | testthat suite, known-truth simulations, validation scripts | `tests/`, `inst/validation/` | Invariance/differential/stress tests |
| 44 | Documentation/release | 24 vignettes, README, citations, local validation guide | package docs | `R CMD check --as-cran` locally |

## Component-number criteria implemented

[`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md)
can combine: scree elbow, cumulative explained variance, Kaiser (only
when correlation/UV scaling makes it meaningful), broken stick,
normal-reference parallel analysis, permutation-reference parallel
analysis, Marchenko-Pastur upper-edge screening, masked reconstruction
cross-validation, bootstrap subspace stability, PPCA-BIC, and
engine-specific validation when a backend provides an appropriate
criterion. Logistic PCA currently uses cross-validated negative log
likelihood through
[`logisticPCA::cv.lpca()`](https://rdrr.io/pkg/logisticPCA/man/cv.lpca.html).
Non-Euclidean engines are filtered so Gaussian PCA rules are not applied
silently.

The consensus is intentionally transparent: the individual
recommendations and disagreement range are retained. No disagreement is
hidden behind a single automated answer.

## Inferential philosophy

Inference is kept separate from descriptive PCA. Permutation tests
answer whether observed correlation/eigenspectrum structure exceeds an
explicit null reference. Bootstrap answers uncertainty/stability
questions conditional on resampling the observed empirical population.
Neither procedure converts PCA into a supervised test of group
separation.

## Robustness taxonomy

The package explicitly separates:

1.  casewise robust PCA (whole-row contamination);
2.  cellwise robust PCA (individual contaminated cells);
3.  low-rank + sparse matrix decomposition (RPCA/PCP);
4.  robust sparse PCA (robustness + sparse loading structure).

These solve different statistical problems and therefore use separate
`method` values.
