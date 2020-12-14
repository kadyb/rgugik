base_URL = "https://opendata.geoportal.gov.pl/"

sample_orto = paste0(base_URL, "ortofotomapa/41/41_3756_N-33-130-D-b-2-3.tif")
orto = data.frame(URL = sample_orto, filename = "sample_orto",
                  sha1 = "312c81963a31e268fc20c442733c48e1aa33838f",
                  stringsAsFactors = FALSE)

sample_DEM = paste0(base_URL, "NumDaneWys/NMT/73556/73556_1002897_N-33-130-D-b-2-3.asc")
DEM = data.frame(URL = sample_DEM, filename = "sample_DEM",
                 sha1 = "392a0edf763e38fa1b7b6067ac1b080c47374dd2",
                 stringsAsFactors = FALSE)

# ORTO
tmp = tempfile()
status = tile_download(orto, outdir = tmp)

# status should be NULL (successfully downloaded), otherwise return NULL
if (!is.null(status)) {
  return(NULL)
}

file_path = list.files(tmp, full.names = TRUE)
file_size = file.info(file_path)$size / 2^20
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))

test_that("check file size", {
  expect_true(file_size > 2)
})

test_that("check file ext", {
  expect_true(file_ext == "tif")
})


# DEM
tmp = tempfile()
sttus = tile_download(DEM, outdir = tmp)

if (!is.null(status)) {
  return(NULL)
}

file_path = list.files(tmp, full.names = TRUE)
file_size = file.info(file_path)$size / 2^20
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))

test_that("check file size", {
  expect_true(file_size > 1)
})

test_that("check file ext", {
  expect_true(file_ext == "asc")
})


# internal checkSHA function
test_that("check checkSHA warning", {
  expect_warning(rgugik:::checkSHA_fun("fakeSHA", DEM$filename, file_path),
                 paste(DEM$filename, "incorrect SHA"))
})


# test stops
df = data.frame("URL" = integer(), "filename" = integer(), "sha1" = integer())

test_that("check stops", {
  expect_error(tile_download(df),
               "empty df")
  expect_error(tile_download(df[, -1]),
               "data frame should come from 'request_orto'")
  expect_error(tile_download(df[, -2]),
               "data frame should come from 'request_orto'")
  expect_error(tile_download(df[, -3], check_SHA = TRUE),
               "'sha1' column not found")
})
