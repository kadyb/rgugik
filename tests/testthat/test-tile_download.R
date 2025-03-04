skip_on_cran()


base_URL = "https://opendata.geoportal.gov.pl/"

sample_ortho = paste0(base_URL, "ortofotomapa/41/41_3756_N-33-130-D-b-2-3.tif")
ortho = data.frame(URL = sample_ortho, filename = "sample_ortho",
                   stringsAsFactors = FALSE)

sample_DEM = paste0(base_URL, "NumDaneWys/NMT/73556/73556_1002897_N-33-130-D-b-2-3.asc")
DEM = data.frame(URL = sample_DEM, filename = "sample_DEM",
                 stringsAsFactors = FALSE)

# ORTHO
tmp = tempfile()
status = tile_download(ortho, outdir = tmp)

# status should be NULL (successfully downloaded), otherwise return NULL
if (!is.null(status)) {
  return(NULL)
}

file_path = list.files(tmp, full.names = TRUE)
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))

test_that("check file ext", {
  expect_true(file_ext == "tif")
})


# DEM
tmp = tempfile()
status = tile_download(DEM, outdir = tmp)

if (!is.null(status)) {
  return(NULL)
}

file_path = list.files(tmp, full.names = TRUE)
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))

test_that("check file ext", {
  expect_true(file_ext == "asc")
})


# test stops
df = data.frame("URL" = integer(), "filename" = integer())

test_that("check stops", {
  expect_error(tile_download(df),
               "empty df")
  expect_error(tile_download(df[, -1]),
               "data frame should come from 'request_ortho'")
  expect_error(tile_download(df[, -2]),
               "data frame should come from 'request_ortho'")
})
