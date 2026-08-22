# Changelog

## pcaLab 0.1.0

Initial comprehensive development release implementing the 44-block
architecture.

- Unified `pca_fit` interface and `pca_fit` S3 class.
- Classical, weighted, NIPALS, EM, probabilistic, Bayesian, robust,
  cellwise-robust, sparse, robust-sparse, PCP/RPCA, kernel, logistic,
  GLM, compositional, functional, dynamic, multilevel, randomized, and
  incremental engines.
- Dimensionality selection by scree elbow, cumulative variance, Kaiser,
  broken-stick, Horn-style parallel analysis, permutation envelopes,
  masked cross-validation, stability, PPCA-BIC, and consensus.
- PCAtest-inspired permutation inference for global structure, axes,
  loading indices, and variable-component correlations.
- Bootstrap confidence intervals with sign/component alignment and
  subspace stability diagnostics.
- Scores, loadings, correlation loadings, contributions, cos2,
  communalities, reconstruction and residual diagnostics.
- Robust score-distance/orthogonal-distance diagnostics.
- Supplementary groups, centroids, confidence ellipses, bootstrap
  regions, and chi-square confidence circles.
- Publication-ready figures, tables, exporting, reporting, and tour
  integration.
- Expanded educational module covering rotations, variance,
  eigenvalues/eigenvectors, SVD, scores, loadings, reconstruction,
  scaling, component selection, and biplots.
- ASCA, multiblock, dynamic, functional and streaming workflows.
- Twenty-four vignettes, validation scripts, tests, references, and a
  Shiny teaching application.
- Generalized-engine adapters now preserve backend geometry explicitly:
  logistic PCA uses backend scores/loadings, fitted probabilities and
  native cross-validation; GLM-PCA handles its feature-by-observation
  backend orientation and exposes fitted means without inventing an
  invalid classical new-data projection.
- Component-number selection is geometry-aware and prevents automatic
  use of ordinary Gaussian PCA criteria for generalized/nonlinear
  engines where those criteria are not justified.
- The eigenvalue/eigenvector/SVD and generalized-PCA teaching vignettes
  were expanded with derivations, interpretation safeguards,
  rank/stability issues, and reporting guidance.
- Same-engine bootstrap no longer silently falls back to classical PCA
  for unsupported engines; users must explicitly request a classical
  local-geometry sensitivity analysis. Subspace stability now exposes
  the same refit choice.
- Reports and cumulative-variance graphics now guard against presenting
  ordinary explained-variance language for generalized/nonlinear engines
  that do not define that partition.
