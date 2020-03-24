# Module UI
  
#' @title   mod_world_ui and mod_world_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_world
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_world_ui <- function(id){
  ns <- NS(id)

  tagList(
    f7Card(
      title = "Confirmed Cases - Worldwide",
      echarts4r::echarts4rOutput(ns("world"), height = "60vh"),
      footer = f7Row(
        f7Col(uiOutput(ns("copy_ui"))),
        f7Col("Select a country to see it displayed below.")
      )
    ),
    f7Card(
      title = uiOutput(ns("selected")),
      echarts4r::echarts4rOutput(ns("plot"), height = 250),
      footer = uiOutput(ns("copy"))
    )
  )
}
    
# Module Server
    
#' @rdname mod_world
#' @export
#' @keywords internal
    
mod_world_server <- function(input, output, session, df){
  ns <- session$ns

  embed_url <- golem::get_golem_options("embed_url")

  output$copy <- renderUI({
    country <- "any"
    if(!is.null(input$world_clicked_data))
      country <- input$world_clicked_data$name
    copy(embed_url, "jhu", paste0("&chart=world-timeline&country=", country))
  })

  output$selected <- renderUI({
    if(is.null(input$world_clicked_data))
      return(span("Cases outside China"))
    else
      return(span("Cases in", input$world_clicked_data$name))
  })

  output$plot <- echarts4r::renderEcharts4r({
    mod_china_others_echarts(df, input$world_clicked_data$name)
  })

  output$copy_ui <- renderUI({
    copy(embed_url, "jhu", "&chart=world-map")
  })

  output$world <- echarts4r::renderEcharts4r({
    mod_world_echarts(df)
  })
}

mod_world_echarts <- function(df){
  df %>% 
    dplyr::filter(date == max(date)) %>%
    echarts4r::e_country_names(country_iso2c, country) %>% 
    dplyr::filter(type == "confirmed") %>% 
    dplyr::group_by(country) %>% 
    dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>% 
    dplyr::ungroup() %>% 
    echarts4r::e_charts(country) %>% 
    echarts4r::e_map(
      cases, 
      roam = TRUE,
      itemStyle = list(
        areaColor = "#242323"
      ),
      label = list(
        emphasis = list(
          color = "#ffffff",
          fontSite = 15
        )
      )
    ) %>% 
    echarts4r::e_visual_map(
      cases, 
      textStyle = list(color = "#fff"),
      orient = "horizontal",
      right = "center"
    ) %>% 
    echarts4r::e_theme(theme)
}

mod_china_others_echarts <- function(df, pattern = NULL){
  ls <- list(
    shadowColor = "rgba(0, 0, 0, 0.8)",
    shadowBlur = 5,
    shadowOffsetY = 3
  )

  if(is.null(pattern) || pattern == "any")
    dat <- dplyr::filter(df, !grepl("China", country))
  else
    dat <- dplyr::filter(df, grepl(pattern, country))

  dat %>% 
    dplyr::filter(type == "confirmed") %>% 
    dplyr::group_by(date) %>% 
    dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>% 
    dplyr::ungroup() %>% 
    echarts4r::e_charts(date, dispose = FALSE) %>% 
    echarts4r::e_line(cases, lineStyle = ls) %>% 
    echarts4r::e_tooltip(
      trigger = "axis",
      axisPointer = list(
        type = "shadow"
      )
    ) %>% 
    echarts4r::e_hide_grid_lines("x") %>% 
    echarts4r::e_legend(FALSE) %>% 
    echarts4r::e_theme(theme)
}

## To be copied in the UI
# mod_world_ui("world_ui_1")
    
## To be copied in the server
# callModule(mod_world_server, "world_ui_1")
 
