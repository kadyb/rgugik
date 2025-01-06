### test multiple file downloads manually ###

if (FALSE) { # change to TRUE to run the test

  library(rgugik)
  library(sf)

  options(timeout = 600)
  tmp = tempdir()

  polygon = st_bbox(c(xmin = 512000, xmax = 517000, ymin = 357000, ymax = 360000),
                    crs = "EPSG:2180")
  polygon = st_as_sfc(polygon)

  ### orthoimages
  orthoimages = ortho_request(polygon) # n = 114
  tile_download(orthoimages, outdir = tmp)

  ### DEMs
  DEMs = DEM_request(polygon) # n = 164
  tile_download(DEMs, outdir = tmp)

}
