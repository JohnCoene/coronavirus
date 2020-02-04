# Module UI
  
#' @title   mod_table_world_ui and mod_table_world_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_table_world
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_table_world_ui <- function(id, label){
  ns <- NS(id)

  f7Col(
    f7ExpandableCard(
      title = label,
      id = "world_card",
      subtitle = "Cases by country",
      uiOutput(ns("table"))
    )
  )
}
    
# Module Server
    
#' @rdname mod_table_world
#' @export
#' @keywords internal
    
mod_table_world_server <- function(input, output, session, df){
  ns <- session$ns

  output$table <- renderUI({
    df %>% 
      dplyr::filter(date == max(date)) %>%
      dplyr::filter(country != "Mainland China") %>% 
      dplyr::select(country, type, cases) %>% 
      dplyr::group_by(country, type) %>% 
      dplyr::summarise(cases = sum(cases)) %>% 
      dplyr::ungroup() %>% 
      tidyr::pivot_wider(country, names_from = type, values_from = cases) %>% 
      dplyr::arrange(-confirmed) %>% 
      dplyr::mutate(
        confirmed = as.integer(confirmed),
        recovered = as.integer(recovered),
        death = as.integer(death)
      ) %>% 
      dplyr::select(
        Country = country,
        Confirmed = confirmed, 
        Recovered = recovered,
        Deaths = death
      ) %>% 
      as_f7_table(card = TRUE)
  })
}
    
## To be copied in the UI
# mod_table_world_ui("table_world_ui_1")
    
## To be copied in the server
# callModule(mod_table_world_server, "table_world_ui_1")
 
