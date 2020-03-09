# Module UI
  
#' @title   mod_new_cases_ui and mod_new_cases_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_new_cases
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_new_cases_ui <- function(id){
  ns <- NS(id)

  f7Card(
    title = "Daily new cases",
    f7Toggle(ns("cm"), "Cumulative"),
    echarts4r::echarts4rOutput(ns("plot"), height = 250),
    footer = uiOutput(ns("copy"))
  )
}
    
# Module Server
    
#' @rdname mod_new_cases
#' @export
#' @keywords internal
    
mod_new_cases_server <- function(input, output, session, df){
  ns <- session$ns

  embed_url <- golem::get_golem_options("embed_url")

  output$copy <- renderUI({
    copy(embed_url, "jhu", paste0("&chart=cases-added&cumulative=", tolower(input$cm)))
  })

  output$plot <- echarts4r::renderEcharts4r({
    mode_new_cases_echarts(df, input$cm)
  })
}

mode_new_cases_echarts <- function(df, cumul = FALSE){
  df %>% 
    dplyr::group_by(date, type) %>%
    dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>%  
    dplyr::group_by(type) %>% 
    dplyr::arrange(date) %>% 
    dplyr::mutate(
      cases_lag = dplyr::lag(cases),
      diff = cases - cases_lag
    ) %>% 
    dplyr::group_by(type) %>% 
    dplyr::mutate(
      diff = dplyr::case_when(
        is.na(diff) ~ 0,
        TRUE ~ diff
      ),
      diff = dplyr::case_when(
        cumul ~ cumsum(diff),
        TRUE ~ diff
      )
    ) %>% 
    echarts4r::e_charts(date, dispose = FALSE) %>% 
    echarts4r::e_bar(diff) %>% 
    echarts4r::e_color(
      c(confirmed_pal[3], deaths_pal[4], recovered_pal[4])
    ) %>% 
    echarts4r::e_tooltip(
      trigger = "axis",
      axisPointer = list(
        type = "shadow"
      )
    ) %>% 
    echarts4r::e_legend(
      selectedMode = "single",
      selected = list(
        "confirmed" = TRUE
      )
    ) %>% 
    echarts4r::e_hide_grid_lines("x") %>% 
    echarts4r::e_group("JHU") %>%
    echarts4r::e_theme(theme)
}
