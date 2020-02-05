# Module UI
  
#' @title   mod_map_ui and mod_map_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_map
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_map_ui <- function(id){
  ns <- NS(id)

  f7Card(
    title = "Confirmed Cases - China",
    echarts4r::echarts4rOutput(ns("map"), height = "70vh")
  )
}
    
# Module Server
    
#' @rdname mod_map
#' @export
#' @keywords internal
    
mod_map_server <- function(input, output, session, df){
  ns <- session$ns

  output$map <- echarts4r::renderEcharts4r({
    
    dat <- df %>% 
      dplyr::filter(country %in% c("Mainland China", "Hong Kong", "Taiwan")) %>% 
      dplyr::filter(type == "confirmed") %>% 
      dplyr::left_join(chinese_provinces, by = "state") %>% 
      dplyr::arrange(desc(date))

    index <- length(unique(dat$date)) -1 
    titles <- unique(dat$date) %>% 
      rev() %>% 
      purrr::map(function(x){
        list(text = format(x, "%d %B %H:00"))
      })
      
    dat %>% 
      dplyr::group_by(date) %>% 
      echarts4r::e_charts(chinese, timeline = TRUE) %>% 
      echarts4r.maps::em_map("China") %>% 
      echarts4r::e_map(cases, map = "China", name = "confirmed") %>% 
      echarts4r::e_visual_map(cases, min = 0, textStyle = list(color = "#fff")) %>% 
      echarts4r::e_theme(theme) %>% 
      echarts4r::e_tooltip() %>% 
      echarts4r::e_timeline_opts(currentIndex = index) %>% 
      echarts4r::e_timeline_serie(
        title = titles
      ) %>% 
      echarts4r::e_timeline_opts(
        playInterval = 600, 
        symbolSize = 4, 
        axis_type = "time",
        label = list(
          show = FALSE
        ),
        checkpointStyle = list(
          symbol = "pin",
          symbolSize = 20
        )
      )
  })
}
