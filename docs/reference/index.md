# Package index

## Package

- [`pcaLab-package`](https://wep69.github.io/pcaLab/reference/pcaLab-package.md)
  [`pcaLab`](https://wep69.github.io/pcaLab/reference/pcaLab-package.md)
  : pcaLab: Teaching, Inference, Robustness, and Advanced Principal
  Component Analysis

## Core PCA

- [`pca_fit()`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  [`print(`*`<pca_fit>`*`)`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  [`summary(`*`<pca_fit>`*`)`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  [`print(`*`<summary.pca_fit>`*`)`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  [`fitted(`*`<pca_fit>`*`)`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  [`residuals(`*`<pca_fit>`*`)`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  [`predict(`*`<pca_fit>`*`)`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  [`plot(`*`<pca_fit>`*`)`](https://wep69.github.io/pcaLab/reference/pca_fit.md)
  : Fit Principal Component Analysis and advanced variants
- [`pca_preprocess()`](https://wep69.github.io/pcaLab/reference/pca_preprocess.md)
  : Preprocess data for PCA
- [`pca_reconstruct()`](https://wep69.github.io/pcaLab/reference/pca_reconstruct.md)
  : Reconstruct observations from retained principal components
- [`pca_doctor()`](https://wep69.github.io/pcaLab/reference/pca_doctor.md)
  : Diagnose whether standard PCA assumptions and data geometry are
  suitable
- [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md)
  : Report optional engine capabilities
- [`pca_simulate()`](https://wep69.github.io/pcaLab/reference/pca_simulate.md)
  : Simulate PCA data with known latent structure and optional
  contamination
- [`pca_example_agronomy()`](https://wep69.github.io/pcaLab/reference/pca_example_agronomy.md)
  : Synthetic agronomy dataset for examples and teaching

## Dimensionality and inference

- [`pca_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_ncomp.md)
  : Select the number of PCA components using multiple criteria
- [`pca_parallel()`](https://wep69.github.io/pcaLab/reference/pca_parallel.md)
  : Parallel analysis for PCA
- [`pca_cv()`](https://wep69.github.io/pcaLab/reference/pca_cv.md) :
  Masked cross-validation for PCA dimensionality
- [`pca_broken_stick()`](https://wep69.github.io/pcaLab/reference/pca_broken_stick.md)
  : Broken-stick expected proportions
- [`pca_test()`](https://wep69.github.io/pcaLab/reference/pca_test.md) :
  Permutation tests for global PCA structure, axes, and variable
  contributions
- [`pca_boot()`](https://wep69.github.io/pcaLab/reference/pca_boot.md) :
  Bootstrap PCA uncertainty with component alignment
- [`pca_stability()`](https://wep69.github.io/pcaLab/reference/pca_stability.md)
  : Assess component and subspace stability
- [`pca_associate()`](https://wep69.github.io/pcaLab/reference/pca_associate.md)
  : Associate original variables with principal components

## Diagnostics and comparison

- [`pca_diagnose()`](https://wep69.github.io/pcaLab/reference/pca_diagnose.md)
  : PCA influence and outlier diagnostics
- [`pca_compare()`](https://wep69.github.io/pcaLab/reference/pca_compare.md)
  : Compare PCA methods on common metrics
- [`pca_supplementary()`](https://wep69.github.io/pcaLab/reference/pca_supplementary.md)
  : Project supplementary observations or variables without refitting
  PCA
- [`pca_group()`](https://wep69.github.io/pcaLab/reference/pca_group.md)
  : Add external group summaries and confidence regions to PCA scores

## Graphics, tours, and reporting

- [`pca_plot()`](https://wep69.github.io/pcaLab/reference/pca_plot.md) :
  Publication-ready PCA figures
- [`pca_export_plot()`](https://wep69.github.io/pcaLab/reference/pca_export_plot.md)
  : Export a publication-ready PCA figure
- [`pca_theme_publication()`](https://wep69.github.io/pcaLab/reference/pca_theme_publication.md)
  : Publication theme used by pcaLab
- [`pca_tour()`](https://wep69.github.io/pcaLab/reference/pca_tour.md) :
  Explore high-dimensional data with projection tours anchored to PCA
- [`pca_tour_compare()`](https://wep69.github.io/pcaLab/reference/pca_tour_compare.md)
  : Compare PCA view with local and guided tour histories
- [`pca_table()`](https://wep69.github.io/pcaLab/reference/pca_table.md)
  : Create publication-ready PCA tables
- [`pca_export_table()`](https://wep69.github.io/pcaLab/reference/pca_export_table.md)
  : Export a PCA table
- [`pca_report()`](https://wep69.github.io/pcaLab/reference/pca_report.md)
  : Generate a reproducible PCA report

## Structured PCA

- [`pca_asca()`](https://wep69.github.io/pcaLab/reference/pca_asca.md) :
  ANOVA-Simultaneous Component Analysis (ASCA)
- [`pca_multiblock()`](https://wep69.github.io/pcaLab/reference/pca_multiblock.md)
  : Multiblock PCA by block scaling and concatenation
- [`pca_incremental_init()`](https://wep69.github.io/pcaLab/reference/pca_incremental_init.md)
  : Initialize an incremental PCA state
- [`pca_incremental_update()`](https://wep69.github.io/pcaLab/reference/pca_incremental_update.md)
  : Update an incremental PCA state with a batch
- [`pca_incremental_finalize()`](https://wep69.github.io/pcaLab/reference/pca_incremental_finalize.md)
  : Finalize an incremental PCA state

## Teaching

- [`pca_teach_app()`](https://wep69.github.io/pcaLab/reference/pca_teach_app.md)
  : Launch the interactive PCA teaching laboratory
- [`pca_teach_biplot()`](https://wep69.github.io/pcaLab/reference/pca_teach_biplot.md)
  : Teach biplot geometry
- [`pca_teach_eigen()`](https://wep69.github.io/pcaLab/reference/pca_teach_eigen.md)
  : Teach eigenvalues and eigenvectors in PCA
- [`pca_teach_loadings()`](https://wep69.github.io/pcaLab/reference/pca_teach_loadings.md)
  : Teach loadings and variable-component relationships
- [`pca_teach_ncomp()`](https://wep69.github.io/pcaLab/reference/pca_teach_ncomp.md)
  : Teach component-number selection
- [`pca_teach_reconstruction()`](https://wep69.github.io/pcaLab/reference/pca_teach_reconstruction.md)
  : Teach low-rank reconstruction
- [`pca_teach_rotation()`](https://wep69.github.io/pcaLab/reference/pca_teach_rotation.md)
  : Teach planar rotation and weighted linear combinations
- [`pca_teach_scaling()`](https://wep69.github.io/pcaLab/reference/pca_teach_scaling.md)
  : Teach the effects of scaling
- [`pca_teach_scores()`](https://wep69.github.io/pcaLab/reference/pca_teach_scores.md)
  : Teach scores
- [`pca_teach_svd()`](https://wep69.github.io/pcaLab/reference/pca_teach_svd.md)
  : Teach singular value decomposition and its equivalence to PCA
- [`pca_teach_variance()`](https://wep69.github.io/pcaLab/reference/pca_teach_variance.md)
  : Teach variance maximization over projection directions

## Clustering on PCA scores

- [`pca_cluster()`](https://wep69.github.io/pcaLab/reference/pca_cluster.md)
  : Cluster observations based on PCA scores
- [`pca_cluster_evaluate()`](https://wep69.github.io/pcaLab/reference/pca_cluster_evaluate.md)
  : Evaluate clustering across multiple values of k
- [`pca_cluster_compare()`](https://wep69.github.io/pcaLab/reference/pca_cluster_compare.md)
  : Compare clustering methods on PCA scores
- [`pca_cluster_stability()`](https://wep69.github.io/pcaLab/reference/pca_cluster_stability.md)
  : Bootstrap cluster stability assessment
- [`pca_cluster_boundary()`](https://wep69.github.io/pcaLab/reference/pca_cluster_boundary.md)
  : Compute cluster boundaries for PCA score plots
- [`pca_cluster_labels()`](https://wep69.github.io/pcaLab/reference/pca_cluster_labels.md)
  : Generate observation labels for PCA score plots
- [`pca_cluster_report()`](https://wep69.github.io/pcaLab/reference/pca_cluster_report.md)
  : Generate a comprehensive clustering report
