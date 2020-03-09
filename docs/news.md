# Changelog

## coronavirus 0.1.2

- Added news tab
- Added daily cases to JHU tab
- Added line graph of cases outside China
- Added cumulative view on new cases in JHU tab
- Improve chart transition

## coronavirus 0.1.1

- Initialise embeds; ability to embed charts, optionally.
- Corrected JHU maps.
- Changed JHU China map to piecewise visual map
- Changed DXY maps to piecewise

## coronavirus 0.1.0

- Initialise API, see `run_api`

## coronavirus 0.0.6

- Add total numbers as returned by Weixin. :warning: great discrepancy between those and the daily figures.
- Fixed to meet new John Hopkins data format.
- PWA works on iPhone

## coronavirus 0.0.5

- Add hubei default province in DXY tab.
- Add shinyscroll to scroll to selected province in DXY tab.
- Extend toast duration to 5 seconds.
- Remove coordinates of cities from crawl.
- Switch to using [Github](https://github.com/CSSEGISandData/2019-nCoV) instead of spreadsheet for JHU data. 
- Add death rate and plot to JHU dashboard
- Added icons, thanks to Victor Perrier

## coronavirus 0.0.4

- Revamped DXY tab, uses counties and provinces instead of geo-located cities.
- John Hopkins added timeline bar chart.
- Added `create_script` to easily create cronjob script.
- Use translation as internal dataset instead of utils data.frame due to encoding issue see [#6](https://github.com/JohnCoene/coronavirus/issues/6).
- Force Shiny version `1.4.0`, see [#6](https://github.com/JohnCoene/coronavirus/issues/6).
- Improve loader on DXY city map

## coronavirus 0.0.3

- Connect all charts in dxy and weixin tabs
- Corrected deaths and recovered in DingXiangYuan data, was swapped, see [#2](https://github.com/JohnCoene/coronavirus/issues/2)
- Number of suspected by city given by DingXiangYuan is wildly inaccurate, has been removed.
- JHU timeline uses time scale for better, more accurate representation of events.
- Corrected legend on timeline in JHU tab

## coronavirus 0.0.2

- Added DXY data source and corresponding tab
- Corrected Timeline map dates on JHU map

## coronavirus 0.0.1

* Initial version
