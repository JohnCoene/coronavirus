# Module UI
  
#' @title   mod_table_ui and mod_table_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_table
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_china_ui <- function(id, label){
  ns <- NS(id)

  f7Col(
    f7ExpandableCard(
      title = label,
      id = "china_card",
      subtitle = "Cases by provinces in China",
      uiOutput(ns("table"))
    )
  )
}
    
# Module Server
    
#' @rdname mod_table
#' @export
#' @keywords internal
    
mod_china_server <- function(input, output, session, df){
  ns <- session$ns

  output$table <- renderUI({
    df %>% 
      dplyr::filter(date == max(date)) %>%
      dplyr::filter(country == "Mainland China") %>% 
      dplyr::select(state, type, cases) %>% 
      tidyr::pivot_wider(state, names_from = type, values_from = cases) %>% 
      dplyr::arrange(-confirmed) %>% 
      dplyr::mutate(
        confirmed = as.integer(confirmed),
        recovered = as.integer(recovered),
        death = as.integer(death)
      ) %>% 
      dplyr::select(
        Province = state,
        Confirmed = confirmed, 
        Recovered = recovered,
        Deaths = death
      ) %>% 
      as_f7_table(card = TRUE)
  })
}
