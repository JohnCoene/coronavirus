#' Run embeds app
#' 
#' @export 
run_embeds <- function(){
  with_golem_options(
    app = shinyApp(ui = embeds_ui, server = embeds_server), 
    golem_opts = list()
  )
}