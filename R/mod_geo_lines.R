# Module UI
  
#' @title   mod_geo_lines_ui and mod_geo_lines_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_geo_lines
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_geo_lines_ui <- function(id){
  ns <- NS(id)
  f7Card(
    title = "Travel",
    echarts4r::echarts4rOutput(ns("map")),
    footer = "How much and where to the virus traveled"
  )
}
    
# Module Server
    
#' @rdname mod_geo_lines
#' @export
#' @keywords internal
    
mod_geo_lines_server <- function(input, output, session){
  ns <- session$ns

  output$map <- echarts4r::renderEcharts4r({

  })
}
