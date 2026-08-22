# Local Validation and Release Procedure for pcaLab

This source tree was produced in an environment without an R
interpreter. The following procedure is therefore mandatory before
scientific use, CRAN submission, or public release.

## 1. Recommended local environment

Use a current R release on Windows, macOS, or Linux. On Windows, install
the Rtools version that corresponds to the installed R release. A clean
library is preferable for release testing.

## 2. Unpack and inspect

``` r

pkg <- "D:/path/to/pcaLab_0.1.0"
list.files(pkg)
read.dcf(file.path(pkg, "DESCRIPTION"))
```

Replace the placeholder maintainer email in `DESCRIPTION` before
release.

## 3. Install development/validation dependencies

``` r

install.packages(c(
  "devtools", "roxygen2", "testthat", "knitr", "rmarkdown",
  "ggplot2", "gt", "plotly", "tourr", "irlba", "corpcor"
))
```

Install optional engine packages only if those engines will be validated
locally:

``` r

install.packages(c(
  "rospca", "cellWise", "sparsepca", "elasticnet",
  "logisticPCA", "glmpca", "MFPCA", "openxlsx",
  "officer", "flextable", "shiny"
))

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("pcaMethods")
```

## 4. Regenerate documentation

``` r

devtools::document(pkg)
```

Then inspect the generated `NAMESPACE` and all `man/*.Rd` files. Do not
continue if roxygen changes indicate an unexpected export or missing
import.

## 5. Run unit tests

``` r

devtools::test(pkg)
```

All base-engine tests must pass. Optional-backend tests should either
pass or skip explicitly because the relevant package is not installed.

## 6. Run the package’s mathematical validation script

``` r

source(file.path(pkg, "inst", "validation", "validate_core.R"))
```

The script checks SVD/eigenvalue identities, comparison with
[`stats::prcomp`](https://rdrr.io/r/stats/prcomp.html), sign-invariant
loading agreement, low-rank reconstruction, incremental covariance
equivalence, and planted-rank simulations.

## 7. Run examples and vignettes

``` r

devtools::run_examples(pkg)
devtools::build_vignettes(pkg)
```

Inspect all generated figures. Publication graphics must have readable
labels, no clipped legends, correct units, and no interpretation that
exceeds what the method estimates.

## 8. Run the optional-engine validation script

``` r

source(file.path(pkg, "inst", "validation", "validate_optional_engines.R"))
```

This script checks current backend adapters, including logistic-PCA
fitted values/prediction/cross-validation, GLM-PCA orientation/fitted
values, shrinkage projection/reconstruction, and installed
robust/sparse/randomized/Bayesian engines.

## 9. Manual advanced-engine smoke tests

Run at least one reproducible example for every installed engine:

``` r

library(pcaLab)
ex <- pca_example_agronomy(seed = 123)
X <- ex$data

methods <- c("classical", "weighted", "nipals", "em", "ppca",
             "rpca", "kernel", "shrinkage", "randomized")

for (m in methods) {
  cat("\n---", m, "---\n")
  z <- pca_fit(X, method = m, scale = TRUE, ncomp = 3)
  print(z)
}
```

For optional methods, condition on
[`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md).

## 10. Check inferential reproducibility

``` r

fit <- pca_fit(X, scale = TRUE)
a <- pca_test(fit, nperm = 499, seed = 1)
b <- pca_test(fit, nperm = 499, seed = 1)
stopifnot(identical(a$global, b$global))

ba <- pca_boot(fit, nboot = 199, seed = 1)
bb <- pca_boot(fit, nboot = 199, seed = 1)
stopifnot(isTRUE(all.equal(ba$eigenvalue_ci, bb$eigenvalue_ci)))
```

## 11. Stress tests

Explicitly test:

- duplicated/constant variables;
- near-singular covariance matrices;
- p much larger than n;
- nearly equal eigenvalues;
- missing values under NIPALS/EM/BPCA;
- casewise outliers;
- cellwise contamination;
- zeros in compositional data;
- binary/count data for generalized PCA;
- nonlinear manifolds for kernel/NLPCA;
- long time series for dynamic PCA;
- small chunks for incremental PCA.

Document every numerical warning and decide whether it should become a
user-facing diagnostic.

## 12. Build source package

``` r

tarball <- devtools::build(pkg, vignettes = TRUE)
tarball
```

Do not use the hand-created development archive as the final CRAN source
tarball. `R CMD build` must create the release artifact.

## 13. Standard check

``` r

devtools::check(pkg, document = FALSE, manual = TRUE, vignettes = TRUE)
```

Resolve every ERROR and WARNING. Investigate every NOTE.

## 14. CRAN-like check

From a terminal:

``` text
R CMD build pcaLab_0.1.0
R CMD check --as-cran pcaLab_0.1.0.tar.gz
```

Also test with win-builder/rhub if preparing a CRAN submission.

## 15. Numerical cross-validation against reference packages

For classical PCA, compare against
[`stats::prcomp`](https://rdrr.io/r/stats/prcomp.html). For each
optional engine, compare the fitted subspace, eigenvalues or
reconstruction against its native backend. Compare subspaces by absolute
loading correlations/principal angles rather than raw signs because
eigenvector signs are arbitrary.

## 16. Final publication-output audit

Generate at minimum:

``` r

pca_export_plot(pca_plot(fit, "scree"), "scree.pdf")
pca_export_plot(pca_plot(fit, "scores", group = ex$group), "scores.tiff", dpi = 600)
pca_export_table(pca_table(fit, "eigenvalues"), "eigenvalues.xlsx")
```

Open each output in an independent viewer. Verify fonts, Unicode
characters, axis labels, component percentages, raster resolution,
vector editability, table precision, and captions.

## 17. Release metadata

Before release:

1.  replace placeholder maintainer contact data;
2.  update package version and date;
3.  regenerate documentation;
4.  update `NEWS.md`;
5.  verify all bibliographic metadata;
6.  run all tests and vignettes in a clean session;
7.  store [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html)
    with the validation record;
8.  archive the exact source tarball that passed checking.
