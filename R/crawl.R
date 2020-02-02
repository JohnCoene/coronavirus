#' Crawl Data
#' 
#' Crawl John Hopkin's data and store in database. 
#' Every time the function is called the entirety of 
#' the data is pulled and the content of the database 
#' is overwritten. 
#' 
#' @export
crawl_coronavirus <- function(){

  # manage connection pool
  con <- connect()
  on.exit({
    disconnect(con)
  })

  # get data
  cli::cli_alert_info("Crawling data")
  token <- get_token()
  googlesheets::gs_auth(token = token)
  sheets <- googlesheets::gs_url(spreadsheet, verbose = FALSE)
  pages <- googlesheets::gs_ws_ls(sheets)

  msg <- paste("Found", length(pages), "pages of data")
  cli::cli_alert_info(msg)

  # collect and clean
  df <- purrr::map2(pages, 1:length(pages), function(x, y){
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
    sh$page_index <- y
    return(sh)
  }) %>% 
    purrr::map_dfr(clean_columns)

  # run quietly
  correct_quiet <- purrr::quietly(correct_dates)

  # correct dates
  df$last_update <- df$last_update %>% 
    anytime::anytime() %>% 
    purrr::map2(df$last_update, correct_quiet) %>% 
    purrr::map("result") %>% 
    unlist() %>% 
    as.POSIXct(origin = "1970-01-01")

  # save
  cli::cli_alert_success("Writing to database")
  DBI::dbWriteTable(con, "daily", df, overwrite = TRUE, append = FALSE)

  invisible(df)
}
