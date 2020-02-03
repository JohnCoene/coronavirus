#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here 
    f7Page(
      title = "Coronavirus",
      dark_mode = TRUE,
      init = f7Init(skin = "md", theme = "dark"),
      manifest = "./www/manifest.json",
      waiter::waiter_show_on_load(loader, color = "#000"),
      f7SingleLayout(
        f7Row(
          f7Col(
            mod_count_ui("count_ui_1", "confirmed")
          ),
          f7Col(
            mod_count_ui("count_ui_2", "deaths")
          ),
          f7Col(
            mod_count_ui("count_ui_3", "recovered")
          )
        ),
        mod_trend_ui("trend_ui_1"),
        mod_map_ui("map_ui_1"),
        mod_world_ui("world_ui_1"),
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
    tags$link(rel="stylesheet", type="text/css", href="www/style.css")
  )
}

loader <- tagList(
  waiter::spin_loaders(42),
  br(),
  br(),
  "Loading data..."
)