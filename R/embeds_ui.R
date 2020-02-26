embeds_ui <- function(){
  fluidPage(
    title = "coronavirus",
    tags$head(
      tags$link(rel="stylesheet", type="text/css", href="www/style.css"),
      tags$link(rel="stylesheet", type="text/css", href="www/embeds.css"),
      sever::use_sever(),
      waiter::use_waiter(include_js = FALSE),
      HTML(
        "
  <script async src='https://www.googletagmanager.com/gtag/js?id=UA-74544116-1'></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());

    gtag('config', 'UA-74544116-1');
  </script>"
      )
    ),
    echarts4r::echarts4rOutput("chart", height = "100vh"),
    waiter::waiter_show_on_load(loader, color = "#000"),
    waiter::waiter_hide_on_render("chart")
  )
}
