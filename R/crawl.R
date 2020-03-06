#' Crawl Data
#' 
#' Crawl John Hopkin's data and store in database. 
#' Every time the function is called the entirety of 
#' the data is pulled and the content of the database 
#' is overwritten. 
#' 
#' @export
crawl_coronavirus <- function(){

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
    confirmed <- readr::read_csv(confirmed_sheet, col_types = readr::cols())
    recovered <- readr::read_csv(recovered_sheet, col_types = readr::cols())
    deaths <- readr::read_csv(deaths_sheet, col_types = readr::cols())
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
      date = as.Date(date, format = "%m/%d/%y"),
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

  china <- nCov2019::get_nCov2019(lang = "zh")
  china_daily <- china$chinaDayList %>% 
    dplyr::mutate(
      date = paste0("2020.", date),
      date = as.Date(date, "%Y.%m.%d")
    ) %>% 
    dplyr::mutate_if(is.character, as.numeric)
  
  china_total <- as.data.frame(china$chinaTotal, stringsAsFactors = FALSE) 

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
    dplyr::left_join(chinese_provinces, by = c("province" = "chinese")) %>% 
    dplyr::rename(province_pinyin = state)

  log <- tibble::tibble(last_updated = Sys.time())

  # crawl news
  news <- NULL
  if(file.exists(config_file)){
    if(has_newsapi()){
      cli::cli_alert_info("Crawling news from newsapi.org")
      set_news_api_token()
      news <- newsapi::every_news("coronavirus OR covid", results = 100, language = "en", sort = "popularity")
    } else {
      cli::cli_alert_danger("Not `newsapi` entry in config file, not crawling news.")
    }
  }

  # save
  if(file.exists(config_file)){
    cli::cli_alert_success("Writing to database")
    DBI::dbWriteTable(con, "jhu", df, overwrite = TRUE, append = FALSE)
    DBI::dbWriteTable(con, "weixin_total", china_total, overwrite = TRUE, append = FALSE)
    DBI::dbWriteTable(con, "weixin", china_daily, overwrite = TRUE, append = FALSE)
    DBI::dbWriteTable(con, "dxy", dxy, overwrite = TRUE, append = FALSE)
    DBI::dbWriteTable(con, "log", log, append = TRUE)
    DBI::dbWriteTable(con, "news", news, overwrite = TRUE)
  }

  dat <- list(
    jhu = df,
    weixin = china_daily,
    weixin_total = china_total,
    dxy = dxy,
    news = news
  )

  invisible(dat)
}

#' Cronjob
#' 
#' Create script file for cronjob.
#' 
#' @export 
create_script <- function(){
  file <- system.file("scrape.R", package = "coronavirus")
  created <- file.copy(file, to = "script.R")
  if(created)
    cli::cli_alert_success("script.R file copied")
  else
    cli::cli_alert_danger("Cannot create script")
  
  invisible()
}