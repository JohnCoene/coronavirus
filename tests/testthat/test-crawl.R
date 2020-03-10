context("Crawler")

test_that("crawler works", {
  v <- crawl_coronavirus()

  expect_length(v, 4)
  expect_named(v, c("jhu", "weixin", "weixin_total", "dxy"))
  expect_is(v, "list")
  expect_is(v[[1]], "data.frame")
  expect_is(v[[2]], "data.frame")
  expect_is(v[[3]], "data.frame")
  expect_is(v[[4]], "data.frame")
})
