skip_on_cran()

tmp = tempdir()
status = egib_layer_download(county = "trzebnicki", layer = "dzialki", outdir = tmp)

# status should be sf data frame
expect_s3_class(status, c("sf", "data.frame"))

# test stops
test_that("check stops", {
  expect_error(egib_layer_download(), "'county' and 'TERYT' are empty")
  expect_error(egib_layer_download("Świętochłowice", "2476"), "use only one input")
  expect_error(egib_layer_download(county = "XXX"), "incorrect county name")
  expect_error(egib_layer_download(TERYT = "0"), "incorrect TERYT")
  expect_error(egib_layer_download("Łomża"), "there is no layers available")
  expect_error(egib_layer_download(TERYT = "0220", layer = "Osnowa"), "here is more than 1 layer")
})
