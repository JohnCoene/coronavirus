context("Crawler")

test_that("crawler works", {
  v <- crawl_coronavirus()

  expect_length(v, 5)
  expect_named(v, c("jhu", "weixin", "weixin_total", "dxy", "news"))
  expect_is(v, "list")
  expect_is(v[[1]], "data.frame")
  expect_is(v[[2]], "data.frame")
  expect_is(v[[3]], "data.frame")
  expect_is(v[[4]], "data.frame")
  expect_null(v[[5]])
})
