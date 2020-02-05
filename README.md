<div align="center">

![](/inst/app/www/coronavirus.png)

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

[Dashboard](https://shiny.john-coene.com/coronavirus) | [changelog](news.md) 

Dashboard to track the spread of the coronavirus, based on three data sources, built with [shinyMobile](https://rinterface.github.io/shinyMobile/) and [echarts4r](https://echarts4r.john-coene.com/).

</div>

## Get it

You can view the [dashboard](https://shiny.john-coene.com/coronavirus) online or download the package to run it locally or deploy it.

``` r
install.packages("remotes")
remotes::install_github("JohnCoene/coronavirus")
```

## Dev

You can test the app before preparing any kind of deployment you can test like so.

```r
library(coronavirus)

virus <- crawl_coronavirus()
run_app(virus)
```

## Production

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

You can deploy on whatever server you like, install R and the [Shiny Community server](https://rstudio.com/products/shiny/download-server/), then install the package from the terminal with. This also works on [shinyapps.io](https://www.shinyapps.io/).

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

See the data section below to set up the crom job.

## Data

See Credits below for the data sources. The package contains a dataset named `china_cities_location` which contains the geographic coordinates of Chinese cities as returned by the DXY data source. I will update it regularly, reinstall the package to get the updated version, or run the `dxy` file in the `data-raw` directory and rebuild the package with `devtools::install`. 

This is done so because it requires a Google Geocode API key (set as `GOOGLE_GEOCODE_KEY` environment variable) and would make the package much more cumbersome to run.

**Cronjob**

To set up the cronjob, recreate your config file somewhere in your home directory.

```
cd /home
mkdir ncov
R -e "coronavirus::create_config()"
vi _coronavirus.yml
```

After editing the config file place a script.R file.

```r
# in script.R
googlesheets4::sheets_deauth()
data("china_cities_location", package = "coronavirus")
coronavirus::crawl_coronavirus()
```

You should test that all works fine by running the crawler once from the terminal.

```bash
Rscript script.R
```

Then set up the cron job.

```bash
crontab -e
```

In that file place the following to crawl every hour. If you want to set another interval consult [crontab guru](https://crontab.guru/).

```bash
0 * * * * cd /home/ncov && Rscript script.R
```

All set!

## Credits

- Data from [John Hopkins GIS dashboard](https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6)
- Data from Wixin using [nCov2019](https://github.com/GuangchuangYu/nCov2019) by Guangchuang Yu
- Data from [DianXianYing](https://ncov.dxy.cn/ncovh5/view/pneumonia)
- The [shinyMobile](https://github.com/RinteRface/shinyMobile) framework

## To do

- API
- Predictive model (currently limited to a fit)

## Contribute

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
