t1 = geocodePL_get(address = "Marki") # place
t2 = geocodePL_get(address = "Królewskie Brzeziny 13") # place and house number
t3 = geocodePL_get(road = "632") # road number
t4 = geocodePL_get(rail_crossing = "001 018 478")
t5 = geocodePL_get(geoname = "Las Mierzei") # physiographic object
t6 = geocodePL_get(address = "Poznań Aleja Niepodległosci")

# if output is "connection error", check type and return NULL
if (typeof(t1) == "character" ||
    typeof(t2) == "character" ||
    typeof(t3) == "character" ||
    typeof(t4) == "character" ||
    typeof(t5) == "character" ||
    t6 == "connection error") {
  return(NULL)
}


test_that("check if ouput is sf/data.frame", {
  expect_s3_class(t1, c("sf", "data.frame"))
  expect_s3_class(t2, c("sf", "data.frame"))
  expect_s3_class(t3, c("sf", "data.frame"))
  expect_s3_class(t4, c("sf", "data.frame"))
  expect_s3_class(t5, c("sf", "data.frame"))
})

test_that("check number of columns", {
  expect_true(ncol(t1) == 12)
  expect_true(ncol(t2) == 15)
  expect_true(ncol(t3) == 8)
  expect_true(ncol(t4) == 10)
  expect_true(ncol(t5) == 12)
})

test_that("check if object was not found", {
  expect_true(t6 == "object not found")
})

# test stops
test_that("check stops", {
  expect_error(geocodePL_get(),
               "all inputs are empty")
  expect_error(geocodePL_get(rail_crossing = "0"),
               "rail crossing ID must be 11 characters long")
})
