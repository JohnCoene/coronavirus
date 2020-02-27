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
    f7Toggle(ns("log"), "Logarithmic Scale"),
    f7Card(
      title = "Provinces",
      echarts4r::echarts4rOutput(ns("map"), height = "50vh"),
      footer = f7Row(
        f7Col(uiOutput(ns("copy_region"))),
        f7Col("Select a province to see its cities displayed below")
      )
    ),
    f7Card(
      title = "Cities",
      id = ns("cities"),
      echarts4r::echarts4rOutput(ns("region"), height = "50vh"),
      footer = uiOutput(ns("copy_city"))
    )
  )
}
    
# Module Server
    
#' @rdname mod_city_map
#' @export
#' @keywords internal
    
mod_city_map_server <- function(input, output, session, df){
  ns <- session$ns

  embed_url <- golem::get_golem_options("embed_url")

  output$copy_region <- renderUI({
    copy(
      embed_url, 
      "dxy", 
      paste0(
        "&chart=china&log=", tolower(input$log), 
        "&variable=", input$variable
      )
    )
  })

  output$copy_city <- renderUI({
    if(is.null(input$map_clicked_data)) {
      selected <- default_province
    } else {
      selected <- input$map_clicked_data$name
    }

    copy(
      embed_url, 
      "dxy", 
      paste0(
        "&chart=province&log=", tolower(input$log), 
        "&province=", selected,
        "&variable=", input$variable
      )
    )
  })

  output$map <- echarts4r::renderEcharts4r({
    mod_city_map_china_echarts(df, input$variable, input$log)
  })

  output$region <- echarts4r::renderEcharts4r({
    if(is.null(input$map_clicked_data)) {
      selected <- default_province
    } else {
      selected <- input$map_clicked_data$name
      shinyscroll::scroll(ns("cities"), "start")
    }
    mod_city_map_region_echarts(df, input$variable, selected, input$log)
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

mod_city_map_china_echarts <- function(df, variable, log){
  selected <- input_to_case(variable)

  palette <- input_to_palette(variable)

  formatter <- NULL
  if(!log)
    formatter <- htmlwidgets::JS(
        "function(min, max){
          return(Math.floor(min / 100) * 100 + ' - ' + Math.floor(max / 100) * 100)
        }")

  df %>% 
    dplyr::select(province, province_pinyin, variable = selected) %>% 
    dplyr::group_by(province, province_pinyin) %>% 
    dplyr::summarise(cases = sum(variable, ny.rm = TRUE)) %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(
      cases = as.numeric(cases),
      cases = dplyr::case_when(
        log ~ log1p(cases),
        TRUE ~ cases
      )
    ) %>% 
    echarts4r::e_chart(province) %>% 
    echarts4r.maps::em_map("China") %>% 
    echarts4r::e_map(
      cases, 
      map = "China",
      name = selected,
      itemStyle = list(
        areaColor = "#eee",
        emphasis = list(
          areaColor = "#ffa352"
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
      precision = 1,
      type = "piecewise",
      formatter = formatter,
      right = "center",
      top = "top",
      orient = "horizontal",
      textStyle = list(color = "#fff"),
      inRange = list(
        color = palette
      )
    )
}

mod_city_map_region_echarts <- function(df, variable, selected, log){

  palette <- input_to_palette(variable)
  selected_variable <- input_to_case(variable)

  subset <- df %>% 
    dplyr::select(cityName, province, province_pinyin, variable = selected_variable) %>% 
    dplyr::filter(province == selected) %>% 
    dplyr::mutate(cityName = substr(cityName, 1, 2)) %>% 
    dplyr::mutate(
      variable = as.numeric(variable),
      variable = dplyr::case_when(
        log ~ log1p(variable),
        TRUE ~ variable
      )
    )

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
          areaColor = "#ffa352"
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
    echarts4r::e_title(selected, top = 10, left = 10) %>% 
    echarts4r::e_show_loading(color = "#ffffff", mask_color = '#000')
}