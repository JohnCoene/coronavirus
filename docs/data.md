# Data

Minor checks of the crawler.

[![Coveralls test coverage](https://coveralls.io/repos/github/JohnCoene/coronavirus/badge.svg)](https://coveralls.io/r/JohnCoene/coronavirus?branch=master) [![Codecov test coverage](https://codecov.io/gh/JohnCoene/coronavirus/branch/master/graph/badge.svg)](https://codecov.io/gh/JohnCoene/coronavirus?branch=master)

## Sources

- Data from [John Hopkins GIS dashboard](https://github.com/CSSEGISandData/2019-nCoV) accessed via readr (used to be from Google sheet).
- Data from Weixin using the [nCov2019](https://github.com/GuangchuangYu/nCov2019) package thanks to Guangchuang Yu
- Data from [DingXiangYuan](https://ncov.dxy.cn/ncovh5/view/pneumonia) scraped using rvest.

## Cronjob

To set up the cronjob, recreate your config file somewhere in your home directory.

```
cd /home
mkdir ncov
R -e "coronavirus::create_config()"
vi _coronavirus.yml
```

After editing the config file we can create the script that will crawl fresh data. There is a convenience `create_script` function to do so.

```bash
R -e "coronavirus::create_script()"
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

Though every version should be backward compatible, it's good practice to re-run a crawl after installing a new version of the package. 

## Corrections

:warning: Corrected inaccuracies

`v0.1.1`

- There was an issue were the number of cases counted in the John Hopkins map of china and world map was wrongly filtered and gave numbers higher than actually are.

`v0.0.6`

- Corrected death rate from `deaths/confirmed` to `deaths/(confirmed + recovered)` 

`v0.0.3`:

- Deaths and recovered numbers for DingXiangYuan data was previously [swapped](https://github.com/JohnCoene/coronavirus/issues/2), now fixed.
- Number of suspected by city given by DingXiangYuan is wildly inaccurate, has been removed.
- Replaced Map on JHU tab as color scaling was inaccurate due to timeline.
