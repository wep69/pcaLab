# Exploration and Communication: Tours, Publication-Ready Figures, Tables, and Reproducible Reports

## Exploration and Communication: Tours, Publication-Ready Figures, Tables, and Reproducible Reports

**Package:** `pcaLab`\
**Target version:** `0.1.0`\
**Role in the vignette system:** Exploratory projection beyond a single
PCA plane and the complete communication layer for figures, tables,
exports, and reproducible reports.

> This source is intentionally instructional. It is not precompiled
> here. Code that requires an optional backend is guarded in the
> examples or should be run only after
> [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md)
> confirms availability.

### Learning objectives

The reader will learn to:

1.  understand why PCA provides only one variance-maximizing projection
    among many possible views;
2.  use local, grand, guided, radial, and history tours appropriately;
3.  compare projection histories without converting exploratory
    animation into inferential evidence;
4.  create scree, score, loading, correlation-circle, contribution,
    cos², diagnostic, inference, stability, trajectory, eigenfunction,
    reconstruction, and 3D figures;
5.  export PDF/SVG vector graphics and high-resolution TIFF/PNG files;
6.  produce publication-ready eigenvalue, loading, score, variable,
    diagnostic, preprocessing, dimensionality, inferential, bootstrap,
    and association tables;
7.  export tables in reproducible machine-readable and document-ready
    formats;
8.  generate a structured analysis report with
    [`pca_report()`](https://wep69.github.io/pcaLab/reference/pca_report.md).

### Scope and relationship to the other vignettes

This vignette is intentionally focused. It develops the topics below in
depth and avoids reproducing material assigned to other blocks.

**Developed here:** Exploratory projection beyond a single PCA plane and
the complete communication layer for figures, tables, exports, and
reproducible reports.

**Not developed here:** Method choice and failure modes are deliberately
reserved for the final decision-oriented vignette.

## Part XIII. Touring and exploratory projection

### 42. PCA gives one variance-maximizing view; tours explore alternatives

A two-dimensional PCA plot is only one projection of a high-dimensional
cloud.

[`pca_tour()`](https://wep69.github.io/pcaLab/reference/pca_tour.md)
uses the fitted PCA loading plane as the starting basis.

#### 42.1 Local tour

A local tour explores nearby rotations and asks whether the visible PCA
structure persists under small perturbations.

``` r

if (requireNamespace("tourr", quietly = TRUE)) {
  pca_tour(
    fit,
    type = "local",
    dims = c(1, 2),
    group = meta$treatment,
    angle = pi / 10,
    max_frames = 60
  )
}
```

#### 42.2 Grand tour

``` r

if (requireNamespace("tourr", quietly = TRUE)) {
  pca_tour(
    fit,
    type = "grand",
    dims = c(1, 2),
    group = meta$treatment,
    max_frames = 60
  )
}
```

#### 42.3 Guided tour

``` r

if (requireNamespace("tourr", quietly = TRUE)) {
  pca_tour(
    fit,
    type = "guided",
    dims = c(1, 2),
    group = meta$treatment,
    max_frames = 60
  )
}
```

#### 42.4 Radial tour

``` r

if (requireNamespace("tourr", quietly = TRUE)) {
  pca_tour(
    fit,
    type = "radial",
    dims = c(1, 2),
    variable = 1,
    max_frames = 60
  )
}
```

#### 42.5 Save a tour history

``` r

if (requireNamespace("tourr", quietly = TRUE)) {
  tour_history <- pca_tour(
    fit,
    type = "history",
    dims = c(1, 2),
    max_frames = 40,
    save_history = TRUE
  )
}
```

#### 42.6 Export GIF when supported

``` r

if (
  requireNamespace("tourr", quietly = TRUE) &&
  requireNamespace("gifski", quietly = TRUE)
) {
  pca_tour(
    fit,
    type = "local",
    dims = c(1, 2),
    group = meta$treatment,
    gif_file = "pca_local_tour.gif",
    max_frames = 50
  )
}
```

#### 42.7 Compare projection histories

``` r

if (requireNamespace("tourr", quietly = TRUE)) {
  tour_cmp <- pca_tour_compare(
    fit,
    dims = c(1, 2),
    max_bases = 50,
    angle = pi / 8
  )

  names(tour_cmp)
}
```

#### Interpretation

Tours are not decorative animation. They answer a useful diagnostic
question:

**Is the visually compelling pattern in the PCA plane stable, or does
another nearby projection reveal a substantially different structure?**

A grand or guided tour can also reveal clustering or nonlinear structure
that variance-maximizing PCA does not emphasize.

------------------------------------------------------------------------

## Part XIV. Publication-ready figures and tables

### 43. Figure gallery

The main static figure types are:

``` r

# Component spectrum.
pca_plot(fit, "scree")
pca_plot(fit, "cumulative")

# Observations.
pca_plot(fit, "scores", dims = c(1, 2))
pca_plot(fit, "scores", dims = c(1, 3), group = meta$treatment)

# Variables.
pca_plot(fit, "loadings", component = 1)
pca_plot(fit, "correlation_circle", dims = c(1, 2))
pca_plot(fit, "contributions", component = 1)
pca_plot(fit, "cos2", component = 1)
pca_plot(fit, "biplot", dims = c(1, 2))

# Diagnostics.
pca_plot(fit, "diagnostics")
pca_plot(fit, "reconstruction")

# Inference and stability.
pca_plot(fit, "bootstrap_loadings", component = 1, bootstrap = boot)
pca_plot(fit, "eigen_ci", bootstrap = boot)
pca_plot(fit, "inference_axes", inference = ptest)
pca_plot(fit, "dimension_selection", selection = selection)
```

For functional PCA:

``` r

pca_plot(fit_fpca, "eigenfunctions")
```

For dynamic PCA:

``` r

pca_plot(fit_dyn, "trajectory")
```

#### 43.1 Interactive three-dimensional score plot

``` r

if (requireNamespace("plotly", quietly = TRUE)) {
  p3 <- pca_plot(
    fit,
    type = "scores3d",
    dims = c(1, 2, 3),
    group = meta$treatment
  )

  p3
}
```

#### 43.2 Export publication figures

Vector PDF:

``` r

pca_export_plot(
  p_scores_grouped,
  "pca_scores.pdf",
  width = 7,
  height = 5,
  dpi = 600
)
```

Vector SVG:

``` r

pca_export_plot(
  p_biplot,
  "pca_biplot.svg",
  width = 7,
  height = 5,
  dpi = 600
)
```

High-resolution TIFF:

``` r

pca_export_plot(
  p_diag,
  "pca_diagnostics.tiff",
  width = 7,
  height = 5,
  dpi = 600
)
```

High-resolution PNG:

``` r

pca_export_plot(
  p_scree,
  "pca_scree.png",
  width = 7,
  height = 5,
  dpi = 600
)
```

#### Figure principles

1.  Label axes with the component and explained variance when the engine
    defines ordinary variance partition.
2.  Show observed scores when possible.
3.  Distinguish supplementary group information from model-fitting
    information.
4.  Use color together with shape where group identification matters.
5.  Use accessible palettes and readable symbols.
6.  Avoid implying statistical significance from visual separation
    alone.
7.  Report the preprocessing used to obtain the plotted coordinates.
8.  Avoid showing only PC1-PC2 if important structure is retained in
    later axes.
9.  For robust fits, show diagnostic distance maps in addition to
    ordinary score plots.
10. For bootstrap inference, show uncertainty rather than only point
    loadings.
11. Use vector formats for line art whenever the journal accepts them.
12. Use 600-dpi raster output when raster submission is required.

------------------------------------------------------------------------

### 44. Publication-ready tables

#### 44.1 Eigenvalues

``` r

tab_eigen <- pca_table(
  fit,
  type = "eigenvalues"
)

tab_eigen
```

#### 44.2 Loadings

``` r

tab_loadings <- pca_table(
  fit,
  type = "loadings"
)
```

#### 44.3 Scores

``` r

tab_scores <- pca_table(
  fit,
  type = "scores"
)
```

#### 44.4 Variable metrics

``` r

tab_var <- pca_table(
  fit,
  type = "variables",
  component = 1
)
```

#### 44.5 Diagnostics

``` r

tab_diag <- pca_table(
  fit,
  type = "diagnostics"
)
```

#### 44.6 Preprocessing audit

``` r

tab_prep <- pca_table(
  fit,
  type = "preprocessing"
)
```

#### 44.7 Dimensionality-selection table

``` r

tab_ncomp <- pca_table(
  fit,
  type = "ncomp",
  selection = selection
)
```

#### 44.8 Inferential tables

``` r

tab_global <- pca_table(
  fit,
  type = "inference_global",
  inference = ptest
)

tab_axes <- pca_table(
  fit,
  type = "inference_axes",
  inference = ptest
)
```

#### 44.9 Bootstrap eigenvalues

``` r

tab_boot <- pca_table(
  fit,
  type = "bootstrap_eigenvalues",
  bootstrap = boot
)
```

#### 44.10 Association table

``` r

tab_assoc <- pca_table(
  fit,
  type = "associations",
  inference = ptest,
  bootstrap = boot,
  association = assoc
)
```

#### 44.11 `gt` tables

``` r

if (requireNamespace("gt", quietly = TRUE)) {
  gt_eigen <- pca_table(
    fit,
    type = "eigenvalues",
    format = "gt"
  )

  gt_eigen
}
```

#### 44.12 Export formats

``` r

pca_export_table(tab_eigen, "pca_eigenvalues.csv")
pca_export_table(tab_eigen, "pca_eigenvalues.tsv")
pca_export_table(tab_eigen, "pca_eigenvalues.md")
pca_export_table(tab_eigen, "pca_eigenvalues.tex")
```

If optional backends are installed:

``` r

if (requireNamespace("openxlsx", quietly = TRUE)) {
  pca_export_table(tab_eigen, "pca_eigenvalues.xlsx")
}

if (requireNamespace("gt", quietly = TRUE)) {
  pca_export_table(tab_eigen, "pca_eigenvalues.html")
}

if (
  requireNamespace("officer", quietly = TRUE) &&
  requireNamespace("flextable", quietly = TRUE)
) {
  pca_export_table(tab_eigen, "pca_eigenvalues.docx")
}
```

------------------------------------------------------------------------

### 45. Generate a reproducible PCA report

Markdown output is always supported:

``` r

pca_report(
  fit,
  file = "agronomy_pca_report.md",
  inference = ptest,
  selection = selection,
  bootstrap = boot
)
```

HTML is available when `rmarkdown` is installed:

``` r

if (requireNamespace("rmarkdown", quietly = TRUE)) {
  pca_report(
    fit,
    file = "agronomy_pca_report.html",
    inference = ptest,
    selection = selection,
    bootstrap = boot
  )
}
```

The report records:

- PCA method and engine;
- observations and variables;
- retained components;
- centering and scaling;
- component spectrum;
- variable interpretation;
- observation diagnostics;
- optional permutation inference;
- optional component-number selection;
- optional bootstrap uncertainty;
- interpretation safeguards appropriate to the fitted geometry.

------------------------------------------------------------------------

### Where to continue

Continue to `09-method-choice-limitations-validation.Rmd` before
finalizing a scientific analysis or package validation.

### Reproducibility note

The examples use package-generated or explicitly simulated teaching
data. They demonstrate workflow and interpretation, not empirical
evidence. For stochastic procedures, set and report a seed. For optional
engines, record backend versions with
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) and preserve
the preprocessing specification used to create the fitted object.
