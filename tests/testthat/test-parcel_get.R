parcel_byID = parcel_get(TERYT = "141201_1.0001.6509")
parcel_byCOORDS = parcel_get(X = 313380.5, Y = 460166.4)

# if output is "connection error", check type and return NULL
if (typeof(parcel_byID) == "character" ||
    typeof(parcel_byCOORDS) == "character") {
  return(NULL)
}


test_that("check if ouput is sf/sfc", {
  expect_s3_class(parcel_byID, "sfc")
  expect_s3_class(parcel_byCOORDS, "sf")
})

test_that("check number of rows", {
  expect_true(length(parcel_byID) == 1)
  expect_true(nrow(parcel_byCOORDS) == 1)
})

test_that("check number of columns", {
  expect_true(ncol(parcel_byCOORDS) == 2)
})


# test stops
test_that("check stops", {
  expect_error(parcel_get(X = NULL, Y = 0), "missing coordinates")
})
