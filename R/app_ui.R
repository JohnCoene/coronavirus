#' @import shiny
app_ui <- function() {
  version <- paste0("v", packageVersion("coronavirus"))

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here 
    f7Page(
      title = "Coronavirus",
      dark_mode = TRUE,
      init = f7Init(
        skin = "md", 
        theme = "dark"
      ),
      f7TabLayout(
        navbar = f7Navbar(
          title = "Coronavirus Tracker",
          hairline = FALSE,
          shadow = TRUE,
          left_panel = TRUE,
          right_panel = FALSE
        ),
        panels = tagList(
          f7Panel(
            title = "About", 
            side = "left", 
            theme = "dark",
            effect = "cover",
            p("Tracks data on Novel Coronavirus 2019 using data from John Hopkins, Weixin (WeChat), and DingXiangYuan (DXY). The Database is refreshed every hour, the code is open-source so you can deploy it yourself, see below."),
            f7Link(label = "Author", src = "https://john-coene.com", external = TRUE),
            f7Link(label = "John Hopkins Data", src = "https://github.com/CSSEGISandData/2019-nCoV", external = TRUE),
            f7Link(label = "Weixin Data", src = "https://github.com/GuangchuangYu/nCov2019", external = TRUE),
            f7Link(label = "DXY Data", src = "https://ncov.dxy.cn/ncovh5/view/pneumonia", external = TRUE),
            f7Link(label = "API", src = "http://shiny.john-coene.com:8080/__swagger__/", external = TRUE),
            f7Link(label = "Code", src = "https://github.com/JohnCoene/coronavirus", external = TRUE),
            f7Link(label = "Docs", src = "https://coronavirus.john-coene.com", external = TRUE),
            tags$pre(tags$code(version))
          )
        ),
        f7Tabs(
          animated = TRUE,
          id = 'tabs',
          f7Tab(
            tabName = "Home",
            icon = f7Icon("info_circle", old = FALSE),
            active = TRUE,
            swipeable = TRUE,
            waiter::waiter_show_on_load(loader, color = "#000"),
            h2("John Hopkins Data", class = "center"),
            p(tags$small("Data on China and the rest of the World."), class = "center"),
            f7Row(
              f7Col(
                mod_count_ui("count_ui_1", "Confirmed"),
              ),
              f7Col(
                mod_count_ui("count_ui_2", "Deaths")
              ),
              f7Col(
                mod_count_ui("count_ui_3", "Recovered")
              )
            ),
            h2("Weixin Data", class = "center"),
            p(tags$small("Data on China."), class = "center"),
            f7Row(
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_1", "Confirmed")
              ),
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_4", "Suspected")
              ),
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_2", "Deaths")
              ),
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_3", "Recovered")
              )
            ),
            h2("DXY Data", class = "center"),
            p(tags$small("Data on China."), class = "center"),
            f7Row(
              f7Col(mod_count_weixin_ui("count_dxy_ui_1", "Confirmed")),
              f7Col(mod_count_weixin_ui("count_dxy_ui_3", "Deaths")),
              f7Col(mod_count_weixin_ui("count_dxy_ui_4", "Recovered"))
            )
          ),
          f7Tab(
            tabName = "John Hopkins",
            icon = f7Icon("waveform_path", old = FALSE),
            active = FALSE,
            swipeable = TRUE,
            h2("John Hopkins Data", class = "center"),
            p(tags$small("Data on China and the rest of the world."), class = "center"),
            f7Row(
              f7Col(
                mod_count_ui("count_ui_1_jhu", "Confirmed"),
              ),
              f7Col(
                mod_count_ui("count_ui_2_jhu", "Deaths")
              ),
              f7Col(
                mod_count_ui("count_ui_3_jhu", "Recovered")
              )
            ),
            mod_new_cases_ui("new_cases"),
            f7Row(
              f7Col(mod_trend_ui("trend_ui_1")),
              f7Col(mod_jhu_death_rate_ui("jhu_death_rate_ui_1"))
            ),
            mod_map_ui("map_ui_1"),
            mod_time_provinces_ui("time_provinces_1"),
            mod_china_others_ui("china_others"),
            mod_world_ui("world_ui_1"),
            f7Row(
              mod_china_ui("table_china", "China"),
              mod_table_world_ui("table_world", "World")
            )
          ),
          f7Tab(
            tabName = "Weixin",
            icon = f7Icon("waveform", old = FALSE),
            swipeable = TRUE,
            active = FALSE,
            h2("Weixin Data", class = "center"),
            p(tags$small("Data on China."), class = "center"),
            f7Row(
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_1_wx", "Confirmed")
              ),
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_4_wx", "Suspected")
              ),
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_2_wx", "Deaths")
              ),
              f7Col(
                mod_count_weixin_ui("count_weixin_ui_3_wx", "Recovered")
              )
            ),
            f7Row(
              f7Col(mod_china_trend_ui("china_trend_ui_confirm", "Confirmed")),
              f7Col(mod_china_trend_ui("china_trend_ui_suspect", "Suspected"))
            ),
            f7Row(
              f7Col(mod_china_trend_ui("china_trend_ui_dead", "Deaths")),
              f7Col(mod_china_trend_ui("china_trend_ui_heal", "Recovered"))
            ),
            f7Block(
              f7BlockHeader("Data Integrity"),
              p(
                "There is a great discrepancy between total figures for China and",
                "daily numbers reported."
              )
            )
          ),
          f7Tab(
            tabName = "DXY",
            icon = f7Icon("graph_circle", old = FALSE),
            swipeable = TRUE,
            active = FALSE,
            h2("DXY Data", class = "center"),
            p(tags$small("Data on China."), class = "center"),
            waiter::waiter_hide_on_render("count_ui_1-cnt"),
            f7Row(
              f7Col(mod_count_weixin_ui("count_dxy_ui_1_dxy", "Confirmed")),
              f7Col(mod_count_weixin_ui("count_dxy_ui_3_dxy", "Deaths")),
              f7Col(mod_count_weixin_ui("count_dxy_ui_4_dxy", "Recovered"))
            ),
            mod_city_map_ui("city_map_1"),
            mod_dxy_table_ui("dxy_table_ui_1")
          ),
          f7Tab(
            tabName = "News",
            icon = f7Icon("quote_bubble", old = FALSE),
            swipeable = TRUE,
            active = FALSE,
            mod_news_ui("news")
          )
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
    tags$script(src="www/copy.js"),
    sever::use_sever(),
    shinyscroll::use_shinyscroll(),
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
    ),
    tags$meta(property="og:title", content="Coronavirus Tracker"),
    tags$meta(property="og:type", content="article"),
    tags$meta(property="og:url", content="https://shiny.john-coene.com/coronavirus"),
    tags$meta(property="og:image", content="https://shiny.john-coene.com/coronavirus/www/coronavirus.png"),
    tags$meta(property="og:description", content="A Coronavirus tracker app using John Hopkins and Weixin Data"),
    tags$meta(name="twitter:card", content="summary_large_image"),
    tags$meta(name="twitter:site", content="@jdatap"),
    tags$meta(name="twitter:title", content="Coronavirus Tracker"),
    tags$meta(name="twitter:description", content="A Coronavirus tracker app using John Hopkins and Weixin Data"),
    tags$meta(name="twitter:image:src", content="https://shiny.john-coene.com/coronavirus/www/coronavirus.png"),
    shiny::tags$link(rel = "apple-touch-icon", href = "www/icons/apple-touch-icon.png"),
    
    # pwa materials (this is not a permanent fix). shinyMobile will
    # handle this better soon!
    tags$link(rel = "manifest", href = "www/manifest.json"),
    tags$meta(name="theme-color", content="#000000")
    
    # Launch screen for IOS
    # Below is just an example in case you would like to try
    # This is done by default for Android but not iOS :(
    # Also you would have to handle as many devices as possible ...
    # shiny::tags$link(href = "www/splashscreens/iphone5_splash.png", media = "(device-width: 320px) and (device-height: 568px) and (-webkit-device-pixel-ratio: 2)", rel = "apple-touch-startup-image")
    
  )
}

loader <- tagList(
  waiter::spin_loaders(42),
  br(),
  h3("Loading data")
)