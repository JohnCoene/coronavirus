#' @import shiny
app_server <- function(input, output,session) {
  con <- connect()
  df <- DBI::dbReadTable(con, "jhu")
  china_daily <- DBI::dbReadTable(con, "weixin")

  on.exit({
    disconnect(con)
  })

  # counts jhu
  callModule(mod_count_server, "count_ui_1", df = df, type_filter = "confirmed")
  callModule(mod_count_server, "count_ui_2", df = df, type_filter = "death")
  callModule(mod_count_server, "count_ui_3", df = df, type_filter = "recovered")

  # counts weixin
  callModule(
    mod_count_weixin_server, "count_weixin_ui_1", 
    df = china_daily, column = "confirm"
  )
  callModule(
    mod_count_weixin_server, "count_weixin_ui_2", 
    df = china_daily, column = "dead"
  )
  callModule(
    mod_count_weixin_server, "count_weixin_ui_3", 
    df = china_daily, column = "heal"
  )
  callModule(
    mod_count_weixin_server, "count_weixin_ui_4", 
    df = china_daily, column = "suspect"
  )

  # trend
  callModule(mod_trend_server, "trend_ui_1", df = df)

  # maps
  callModule(mod_map_server, "map_ui_1", df = df)
  callModule(mod_world_server, "world_ui_1", df = df)

  # tables
  callModule(mod_china_server, "table_china", df = df)
  callModule(mod_table_world_server, "table_world", df = df)

  waiter::waiter_hide()
}
