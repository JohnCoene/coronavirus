#' Run the Shiny Application
#' 
#' Run the dashboard
#' 
#' @param data list as returned by \code{\link{crawl_coronavirus}}, otherwise uses database.
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
#' @importFrom stats coef nls
#' @import shinyMobile
run_app <- function(data = NULL) {
  with_golem_options(
    app = shinyApp(ui = app_ui, server = app_server), 
    golem_opts = list(data = data)
  )
}
