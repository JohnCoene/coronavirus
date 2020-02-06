# constants
config_file <- "_coronavirus.yml"
spreadsheet <- "https://docs.google.com/spreadsheets/d/1UF2pSkFTURko2OvfHWWlFpDFAr1UxCBA4JLwlSP6KFo"
theme <- "dark"
dxy_url <- "https://ncov.dxy.cn/ncovh5/view/pneumonia"

# global variables
globalVariables(
  c(
    ".", "cases", "type", "country", "chinese", "country_iso2c",
    "confirmed", "death", "desc", "recovered", "state", "cityName",
    "china_cities_location", "cities", "lat", "lon", "value",
    "confirmedCount", "curedCount", "deadCount", "suspectedCount"
  )
)

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

check_config <- function(config){
  if(config$database$user == "me" && config$database$password == "password" && config$database$name == "name")
    stop("Complete the config file: _coronavirus.yml")
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
  names(df)[1:5] <- c(
    "state",
    "country",
    "first", 
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

#' Convert
#' 
#' Convert dates.
#' 
#' @keywords internal
as_date <- function(date){
  date <- lubridate::mdy_hm(date, "%m/%d/%Y %H:%M %p")
  date[!is.na(date)]
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
#' Geolocate DianXiangYuan data. 
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
