# Module UI
  
#' @title   mod_jhu_death_rate_ui and mod_jhu_death_rate_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_jhu_death_rate
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_jhu_death_rate_ui <- function(id){
  ns <- NS(id)
  f7Card(
    id = ns("card"),
    title = "Death Rate",
    echarts4r::echarts4rOutput(ns("trend"), height = 395),
    footer = f7Row(
      f7Col(uiOutput(ns("copy_ui"))),
      f7Col("deaths / (confirmed + recovered)")
    )
  )
}
    
# Module Server
    
#' @rdname mod_jhu_death_rate
#' @export
#' @keywords internal
    
mod_jhu_death_rate_server <- function(input, output, session, df){
  ns <- session$ns

  embed_url <- golem::get_golem_options("embed_url")

  output$copy_ui <- renderUI({
    copy(embed_url, "jhu", "&chart=death-rate")
  })

  output$trend <- echarts4r::renderEcharts4r({
    mod_jhu_death_rate_echarts(df)
  })
}

mod_jhu_death_rate_echarts <- function(df){
  form <- htmlwidgets::JS("function(value){
    return(value + '%')
  }")

  df %>% 
    dplyr::filter(country_iso2c == "CN") %>% 
    dplyr::group_by(date, type) %>% 
    dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>% 
    dplyr::ungroup() %>%
    tidyr::pivot_wider(
      id_cols = date,
      names_from = type,
      values_from = cases,
      values_fill = list(
        cases = 0
      )
    ) %>%
    dplyr::mutate(
      rate = death / (confirmed + recovered),
      rate = round(rate * 100, 3)
    ) %>% 
    echarts4r::e_charts(date) %>% 
    echarts4r::e_area(rate, name = "Death rate") %>% 
    echarts4r::e_tooltip(trigger = "axis") %>% 
    echarts4r::e_legend(FALSE) %>% 
    echarts4r::e_y_axis(formatter = form) %>% 
    echarts4r::e_visual_map(
      rate,
      show = FALSE,
      inRange = list(
        color = deaths_pal
      )
    ) %>% 
    echarts4r::e_mark_point(
      data = list(type = "max"), 
      itemStyle = list(color = "white"),
      label = list(color = "#000"),
      title = "Max"
    ) %>% 
    echarts4r::e_mark_line(
      data = list(type = "average"),
      itemStyle = list(color = "white"),
      title = "Average"
    ) %>% 
    echarts4r::e_hide_grid_lines() %>% 
    echarts4r::e_theme(theme) %>% 
    echarts4r::e_group("JHU") %>% 
    echarts4r::e_connect_group("JHU")
}
    
## To be copied in the UI
# mod_jhu_death_rate_ui("jhu_death_rate_ui_1")
    
## To be copied in the server
# callModule(mod_jhu_death_rate_server, "jhu_death_rate_ui_1")
 
