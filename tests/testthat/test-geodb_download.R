# skip test on GitHub and CRAN
skip_on_ci()
skip_on_cran()


tmp = tempfile()
status = geodb_download("opolskie", outdir = tmp, unzip = FALSE) # 5.8 MB

# status should be NULL (successfully downloaded), otherwise return NULL
if (!is.null(status)) {
  return(NULL)
}

file_path = list.files(tmp, full.names = TRUE)
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))

test_that("check file ext", {
  expect_true(file_ext == "zip")
})


# test stops
test_that("check stops", {
  expect_error(geodb_download(voivodeships = NULL), "enter names or TERC")
})
