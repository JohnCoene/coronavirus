<div align="center">

![](https://coronavirus.john-coene.com/_media/banner.png)

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build status](https://travis-ci.org/JohnCoene/coronavirus.svg?branch=master)](https://travis-ci.org/JohnCoene/coronavirus)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

Dashboard to track the spread of the coronavirus, based on three data sources, built with [shinyMobile](https://rinterface.github.io/shinyMobile/) and [echarts4r](https://echarts4r.john-coene.com/).

[Dashboard](https://shiny.john-coene.com/coronavirus) | [Docs](https://coronavirus.john-coene.com) | [Changelog](NEWS.md)

</div>

## Get it

You can view the [dashboard](https://shiny.john-coene.com/coronavirus) online or download the package to run it locally or deploy it.

``` r
# install.packages("remotes")
remotes::install_github("JohnCoene/coronavirus")
```

## Test

You can test the app before preparing any kind of deployment (e.g.: set up a database), visit the [docs](https://coronavirus.john-coene.com) if you want to deploy it.

```r
library(coronavirus)

virus <- crawl_coronavirus()
run_app(virus)
```

## Contribute

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
