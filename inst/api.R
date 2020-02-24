#* Get John Hopkins Data
#* @serializer unboxedJSON
#* @get /jhu
function(){
  con <- coronavirus:::connect()

  on.exit({
    coronavirus:::disconnect()
  })

  DBI::dbReadTable(con, "jhu") %>% 
    purrr::transpose()
}

#* Get Weixin Data
#* @serializer unboxedJSON
#* @get /weixin
function(){
  con <- coronavirus:::connect()

  on.exit({
    coronavirus:::disconnect()
  })

  details <- DBI::dbReadTable(con, "weixin") %>% 
    purrr::transpose()

  list(
    total = DBI::dbReadTable(con, "weixin_total"),
    data = details
  )
}

#* Get Weixin Data
#* @serializer unboxedJSON
#* @get /dxy
function(){
  con <- coronavirus:::connect()

  on.exit({
    coronavirus:::disconnect()
  })

  DBI::dbReadTable(con, "dxy") %>% 
    purrr::transpose()
}
