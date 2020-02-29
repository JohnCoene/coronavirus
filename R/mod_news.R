# Module UI
  
#' @title   mod_news_ui and mod_news_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_news
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_news_ui <- function(id){
  ns <- NS(id)
  tagList(
    f7Block(
      h2("News", class = "center"),
      p(tags$small("Latest articles on the coronavirus."), class = "center"),
      inset = TRUE
    ),
    f7Block(uiOutput(ns("articles")))
  )
}
    
# Module Server
    
#' @rdname mod_news
#' @export
#' @keywords internal
    
mod_news_server <- function(input, output, session, df){
  ns <- session$ns

  output$articles <- renderUI({
    if(is.null(df))
      return(span("No newsapi token"))

    nws <- data.frame()
    for(i in 1:nrow(df)){
      if(i %% 2 == 0){
        row <- df[i,]
        nws <- dplyr::bind_rows(nws, row)
      }
    }

    items <- nws %>% 
      dplyr::distinct() %>% 
      purrr::transpose() %>% 
      purrr::map(function(article){
        f7ListItem(
          title = article$title,
          subtitle = substr(article$author, 1, 25),
          tagList(
            article$description,
          ),
          media = tags$img(
            src = article$urlToImage
          ),
          footer = tags$a(
            class = "link external article-link",
            article$source,
            href = article$url
          )
        )
      })
    
    f7List(mode = "media", items)
  })
}
