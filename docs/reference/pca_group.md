# Add external group summaries and confidence regions to PCA scores

PCA itself remains unsupervised; group labels are used only after
fitting.

## Usage

``` r
pca_group(
  fit,
  group,
  dims = c(1, 2),
  region = c("mean_chisq", "data_chisq", "bootstrap", "circle_chisq", "none"),
  level = 0.95,
  nboot = 999L,
  npoints = 200L,
  seed = NULL
)
```

## Arguments

- fit:

  A `pca_fit` object.

- group:

  Group/treatment label with one value per fitted observation.

- dims:

  Two principal-component indices.

- region:

  `"mean_chisq"`, `"data_chisq"`, `"bootstrap"`, `"circle_chisq"`, or
  `"none"`.

- level:

  Confidence/content level.

- nboot:

  Bootstrap replicates for centroid regions.

- npoints:

  Number of points per region curve.

- seed:

  Optional seed.

## Value

Group centroids, sizes, and region coordinates.

## Examples

``` r
fit <- pca_fit(iris[, 1:4], center = TRUE, scale = TRUE, ncomp = 3)
grp <- pca_group(fit, iris$Species, region = "data_chisq")
grp$centroids
#>        group  n          x          y
#> 1     setosa 50 -2.2173249 -0.2879627
#> 2 versicolor 50  0.4947904  0.5483335
#> 3  virginica 50  1.7225345 -0.2603708
head(grp$regions)
#>           group         x        y
#> setosa.1 setosa -2.166891 1.991763
#> setosa.2 setosa -2.182740 1.990977
#> setosa.3 setosa -2.198623 1.987919
#> setosa.4 setosa -2.214525 1.982592
#> setosa.5 setosa -2.230429 1.975002
#> setosa.6 setosa -2.246320 1.965157
# group labels remain supplementary to the unsupervised fit
```
