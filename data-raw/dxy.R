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

# China GEOJSON
# download
china_json <- raster::getData('GADM', country = 'CHINA', level = 2)

china_json <- rmapshaper::ms_simplify(china_json, keep = 0.05) 
china_json <- geojsonio::geojson_list(china_json)

china_json$features <- china_json$features %>% 
  purrr::map(function(x){ 
    x$properties$name <- x$properties$NAME_2
    return(x)
  })

# test
library(echarts4r)

e_charts() %>%
  e_map_register("CHINA", china_json) %>%
  e_map(map = "CHINA")

# translations
translations <- readr::read_csv("./data-raw/translations.csv", col_types = readr::cols())
names(translations) <- c("chinese", "english")
translations <- dplyr::mutate(
  translations, 
  english = gsub(" City", "", english)
)

usethis::use_data(china_cities_location, overwrite = TRUE)
