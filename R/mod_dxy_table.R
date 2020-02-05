# Module UI
  
#' @title   mod_dxy_table_ui and mod_dxy_table_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_dxy_table
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_dxy_table_ui <- function(id){
  ns <- NS(id)
  f7ExpandableCard(
    title = "Cities",
    id = "china_card",
    subtitle = "Cases by city in China",
    uiOutput(ns("table"))
  )
}
    
# Module Server
    
#' @rdname mod_dxy_table
#' @export
#' @keywords internal
    
mod_dxy_table_server <- function(input, output, session, df){
  ns <- session$ns

  output$table <- renderUI({
    df %>% 
      dplyr::arrange(-confirmedCount) %>%  
      dplyr::select(
        City = cityName,
        Confirmed = confirmedCount,
        Recovered = curedCount,
        Deaths = deadCount
      ) %>% 
      as_f7_table(card = TRUE)
  })
}
    
## To be copied in the UI
# mod_dxy_table_ui("dxy_table_ui_1")
    
## To be copied in the server
# callModule(mod_dxy_table_server, "dxy_table_ui_1")
 
