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


# test EPSG 4326
polygon_4326 = st_transform(polygon, 4326)
minmax_4326 = minmaxDTM_get(polygon_4326)

test_that("check if ouput is sf/data.frame", {
  expect_equal(minmax, minmax_4326)
})
