test_url = function(url) {

  # check internet connection
  if (!curl::has_internet()) {
    message("no internet connection")
    return(invisible(NULL))
  }

  # try for timeout problem (5 secs)
  timeout = try(httr::HEAD(url, httr::timeout(5)), silent = TRUE)
  if (class(timeout) == "try-error") {
    message("connection timeout")
    return(invisible(NULL))
  }

  # check HTTP status > 400
  if (httr::http_error(url)) {
    message("data source problem")
    return(invisible(NULL))
  }

}

# test_url("http://httpbin.org/status/404")
# test_url("http://httpbin.org/delay/6")
# test_url("http://httpbin.org") # OK


# try obtain online data
try_obtain = function(expr) {

  try_class = class(try(expr = expr, silent = TRUE))

  if (try_class == "try-error") {
    message("data source problem")
    return(invisible(NULL))
  }

  if (try_class != "try-error" && is.integer(expr)) {
    return(invisible(NULL))
  } else {
    return(expr)
  }

}

# url = "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.16.zip"
# try_obtain(utils::download.file(url, tempfile(), mode = "wb"))

# url = paste0(
# "https://mapy.geoportal.gov.pl/gprest/services/SkorowidzeFOTOMF/MapServer/0/query?",
# "geometry={'xmin':351643, 'ymin':507730, 'xmax':351824, 'ymax':507793, ",
# "'spatialReference':{'wkid':2180}}&geometryType=esriGeometryEnvelope",
# "&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=json"
# )
# test = try_obtain(jsonlite::fromJSON(url))
