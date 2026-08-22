# Simulate PCA data with known latent structure and optional contamination

Simulate PCA data with known latent structure and optional contamination

## Usage

``` r
pca_simulate(
  n = 200L,
  p = 10L,
  rank = 3L,
  eigenvalues = NULL,
  noise = 0.3,
  casewise = 0,
  cellwise = 0,
  nonlinear = FALSE,
  seed = 1L
)
```

## Arguments

- n:

  Number of observations.

- p:

  Number of variables.

- rank:

  Latent rank.

- eigenvalues:

  Latent signal variances.

- noise:

  Standard deviation of isotropic noise.

- casewise:

  Fraction of rows contaminated.

- cellwise:

  Fraction of individual cells contaminated.

- nonlinear:

  If TRUE, append a curved relationship to the first variables.

- seed:

  Random seed.

## Value

List with observed data and known truth.

## Examples

``` r
s <- pca_simulate(n = 150, p = 8, rank = 3,
                   eigenvalues = c(6, 4, 2), noise = 0.2, seed = 1)
dim(s$data)
#> [1] 150   8
s$eigenvalues
#> [1] 6 4 2
# recover the planted subspace with classical PCA
fit <- pca_fit(s$data, scale = FALSE)
fit$eigenvalues[1:3]
#>      PC1      PC2      PC3 
#> 5.150556 4.201947 2.182483 
```
