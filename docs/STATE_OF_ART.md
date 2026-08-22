# State of the Art and Scientific Positioning

## Why another PCA package?

The R ecosystem already contains excellent implementations of individual
PCA methods. The scientific gap addressed by pcaLab is therefore
**integration and auditability**, not the absence of algorithms.
Conventional PCA is available in base R; other packages specialize in
robust PCA, missing-data PCA, sparse PCA, generalized PCA, functional
PCA, high-dimensional computation, or visualization. Inferential testing
and projection tours are typically separate again.

pcaLab combines these layers through one object model while preserving
the distinction between methods that solve different statistical
problems.

## Teaching foundation

The teaching architecture follows the visual sequence developed by
Saccenti (2024): two- and three-dimensional visualization, rotation,
variance as information, maximum-variance directions, principal
components, scores/loadings, dimensionality reduction, interpretation,
scaling, and the limits of PCA. pcaLab expands this sequence by making
the eigenvalue problem, SVD equivalence, component uncertainty, subspace
stability, inferential testing, and component-number selection explicit.

No figure from that article is copied. The package uses original
synthetic demonstrations and an original agronomy-oriented simulation.

## Inference

PCAtest demonstrated the value of testing whether observed PCA structure
exceeds that expected under a column-wise permutation null. pcaLab
implements the same conceptual hierarchy: global structure, axes, and
variable-component evidence, while retaining Monte Carlo null
distributions and applying the standard +1 correction to
simulation-based p-values.

## Robustness

Robustness is not a single concept. pcaLab separates rowwise/casewise
outliers, cellwise contamination, sparse gross-error matrix
decomposition, and robust sparse loading estimation. This distinction is
essential because the estimands and contamination models differ.

## Nonlinearity

Kernel PCA and inverse nonlinear PCA are implemented as nonlinear
component methods. Logistic PCA and GLM-PCA are instead generalized
low-dimensional models for non-Gaussian data. t-SNE and UMAP are
intentionally not labeled as PCA and are not presented as substitutes
for eigenvalue-based variance decomposition.

## Structured data

Classical PCA assumes rows can be treated as exchangeable observations
for many inferential operations. Repeated measures, functional curves,
temporal dependence, multiblock data, and designed experiments violate
or modify that simple structure. pcaLab therefore includes functional,
dynamic, multilevel, multiblock, and ASCA workflows, each with explicit
interpretation boundaries.

## Design principle

A high-level workflow is:

``` text
Data audit
  -> scientifically defensible preprocessing
  -> PCA family selection
  -> dimensionality selection
  -> fit
  -> diagnostics
  -> inference and/or bootstrap stability when justified
  -> variable interpretation
  -> supplementary grouping/context
  -> publication-ready figures/tables
  -> reproducible report
```

The package never chooses a PCA family solely because it gives stronger
separation or smaller p-values.
