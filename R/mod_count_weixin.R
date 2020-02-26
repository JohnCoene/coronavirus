# Module UI
  
#' @title   mod_count_weixin_ui and mod_count_weixin_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_count_weixin
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_count_weixin_ui <- function(id, label = NULL, source = "Weixin", color = "#fff"){
  ns <- NS(id)
  f7Card(
    h2(
      class = "center",
      span(countup::countupOutput(ns("cnt")), style = paste0("color:", color, ";"), class = "count"),
      br(),
      if(!is.null(label)) tagList(span(label, class = "count-small"), br())
    )
  )
}
    
# Module Server
    
#' @rdname mod_count_weixin
#' @export
#' @keywords internal
    
mod_count_weixin_server <- function(input, output, session, df, column){
  ns <- session$ns

  output$cnt <- countup::renderCountup({
    if("date" %in% names(df)) # weixin
      df %>% 
        dplyr::pull(column) %>% 
        countup::countup()
    else # dxy
      df %>% 
        dplyr::pull(column) %>% 
        sum(na.rm = TRUE) %>% 
        countup::countup()
  })
}
    
## To be copied in the UI
# mod_count_weixin_ui("count_weixin_ui_1")
    
## To be copied in the server
# callModule(mod_count_weixin_server, "count_weixin_ui_1")
 
