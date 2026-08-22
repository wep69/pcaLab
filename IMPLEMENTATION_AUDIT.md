# pcaLab 0.1.0 Implementation Audit

Audit date: 2026-08-14

## Executive status

All 44 planned blocks are represented in the development source tree by executable R interfaces, engine adapters, teaching material, diagnostics, inferential procedures, reporting infrastructure, tests, or release documentation. The package currently exposes **43 public functions**, **23 PCA engine labels**, **24 English vignettes**, **15 testthat files**, **17 R source files**, and **7 grouped Rd help pages**.

This is a **development source audit**, not an R runtime certification. The present execution environment does not contain R or Rscript, so `R CMD build`, `R CMD check --as-cran`, examples, vignettes, native optional backends, and numerical tests could not be executed here. Those checks are mandatory before scientific release.

## Source inventory

- R source files: 17
- R source lines: 3059
- Public exports: 43
- Registered S3 methods: 7
- PCA engine labels: 23
- testthat files: 15
- test code lines: 348
- Vignettes: 24
- Vignette source lines: 1463
- Teaching application: `inst/shiny/pca_teach/app.R`
- Core mathematical validation: `inst/validation/validate_core.R`
- Optional-engine validation: `inst/validation/validate_optional_engines.R`
- Reproducible report template: `inst/templates/analysis-report.Rmd`

## The 44 implemented blocks

The authoritative block-to-code mapping is `IMPLEMENTATION_MATRIX.md`. It covers:

1. state of the art;
2. gap analysis;
3. PCA scope/taxonomy;
4. mathematical foundations;
5. eigenvalues, eigenvectors, Rayleigh optimization, and SVD;
6. data audit and preprocessing;
7. common object architecture;
8. classical PCA;
9. weighted and scaled PCA;
10. scores and loadings;
11. quality of representation and reconstruction;
12. dimensionality selection;
13. global PCA inference;
14. component/axis inference;
15. variable-component association;
16. bootstrap uncertainty;
17. component and subspace stability;
18. diagnostics and influence;
19. casewise robust PCA;
20. cellwise robust PCA;
21. low-rank plus sparse RPCA/PCP;
22. sparse PCA;
23. robust sparse PCA;
24. high-dimensional/shrinkage/randomized PCA;
25. missing-data PCA;
26. probabilistic PCA;
27. Bayesian PCA;
28. kernel PCA;
29. nonlinear PCA;
30. logistic and GLM-PCA;
31. compositional PCA;
32. functional PCA;
33. dynamic PCA;
34. multilevel, ASCA, and multiblock PCA;
35. incremental/streaming PCA;
36. tuning and cross-validation;
37. method comparison;
38. supplementary information and groups;
39. publication-ready static graphics;
40. 3D/interactivity/touring;
41. tables and reproducible reporting;
42. expanded teaching module;
43. scientific/computational validation;
44. documentation and release infrastructure.

## Core engine registry

`pca_fit()` currently recognizes:

`classical`, `weighted`, `nipals`, `em`, `ppca`, `bayesian`, `robust`, `cellwise`, `sparse`, `robust_sparse`, `rpca`, `kernel`, `nlpca`, `shrinkage`, `logistic`, `glmpca`, `compositional`, `functional`, `dynamic`, `multilevel`, `multiblock`, `randomized`, and `incremental`.

The registry in `pca_capabilities()` was statically checked against the `pca_fit()` method vector and is identical in content and order.

## Dimensionality selection

For Euclidean PCA geometries, `pca_ncomp()` integrates:

- automated scree elbow;
- cumulative explained variance;
- Kaiser criterion only under centered unit-variance geometry;
- broken-stick expectation;
- normal-reference parallel analysis;
- column-wise permutation parallel analysis;
- Marchenko-Pastur upper-edge screening under its stated reference assumptions;
- masked reconstruction cross-validation;
- bootstrap subspace stability;
- PPCA-BIC;
- transparent consensus and disagreement range.

The selection layer is geometry-aware. Logistic PCA uses the backend's cross-validated negative log likelihood through `logisticPCA::cv.lpca()`. Kernel PCA is restricted to feature-space spectral summaries in the generic selector. GLM-PCA and inverse nonlinear PCA deliberately reject automatic transfer of ordinary covariance-PCA selection rules.

## Inference and uncertainty

`pca_test()` implements a PCAtest-inspired hierarchy for centered, unit-variance **classical PCA**. Weighted and nonclassical fits are rejected so that observation weighting or alternative geometries are never silently discarded:

- global \(\Psi\) and \(\Phi\) structure statistics;
- null eigenspectra/rank-of-roots evidence;
- loading-index evidence;
- variable-PC correlation evidence;
- Monte Carlo p-values;
- multiplicity adjustment.

`pca_boot()` and `pca_stability()` explicitly align resampled components and account for eigenvector sign indeterminacy. Stability summaries include principal-angle/subspace behavior so that nearly tied eigenvalues are not reduced to unstable single-vector interpretations.

## Variable-component interpretation

`pca_associate()` combines effect, representation, inference, and stability rather than imposing a universal loading cutoff. The table can include eigenvector loadings, variable-PC correlations, cos2, contributions relative to the average 1/p reference, permutation/FDR evidence, bootstrap intervals, sign stability, and axis-level significance.

## Robustness taxonomy

The implementation deliberately separates four different problems:

- casewise robust PCA through ROBPCA;
- cellwise robust PCA through MacroPCA;
- low-rank plus sparse gross-error decomposition through an internal Principal Component Pursuit implementation;
- robust sparse loading estimation through optional robust-sparse backends.

These methods are not labeled as interchangeable.

## Generalized and nonlinear geometry safeguards

The logistic-PCA adapter uses backend `U` loadings and `PCs` scores directly, exposes fitted probabilities/link values, supports native new-data score prediction, and uses native cross-validation for rank selection.

The GLM-PCA adapter converts pcaLab's observation-by-variable convention to the backend's feature-by-observation convention, then transposes fitted means back to the public convention. It does not manufacture a classical loading-projection rule for arbitrary new observations because the backend does not define that operation.

Kernel/nonlinear/generalized engines carry explicit warnings when ordinary variance-partition interpretation is not valid.

## Compositional safeguards

Compositional PCA:

- requires at least two parts;
- rejects negative values and rows with non-positive/invalid totals;
- requires an explicit positive pseudocount when zeros remain;
- closes rows before log-ratio transformation;
- supports CLR and ILR coordinates;
- enforces the p-1 compositional rank limit;
- stores part-space loadings and a composition-scale back-transformation helper.

## Static checks completed in this environment

The following checks passed:

- delimiter balance across R source, tests, and validation scripts, with quoted strings, comments, and backtick identifiers excluded from the parser;
- all 43 exported names have top-level function definitions;
- all 43 exported names have Rd aliases;
- no missing internal `.pca_*` helper referenced by the source;
- no duplicate top-level function definitions;
- `pca_fit()` and `pca_capabilities()` contain the same 23 methods;
- no TODO/FIXME/XXX markers;
- no selected Portuguese-language diagnostic/documentation terms in R, man, vignette, README, validation, or test sources;
- optional packages referenced with `pkg::fun` are represented in `DESCRIPTION` when they are non-base dependencies.

These static checks do **not** substitute for R parsing or execution.

## Publication-ready output implementation

The plotting/reporting layer includes:

- scree/cumulative spectra;
- score maps for arbitrary PC pairs;
- loadings;
- correlation circles;
- contributions and cos2;
- biplots;
- inferential and bootstrap uncertainty graphics;
- outlier maps;
- group centroids and inferential/descriptive regions;
- 3D Plotly scores;
- projection tours;
- vector PDF/SVG and high-resolution PNG/TIFF export;
- structured tables and CSV/TSV/Markdown/LaTeX/XLSX/HTML/DOCX export where supporting packages are installed.

The final visual audit must still be performed on files rendered by a local R installation.

## Teaching implementation

The teaching sequence is grounded in the visual-to-mathematical progression of Saccenti (2024) but uses original code/examples. It includes rotations, variance as information, eigenvector transformation, Rayleigh maximization, SVD equivalence, scores/loadings, reconstruction, scaling, component selection, biplot interpretation, and a Shiny laboratory. The eigen/SVD vignette also explains sign ambiguity, repeated/nearly repeated eigenvalues, p versus n rank limits, and why subspace stability may be more meaningful than individual loading stability.

## Release blockers that remain external to this environment

1. Replace `maintainer@example.org` in `DESCRIPTION` with the real maintainer address.
2. Run roxygen/documentation generation in the target R release.
3. Run all tests, examples, vignettes, and both validation scripts.
4. Install and exercise each optional backend that will be claimed as supported.
5. Run `R CMD build`.
6. Run `R CMD check --as-cran` and resolve every ERROR/WARNING and investigate every NOTE.
7. Inspect every exported graphic/table file independently.
8. Validate numerical equivalence against reference backends and known-truth simulations.
9. Archive the exact R-built source tarball and session information that passed the checks.

## Audit conclusion

The **source implementation of the 44-block architecture is complete at the development-code level**. The package is intentionally labeled development status because this environment cannot perform the decisive R runtime and CRAN checks. No claim of CRAN readiness or numerical certification should be made until the procedure in `LOCAL_VALIDATION.md` and `CRAN_SUBMISSION_CHECKLIST.md` has been completed successfully.
