#' Crawl Data
#' 
#' Crawl John Hopkin's data and store in database. 
#' Every time the function is called the entirety of 
#' the data is pulled and the content of the database 
#' is overwritten. 
#' 
#' @param deauth Forces deauthenticatication via googlesheets4.
#' 
#' @export
crawl_coronavirus <- function(deauth = TRUE){

  if(deauth)
    googlesheets4::sheets_deauth()

  con <- NULL
  if(file.exists(config_file)){
    con <- connect()
  }

  on.exit({
    disconnect(con)
  })

  # get data
  cli::cli_alert_info("Crawling data from John Hopkins")
  
  # read data
  suppressMessages({
    confirmed <- googlesheets4::sheets_read(spreadsheet, sheet = "Confirmed")
    recovered <- googlesheets4::sheets_read(spreadsheet, sheet = "Recovered")
    deaths <- googlesheets4::sheets_read(spreadsheet, sheet = "Death")
  })

  # add col
  confirmed$type <- "confirmed"
  recovered$type <- "recovered"
  deaths$type <- "death"

  # rename
  confirmed <- rename_sheets(confirmed)
  recovered <- rename_sheets(recovered)
  deaths <- rename_sheets(deaths)

  # pivot longer
  confirmed <- pivot(confirmed)
  recovered <- pivot(recovered)
  deaths <- pivot(deaths)

  df <- dplyr::bind_rows(confirmed, recovered, deaths) %>% 
    dplyr::mutate(
      date = as_date(date),
      cases = trimws(cases),
      cases = as.numeric(cases),
      cases = dplyr::case_when(
        is.na(cases) ~ 0,
        TRUE ~ cases
      ),
      country = dplyr::case_when(
        country == "US" ~ "United States of America",
        TRUE ~ country
      ),
      country_iso2c = countrycode::countrycode(country, "country.name", "iso2c")
    )

  cli::cli_alert_info("Crawling data from Weixin")

  china <- nCov2019::get_nCov2019()
  china_daily <- china$chinaDayList %>% 
    dplyr::mutate(
      date = paste0("2020.", date),
      date = as.Date(date, "%Y.%m.%d")
    ) %>% 
    dplyr::mutate_if(is.character, as.numeric)

  cli::cli_alert_info("Crawling data from DXY")
  dxy_list <- xml2::read_html(dxy_url) %>% 
    rvest::html_node("#getAreaStat") %>% 
    rvest::html_text() %>% 
    gsub("try \\{ window.getAreaStat = ", "", .) %>% 
    gsub("\\}catch\\(e\\)\\{\\}", "", .) %>% 
    jsonlite::fromJSON() 
  
  dxy <- dxy_list %>% 
    dplyr::pull(cities) %>% 
    purrr::map2(dxy_list$provinceShortName, function(city, province){
      if(nrow(city))
        city$province <- province
      return(city)
    }) %>% 
    purrr::map2(dxy_list$provinceName, function(city, province){
      if(nrow(city))
        city$province_long <- province
      return(city)
    }) %>% 
    purrr::map_dfr(tibble::as_tibble) %>% 
    dplyr::left_join(china_cities_location, by = "cityName") %>% 
    dplyr::left_join(chinese_provinces, by = c("province" = "chinese")) %>% 
    dplyr::rename(province_pinyin = state)

  log <- tibble::tibble(last_updated = Sys.time())

  # save
  if(file.exists(config_file)){
    cli::cli_alert_success("Writing to database")
    DBI::dbWriteTable(con, "jhu", df, overwrite = TRUE, append = FALSE)
    DBI::dbWriteTable(con, "weixin", china_daily, overwrite = TRUE, append = FALSE)
    DBI::dbWriteTable(con, "dxy", dxy, overwrite = TRUE, append = FALSE)
    DBI::dbWriteTable(con, "log", log, append = TRUE)
  }

  dat <- list(
    jhu = df,
    weixin = china_daily,
    dxy = dxy
  )

  invisible(dat)
}
