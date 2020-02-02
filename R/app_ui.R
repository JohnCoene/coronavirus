#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here 
    fluidPage(
      title = "coronavirus",
      mod_dash_ui("dash_ui_1")
    )
  )
}

#' @import shiny
golem_add_external_resources <- function(){
  
  addResourcePath(
    'www', system.file('app/www', package = 'coronavirus')
  )
 
  tags$head(
    golem::activate_js(),
    golem::favicon(),
    waiter::use_waiter(),
    tags$link(rel="stylesheet", type="text/css", href="www/style.css")
  )
}
