#' API
#' 
#' Return path to API file.
#' 
#' @param host,port Host and port passed to \code{plumber}.
#' 
#' @section Functions:
#' \itemize{
#'  \item{\code{run_api} - Runs the API interactively.}
#'  \item{\code{scaffold_api} - Copies required files for docker deployment in current directory.}
#' }
#' 
#' @details The \code{scaffold_api} function copies the files necessary to deploy the 
#' the api using docker. Make sure you do so from the directory that contains your 
#' configuration file (\code{\link{create_config}}). Once copied run
#' \code{docker build -t coronavirus .} to build the docker image with your config file.
#' Then run \code{docker run -p 80:8000 -d coronavirus} where \code{80} is the port you want
#' to map to (of your machine).
#' 
#' @examples \dontrun{run_api()}
#' 
#' @name api
#' @export
run_api <- function(host = "0.0.0.0", port = 3000){
  # check that file present
  has_config()

  fl <- system.file("api/api.R", package = "coronavirus")

  pr <- plumber::plumb(fl)
  pr$run(
    host = host, port = port,
    swagger = TRUE
  )
}

#' @rdname api
#' @export
scaffold_api <- function(){
  # check that file present
  has_config()

  api <- system.file("api/api.R", package = "coronavirus")
  dockerfile <- system.file("api/Dockerfile", package = "coronavirus")

  # copy files
  api_copy <- file.copy(api, "api.R")
  api_docker <- file.copy(dockerfile, "Dockerfile")

  if(api_copy && api_docker)
    cli::cli_alert_success("Files copied successfully")
  else
    cli::cli_alert_danger("Could not copy files.")

  cli::cli_alert_info("Run\ndocker build -t coronavirus .")
  cli::cli_alert_info("Then\ndocker run -p 80:8000 -d coronavirus")
  invisible()
}