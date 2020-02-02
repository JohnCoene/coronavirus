#' @import shiny
app_server <- function(input, output,session) {
  callModule(mod_dash_server, "dash_ui_1")
}
