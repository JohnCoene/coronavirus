# Module UI
  
#' @title   mod_city_map_ui and mod_city_map_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_city_map
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_city_map_ui <- function(id, label){
  ns <- NS(id)
  f7Card(
    title = label,
    echarts4r::echarts4rOutput(ns("map"), height = "70vh"),
    footer = "Points are log scaled, tooltips give real values."
  )
}
    
# Module Server
    
#' @rdname mod_city_map
#' @export
#' @keywords internal
    
mod_city_map_server <- function(input, output, session, df, column, name, connect = FALSE){
  ns <- session$ns

  output$map <- echarts4r::renderEcharts4r({
    range <- range(df[[column]])

    rescaling <- paste0(
      "function(data){ return (Math.log(data[3]) * 3);}"
    )

    e <- df %>% 
      dplyr::select(cityName, lat, lon, value = column) %>%
      dplyr::slice(1:100) %>% 
      echarts4r::e_charts(lon) %>% 
      echarts4r.maps::em_map("China") %>%  
      echarts4r::e_geo(
        "China",
        roam = TRUE,
        itemStyle = list(
          areaColor = "#242323",
          emphasis = list(
            areaColor = "#242323"
          )
        ),
        label = list(
          emphasis = list(
            color = "#ffffff",
            fontSite = 15
          )
        ),
        boundingCoords = list(
          c(106, 37),
          c(118, 22)
        )
      ) %>% 
      echarts4r::e_scatter(
        lat, value, 
        bind = cityName,
        coord_system = "geo",
        name = name,
        scale = NULL,
        scale_js = rescaling
      ) %>% 
      echarts4r::e_visual_map(
        value,
        scale = NULL,
        position = "top",
        orient = "horizontal",
        textStyle = list(color = "#fff")
      ) %>% 
      echarts4r::e_tooltip(
        formatter = htmlwidgets::JS("
          function(params){
            return(params.name + ': ' + params.value[3])
          }
      ")
      ) %>% 
      echarts4r::e_legend(FALSE) %>% 
      echarts4r::e_theme(theme) %>% 
      echarts4r::e_group("dxyMap")

    if(connect)
      e <- echarts4r::e_connect_group(e, "dxyMap")

    return(e)
  })
}
