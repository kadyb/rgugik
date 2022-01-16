#' @title Get the geometry of cadastral parcels
#'
#' @param TERYT parcel ID (18 characters, e.g. "141201_1.0001.6509")
#' @param X longitude (EPSG: 2180)
#' @param Y latitude (EPSG: 2180)
#'
#' @return a simple feature geometry (in case of TERYT) or data frame with simple
#' feature geometry and TERYT (in case of coordinates)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' parcel = parcel_get(TERYT = "141201_1.0001.6509")
#' parcel = parcel_get(X = 313380.5, Y = 460166.4)
#' }
parcel_get = function(TERYT = NULL, X = NULL, Y = NULL) {

  if (!is.null(TERYT)) {

    # get by TERYT (parcel ID)
    prepared_URL = paste0("https://uldk.gugik.gov.pl/?request=GetParcelById&id=", TERYT,
                          "&result=geom_wkb")

    output = tryGet(readLines(prepared_URL, warn = FALSE))

    if (any(output %in% c("error", "warning"))) {
      return(invisible("connection error"))
    }

    # "0" means no server side errors
    if (output[1] != "0") {
      return(invisible("connection error"))
    }

    wkb = structure(list(output[2]), class = "WKB")
    geom = sf::st_as_sfc(wkb, EWKB = TRUE, crs = 2180)

  } else {

    if (is.null(X) || is.null(Y)) {
      stop("missing coordinates")
    }

    result = c("geom_wkb", "teryt")
    result = paste(result, collapse = ",")
    coords = paste(Y, X, sep = ",") # X, Y coordinates are inverted

    # get by XY
    prepared_URL = paste0("https://uldk.gugik.gov.pl/?request=GetParcelByXY&xy=", coords,
                          "&result=", result)

    output = tryGet(readLines(prepared_URL, warn = FALSE))

    if (any(output %in% c("error", "warning"))) {
      return(invisible("connection error"))
    }

    # "0" means no server side errors
    if (output[1] != "0") {
      return(invisible("connection error"))
    }

    output = output[2]
    output = unlist(strsplit(output, "\\|"))
    wkb = structure(list(output[1]), class = "WKB")
    geom = sf::st_as_sfc(wkb, EWKB = TRUE, crs = 2180)
    geom = sf::st_sf(geom, TERYT = output[2])
  }

  # geometry is returned in EPSG: 2180
  return(geom)
}
