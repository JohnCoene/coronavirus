# Building a Prod-Ready, Robust Shiny Application.
# 
# Each step is optional. 
# 

# 2. All along your project

## 2.1 Add modules
## 
golem::add_module( name = "trend" ) # Name of the module
golem::add_module( name = "count" ) # Name of the module
golem::add_module( name = "map" ) # Name of the module
golem::add_module( name = "world" ) # Name of the module
golem::add_module( name = "table" ) # Name of the module
golem::add_module( name = "table_world" ) # Name of the module
golem::add_module( name = "count_weixin" ) # Name of the module
golem::add_module( name = "chiny_trend" ) # Name of the module
golem::add_module( name = "city_map" ) # Name of the module
golem::add_module( name = "dxy_table" ) # Name of the module
golem::add_module( name = "geo_lines" ) # Name of the module
golem::add_module( name = "time_provinces" ) # Name of the module
golem::add_module( name = "jhu_death_rate" ) # Name of the module
golem::add_module( name = "news" ) # Name of the module
golem::add_module( name = "new_cases" ) # Name of the module
golem::add_module( name = "china_others" ) # Name of the module

## 2.2 Add dependencies

usethis::use_package( "thinkr" ) # To call each time you need a new package

## 2.3 Add tests

usethis::use_test( "app" )

## 2.4 Add a browser button

golem::browser_button()

## 2.5 Add external files

golem::add_js_file( "script" )
golem::add_js_handler( "handlers" )
golem::add_css_file( "style" )

# 3. Documentation

## 3.1 Vignette
usethis::use_vignette("coronavirus")
devtools::build_vignettes()

## 3.2 Code coverage
## You'll need GitHub there
usethis::use_github()
usethis::use_travis()
usethis::use_appveyor()

# You're now set! 
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")
