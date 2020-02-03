config_file <- "_coronavirus.yml"
token_file <- "googlesheets.rds"
spreadsheet <- "https://docs.google.com/spreadsheets/d/1UF2pSkFTURko2OvfHWWlFpDFAr1UxCBA4JLwlSP6KFo"

globalVariables(c(".", "confirmed", "country_region", "last_update", "province_state"))

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

#' Retrieve Token
#' 
#' Retrieves token file.
#' 
#' @keywords internal
get_token <- function(){
  has_token()
  readRDS(token_file)
}

#' Has Config
#' 
#' Ensure config file is present.
#' 
#' @keywords internal
has_token <- function(){
  has_token <- file.exists(token_file)
  if(!has_token)
    stop(
      "Missing config file, see `create_token`", call. = FALSE
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