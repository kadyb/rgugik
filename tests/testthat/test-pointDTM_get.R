skip_on_cran()


library(sf)

polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
DTM = pointDTM_get(polygon, distance = 3)

# output's length should be 2 (sf/data.frame)
if (!length(DTM) == 2) {
  return(NULL)
}


test_that("check if ouput is sf/data.frame", {
  expect_s3_class(DTM, c("sf", "data.frame"))
})

test_that("check number of rows", {
  expect_true(nrow(DTM) == 586)
})

test_that("check number of columns", {
  expect_true(ncol(DTM) == 2)
})

test_that("check elevation sd", {
  expect_true(sd(DTM$Z) > 0)
})


# test stops
polygon2 = rbind(polygon, polygon)

test_that("check stops", {
  expect_error(pointDTM_get(polygon, distance = 0),
               "distance between the points cannot be less than 1 m")
  expect_error(pointDTM_get(polygon, distance = 1.5),
               "'distance' must contain an integer")
  expect_error(pointDTM_get(polygon2),
               "polygon must contain one object")
})
