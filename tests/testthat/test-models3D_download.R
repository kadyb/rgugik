tmp = tempfile()
status = models3D_download(county = "Sopot", LOD = "LOD1",
                           outdir = tmp, unzip = FALSE) # 2.4 MB

# status should be NULL (successfully downloaded), otherwise return NULL
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
  expect_true(file_ext == "zip")
})


# unzip
tmp = tempfile()
status = models3D_download(TERYT = 2264, LOD = "LOD1",
                           outdir = tmp, unzip = TRUE) # 2.4 MB

if (!is.null(status)) {
  return(NULL)
}

file_path = list.files(tmp, full.names = TRUE)
file_number = length(file_path)
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))


test_that("check number of files", {
  expect_true(file_number == 1L)
})

test_that("check if zip is removed", {
  expect_true(!"zip" %in% file_ext)
})


# test stops
test_that("check stops", {
  expect_error(models3D_download(), "'county' and 'TERYT' are empty")
  expect_error(models3D_download("Świętochłowice", 2476), "use only one input")
  expect_error(models3D_download(county = "XXX"), "incorrect county name")
  expect_error(models3D_download(TERYT = "0"), "incorrect TERYT")
  expect_error(models3D_download(TERYT = 2476, LOD = "0"),
               "inncorect LOD, should be 'LOD1' or 'LOD2'")
})
