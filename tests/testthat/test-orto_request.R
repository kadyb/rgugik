library(sf)

polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
req_df = orto_request(polygon)


test_that("check if ouput is data frame", {
  skip_on_ci()
  expect_s3_class(req_df, "data.frame")
})

test_that("check number of rows", {
  skip_on_ci()
  expect_true(nrow(req_df) > 0)
})

test_that("check number of columns", {
  skip_on_ci()
  expect_true(ncol(req_df) == 11)
})
