# Synthetic agronomy dataset for examples and teaching

This function returns simulated, not empirical, measurements. It is
intended for demonstrations and software tests only.

## Usage

``` r
pca_example_agronomy(seed = 42L)
```

## Arguments

- seed:

  Random seed.

## Value

List with numeric traits and supplementary treatment/block metadata.

## Examples

``` r
ex <- pca_example_agronomy(seed = 1)
head(ex$data)
#>       plant_height leaf_area chlorophyll photosynthesis stomatal_conductance
#> Plot1     69.93357  25.09399    35.52906       9.893584            0.1899154
#> Plot2     65.50083  18.45340    43.86799      17.745686            0.3722617
#> Plot3     69.45896  19.87693    41.07633      14.819492            0.3993073
#> Plot4     89.77644  31.11528    39.47994      15.291008            0.2926449
#> Plot5     67.84829  19.40400    40.56585      15.382051            0.3629483
#> Plot6     60.97217  23.01995    34.00412      14.450553            0.2806209
#>         biomass    yield
#> Plot1 1.2754968 2.445967
#> Plot2 1.3638781 2.661088
#> Plot3 0.6950348 1.550282
#> Plot4 1.4756503 2.598073
#> Plot5 1.3752376 2.105774
#> Plot6 0.8621360 2.205947
table(ex$metadata$treatment)
#> 
#> T1 T2 T3 T4 T5 T6 
#> 12 12 12 12 12 12 
```
