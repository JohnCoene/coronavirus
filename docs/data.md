# Data

## Sources

- Data from [John Hopkins GIS dashboard](https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6) accessed via googlesheets4.
- Data from Weixin using the [nCov2019](https://github.com/GuangchuangYu/nCov2019) package thanks to Guangchuang Yu
- Data from [DianXiangYing](https://ncov.dxy.cn/ncovh5/view/pneumonia) scraped using rvest.

## Cronjob

To set up the cronjob, recreate your config file somewhere in your home directory.

```
cd /home
mkdir ncov
R -e "coronavirus::create_config()"
vi _coronavirus.yml
```

After editing the config file place a script.R file.

```r
library(coronavirus)

# in script.R
googlesheets4::sheets_deauth() # force deauth 

# crawl
crawl_coronavirus()
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

## Corrections

:warning: Corrected inaccuracies

In `v0.0.3`:

- Deaths and recovered numbers for DianXiangYing data was previously [swapped](https://github.com/JohnCoene/coronavirus/issues/2), now fixed.
- Number of suspected by city given by DianXiangYing is wildly inaccurate, has been removed.
