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

Create the config file required to run the crawler. :warning: you should only have to do this once.

``` r
library(coronavirus)

# create and fill config file
create_config()
```

Fill in the config file created with the credentials to your Postgres database. Then run the crawler and launch the app. Every time you want to update the data, re-run `crawl_coronavirus`.

```r
# crawl data
crawl_coronavirus()

# launch the dashboard
run_app()
```

## Deploy

:+1: Open an issue if you have problems deploying, I'm more than happy helping.

You can deploy on whatever server you like, install R and the [Shiny Community server](https://rstudio.com/products/shiny/download-server/), then install the package from the terminal with.

```bash
sudo su - -c "R -e \"install.packages('remotes')\""
sudo su - -c "R -e \"remotes::install_github('JohnCoene/coronavirus')\""
```

Once this done create a directory under `/srv/shiny-server/`, where you can create the config file.

```bash
cd /srv/shiny-server
mkdir coronavirus
cd ./coronavirus
R -e "coronavirus::create_config()"
vi _coronavirus.yml
```

Fill in the config file and create the app.

```bash
echo "coronavirus::run_app()" > app.R 
```

You can then visit `http://my.server.ip:3838/coronavirus`, you can change the port in the `/etc/shiny-server/shiny-server.conf` file, change it to `80` to have your app at `http://my.server.ip/coronavirus`.

## Credits

- Data from [John Hopkins GIS dashboard](https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6)
- Data from Wixin using [nCov2019](https://github.com/GuangchuangYu/nCov2019) by Guangchuang Yu
- The [shinyMobile](https://github.com/RinteRface/shinyMobile) framework

## To do

- API
- Predictive model (currently limited to a fit)

## Contribute

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
