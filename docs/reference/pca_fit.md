# Fit Principal Component Analysis and advanced variants

A unified interface for classical and advanced PCA engines.

## Usage

``` r
pca_fit(
  data,
  method = c("classical", "weighted", "nipals", "em", "ppca", "bayesian", "robust",
    "cellwise", "sparse", "robust_sparse", "rpca", "kernel", "nlpca", "shrinkage",
    "logistic", "glmpca", "compositional", "functional", "dynamic", "multilevel",
    "multiblock", "randomized", "incremental"),
  center = TRUE,
  scale = FALSE,
  ncomp = NULL,
  transform = c("none", "log1p", "sqrt"),
  weights = NULL,
  ...
)

# S3 method for class 'pca_fit'
print(x, ...)

# S3 method for class 'pca_fit'
summary(object, ...)

# S3 method for class 'summary.pca_fit'
print(x, ...)

# S3 method for class 'pca_fit'
fitted(object, ...)

# S3 method for class 'pca_fit'
residuals(object, original_scale = TRUE, ...)

# S3 method for class 'pca_fit'
predict(object, newdata, ncomp = object$ncomp, ...)

# S3 method for class 'pca_fit'
plot(x, ...)
```

## Arguments

- data:

  Numeric matrix/data frame, except where an engine documents a
  specialized input.

- method:

  PCA engine. See
  [`pca_capabilities()`](https://wep69.github.io/pcaLab/reference/pca_capabilities.md).

- center:

  Logical; center variables before fitting.

- scale:

  Scaling method accepted by
  [`pca_preprocess()`](https://wep69.github.io/pcaLab/reference/pca_preprocess.md).

- ncomp:

  Number of retained components. `NULL` uses the maximum meaningful rank
  for most engines.

- transform:

  Optional element-wise preprocessing transformation: `"none"`,
  `"log1p"`, or `"sqrt"`. Specialized data-type engines may require
  `"none"`.

- weights:

  Optional observation weights for weighted PCA.

- ...:

  Engine-specific arguments.

- x:

  A `pca_fit` object.

- object:

  A `pca_fit` object.

- original_scale:

  Return residuals in the original measurement scale.

- newdata:

  New observations with the original variables.

## Value

An object of class `pca_fit`.

## Examples

``` r
# Classical standardized PCA on Fisher's iris measurements
fit <- pca_fit(iris[, 1:4], method = "classical", center = TRUE, scale = TRUE)
summary(fit)
#> pcaLab summary
#> Method: classical
#>  component eigenvalue    variance cumulative
#>        PC1 2.91849782 0.729624454  0.7296245
#>        PC2 0.91403047 0.228507618  0.9581321
#>        PC3 0.14675688 0.036689219  0.9948213
#>        PC4 0.02071484 0.005178709  1.0000000
head(predict(fit, iris[1:5, 1:4]))
#>         PC1        PC2         PC3         PC4
#> 1 -2.257141 -0.4784238  0.12727962  0.02408751
#> 2 -2.074013  0.6718827  0.23382552  0.10266284
#> 3 -2.356335  0.3407664 -0.04405390  0.02828231
#> 4 -2.291707  0.5953999 -0.09098530 -0.06573534
#> 5 -2.381863 -0.6446757 -0.01568565 -0.03580287

# Observation-weighted PCA
pca_fit(iris[, 1:4], method = "weighted", ncomp = 2,
        weights = seq_len(nrow(iris)))
#> pcaLab fit
#>   Method: weighted
#>   Observations: 150
#>   Variables: 4
#>   Components retained: 2
#>   Variance partition: not defined for this engine

# Compositional PCA on a small parts matrix
parts <- matrix(c(1, 2, 3, 2, 5, 4, 4, 3, 2), nrow = 3, byrow = TRUE)
pca_fit(parts, method = "compositional", coordinate = "ilr", ncomp = 2)
#> pcaLab fit
#>   Method: compositional
#>   Observations: 3
#>   Variables: 2
#>   Components retained: 2
#>   Variance explained by retained components: 100.0%
```
