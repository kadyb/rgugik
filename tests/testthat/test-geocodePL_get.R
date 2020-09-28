t1 = geocodePL_get(address = "Marki") # place
t2 = geocodePL_get(address = "Marki, Andersa") # place and street
t3 = geocodePL_get(address = "Marki, Andersa 1") # place, street and house number
t4 = geocodePL_get(address = "Królewskie Brzeziny 13") # place and house number

t5 = geocodePL_get(road = "632") # road number
t6 = geocodePL_get(road = "632 55") # road number and mileage

t7 = geocodePL_get(rail_crossing = "001 018 478")

t8 = geocodePL_get(geoname = "Las Mierzei") # physiographic object


test_that("check if ouput is list", {
  expect_type(t1, "list")
  expect_type(t2, "list")
  expect_type(t3, "list")
  expect_type(t4, "list")
  expect_type(t5, "list")
  expect_type(t6, "list")
  expect_type(t7, "list")
  expect_type(t8, "list")
})

test_that("check length", {
  expect_true(length(t1) == 10)
  expect_true(length(t2) == 11)
  expect_true(length(t3) == 16)
  expect_true(length(t4) == 15)
  expect_true(length(t5) == 5)
  expect_true(length(t6) == 5)
  expect_true(length(t7) == 6)
  expect_true(length(t8) == 12)
})
