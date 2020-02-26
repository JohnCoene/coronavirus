# Module UI
  
#' @title   mod_time_provinces_ui and mod_time_provinces_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_time_provinces
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_time_provinces_ui <- function(id){
  ns <- NS(id)

  f7Card(
    title = "Confirmed Cases - China",
    f7Toggle(ns("log"), "Logarithmic Scale log(1 + x)", checked = TRUE),
    echarts4r::echarts4rOutput(ns("map"), height = "70vh")
  )
}
    
# Module Server
    
#' @rdname mod_time_provinces
#' @export
#' @keywords internal
    
mod_time_provinces_server <- function(input, output, session, df){
  ns <- session$ns

  output$map <- echarts4r::renderEcharts4r({
    mod_time_provinces_echarts(df, input$log)
  })
}

mod_time_provinces_echarts <- function(df, log){
  dat <- df %>% 
    dplyr::filter(country %in% c("Mainland China", "Hong Kong", "Taiwan")) %>% 
    dplyr::left_join(chinese_provinces, by = "state") %>% 
    dplyr::arrange(desc(date)) %>% 
    dplyr::select(chinese, type, date, cases) %>% 
    dplyr::mutate(
      cases = dplyr::case_when(
        log ~ log1p(cases),
        TRUE ~ cases
      )
    )

  index <- length(unique(dat$date)) -1 
  titles <- unique(dat$date) %>% 
    rev() %>% 
    purrr::map(function(x){
      list(text = format(x, "%d %B %H:00"))
    })

  mx <- max(dat$cases)
  mn <- min(dat$cases)

  dat %>% 
    dplyr::group_by(date) %>% 
    echarts4r::e_charts(chinese, timeline = TRUE) %>% 
    echarts4r.maps::em_map("China") %>% 
    echarts4r::e_map(cases, map = "China", name = "confirmed") %>% 
    echarts4r::e_visual_map(
      max = mx,
      min = mn,
      orient = "horizontal",
      right = "center",
      top = 25,
      textStyle = list(color = "#fff")
    ) %>% 
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
}
    
## To be copied in the UI
# mod_time_provinces_ui("time_provinces_1")
    
## To be copied in the server
# callModule(mod_time_provinces_server, "time_provinces_1")
 
