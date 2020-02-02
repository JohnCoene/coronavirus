config_file <- "_coronavirus.yml"
token_file <- "googlesheets.rds"
spreadsheet <- "https://docs.google.com/spreadsheets/d/1yZv9w9zRKwrGTaR-YzmAqMefw4wMlaXocejdxZaTs6w"

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

#' Clean Names
#' 
#' Clean data.frame names
#' 
#' @keywords internal 
clean_columns <- function(df){
  nms <- names(df)

  nms <- gsub("/", "_", nms) %>% 
    gsub(" ", "_", .) %>% 
    tolower()

  nms[nms == "country"] <- "country_region"
  nms[nms == "date_last_updated"] <- "last_update"

  names(df) <- nms

  to_keep <- c(
    "province_state",
    "country_region",
    "confirmed",
    "deaths",
    "recovered",
    "last_update",
    "page_index"
  )

  dplyr::select(df, dplyr::one_of(!!!to_keep))
}

#' Correct Dates
#' 
#' @param x An object of class date.
#' 
#' @keywords internal
correct_dates <- function(x, y){
  if(is.na(x)){
    x <- as.Date(y, "%m/%d/%y")
    x <- paste(x, "00:00:00")
    x <- as.POSIXct(x)
  }
  
  return(x)
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

geoloc <- function(df){

  search <- dplyr::select(df, country_region, province_state) %>% 
    dplyr::filter(!is.na(province_state)) %>% 
    dplyr::mutate(
      search = dplyr::case_when(
        is.na(country_region) ~ province_state,
        TRUE ~ paste0(country_region, ", ", province_state)
      )
    ) %>% 
    dplyr::distinct_all()

  geolocate(search) %>% 
    dplyr::left_join(search, search, by = "search") %>% 
    dplyr::left_join(df, by = c("country_region", "province_state"))
}

geolocate <- function(search){
  conf <- get_config()

  key <- conf$google_geocode_key

  purrr::map_dfr(search$search, locate, key = key)
}

locate <- function(search, key){
  srch <- gsub(" ", "+", srch)
  url <- paste0(
    "https://maps.googleapis.com/maps/api/geocode/json?address=",
    srch,
    "&key=", key
  )
  json <- tryCatch(httr::GET(url), error = function(e) e)

  while(inherits(json, "error")){
    Sys.sleep(.5)
    json <- tryCatch(httr::GET(url), error = function(e) e)
  }

  cnt <- httr::content(json)

  loc <- data.frame(lat = NA_real_, lng = NA_real_)

  if(length(cnt$results)){
    if(length(cnt$results[[1]]$geometry$location))
      loc <- cnt$results[[1]]$geometry$location
  }

  loc$search <- search

  return(loc)
  
}