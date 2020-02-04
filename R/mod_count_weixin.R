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
mod_count_weixin_ui <- function(id, label = NULL, source = "Weixin"){
  ns <- NS(id)
  f7Card(
    h5(
      class = "center",
      if(!is.null(label)) tagList(label, br()),
      countup::countupOutput(ns("cnt")),
      br(),
      tags$small(source)
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
    df %>% 
      dplyr::filter(date == max(date)) %>%
      dplyr::pull(column) %>% 
      sum(na.rm = TRUE) %>% 
      countup::countup()
  })
}
    
## To be copied in the UI
# mod_count_weixin_ui("count_weixin_ui_1")
    
## To be copied in the server
# callModule(mod_count_weixin_server, "count_weixin_ui_1")
 
