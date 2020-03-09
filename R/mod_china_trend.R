# Module UI
  
#' @title   mod_chiny_trend_ui and mod_chiny_trend_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_chiny_trend
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_china_trend_ui <- function(id, label){
  ns <- NS(id)
  f7Card(
    title = label,
    f7Toggle(ns("log"), "Logarithmic Scale log(1 + x)"),
    echarts4r::echarts4rOutput(ns("trend")),
    footer = uiOutput(ns("copy_ui"))
  )
}
    
# Module Server
    
#' @rdname mod_chiny_trend
#' @export
#' @keywords internal
    
mod_china_trend_server <- function(input, output, session, df, column = "confirm", connect = FALSE){
  ns <- session$ns

  embed_url <- golem::get_golem_options("embed_url")

  output$copy_ui <- renderUI({
    copy(embed_url, "weixin", paste0("&chart=trend&type=", column, "&log=", tolower(input$log)))
  })

  output$trend <- echarts4r::renderEcharts4r({
    mod_china_trend_echarts(df, column = column, connect = connect, log = input$log)
  })
}
    
column_to_palette <- function(x){
  switch(
    x,
    "confirm" = confirmed_pal,
    "dead" = deaths_pal,
    "heal" = recovered_pal,
    "suspect" = suspected_pal
  )
}

mod_china_trend_echarts <- function(df, column = "confirm", connect = FALSE, log = FALSE){

  palette <- column_to_palette(column)

  if(log)
    df[[column]] <- log1p(df[[column]])

  e <- df %>% 
    echarts4r::e_charts(date, dispose = FALSE) %>% 
    echarts4r::e_area_(column) %>% 
    echarts4r::e_visual_map_(
      column, 
      show = FALSE,
      inRange = list(
        color = palette
      )
    ) %>% 
    echarts4r::e_theme(theme) %>% 
    echarts4r::e_legend(FALSE) %>% 
    echarts4r::e_tooltip(trigger = "axis") %>% 
    echarts4r::e_group("weixinTrend") %>% 
    echarts4r::e_hide_grid_lines("x")

  if(connect)
    e <- echarts4r::e_connect_group(e, "weixinTrend")

  return(e)
}
