# Module UI
  
#' @title   mod_china_others_ui and mod_china_others_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_china_others
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_china_others_ui <- function(id){
  ns <- NS(id)

  f7Card(
    title = "Cases outside China",
    echarts4r::echarts4rOutput(ns("plot"), height = 250),
    footer = uiOutput(ns("copy"))
  )
}
    
# Module Server
    
#' @rdname mod_china_others
#' @export
#' @keywords internal
    
mod_china_others_server <- function(input, output, session, df){
  ns <- session$ns

  embed_url <- golem::get_golem_options("embed_url")

  output$copy <- renderUI({
    copy(embed_url, "jhu", "&chart=world-timeline")
  })

  output$plot <- echarts4r::renderEcharts4r({
    mod_china_others_echarts(df)
  })
}


mod_china_others_echarts <- function(df){
  ls <- list(
    shadowColor = "rgba(0, 0, 0, 0.8)",
    shadowBlur = 5,
    shadowOffsetY = 3
  )

  df %>% 
    dplyr::filter(country != "Mainland China") %>% 
    dplyr::filter(type == "confirmed") %>% 
    dplyr::group_by(date) %>% 
    dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>% 
    dplyr::ungroup() %>% 
    echarts4r::e_charts(date) %>% 
    echarts4r::e_line(cases, lineStyle = ls) %>% 
    echarts4r::e_tooltip(
      trigger = "axis",
      axisPointer = list(
        type = "shadow"
      )
    ) %>% 
    echarts4r::e_hide_grid_lines("x") %>% 
    echarts4r::e_legend(FALSE) %>% 
    echarts4r::e_theme(theme)
}

    
## To be copied in the UI
# mod_china_others_ui("china_others")
    
## To be copied in the server
# callModule(mod_china_others_server, "china_others")
 
