<div align="center">

<img src="./man/figures/logo.png" height="250px" />

<!-- badges: start -->
[![CircleCI build status](https://circleci.com/gh/JohnCoene/coronavirus.svg?style=svg)](https://circleci.com/gh/JohnCoene/coronavirus)
[![Travis build status](https://travis-ci.org/JohnCoene/coronavirus.svg?branch=master)](https://travis-ci.org/JohnCoene/coronavirus)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/JohnCoene/coronavirus?branch=master&svg=true)](https://ci.appveyor.com/project/JohnCoene/coronavirus)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
![](https://img.shields.io/badge/license-MIT-blue)
<!-- badges: end -->

Dashboard to track the spread of the coronavirus, based on three data sources, built with [shinyMobile](https://rinterface.github.io/shinyMobile/) and [echarts4r](https://echarts4r.john-coene.com/).

[Tracker](https://shiny.john-coene.com/coronavirus) | [Docs](https://coronavirus.john-coene.com) | [API](https://coronavirus.john-coene.com/#/api) | [Changelog](NEWS.md)

</div>

## Test

You can test the app before preparing any kind of deployment (e.g.: set up a database), visit the [docs](https://coronavirus.john-coene.com) if you want to deploy it.

```r
library(coronavirus)

virus <- crawl_coronavirus()
run_app(virus)
```

![](https://coronavirus.john-coene.com/_media/banner.png)

## Get it

You can view the [dashboard](https://shiny.john-coene.com/coronavirus) online or download the package to run it locally or deploy it.

``` r
# install.packages("remotes")
remotes::install_github("JohnCoene/coronavirus")
```

## Contribute

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
