t1 = geocodePL_get(address = "Marki") # place
t2 = geocodePL_get(address = "Królewskie Brzeziny 13") # place and house number
t3 = geocodePL_get(road = "632") # road number
t4 = geocodePL_get(rail_crossing = "001 018 478")
t5 = geocodePL_get(geoname = "Las Mierzei") # physiographic object


test_that("check if ouput is list", {
  expect_type(t1, "list")
  expect_type(t2, "list")
  expect_type(t3, "list")
  expect_type(t4, "list")
  expect_type(t5, "list")
})

test_that("check length", {
  expect_true(length(t1) == 10)
  expect_true(length(t2) == 15)
  expect_true(length(t3) == 5)
  expect_true(length(t4) == 6)
  expect_true(length(t5) == 12)
})


# test stops
test_that("check stops", {
  expect_error(geocodePL_get(rail_crossing = "0"),
               "rail crossing ID must be 11 characters long")
})
