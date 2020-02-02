# Module UI
  
#' @title   mod_dash_ui and mod_dash_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_dash
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_dash_ui <- function(id){
  ns <- NS(id)

  tagList(
    
  )
}
    
# Module Server
    
#' @rdname mod_dash
#' @export
#' @keywords internal
    
mod_dash_server <- function(input, output, session){
  ns <- session$ns
}
    
## To be copied in the UI
# mod_dash_ui("dash_ui_1")
    
## To be copied in the server
# callModule(mod_dash_server, "dash_ui_1")
 
