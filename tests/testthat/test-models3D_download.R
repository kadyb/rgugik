tmp = tempfile()
models3D_download(county = "Świętochłowice", LOD = "LOD1",
                  outdir = tmp, unzip = FALSE) # 1.2 MB
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
models3D_download(TERYT = 2476, LOD = "LOD1",
                  outdir = tmp, unzip = TRUE) # 1.2 MB
file_path = list.files(tmp, full.names = TRUE)
file_number = length(file_path)
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))


test_that("check number of files", {
  expect_true(file_number == 1L)
})

test_that("check if zip is removed", {
  expect_true(!"zip" %in% file_ext)
})
