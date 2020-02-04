<div align="center">

![](/inst/app/www/coronavirus.png)

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Dashboard to track the spread of the coronavirus, based on the data from [John Hopkins' dashboard](https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6), built with [shinyMobile](https://rinterface.github.io/shinyMobile/) and [echarts4r](https://echarts4r.john-coene.com/).

[Dashboard](https://shiny.john-coene.com/coronavirus)

</div>

## Get it

``` r
install.packages("remotes")
remotes::install_github("JohnCoene/coronavirus")
```

## Usage

The function `crawl_coronavirus` crawls the data and overrides the whole Postgres database, it is intended to be used via a cron job.

``` r
library(coronavirus)

# create and fill config file
create_config()

# crawl data
crawl_coronavirus()

# launch the dashboard
run_app()
```

## Credits

- Data from [John Hopkins GIS dashboard](https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6)
- Data from Wixin using [nCov2019](https://github.com/GuangchuangYu/nCov2019) by Guangchuang Yu
- The [shinyMobile](https://github.com/RinteRface/shinyMobile) framework

## To do

- API
- Predictive model (currently limited to a fit)

## Contribute

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
