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
    echarts4r::echarts4rOutput(ns("trend"), height = 385),
    footer = "Resolved cases (death or recovery) / deaths"
  )
}
    
# Module Server
    
#' @rdname mod_jhu_death_rate
#' @export
#' @keywords internal
    
mod_jhu_death_rate_server <- function(input, output, session, df){
  ns <- session$ns

  output$trend <- echarts4r::renderEcharts4r({

    form <- htmlwidgets::JS("function(value){
      return(value + '%')
    }")

    df %>% 
      dplyr::mutate(date2 = as.Date(date)) %>%
      dplyr::group_by(date2, type) %>% 
      dplyr::filter(date == max(date)) %>% 
      dplyr::filter(country_iso2c == "CN") %>% 
      dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>% 
      dplyr::ungroup() %>%
      tidyr::pivot_wider(
        id_cols = date2,
        names_from = type,
        values_from = cases,
        values_fill = list(
          cases = 0
        )
      ) %>%
      dplyr::mutate(
        rate = deadCount / (deadCount + curedCount), # I'm making the change based on mod_dxy_table.R but I'm not 100% sure of the names of the variables
        rate = round(rate * 100, 3)
      ) %>% 
      echarts4r::e_charts(date2) %>% 
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
      echarts4r::e_theme(theme) %>% 
      echarts4r::e_group("JHU") %>% 
      echarts4r::e_connect_group("JHU")
  })
}
    
## To be copied in the UI
# mod_jhu_death_rate_ui("jhu_death_rate_ui_1")
    
## To be copied in the server
# callModule(mod_jhu_death_rate_server, "jhu_death_rate_ui_1")
 
