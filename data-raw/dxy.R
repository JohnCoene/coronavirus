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

usethis::use_data(china_cities_location, overwrite = TRUE)
