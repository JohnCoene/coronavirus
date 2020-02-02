#' Crawl Data
#' 
#' Crawl John Hopkin's data and store in database. 
#' Every time the function is called the entirety of 
#' the data is pulled and the content of the database 
#' is overwritten. 
#' 
#' @export
crawl_coronavirus <- function(){
  config <- get_config()

  has_vars <- all(c("user", "password", "host") %in% names(config$database))

  if(!has_vars)
    stop("Missing variables in config file, see `create_config`", call. = FALSE)

  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    host = config$database$host,
    user = config$database$user,
    password = config$database$password,
    dbname = config$database$name,
    port = 5432
  )

  # get data
  cli::cli_alert_info("Crawling data")
  token <- get_token()
  googlesheets::gs_auth(token = token)
  sheets <- googlesheets::gs_url(spreadsheet, verbose = FALSE)
  pages <- googlesheets::gs_ws_ls(sheets)

  msg <- paste("Found", length(pages), "pages of data")
  cli::cli_alert_info(msg)

  df <- purrr::map(pages, function(x){
    Sys.sleep(5)
    sh <- tryCatch(
      googlesheets::gs_read(sheets, x, col_types = readr::cols(), verbose = FALSE),
      error = function(e) e
    )

    while(inherits(sh, "error")){
      Sys.sleep(5)
      sh <- tryCatch(
        googlesheets::gs_read(sheets, x, col_types = readr::cols(), verbose = FALSE),
        error = function(e) e
      )
    }
    return(sh)
  }) %>% 
    purrr::map_dfr(clean_columns)

  correct_quiet <- purrr::quietly(correct_dates)

  # correct dates
  df$last_update <- df$last_update %>% 
    anytime::anytime() %>% 
    purrr::map2(df$last_update, correct_quiet) %>% 
    purrr::map("result") %>% 
    unlist() %>% 
    as.POSIXct(origin = "1970-01-01")

  cli::cli_alert_success("Writing to database")

  DBI::dbWriteTable(con, "daily", df, overwrite = TRUE, append = FALSE)

  DBI::dbDisconnect(con)
  invisible(df)
}
