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
    f7Toggle(ns("log"), "Logarithmic Scale log(1 + x)"),
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
      dplyr::left_join(chinese_provinces, by = "state") %>% 
      dplyr::arrange(desc(date)) %>% 
      dplyr::select(state, type, date, cases) %>% 
      dplyr::mutate(
        cases = dplyr::case_when(
          input$log ~ log1p(cases),
          TRUE ~ cases
        )
      )

    index <- length(unique(dat$date)) -1 
    titles <- unique(dat$date) %>% 
      rev() %>% 
      purrr::map(function(x){
        list(text = format(x, "%d %B %H:00"))
      })

    dat %>% 
      tidyr::pivot_wider(
        c(state, date),
        names_from = type,
        values_from = cases
      ) %>% 
      dplyr::arrange(desc(date), desc(confirmed)) %>% 
      dplyr::group_by(date) %>% 
      echarts4r::e_charts(state, timeline = TRUE) %>% 
      echarts4r::e_bar(confirmed, name = "Confirmed") %>% 
      echarts4r::e_bar(recovered, name = "Recovered") %>% 
      echarts4r::e_bar(death, name = "Deaths") %>%  
      echarts4r::e_legend(
        orient = "vertical",
        right = 25,
        top = 50
      ) %>% 
      echarts4r::e_tooltip(
        trigger = "axis",
        axisPointer = list(
          type = "shadow"
        )
      ) %>% 
      echarts4r::e_timeline_serie(
        title = titles
      ) %>% 
      echarts4r::e_timeline_opts(
        currentIndex = index,
        playInterval = 600, 
        symbolSize = 4, 
        axis_type = "time",
        label = list(
          show = FALSE
        ),
        checkpointStyle = list(
          symbol = "diamond",
          symbolSize = 20
        )
      )
      
  #   dat %>% 
  #     dplyr::group_by(date) %>% 
  #     echarts4r::e_charts(chinese, timeline = TRUE) %>% 
  #     echarts4r.maps::em_map("China") %>% 
  #     echarts4r::e_map(cases, map = "China", name = "confirmed") %>% 
  #     echarts4r::e_visual_map(
  #       cases, 
  #       show = FALSE, 
  #       min = 0,
  #       orient = "horizontal",
  #       right = "center"
  #     ) %>% 
  #     echarts4r::e_theme(theme) %>% 
  #     echarts4r::e_tooltip() %>% 
  #     echarts4r::e_timeline_opts(currentIndex = index) %>% 
  #     echarts4r::e_timeline_serie(
  #       title = titles
  #     ) %>% 
  #     echarts4r::e_timeline_opts(
  #       playInterval = 600, 
  #       symbolSize = 4, 
  #       axis_type = "time",
  #       label = list(
  #         show = FALSE
  #       ),
  #       checkpointStyle = list(
  #         symbol = "pin",
  #         symbolSize = 20
  #       )
  #     )
  })
}
