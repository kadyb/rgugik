tmp = tempfile()
pointDTM100_download("opolskie", outdir = tmp, unzip = FALSE) # 3.7 MB
file_path = list.files(tmp, full.names = TRUE)
file_size = file.info(file_path)$size / 2^20
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))


test_that("check file size", {
  expect_true(file_size > 3)
})

test_that("check file ext", {
  expect_true(file_ext == "zip")
})
