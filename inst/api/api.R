connect <- function(){
  config <- yaml::read_yaml("_coronavirus.yml")

  has_vars <- all(c("user", "password", "host") %in% names(config$database))

  if(!has_vars)
    stop("Missing variables in config file, see `create_config`", call. = FALSE)
  
  pool::dbPool(
    RPostgres::Postgres(),
    host = config$database$host,
    user = config$database$user,
    password = config$database$password,
    dbname = config$database$name,
    port = 5432
  )
}

#* Get John Hopkins Data
#* @param type Type of cases to return; \code{confirmed}
#* \code{recovered}, or \code{death}.
#* @param region Region to return either \code{china}, or \code{other}.
#* @serializer unboxedJSON
#* @get /jhu
function(res, type, region){

  msg <- ""

  # check inputs
  if(missing(type))
    msg <- "Must specify type, one of confirmed, recovered, death"

  if(missing(region))
    msg <- "Must specify region, either china, or other"

  if(msg != ""){
    res$status <- 400
    return(
      list(
        error = jsonlite::unbox(msg)
      )
    )
  }

  if(grepl(";", type))
    msg <- "No SQL injection please."

  if(!type %in% c("confirmed", "recovered", "death"))
    msg <- "Invalid type, must be one of confirmed, recovered, death"

  if(!region %in% c("china", "other"))
    msg <- "Invalid region, must be china, or other"

  if(msg != ""){
    res$status <- 400
    return(
      list(
        error = jsonlite::unbox(msg)
      )
    )
  }

  con <- connect()

  on.exit({
    pool::poolClose(con)
  })

  type <- gsub("'", "", type)

  # define clause
  if(region == "china")
    country <- "country = 'Mainland China'"
  else
    country <- "country <> 'Mainland China'"

  data <- DBI::dbGetQuery(
    con, 
    paste0("SELECT * FROM jhu WHERE type = '", type, "' AND ", country, ";")
  ) 
  data <- purrr::transpose(data)

  list(
    source = "John Hopkins CSSE",
    url = "https://github.com/CSSEGISandData/COVID-19",
    data = data
  )
}

#* Get Weixin Data
#* @serializer unboxedJSON
#* @get /weixin
function(){

  con <- connect()

  on.exit({
    pool::poolClose(con)
  })

  total <- DBI::dbReadTable(con, "weixin_total")
  total <- purrr::transpose(total)

  details <- DBI::dbReadTable(con, "weixin") 
  details <- purrr::transpose(details)

  list(
    source = "Tencent QQ",
    url = "https://github.com/GuangchuangYu/nCov2019",
    total = total,
    data = details
  )
}

#* Get Weixin Data
#* @serializer unboxedJSON
#* @get /dxy
function(){

  con <- connect()

  on.exit({
    pool::poolClose(con)
  })

  data <- DBI::dbReadTable(con, "dxy")
  data <- purrr::transpose(data)

  list(
    source = "DingXiangYing",
    url = "https://ncov.dxy.cn/ncovh5/view/pneumonia",
    data = data
  )
}
