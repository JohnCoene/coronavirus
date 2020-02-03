# Module UI
  
#' @title   mod_trend_ui and mod_trend_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_trend
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_trend_ui <- function(id){
  ns <- NS(id)
  tagList(
    f7Card(
      title = "Trend & Prediction",
      echarts4r::echarts4rOutput(ns("trend"))
    )
  )
}
    
# Module Server
    
#' @rdname mod_trend
#' @export
#' @keywords internal
    
mod_trend_server <- function(input, output, session, df = df, type_filter = "confirmed"){
  ns <- session$ns

  output$trend <- echarts4r::renderEcharts4r({
    dat <- df %>% 
      dplyr::filter(type == type_filter) %>% 
      dplyr::group_by(date) %>% 
      dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>% 
      dplyr::mutate(date = as.Date(date)) %>% 
      dplyr::group_by(date) %>% 
      dplyr::filter(date == max(date)) %>% 
      dplyr::filter(cases == max(cases)) %>% 
      dplyr::ungroup() %>% 
      dplyr::arrange(dplyr::desc(date))
    
    x <- rev(1:nrow(dat))
    cases <- dat$cases
    model <- nls(cases ~ (x ^ b), start = c(b = 3), trace = T)

    x <- rev(1:(nrow(dat) + 5))
    pred <- x ^ coef(model)
    dates <- seq.Date(min(dat$date), max(dat$date) + 5, by = "days")

    df <- data.frame(
      date = rev(dates),
      cases = c(rep(NA, 5), cases),
      model = pred
    )

    df %>% 
      echarts4r::e_charts(date) %>% 
      echarts4r::e_line(cases, name = "Confirmed Cases") %>% 
      echarts4r::e_line(model, name = "Model") %>% 
      echarts4r::e_tooltip(trigger = "axis") %>% 
      echarts4r::e_theme(theme)
  })
}
    
## To be copied in the UI
# mod_trend_ui("trend_ui_1")
    
## To be copied in the server
# callModule(mod_trend_server, "trend_ui_1")
 
