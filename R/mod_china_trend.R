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
    echarts4r::echarts4rOutput(ns("trend"))
  )
}
    
# Module Server
    
#' @rdname mod_chiny_trend
#' @export
#' @keywords internal
    
mod_china_trend_server <- function(input, output, session, df, column = "confirm", connect = FALSE){
  ns <- session$ns

  output$trend <- echarts4r::renderEcharts4r({
    e <- df %>% 
      echarts4r::e_charts(date) %>% 
      echarts4r::e_area_(column) %>% 
      echarts4r::e_visual_map_(column, show = FALSE) %>% 
      echarts4r::e_theme(theme) %>% 
      echarts4r::e_legend(FALSE) %>% 
      echarts4r::e_tooltip(trigger = "axis") %>% 
      echarts4r::e_group("weixinTrend")

    if(connect)
      e <- echarts4r::e_connect_group(e, "weixinTrend")

    return(e)
  })
}
    
## To be copied in the UI
# mod_chiny_trend_ui("china_trend_ui_1")
    
## To be copied in the server
# callModule(mod_china_trend_server, "china_trend_ui_1")
 
