# Get Started

## Get it

The tracker takes the form of a package, you can get it from Github with the `remotes` package.

``` r
# install.packages("remotes")
remotes::install_github("JohnCoene/coronavirus")
```

## Test

You can test the app before preparing any kind of deployment (e.g.: set up a database). Load the library and use `crawl_coronavirus` to get data, then forward that data to the `run_app` function which launches the application.

```r
library(coronavirus)

virus <- crawl_coronavirus()
run_app(virus)
```
