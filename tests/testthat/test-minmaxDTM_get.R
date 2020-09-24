library(sf)

polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
minmax = minmaxDTM_get(polygon)


test_that("check if ouput is sf/data.frame", {
  expect_s3_class(minmax, c("sf", "data.frame"))
})

test_that("check number of rows", {
  expect_true(nrow(minmax) > 1)
})

test_that("check number of columns", {
  expect_true(ncol(minmax) == 2)
})
