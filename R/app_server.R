#' @import shiny
app_server <- function(input, output,session) {
  con <- connect()
  df <- DBI::dbReadTable(con, "data")

  on.exit({
    disconnect(con)
  })

  callModule(mod_count_server, "count_ui_1", df = df, type_filter = "confirmed")
  callModule(mod_count_server, "count_ui_2", df = df, type_filter = "death")
  callModule(mod_count_server, "count_ui_3", df = df, type_filter = "recovered")

  callModule(mod_trend_server, "trend_ui_1", df = df)

  waiter::waiter_hide()
}
