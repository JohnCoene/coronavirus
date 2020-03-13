embeds_server <- function(input, output, session){

  echarts4r::e_common(
    font_family = "Quicksand",
    theme = theme
  )

  sever::cleave("Sorry, I've encountered an error", bg_color = "#000", color = "#298614")

  sever::sever(
    tagList(
      h1("Whoops!"),
      p("It looks like you were disconnected"),
      shiny::tags$button(
        "Reload",
        style = "color:#000;background-color:#fff;",
        class = "button button-raised",
        onClick = "location.reload();"
      )
    ),
    bg_color = "#000"
  )

  rv <- reactiveValues(
    data = "", 
    chart = "", 
    log = "", 
    col = "", 
    variable = "",
    province = ""
  )

  observe({
    # parse parameter
    query <- parseQueryString(session$clientData$url_search)
    rv$data <- get_query(query, "data")
    rv$chart <- get_query(query, "chart")
    rv$type <- get_query(query, "type")
    rv$log <- get_query(query, "log")
    rv$variable <- get_query(query, "variable")
    rv$province <- get_query(query, "province")
    rv$cumulative <- get_query(query, "cumulative")
    rv$country <- get_query(query, "country")
  })

  # connect
  con <- connect()

  shiny::onStop(function(){
    disconnect(con)
  })

  output$chart <- echarts4r::renderEcharts4r({

    e <- NULL
    
    if(rv$log == "")
      rv$log <- FALSE

    if(rv$data == "jhu"){

      cat("plotting jhu -", rv$chart, "\n")

      df <- DBI::dbReadTable(con, "jhu")

      if(rv$chart == "trend")
        e <- mode_trend_echarts(df = df, log = rv$log)

      if(rv$chart == "death-rate")
        e <- mod_jhu_death_rate_echarts(df)

      if(rv$chart == "timeline")
        e <- mod_map_echarts(df, rv$log)

      if(rv$chart == "timeline-provinces")
        e <- mod_time_provinces_echarts(df)

      if(rv$chart == "world-map")
        e <- mod_world_echarts(df)

      if(rv$chart == "cases-added")
        e <- mode_new_cases_echarts(df, rv$cumulative)

      if(rv$chart == "world-timeline")
        e <- mod_china_others_echarts(df, rv$country)
      
    } else if(rv$data == "weixin"){
      
      cat("plotting weixin -", rv$type, "\n")

      china_daily <- DBI::dbReadTable(con, "weixin")

      e <- mod_china_trend_echarts(china_daily, column = rv$type, log = rv$log)

    } else if(rv$data == "dxy"){

      cat("plotting dxy -", rv$chart, "\n")

      df <- DBI::dbReadTable(con, "dxy")

      if(rv$chart == "china")
        e <- mod_city_map_china_echarts(df, rv$variable)

      if(rv$chart == "province")
        e <- mod_city_map_region_echarts(df, rv$variable, rv$province)

    }

    return(e)
  })
  
}

#' Get Query
#' 
#' @param query URL query.
#' @param param Parameter to extract.
#' 
#' @keywords internal
get_query <- function(query, param){
  p <- query[[param]]

  if(is.null(p))
    p <- ""

  if(p == "true" || p == "false"){
    p <- toupper(p)
    p <- as.logical(p)
  }

  return(p)
}

# legacy, depreacted keep for embeds
mod_map_echarts <- function(df, log){
  
  dat <- df %>% 
    dplyr::filter(country %in% c("Mainland China", "Hong Kong", "Taiwan")) %>% 
    dplyr::left_join(chinese_provinces, by = "state") %>% 
    dplyr::arrange(desc(date)) %>% 
    dplyr::select(state, type, date, cases) %>% 
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

  bs <- list(
    shadowColor = "rgba(0, 0, 0, 0.8)",
    shadowBlur = 5,
    shadowOffsetX = 3
  )

  dat %>% 
    tidyr::pivot_wider(
      c(state, date),
      names_from = type,
      values_from = cases
    ) %>% 
    dplyr::arrange(desc(date), desc(confirmed)) %>% 
    dplyr::group_by(date) %>% 
    echarts4r::e_charts(state, timeline = TRUE, dispose = FALSE) %>% 
    echarts4r::e_bar(confirmed, name = "Confirmed", itemStyle = bs) %>% 
    echarts4r::e_bar(recovered, name = "Recovered", itemStyle = bs) %>% 
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
}