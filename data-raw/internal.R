# DXY LOCATIONS
dxy_url <- "https://ncov.dxy.cn/ncovh5/view/pneumonia"

dxy <- xml2::read_html(dxy_url) %>% 
  rvest::html_node("#getAreaStat") %>% 
  rvest::html_text() %>% 
  gsub("try \\{ window.getAreaStat = ", "", .) %>% 
  gsub("\\}catch\\(e\\)\\{\\}", "", .) %>% 
  jsonlite::fromJSON()

dxy_cities <- purrr::map_dfr(dxy$cities, tibble::as_tibble)

china_cities_location <- geoloc_dxy(dxy_cities) %>% 
  dplyr::select(cityName = search, lat = lat, lon = lng)

#' Dataframe to match for echarts4r geojson to work.
chinese_provinces <- data.frame(
  state = c("Anhui", "Beijing", "Chongqing", "Fujian", "Gansu", "Guangdong", 
    "Guangxi", "Guizhou", "Hainan", "Hebei", "Heilongjiang", "Henan", 
    "Hubei", "Hunan", "Inner Mongolia", "Jiangsu", "Jiangxi", "Jilin", 
    "Liaoning", "Ningxia", "Qinghai", "Shaanxi", "Shandong", "Shanghai", 
    "Shanxi", "Sichuan", "Tianjin", "Tibet", "Xinjiang", "Yunnan", 
    "Zhejiang", "Hong Kong", "Taiwan"
  ),
  chinese = c(
    "安徽", "北京", "重庆", "福建", "甘肃", "广东", "广西", "贵州", "海南", "河北", 
    "黑龙江", "河南", "湖北", "湖南", "内蒙古", "江苏", "江西", "吉林", "辽宁", "宁夏", 
    "青海", "陕西", "山东", "上海", "山西", "四川", "天津", "西藏", "新疆", "云南",
    "浙江", "香港","台湾"
  ),
  stringsAsFactors = FALSE
)

# default
default_province <- "湖北"

# population
fl <- system.file("extdata/population.csv", package = "coronavirus")
china_population <- readr::read_csv(fl, col_types = readr::cols())

usethis::use_data(china_cities_location, chinese_provinces, default_province, china_population, internal = TRUE, overwrite = TRUE)
