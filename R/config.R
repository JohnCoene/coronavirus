#' Configuration
#' 
#' Creates a configuration file.
#' 
#' @section newsapi:
#' The latest version requires a newsapi token from \url{https://newsapi.org/}.
#' 
#' @rdname config
#' @export
create_config <- function(){
  file <- system.file("coronavirus.yml", package = "coronavirus")
  created <- file.copy(file, to = config_file)
  if(created)
    cli::cli_alert_success("_coronavirus.yml file copied: fill it in")
  else
    cli::cli_alert_danger("Cannot create config file")

  invisible()
}
