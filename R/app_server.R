#' @import shiny
app_server <- function(input, output,session) {
  data <- golem::get_golem_options("data")

  sever::sever(
    tagList(
      h1("Whoops!"),
      p("It looks like you were disconnected"),
      shiny::tags$button(
        "Reload",
        style = "color:#000;background-color:#fff;",
        class = "button button-raised",
        onClick = "location.reload();"
      )
    ),
    bg_color = "#000"
  )

  echarts4r::e_common(
    font_family = "Quicksand",
    theme = theme
  )

  if(is.null(data)){
    con <- connect()
    df <- DBI::dbReadTable(con, "jhu")
    china_daily <- DBI::dbReadTable(con, "weixin")
    dxy <- DBI::dbReadTable(con, "dxy") 

    if("log" %in% DBI::dbListTables(con)){
      log <- DBI::dbGetQuery(con, "SELECT MAX(last_updated) FROM log;")
      
      diff <- difftime(Sys.time(), log$max) %>% as.integer() 

       f7Toast(
         session,
         text = paste("Last updated", diff, "minutes ago"),
         position = "bottom",
         closeTimeout = 3500,
         closeButton = FALSE
       )

    }

    on.exit({
      disconnect(con)
    })
    
  } else {
    df <- data$jhu
    china_daily <- data$weixin
    dxy <- data$dxy
  }


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

  # dxy
  callModule(
    mod_count_weixin_server, "count_dxy_ui_1", 
    df = dxy, column = "confirmedCount"
  )
  callModule(
    mod_count_weixin_server, "count_dxy_ui_3", 
    df = dxy, column = "deadCount"
  )
  callModule(
    mod_count_weixin_server, "count_dxy_ui_4", 
    df = dxy, column = "curedCount"
  )

  # -------------------- Load tab by tab for more responsiveness

  # track initialised tabs
  dxy_init <- jhu_init <- wx_init <- FALSE

  w <- waiter::Waiter$new(html = loader, color = "#000")

  observeEvent(input$tabs, {
    if(input$tabs == "DXY" && !dxy_init){
      
      w$show()

      dxy_init <- TRUE
      # dxy tab
      callModule(
        mod_count_weixin_server, "count_dxy_ui_1_dxy", 
        df = dxy, column = "confirmedCount"
      )
      callModule(
        mod_count_weixin_server, "count_dxy_ui_3_dxy", 
        df = dxy, column = "deadCount"
      )
      callModule(
        mod_count_weixin_server, "count_dxy_ui_4_dxy", 
        df = dxy, column = "curedCount"
      )
      # maps
      callModule(
        mod_city_map_server, 
        "city_map_1", 
        df = dxy
      )

      # table
      callModule(mod_dxy_table_server, "dxy_table_ui_1", df = dxy)

      w$hide()

      callModule(mod_geo_lines_server, "geo_lines_map")

    } else if(input$tabs == "John Hopkins" && !jhu_init){
      jhu_init <- TRUE

      w$show()

      # jhu tab
      callModule(mod_count_server, "count_ui_1_jhu", df = df, type_filter = "confirmed")
      callModule(mod_count_server, "count_ui_2_jhu", df = df, type_filter = "death")
      callModule(mod_count_server, "count_ui_3_jhu", df = df, type_filter = "recovered")

      # trend
      callModule(mod_trend_server, "trend_ui_1", df = df)

      # maps
      callModule(mod_map_server, "map_ui_1", df = df)
      callModule(mod_world_server, "world_ui_1", df = df)
      callModule(mod_time_provinces_server, "time_provinces_1", df = df)

      # tables
      callModule(mod_china_server, "table_china", df = df)
      callModule(mod_table_world_server, "table_world", df = df)

      w$hide()

    } else if(input$tabs == "Weixin" && !wx_init){
      wx_init <- TRUE

      w$show()

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
      callModule(
        mod_china_trend_server, 
        "china_trend_ui_suspect", 
        df = china_daily, 
        column = "suspect",
        connect = TRUE
      )

      w$hide()
    }
  })

}
