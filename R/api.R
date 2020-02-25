#' API
#' 
#' Return path to API file.
#' 
#' @param host,port Host and port passed to \code{plumber}.
#' 
#' @export
run_api <- function(host = "0.0.0.0", port = 3000){
  fl <- system.file("api.R", package = "coronavirus")

  pr <- plumber::plumb(fl)
  pr$run(
    host = host, port = port,
    swagger = TRUE
  )
}