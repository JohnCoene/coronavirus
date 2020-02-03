# constants
config_file <- "_coronavirus.yml"
spreadsheet <- "https://docs.google.com/spreadsheets/d/1UF2pSkFTURko2OvfHWWlFpDFAr1UxCBA4JLwlSP6KFo"
theme <- "dark"

# global variables
globalVariables(c(".", "cases", "type", "country", "chinese", "country_iso2c"))

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
    "安徽",
    "北京",
    "重庆",
    "福建",
    "甘肃",
    "广东",
    "广西",
    "贵州",
    "海南",
    "河北",
    "黑龙江",
    "河南",
    "湖北",
    "湖南",
    "内蒙古",
    "江苏",
    "江西",
    "吉林",
    "辽宁",
    "宁夏",
    "青海",
    "陕西",
    "山东",
    "上海",
    "山西",
    "四川",
    "天津",
    "西藏",
    "新疆",
    "云南",
    "浙江",
    "香港",
    "台湾"
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
  yaml::read_yaml(config_file)
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
disconnect <- function(con){
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