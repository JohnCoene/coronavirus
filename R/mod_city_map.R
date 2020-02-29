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
        "&chart=china", 
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
        "&chart=province", 
        "&province=", selected,
        "&variable=", input$variable
      )
    )
  })

  output$map <- echarts4r::renderEcharts4r({
    mod_city_map_china_echarts(df, input$variable)
  })

  output$region <- echarts4r::renderEcharts4r({
    if(is.null(input$map_clicked_data)) {
      selected <- default_province
    } else {
      selected <- input$map_clicked_data$name
      shinyscroll::scroll(ns("cities"), "start")
    }
    mod_city_map_region_echarts(df, input$variable, selected)
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

mod_city_map_china_echarts <- function(df, variable, log = FALSE){
  selected <- input_to_case(variable)

  palette <- input_to_palette(variable)

  subset <- df %>% 
    dplyr::select(province, province_pinyin, variable = selected) %>% 
    dplyr::group_by(province, province_pinyin) %>% 
    dplyr::summarise(cases = sum(variable, ny.rm = TRUE)) %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(cases = as.numeric(cases)) 
    
  x <- dplyr::arrange(subset, cases) %>% dplyr::pull(cases) %>% unique()
  n <- 5

  pieces <- split(x, sort(x%%n)) %>% 
    unname() %>% 
    purrr::map(range) %>% 
    purrr::map(function(x){
      list(
        gt = round_up(x[1]),
        lte = round_up(x[2])
      )
    })

  for(i in 1:(length(pieces) - 1)){
    pieces[[i]]$lte <- pieces[[i + 1]]$gt
  }

  pieces[[1]]$gt <- 0

  subset %>% 
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
      type = "piecewise",
      pieces = pieces,
      outOfRange = list(
        color = "#000"
      ),
      inRange = list(
        color = palette
      ),
      right = "center",
      top = "top",
      orient = "horizontal",
      textStyle = list(color = "#fff")
    ) %>% 
    echarts4r::e_tooltip()
}

mod_city_map_region_echarts <- function(df, variable, selected){

  palette <- input_to_palette(variable)
  selected_variable <- input_to_case(variable)

  subset <- df %>% 
    dplyr::select(cityName, province, province_pinyin, variable = selected_variable) %>% 
    dplyr::filter(province == selected) %>% 
    dplyr::mutate(cityName = substr(cityName, 1, 2)) %>% 
    dplyr::mutate(variable = as.numeric(variable))

  pinyin <- unique(subset$province_pinyin)
  geojson <- url_to_geojson(pinyin) %>% 
    jsonlite::read_json()

  geojson$features <- geojson$features %>% 
    purrr::map(function(x){ 
      x$properties$name <- substr(x$properties$name, 1, 2)
      return(x)
    })

  x <- dplyr::arrange(subset, variable) %>% dplyr::pull(variable) %>% unique()
  n <- 5

  pieces <- split(x, sort(x%%n)) %>% 
    unname() %>% 
    purrr::map(range) %>% 
    purrr::map(function(x){
      list(
        gt = round_up(x[1]),
        lte = round_up(x[2])
      )
    })

  for(i in 1:(length(pieces) - 1)){
    pieces[[i]]$lte <- pieces[[i + 1]]$gt
  }

  pieces[[1]]$gt <- 0

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
      type = "piecewise",
      pieces = pieces,
      textStyle = list(color = "#fff"),
      orient = "horizontal",
      top = "bottom",
      right = "center",
      inRange = list(
        color = palette
      ),
      outOfRange = list(
        color = "#000"
      )
    ) %>% 
    echarts4r::e_title(selected, top = 10, left = 10) %>% 
    echarts4r::e_show_loading(color = "#ffffff", mask_color = '#000')
}