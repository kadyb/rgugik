# skip test on GitHub and CRAN
skip_on_ci()
skip_on_cran()

tmp = tempdir()
output = egib_download(county = "Świętochłowice", layer = "dzialki", outdir = NULL)

# if output is "connection error", return NULL
if (typeof(output) == "character") return(NULL)

# output should be sf data frame
expect_s3_class(output, c("sf", "data.frame"))

# test stops
test_that("check stops", {
  expect_error(egib_download(), "'county' and 'TERYT' are empty")
  expect_error(egib_download("Świętochłowice", "2476"), "use only one input")
  expect_error(egib_download(county = "XXX"), "incorrect county name")
  expect_error(egib_download(TERYT = "0"), "incorrect TERYT")
  expect_error(egib_download("Łomża"), "there is no layers available")
  expect_error(egib_download(TERYT = "0220", layer = "Osnowa"), "There is more than 1 layer")
})
