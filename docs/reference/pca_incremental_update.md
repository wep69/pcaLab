# Update an incremental PCA state with a batch

Update an incremental PCA state with a batch

## Usage

``` r
pca_incremental_update(state, batch)
```

## Arguments

- state:

  Incremental state.

- batch:

  Numeric matrix with the same variables.

## Examples

``` r
st <- pca_incremental_init(3, center = TRUE)
st <- pca_incremental_update(st, matrix(rnorm(30), 10, 3))
st$n
#> [1] 10
```
