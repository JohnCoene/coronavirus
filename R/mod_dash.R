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
    fluidRow(
      column(
        2,
        h1(
          tags$small("confirmed"), br(),
          countup::countupOutput(ns("total_confirmed"))
        )
      ),
      column(
        6
      ),
      column(
        3
      )
    )
  )
}
    
# Module Server
    
#' @rdname mod_dash
#' @export
#' @keywords internal
mod_dash_server <- function(input, output, session){
  ns <- session$ns

  con <- connect()
  df <- DBI::dbReadTable(con, "daily")

  on.exit({
    disconnect(con)
  })

  output$total_confirmed <- countup::renderCountup({
    waiter::waiter_hide()
    
    df %>% 
      dplyr::group_by(province_state) %>% 
      dplyr::filter(last_update == max(last_update)) %>%
      dplyr::ungroup() %>%  
      dplyr::pull(confirmed) %>% 
      sum(na.rm = TRUE) %>% 
      countup::countup()
  })
}