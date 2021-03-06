context("plotdap")

expect_plotdap <- function(p) {
  expect_s3_class(p, class(p)[1])
  save_plotdap(p)
}

# TODO: maybe png::readPNG() and test the result?
save_plotdap <- function(p) {
  Cairo::Cairo(file = tempfile(fileext = ".png"))
  print(p)
  dev.off()
}

test_that("plotdap() runs without any data", {
  expect_plotdap(plotdap())
  expect_plotdap(plotdap("base"))
})

test_that("plotdap() can handle projections", {
  proj <- "+proj=laea +y_0=0 +lon_0=155 +lat_0=-90 +ellps=WGS84 +no_defs"
  expect_plotdap(plotdap(crs = proj))
  expect_plotdap(plotdap("base", crs = proj))
})

CPSinfo <- info('FRDCPSTrawlLHHaulCatch')
sardines <- tabledap(
  CPSinfo,
  fields = c('latitude',  'longitude', 'time', 'scientific_name', 'subsample_count'),
  'time>=2010-01-01', 'time<=2012-01-01', 'scientific_name="Sardinops sagax"'
)

test_that("plotdap can handle tables", {
  expect_plotdap(
    plotdap() %>% add_tabledap(sardines, ~subsample_count)
  )
  expect_plotdap(
    plotdap("base") %>% add_tabledap(sardines, ~subsample_count)
  )
})

test_that("plotdap can handle tables with projections", {
  expect_plotdap(
    plotdap(crs = "+proj=robin") %>% add_tabledap(sardines, ~subsample_count)
  )
  expect_plotdap(
    plotdap("base", crs = "+proj=robin") %>%
      add_tabledap(sardines, ~subsample_count)
  )
})

sstInfo <- info('jplMURSST41')
murSST <- griddap(
  sstInfo, latitude = c(22, 51), longitude = c(-140, -105),
  time = c('last', 'last'), fields = 'analysed_sst'
)

test_that("plotdap can handle grids", {
  expect_plotdap(
    plotdap() %>% add_griddap(murSST, ~analysed_sst)
  )
  expect_plotdap(
    plotdap("base") %>% add_griddap(murSST, ~analysed_sst)
  )
})

test_that("plotdap can project grids", {
  expect_plotdap(
    plotdap(crs = "+proj=robin") %>% add_griddap(murSST, ~analysed_sst)
  )
  expect_plotdap(
    plotdap("base", crs = "+proj=robin") %>% add_griddap(murSST, ~analysed_sst)
  )
})

test_that("plotdap can handle both tables and grids", {
  expect_plotdap(
    plotdap() %>%
      add_griddap(murSST, ~analysed_sst) %>%
      add_tabledap(sardines, ~subsample_count)
  )
  expect_plotdap(
    plotdap("base") %>%
      add_griddap(murSST, ~analysed_sst) %>%
      add_tabledap(sardines, ~subsample_count)
  )
})

test_that("plotdap can project both tables and grids", {
  expect_plotdap(
    plotdap(crs = "+proj=robin") %>%
      add_griddap(murSST, ~analysed_sst) %>%
      add_tabledap(sardines, ~subsample_count)
  )
  expect_plotdap(
    plotdap("base", crs = "+proj=robin") %>%
      add_griddap(murSST, ~analysed_sst) %>%
      add_tabledap(sardines, ~subsample_count)
  )
})

# multiple time periods
wind <- griddap(
  'erdQMwindmday', time = c('2016-11-16', '2017-01-16'),
  latitude = c(30, 50), longitude = c(210, 240),
  fields = 'x_wind'
)


test_that("plotdap can handle a time series of grids", {
  expect_plotdap(
    plotdap("base", mapTitle = "Average wind over time") %>%
      add_griddap(wind, ~x_wind)
  )
})



# ---------------------------------------------------------------------------
# If I were a betting man, I'd say vdiffr doesn't like that print.ggplotdap()
# calls print.ggplot()...
# ---------------------------------------------------------------------------

# expect_fig <- function(title, fig, ...) {
#   vdiffr::expect_doppelganger(
#     title = title, fig = fig, path = "", ...
#   )
# }
#
# test_that("plotdap works without any data", {
#   expect_fig("plain-ggplot2", plotdap)
#   expect_fig("plain-base", plotdap("base"))
# })
