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
mod_city_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    f7Radio(
      ns("variable"),
      label = "Cases to plot",
      choices = c("Confirmed", "Deaths", "Recovered"),
      selected = "Confirmed"
    ),
    f7Card(
      title = "Provinces",
      echarts4r::echarts4rOutput(ns("map"), height = "50vh"),
      footer = "Select a province to see its counties displayed below"
    ),
    f7Card(
      title = "Counties",
      echarts4r::echarts4rOutput(ns("region"), height = "50vh"),
    )
  )
}
    
# Module Server
    
#' @rdname mod_city_map
#' @export
#' @keywords internal
    
mod_city_map_server <- function(input, output, session, df){
  ns <- session$ns

  output$map <- echarts4r::renderEcharts4r({
    selected <- input_to_case(input$variable)

    palette <- input_to_palette(input$variable)

    df %>% 
      dplyr::select(province, province_pinyin, variable = selected) %>% 
      dplyr::group_by(province, province_pinyin) %>% 
      dplyr::summarise(cases = sum(variable, ny.rm = TRUE)) %>% 
      dplyr::ungroup() %>% 
      echarts4r::e_chart(province) %>% 
      echarts4r.maps::em_map("China") %>% 
      echarts4r::e_map(
        cases, 
        map = "China",
        name = selected,
        itemStyle = list(
          areaColor = "#eee",
          emphasis = list(
            areaColor = "#2196f3"
          )
        ),
        label = list(
          emphasis = list(
            color = "#000",
            fontSite = 18
          )
        )
      ) %>% 
      echarts4r::e_visual_map(
        cases, 
        type = "piecewise",
        formatter = htmlwidgets::JS(
          "function(min, max){
            return(Math.floor(min / 100) * 100 + ' - ' + Math.floor(max / 100) * 100)
          }"
        ),
        right = "center",
        top = "top",
        orient = "horizontal",
        textStyle = list(color = "#fff"),
        inRange = list(
          color = palette
        )
      )
  })

  output$region <- echarts4r::renderEcharts4r({
    req(input$map_clicked_data)

    palette <- input_to_palette(input$variable)
    selected_variable <- input_to_case(input$variable)
    selected <- input$map_clicked_data$name

    subset <- df %>% 
      dplyr::select(cityName, province, province_pinyin, variable = selected_variable) %>% 
      dplyr::filter(province == selected) %>% 
      dplyr::mutate(cityName = substr(cityName, 1, 2))

    pinyin <- unique(subset$province_pinyin)
    geojson <- url_to_geojson(pinyin) %>% 
      jsonlite::read_json()

    geojson$features <- geojson$features %>% 
      purrr::map(function(x){ 
        x$properties$name <- substr(x$properties$name, 1, 2)
        return(x)
      })

    echarts4r::e_charts(subset, cityName) %>% 
      echarts4r::e_map_register(pinyin, geojson) %>% 
      echarts4r::e_map(
        variable, 
        name = selected_variable,
        map = pinyin,
        itemStyle = list(
          areaColor = "#eee",
          emphasis = list(
            areaColor = "#2196f3"
          )
        ),
        label = list(
          emphasis = list(
            color = "#000",
            fontSite = 18
          )
        )
      ) %>% 
      echarts4r::e_visual_map(
        variable, 
        textStyle = list(color = "#fff"),
        inRange = list(
          color = palette
        ),
        orient = "horizontal",
        top = "bottom",
        right = "center"
      ) %>% 
      echarts4r::e_show_loading(color = "#ffffff")

  })
}

#' County Geojson
#' 
#' Get url to a county's geojson.
#' 
#' @param province Province pinyin.
#' 
#' @keywords internal
url_to_geojson <- function(province){
  province <- tolower(province)
  province <- ifelse(province == "tibet", "xizang", province)
  province <- ifelse(province == "inner mongolia", "neimenggu", province)
  province <- ifelse(province == "shaanxi", "shanxi1", province)
  paste0("https://raw.githubusercontent.com/apache/incubator-echarts/master/map/json/province/", province, ".json")
}

#' Input to Case Conversion
#' 
#' Converts case name input to dxy column name
#' 
#' @param x input value.
#' 
#' @name interface
#' @keywords internal
input_to_case <- function(x){
  switch(
    x,
    "Confirmed" = "confirmedCount",
    "Deaths" = "deadCount",
    "Recovered" = "curedCount"
  )
}

#' @rdname interface
#' @keywords internal
input_to_palette <- function(x){
  switch(
    x,
    "Confirmed" = confirmed_pal,
    "Deaths" = deaths_pal,
    "Recovered" = recovered_pal
  )
}