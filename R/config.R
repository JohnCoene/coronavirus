#' Configuration
#' 
#' Creates a configuration file and Google sheets token.
#' 
#' @param id,secret Google console credentials. 
#' 
#' @rdname config
#' @export
create_config <- function(){
  file <- system.file("_coronavirus.yml", package = "coronavirus")
  created <- file.copy(file, to = config_file)
  if(created)
    cli::cli_alert_success("_coronavirus.yml file copied: fill it in")
  else
    cli::cli_alert_danger("Cannot create config file")

  invisible()
}

#' @rdname config
#' @export
create_token <- function(id, secret){
  token <- googlesheets::gs_auth(
    key = id,
    secret = secret,
    cache = FALSE
  ) 

  saveRDS(token, file = token_file)

  invisible()
}