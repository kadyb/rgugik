skip_on_cran()


voivodeship_geom = borders_get(voivodeship = "lubuskie") # 494 KB
county_geom = borders_get(county = "Sopot") # 18 KB
commune_geom1 = borders_get(commune = c("Hel", "Krynica Morska")) # 11 KB
commune_geom2 = borders_get(TERYT = c("2211011", "2210011")) # 11 KB

# if output is "connection error", check type and return NULL
if (typeof(voivodeship_geom) == "character" ||
    typeof(county_geom) == "character" ||
    typeof(commune_geom1) == "character" ||
    typeof(commune_geom2) == "character") {
  return(NULL)
}


test_that("check if ouput is sf", {
  expect_s3_class(voivodeship_geom, "sf")
  expect_s3_class(county_geom, "sf")
  expect_s3_class(commune_geom1, "sf")
  expect_s3_class(commune_geom2, "sf")
})

test_that("check number of rows", {
  expect_true(nrow(voivodeship_geom) == 1)
  expect_true(nrow(county_geom) == 1)
  expect_true(nrow(commune_geom1) == 2)
  expect_true(nrow(commune_geom2) == 2)
})

test_that("check number of columns", {
  expect_true(ncol(voivodeship_geom) == 2)
  expect_true(ncol(county_geom) == 2)
  expect_true(ncol(commune_geom1) == 2)
  expect_true(ncol(commune_geom2) == 2)
})


# test stops
test_that("check stops", {
  expect_error(borders_get(TERYT = 0), "'TERYT' length should be 2, 4 or 7")
})
