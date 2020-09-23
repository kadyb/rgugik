library(testit)

base_URL = "https://opendata.geoportal.gov.pl/"

sample_orto = paste0(base_URL, "ortofotomapa/41/41_3756_N-33-130-D-b-2-3.tif")
orto = data.frame(URL = sample_orto, filename = "sample_orto",
                  sha1 = "312c81963a31e268fc20c442733c48e1aa33838f")

sample_DEM = paste0(base_URL, "NumDaneWys/NMT/73556/73556_1002897_N-33-130-D-b-2-3.asc")
DEM = data.frame(URL = sample_DEM, filename = "sample_DEM",
                 sha1 = "392a0edf763e38fa1b7b6067ac1b080c47374dd2")

# ORTO
tmp = tempfile()
tile_download(orto, outdir = tmp)
file_path = list.files(tmp, full.names = TRUE)
file_size = file.info(file_path)$size / 2^20
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))

assert(
  "check file size",
  file_size > 2
)

assert(
  "check file ext",
  file_ext == "tif"
)

# DEM
tmp = tempfile()
tile_download(DEM, outdir = tmp)
file_path = list.files(tmp, full.names = TRUE)
file_size = file.info(file_path)$size / 2^20
file_ext = substr(file_path, nchar(file_path) - 2, nchar(file_path))

assert(
  "check file size",
  file_size > 1
)

assert(
  "check file ext",
  file_ext == "asc"
)

# test checkSHA_fun
checkSHA_fun(refSHA = "X", fileSHA = "X")
