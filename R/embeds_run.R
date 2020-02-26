#' Run embeds app
#' 
#' @import shiny
#' 
#' @export 
run_embeds <- function(){
  addResourcePath(
    'www', system.file('app/www', package = 'coronavirus')
  )
  with_golem_options(
    app = shinyApp(ui = embeds_ui, server = embeds_server), 
    golem_opts = list()
  )
}