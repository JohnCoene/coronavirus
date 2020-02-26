#' Run embeds app
#' 
#' @export 
run_embeds <- function(){
  addResourcePath(
    'www', system.file('app/www', package = 'coronavirus')
  )
  shiny::shinyApp(embeds_ui(), embeds_server)
}