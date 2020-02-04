# Module UI
  
#' @title   mod_count_ui and mod_count_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_count
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_count_ui <- function(id, label, source = "John Hopkins", color = "#fff"){
  ns <- NS(id)
  f7Card(
    h2(
      class = "center",
      span(countup::countupOutput(ns("cnt")), style = paste0("color:", color, ";"), class = "count"),
      br(),
      span(label, class = "count-small")
    )
  )
}
    
# Module Server
    
#' @rdname mod_count
#' @export
#' @keywords internal
    
mod_count_server <- function(input, output, session, df = data.frame(), type_filter = "confirmed"){
  ns <- session$ns

  output$cnt <- countup::renderCountup({
    df %>% 
      dplyr::filter(date == max(date)) %>%
      dplyr::filter(type == type_filter) %>% 
      dplyr::pull(cases) %>% 
      sum(na.rm = TRUE) %>% 
      countup::countup()
  })
}

## To be copied in the UI
# mod_count_ui("count_ui_1")
    
## To be copied in the server
# callModule(mod_count_server, "count_ui_1")
 
