# pcaLab CRAN Submission Checklist

Use this checklist only after the complete development tree has been
copied to a machine with a current R installation.

## A. Identity and metadata

Replace `maintainer@example.org` with the real maintainer email.

Confirm all author names, roles, ORCID identifiers if added, package
URL, and bug-report URL.

Confirm version and release date.

Confirm GPL-3 licensing metadata and any bundled third-party notices.

Verify every DOI, title, author list, year, journal, volume, and pages
in the bibliography.

Ensure the README and vignettes do not claim runtime validation that has
not been performed.

## B. Dependencies

Install in a clean R library.

Confirm every `Imports` package is required at runtime.

Confirm every `Suggests` package is either conditionally used or needed
for tests/vignettes/output.

Verify graceful skips/errors when optional packages are absent.

Check availability of all suggested packages on the intended
repositories.

## C. Documentation generation

``` r

devtools::document("pcaLab_0.1.0")
```

Inspect generated `NAMESPACE`.

Inspect all Rd pages for missing arguments or malformed math.

Confirm all 43 exported functions are documented.

Run [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html)
indirectly through package checks.

## D. Core tests

``` r

devtools::test("pcaLab_0.1.0")
source("pcaLab_0.1.0/inst/validation/validate_core.R")
```

Classical PCA agrees with
[`stats::prcomp()`](https://rdrr.io/r/stats/prcomp.html) up to
sign/degenerate-subspace equivalence.

SVD and covariance eigenvalues agree under the documented denominator.

Reconstruction error is non-increasing with retained rank.

Weighted PCA identities pass.

Missing-data tests pass.

Incremental and batch covariance/eigenspace tests pass.

Inference is reproducible for fixed seeds.

Near-tied-eigenvalue tests evaluate subspaces rather than raw signs.

## E. Optional-engine tests

``` r

source("pcaLab_0.1.0/inst/validation/validate_optional_engines.R")
```

ROBPCA adapter.

MacroPCA adapter and prediction behavior.

Sparse PCA adapters.

Robust sparse PCA adapter.

Bayesian/NLPCA backend.

Shrinkage PCA and reconstruction.

Logistic PCA scores/loadings, fitted probabilities, prediction, and
cross-validation.

GLM-PCA orientation, loadings/factors, fitted mean matrix, and
convergence diagnostics.

MFPCA path if advertised in release notes.

`irlba` randomized path if advertised in release notes.

## F. Statistical stress tests

p much larger than n.

n much larger than p.

exactly and nearly collinear variables.

repeated/nearly repeated eigenvalues.

constant and near-constant variables.

extreme scale differences.

heavy-tailed data.

casewise contamination.

cellwise contamination.

sparse gross-error matrices.

MCAR missingness and difficult missingness patterns.

binary matrices.

Poisson/negative-binomial count matrices.

compositional zeros with explicitly documented replacement.

nonlinear manifolds.

temporal autocorrelation and lag embeddings.

repeated-measures/multilevel structure.

designed effects for ASCA.

heterogeneous multiblock scales.

## G. Dimensionality-selection audit

Verify scree/cumulative results on known spectra.

Verify Kaiser is unavailable outside centered unit-variance PCA.

Verify broken-stick expectation.

Verify normal and permutation parallel analysis.

Verify Marchenko-Pastur screening only under its stated reference
geometry.

Verify masked CV on planted-rank simulations.

Verify stability criterion under repeated eigenvalues.

Verify PPCA-BIC behavior.

Verify logistic PCA uses engine-specific cross-validated negative log
likelihood.

Verify generalized/nonlinear engines do not silently inherit invalid
Gaussian-PCA rules.

## H. Inferential audit

Simulate independent standardized variables and assess Type-I behavior
of global/axis tests.

Simulate correlated low-rank alternatives and assess detection.

Check Monte Carlo p-value correction.

Check multiplicity adjustment.

Confirm variable-association flags require axis significance when a test
result is supplied.

Confirm bootstrap does not serve as the permutation null hypothesis.

## I. Vignettes and examples

``` r

devtools::run_examples("pcaLab_0.1.0")
devtools::build_vignettes("pcaLab_0.1.0")
```

Build all 24 vignettes.

Inspect equations and code output.

Confirm teaching figures are original and do not reproduce restricted
figures from external articles.

Confirm generalized/nonlinear vignettes use method-specific
interpretation.

Confirm no example depends on internet access.

## J. Publication-output audit

PDF figures are vector where intended.

SVG output is editable.

TIFF/PNG export produces requested DPI and dimensions.

Labels and legends are not clipped.

Axis titles include PC variance only when that quantity is valid for the
engine.

Color is not the only group discriminator where accessibility requires
redundant encoding.

Group regions are labeled correctly as descriptive ellipses,
mean-confidence ellipses, bootstrap regions, or isotropic circles.

Tables retain component names, units, uncertainty, and adjusted
p-values.

DOCX/XLSX/HTML exports open correctly in independent software.

## K. Build and check

From the parent directory:

``` text
R CMD build pcaLab_0.1.0
R CMD check --as-cran pcaLab_0.1.0.tar.gz
```

Zero ERRORs.

Zero WARNINGs.

Every NOTE investigated and documented.

Check on Windows.

Check on Linux.

Check on macOS when feasible.

Check current R release and R-devel when feasible.

## L. Final release record

Save [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html).

Save package dependency versions.

Save exact random seeds for validation simulations.

Save `R CMD check` logs.

Save SHA-256 of the exact source tarball that passed checks.

Update NEWS.

Tag the release only after the checked tarball is frozen.
