#' Run the Shiny Application
#' 
#' Run the dashboard
#' 
#' @param data list as returned by \code{\link{crawl_coronavirus}}, otherwise uses database.
#' @param embed_url Base URL of \code{\link{run_embeds}} app.
#'
#' @export
#' @import shiny
#' @importFrom golem with_golem_options
#' @importFrom stats coef nls
#' @importFrom utils packageVersion
#' 
#' @import shinyMobile
run_app <- function(data = NULL, embed_url = "https://shiny.john-coene.com/coronavirus-embed") {
  options(scipen = 99999)

  with_golem_options(
    app = shinyApp(ui = app_ui, server = app_server), 
    golem_opts = list(data = data, embed_url = embed_url)
  )
}
