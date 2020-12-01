library(sf)

polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
minmax = minmaxDTM_get(polygon)

# output's length should be 2 (sf/data.frame)
if (!length(minmax) == 2) {
  return(NULL)
}


test_that("check if ouput is sf/data.frame", {
  expect_s3_class(minmax, c("sf", "data.frame"))
})

test_that("check number of rows", {
  expect_true(nrow(minmax) > 1)
})

test_that("check number of columns", {
  expect_true(ncol(minmax) == 2)
})


# test EPSG:4326
polygon_4326 = st_transform(polygon, 4326)

test_that("check if the warning is returned for EPSG:4326", {
  expect_warning(minmaxDTM_get(polygon_4326))
})

# suppress the warning because it is already tested above
test_that("check if results are equal", {
  expect_equal(minmax, suppressWarnings(minmaxDTM_get(polygon_4326)))
})


# test stops
polygon = rbind(polygon, polygon)

test_that("check stops", {
  expect_error(minmaxDTM_get(polygon), "polygon must contain one object")
})
