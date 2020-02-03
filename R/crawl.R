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
  
  # read data
  confirmed <- googlesheets4::sheets_read(spreadsheet, sheet = "Confirmed")
  recovered <- googlesheets4::sheets_read(spreadsheet, sheet = "Recovered")
  deaths <- googlesheets4::sheets_read(spreadsheet, sheet = "Death")

  # add col
  confirmed$type <- "confirmed"
  recovered$type <- "recovered"
  deaths$type <- "death"

  # rename
  confirmed <- rename_sheets(confirmed)
  recovered <- rename_sheets(recovered)
  deaths <- rename_sheets(deaths)

  confirmed <- pivot(confirmed)
  recovered <- pivot(recovered)
  deaths <- pivot(deaths)

  df <- dplyr::bind_rows(confirmed, recovered, deaths) %>% 
    dplyr::mutate(date = anytime::anytime(date))

  # save
  cli::cli_alert_success("Writing to database")
  DBI::dbWriteTable(con, "data", df, overwrite = TRUE, append = FALSE)

  invisible(df)
}

