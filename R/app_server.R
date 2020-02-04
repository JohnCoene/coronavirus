#' @import shiny
app_server <- function(input, output,session) {
  con <- connect()

  data <- golem::get_golem_options("data")

  if(is.null(data)){
    df <- DBI::dbReadTable(con, "jhu")
    china_daily <- DBI::dbReadTable(con, "weixin")
    on.exit({
      disconnect(con)
    })
  } else {
    df <- data$jhu
    china_daily <- data$weixin
  }

  # counts jhu
  callModule(mod_count_server, "count_ui_1", df = df, type_filter = "confirmed")
  callModule(mod_count_server, "count_ui_2", df = df, type_filter = "death")
  callModule(mod_count_server, "count_ui_3", df = df, type_filter = "recovered")
  # jhu tab
  callModule(mod_count_server, "count_ui_1_jhu", df = df, type_filter = "confirmed")
  callModule(mod_count_server, "count_ui_2_jhu", df = df, type_filter = "death")
  callModule(mod_count_server, "count_ui_3_jhu", df = df, type_filter = "recovered")

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
  # weixin tab
  callModule(
    mod_count_weixin_server, "count_weixin_ui_1_wx", 
    df = china_daily, column = "confirm"
  )
  callModule(
    mod_count_weixin_server, "count_weixin_ui_2_wx", 
    df = china_daily, column = "dead"
  )
  callModule(
    mod_count_weixin_server, "count_weixin_ui_3_wx", 
    df = china_daily, column = "heal"
  )
  callModule(
    mod_count_weixin_server, "count_weixin_ui_4_wx", 
    df = china_daily, column = "suspect"
  )

  # weixin tab chart
  callModule(mod_china_trend_server, "china_trend_ui_confirm", df = china_daily, column = "confirm")
  callModule(mod_china_trend_server, "china_trend_ui_heal", df = china_daily, column = "heal")
  callModule(mod_china_trend_server, "china_trend_ui_dead", df = china_daily, column = "dead")
  callModule(mod_china_trend_server, "china_trend_ui_suspect", df = china_daily, column = "suspect")

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
