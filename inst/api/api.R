connect <- function(){

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

con <- connect()

#* Get John Hopkins Data
#* @param type Type of cases to return; confirmed, recovered, or death.
#* @param region Region to return either china, or other.
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

  total <- DBI::dbReadTable(con, "weixin_total")

  details <- DBI::dbReadTable(con, "weixin")

  list(
    source = "Tencent QQ",
    url = "https://github.com/GuangchuangYu/nCov2019",
    total = total,
    data = details
  )
}

#* Get DingXianYing Data
#* @serializer unboxedJSON
#* @get /dxy
function(){

  data <- DBI::dbReadTable(con, "dxy")

  list(
    source = "DingXiangYuan",
    url = "https://ncov.dxy.cn/ncovh5/view/pneumonia",
    data = data
  )
}
