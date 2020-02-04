#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here 
    f7Page(
      title = "Coronavirus",
      dark_mode = TRUE,
      init = f7Init(
        skin = "md", 
        theme = "dark",
        serviceWorker = "www/service-worker.js"
      ),
      waiter::waiter_show_on_load(loader, color = "#000"),
      f7SingleLayout(
        f7Row(
          f7Col(
            mod_count_ui("count_ui_1", "Confirmed"),
            mod_count_weixin_ui("count_weixin_ui_1")
          ),
          f7Col(
            mod_count_ui("count_ui_2", "Deaths"),
            mod_count_weixin_ui("count_weixin_ui_2")
          ),
          f7Col(
            mod_count_ui("count_ui_3", "Recovered"),
            mod_count_weixin_ui("count_weixin_ui_3")
          ),
          f7Col(
            mod_count_weixin_ui("count_weixin_ui_4", label = "Suspected")
          )
        ),
        mod_trend_ui("trend_ui_1"),
        mod_map_ui("map_ui_1"),
        mod_world_ui("world_ui_1"),
        f7Row(
          mod_china_ui("table_china", "China"),
          mod_table_world_ui("table_world", "World")
        ),
        navbar = f7Navbar(
          title = "Coronavirus Tracker",
          hairline = TRUE,
          shadow = TRUE
        ),
        toolbar = f7Toolbar(
          position = "bottom",
          f7Link(label = "Author", src = "https://john-coene.com", external = TRUE),
          f7Link(label = "Code", src = "https://github.com/JohnCoene/coronavirus", external = TRUE),
          f7Link(label = "Data", src = "https://docs.google.com/spreadsheets/d/1UF2pSkFTURko2OvfHWWlFpDFAr1UxCBA4JLwlSP6KFo/", external = TRUE)
        )
      )
    )
  )
}

#' @import shiny
golem_add_external_resources <- function(){
  
  addResourcePath(
    'www', system.file('app/www', package = 'coronavirus')
  )
 
  tags$head(
    golem::activate_js(),
    golem::favicon(),
    waiter::use_waiter(include_js = FALSE),
    tags$link(rel="stylesheet", type="text/css", href="www/style.css"),
    HTML(
      "
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src='https://www.googletagmanager.com/gtag/js?id=UA-74544116-1'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-74544116-1');
</script>"
    )
  )
}

loader <- tagList(
  waiter::spin_loaders(42),
  br(),
  br(),
  "Loading data..."
)