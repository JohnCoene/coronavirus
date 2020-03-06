# constants
config_file <- "_coronavirus.yml"
theme <- "dark"
dxy_url <- "https://ncov.dxy.cn/ncovh5/view/pneumonia"

# jhu
confirmed_sheet <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
deaths_sheet <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
recovered_sheet <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"

# pallettes for DXY
deaths_pal <- c("#263238", "#455a64", "#607d8b", "#90a4ae", "#cfd8dc") %>% rev()
recovered_pal <- c("#1b5e20", "#388e3c", "#4caf50", "#81c784", "#c8e6c9") %>% rev()
confirmed_pal <- c("#bf444c", "#d88273", "#f6efa6") %>%  rev()
suspected_pal <- c("#311b92", "#512da8", "#673ab7", "#9575cd", "#d1c4e9") %>% rev()

# global variables
globalVariables(
  c(
    ".", "cases", "type", "country", "chinese", "country_iso2c",
    "confirmed", "death", "desc", "recovered", "state", "cityName",
    "china_cities_location", "cities", "lat", "lon", "value",
    "confirmedCount", "curedCount", "deadCount", "suspectedCount",
    "province", "province_pinyin", "variable", "chinese_provinces",
    "date2", "rate", "cases_lag"
  )
)

#' Retrieve Config
#' 
#' Retrieves config file.
#' 
#' @keywords internal
get_config <- function(){
  has_config()
  config <- yaml::read_yaml(config_file)
  check_config(config)
  return(config)
}

#' Check config
#' 
#' Checks that config is valid.
#' 
#' @keywords internal
check_config <- function(config){
  if(config$database$user == "me" && config$database$password == "password" && config$database$name == "name")
    stop("Complete the config file: _coronavirus.yml")

  if(!length(config$newsapi))
    warning("No newsapi key found in config not crawling news.")
  
  invisible()
}

#' Set the newsapi token
#' @keywords internal
set_news_api_token <- function(){
  config <- yaml::read_yaml(config_file)
  check_config(config)

  newsapi::newsapi_key(config$newsapi$key)
  invisible()
}

#' Has Config
#' 
#' Ensure config file is present.
#' 
#' @keywords internal
has_config <- function(){
  has_config <- file.exists(config_file)
  if(!has_config)
    stop(
      "Missing config file, see `create_config`", call. = FALSE
    )

  invisible()
}

#' Has newsapi config
#' 
#' Check if newsapi config present.
#' 
#' @keywords internal
has_newsapi <- function(){
  config <- yaml::read_yaml(config_file)
  if(length(config$newsapi) > 0){
    if(config$newsapi$key == "https://newsapi.org/" || config$newsapi$key == "https://newsapi.org" )
      return(FALSE)
    return(TRUE)
  }
  else 
    return(FALSE)
  return(TRUE)
}

#' Connect
#' 
#' Connect to database.
#' 
#' @param con Output of \code{connect}.
#' 
#' @rdname connect
#' @keywords internal
connect <- function(){
  config <- get_config()

  has_vars <- all(c("user", "password", "host") %in% names(config$database))

  if(!has_vars)
    stop("Missing variables in config file, see `create_config`", call. = FALSE)
  
  pool::dbPool(
    RPostgres::Postgres(),
    host = config$database$host,
    user = config$database$user,
    password = config$database$password,
    dbname = config$database$name,
    port = 5432
  )
}

#' @rdname connect
#' @keywords internal
disconnect <- function(con = NULL){
  if(!is.null(con))
    pool::poolClose(con)
}

#' Rename
#' 
#' Rename first few columns
#' 
#' @param df Sheet.
#' 
#' @keywords internal
rename_sheets <- function(df){
  names(df)[1:4] <- c(
    "state",
    "country",
    "lat", 
    "lon"
  )
  return(df)
}

#' Pivot
#' 
#' Change data from wide to long.
#' 
#' @param df Sheet.
#' 
#' @keywords internal
pivot <- function(df){
  tidyr::pivot_longer(
    df, 
    tidyselect::contains("/"),
    names_to = c("date"),
    values_to = c("cases"),
    values_ptypes = list(cases = "character")
  )
}

#' Table
#' 
#' Create shinyMobile table.
#' 
#' @param df Data.frame.
#' @param card Whether to use as card.
#' 
#' @keywords internal
as_f7_table <- function(df, card = FALSE){
  headers <- purrr::map(df, class2f7)
  colnames <- names(headers)

  headers <- purrr::map2(headers, colnames, function(x, y){
    tags$th(class = x, y)
  }) 
  
  df_list <- purrr::transpose(df)

  table <- purrr::map(df_list, function(row){
    r <- purrr::map(row, function(cell){
      tags$th(class = class2f7(cell), cell)
    })
    tags$tr(r)
  })

  cl <- "data-table"

  if(card)
    cl <- paste(cl, "card")

  div(
    class = cl,
    tags$table(
      tags$thead(
        tags$tr(headers)
      ),
      tags$tbody(table)
    )
  )
}

#' Get CSS class based on cell class
#' 
#' @param x Value.
#' 
#' @keywords internal
class2f7 <- function(x){
  if(inherits(x, "numeric"))
    return("numeric-cell")
  
  return("label-cell")
}

#' Geolocate DXY Data
#' 
#' Geolocate DingXiangYuan data. 
#' 
#' @details This is used internally to create database of geolocated Chinese cities.
#' 
#' @keywords internal
geoloc_dxy <- function(df){

  key <- Sys.getenv("GOOGLE_GEOCODE_KEY")

  if(key == "")
    stop("Missing `GOOGLE_GEOCODE_KEY` environment variable", call. = FALSE)

  search <- dplyr::select(df, cityName) %>% 
    dplyr::filter(!is.na(cityName)) %>% 
    dplyr::pull(cityName) %>% 
    unique() %>% 
    purrr::map_dfr(locate, key = key)
}

#' Geolocate
#' 
#' Get geolocation using Google Geocode API.
#' 
#' @keywords internal
locate <- function(search, key){

  msg <- paste("Locating", search)
  cli::cli_alert_info(msg)
  
  url <- paste0(
    "https://maps.googleapis.com/maps/api/geocode/json?address=",
    search,
    "&key=", key
  )

  json <- tryCatch(httr::GET(url), error = function(e) e)

  while(inherits(json, "error")){
    Sys.sleep(.5)
    json <- tryCatch(httr::GET(url), error = function(e) e)
  }

  cnt <- httr::content(json)

  loc <- data.frame(lat = NA_real_, lng = NA_real_)

  Sys.sleep(1)

  if(length(cnt$results)){
    if(length(cnt$results[[1]]$geometry$location))
      loc <- cnt$results[[1]]$geometry$location
  }

  loc$search <- search

  return(loc)
  
}

#' Copy URL
#' 
#' @param embed_url Base embed url.
#' @param data Data to use.
#' @param params Parameters.
#' 
#' @keywords internal
copy <- function(embed_url, data, params){
  tags$button(
    class = "button copy-button",
    "Copy Embed Code",
    onClick = paste0("copy(\"<iframe src='", embed_url, "?data=", data, params, "'></iframe>\")")
  )
}

#' Round up
#' 
#' Nicely round up numbers for pieces in maps.
#' 
#' @param x Number.
#' @param nice Vector of ending.
#' 
#' @keywords internal
round_up <- function(x, nice=1:10) {
    if(length(x) != 1) stop("'x' must be of length 1")
    10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}