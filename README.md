# pcaLab

**pcaLab** is an R framework for teaching, fitting, validating, interpreting, comparing, and reporting Principal Component Analysis (PCA) and advanced PCA variants. It is designed around one principle: a PCA result should not be treated as a black box. The package therefore connects geometry, eigenvalues/eigenvectors, singular-value decomposition, dimensionality selection, inference, bootstrap stability, diagnostics, robust and nonlinear extensions, projection tours, and publication-ready reporting through a common workflow.

## Core design goals

1. **Teach the mathematics visually and progressively.** Rotation, variance, projection, covariance, eigenvectors, eigenvalues, SVD, scores, loadings, reconstruction, and scaling are connected explicitly.
2. **Separate descriptive PCA from inferential claims.** Permutation tests, Monte Carlo reference distributions, bootstrap confidence intervals, and subspace stability are available as separate analyses.
3. **Treat dimensionality as a model-selection problem.** Scree, cumulative variance, Kaiser, broken-stick, Horn parallel analysis, column-wise permutation, Marchenko-Pastur screening, masked cross-validation, bootstrap stability, PPCA-BIC, and engine-specific validation when available can be compared rather than collapsed into a single unquestioned rule.
4. **Distinguish advanced PCA families correctly.** Casewise robust PCA, cellwise robust PCA, low-rank-plus-sparse decomposition, sparse PCA, robust sparse PCA, shrinkage PCA, kernel PCA, nonlinear PCA, generalized PCA, compositional PCA, functional PCA, dynamic PCA, multilevel PCA, multiblock PCA, randomized PCA, and streaming PCA are not conflated.
5. **Make interpretation auditable.** Variable-component association combines raw loadings, correlations, cos², contributions, permutation/FDR evidence, bootstrap intervals, and sign stability.
6. **Produce publication-ready outputs.** Static ggplot2 figures, interactive Plotly score plots, tours, 600-dpi raster export, vector PDF/SVG export, and tables for CSV/TSV/Markdown/LaTeX/XLSX/HTML/DOCX are supported.

## Installation from a local source directory

```r
install.packages(c("ggplot2", "testthat"))
install.packages("path/to/pcaLab_0.1.0", repos = NULL, type = "source")
```

Advanced engines are optional. `pca_capabilities()` reports what is available in the current R installation.

## Minimal workflow

```r
library(pcaLab)

ex <- pca_example_agronomy(seed = 42)
fit <- pca_fit(ex$data, method = "classical", center = TRUE, scale = TRUE)

summary(fit)
pca_plot(fit, "scree")
pca_plot(fit, "scores", group = ex$metadata$treatment)
pca_plot(fit, "correlation_circle")

selection <- pca_ncomp(fit, methods = "all", nperm = 499, nboot = 200, seed = 42)
test <- pca_test(fit, nperm = 999, seed = 42)
boot <- pca_boot(fit, nboot = 999, seed = 42)
assoc <- pca_associate(fit, test = test, boot = boot)

grp <- pca_group(fit, ex$metadata$treatment, region = "bootstrap", nboot = 999, seed = 42)
pca_plot(fit, "scores", group = ex$metadata$treatment, group_region = grp)

pca_report(fit, "pca_report.md", inference = test, selection = selection, bootstrap = boot)
```

## Classical and advanced engines

```r
pca_capabilities()
```

The common `pca_fit()` interface currently includes:

- `classical`: centered/scaled SVD PCA;
- `weighted`: observation-weighted covariance PCA;
- `nipals`: internal NIPALS with missing values;
- `em`: iterative low-rank EM-style missing-data PCA;
- `ppca`: probabilistic PCA;
- `bayesian`: Bayesian PCA through `pcaMethods`;
- `robust`: ROBPCA through `rospca`;
- `cellwise`: MacroPCA through `cellWise`;
- `sparse`: sparse PCA through `sparsepca` or `elasticnet`;
- `robust_sparse`: robust sparse PCA through optional backends;
- `rpca`: Principal Component Pursuit low-rank + sparse decomposition;
- `shrinkage`: shrinkage-covariance PCA through `corpcor`;
- `kernel`: RBF, polynomial, or linear kernel PCA with out-of-sample projection;
- `nlpca`: inverse nonlinear PCA through `pcaMethods`;
- `logistic`: logistic PCA for binary data;
- `glmpca`: exponential-family generalized PCA;
- `compositional`: clr or ilr PCA;
- `functional`: dense-grid FPCA or optional multivariate FPCA;
- `dynamic`: lag-embedded classical or robust dynamic PCA;
- `multilevel`: within- or between-subject PCA;
- `multiblock`: block-scaled consensus PCA;
- `randomized`: truncated/randomized SVD through `irlba` when available;
- `incremental`: streaming covariance aggregation and final eigendecomposition.

## What a principal component means

For a centered matrix \(X\), the first principal direction solves

\[
\max_{\|v\|=1} v^T S v, \qquad S = \frac{1}{n-1}X^T X.
\]

The Lagrange condition gives

\[
S v_k = \lambda_k v_k,
\]

so the eigenvector \(v_k\) defines the component direction and the eigenvalue \(\lambda_k\) is the component variance. Equivalently, if

\[
X = UDV^T,
\]

then the loading directions are the columns of \(V\), the scores are \(UD\), and

\[
\lambda_k = d_k^2/(n-1).
\]

`pca_teach_eigen()` and `pca_teach_svd()` expose every object in these equations, while `pca_teach_app()` provides an interactive laboratory.

## Inference and stability

PCA is descriptive unless an inferential framework is added deliberately. `pca_test()` implements a PCAtest-style permutation workflow for:

- global structure statistics \(\Psi\) and \(\Phi\);
- rank-of-roots/eigenvalue evidence for individual axes;
- variable loading-index evidence;
- variable-PC correlation evidence;
- multiplicity correction.

`pca_boot()` resamples observations and then matches/reorients bootstrap components before summarizing eigenvalues, PVE, loadings, correlations, and loading-sign stability. `pca_stability()` additionally reports principal-angle stability for nested subspaces. This distinction matters when eigenvalues are nearly tied: individual eigenvectors can rotate while the joint subspace remains stable.

## How variables are associated with PCs

`pca_associate()` does not define importance using a universal absolute-loading cutoff. It combines:

- eigenvector loading;
- variable-PC correlation;
- cos²;
- contribution relative to the average \(1/p\);
- permutation/FDR evidence;
- bootstrap loading interval;
- loading-sign stability.

The final flag is therefore an auditable synthesis, not a hard-coded folklore threshold.

## Projection tours

`pca_tour()` uses PCA loadings as an anchor and supports grand, guided, local, and radial tours through `tourr`. Local tours assess how visually stable the PCA projection is under nearby rotations. Guided/grand tours can reveal structures that a variance-maximizing projection does not emphasize.

## Group overlays remain supplementary

PCA remains unsupervised. Treatment, cultivar, environment, site, or disease labels supplied to `pca_group()` are used after fitting to calculate centroids and regions. Available regions include data ellipses, chi-square ellipses for the centroid mean, bootstrap centroid regions, and isotropic chi-square circles. No group label is silently used to rotate the PCA solution.

## Reproducibility and release status

This source tree includes tests, vignettes, an implementation matrix, validation instructions, references, a teaching Shiny application, and publication-output helpers.

The package has been run through the complete local validation procedure on a clean Windows installation with R 4.6.0: documentation regeneration, the full unit-test suite, the core mathematical validation script (agreement with `stats::prcomp()`, SVD/eigenvalue identities, reconstruction, sign invariance, explained-variance denominators, planted-rank subspace recovery, incremental covariance equivalence, missing-data engines, RPCA decomposition, permutation p-value bounds, bootstrap alignment, ASCA permutation), the optional-engine validation script, all 23 engine labels in their appropriate data geometries, stress and edge-case audits, dimensionality-selection and inference calibration, bootstrap and subspace-stability audits, prediction/reconstruction checks, the teaching module and Shiny laboratory, tours and GIF rendering, publication-plot and table/report export audits, all 24 vignettes, `R CMD build`, and `R CMD check --as-cran` with 0 ERRORs, 0 WARNINGs, and 0 NOTEs (apart from the documented environment NOTE for a new submission). Cross-platform checks on the official remote builders are submitted as an additional release gate. Exact software versions, seeds, logs, and checksums are archived in the validation record.

## Geometry-aware dimensionality selection

`pca_ncomp()` does not silently transfer Gaussian PCA rules to every advanced engine. Classical and Euclidean PCA variants can use the full menu of reference criteria where their assumptions are meaningful. Kernel PCA is limited automatically to feature-space scree/cumulative summaries by the generic interface. Logistic PCA adds `method = "engine_cv"`, which delegates latent-rank selection to the backend's cross-validated negative log likelihood. GLM-PCA and nonlinear PCA require likelihood/deviance or method-specific validation rather than ordinary eigenvalue heuristics.
