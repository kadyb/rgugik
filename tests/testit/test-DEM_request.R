library(sf)
library(testit)

polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
req_df = DEM_request(polygon)

assert(
  "check if ouput is data frame",
  class(req_df) == "data.frame"
)

assert(
  "check number of rows",
  nrow(req_df) > 0
)

assert(
  "check number of columns",
  ncol(req_df) == 13
)
