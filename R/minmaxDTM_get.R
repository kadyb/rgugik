#' @title Get minimum and maximum elevation for a given polygon
#'
#' @param polygon the polygon layer with only one object (area less than 10 ha),
#' the larger the polygon area, the lower DTM resolution,
#' the input coordinate system must be EPSG:2180
#'
#' @return a data frame with vector points and min/max terrain elevation
#' (EPSG:2180)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#' minmax = minmaxDTM_get(polygon)
#' }
minmaxDTM_get = function(polygon) {

  if (nrow(polygon) != 1) {
    stop("polygon must contain one object")
  }

  # input EPSG must be 2180
  if (!sf::st_crs(polygon)$epsg == 2180) {
    warning("input EPSG must be 2180, trying to transform", immediate. = TRUE)
    polygon = sf::st_transform(polygon, 2180)
  }

  # input area unit is [m^2]
  if (as.vector(sf::st_area(polygon)) > 100000) {
    stop("maximum area is ", 10, " ha")
  }

  geom = sf::st_coordinates(polygon)[, 1:2]

  if (nrow(geom) > 124) {
    stop("geometry is too complex, make it simpler")
  }

  geom = apply(geom, 2, as.integer)
  geom = paste(geom[, 1], geom[, 2], sep = "%20", collapse = ",")
  geom = paste0("POLYGON((", geom, "))")

  base_URL = "https://services.gugik.gov.pl/nmt/?request=GetMinMaxByPolygon&polygon="
  file = "&json"
  prepared_URL = paste0(base_URL, geom, file)

  output = tryGet(jsonlite::fromJSON(prepared_URL))

  if (any(output %in% c("error", "warning"))) {
    return(invisible("connection error"))
  }

  if (length(output) == 1) {
    message("The returned object is not valid. Please try again.")
    return(invisible(NULL))
  }

  print(paste("Polygon area:", output[["Polygon area"]], "m^2"))
  print(paste("Resolution:",  output[["Grid size [m]"]], "m"))

  min_list = sf::st_as_sfc(output[["Hmin geom"]], crs = 2180)
  min_list = sf::st_sf(geom = min_list, elev = sf::st_coordinates(min_list)[, 3])

  max_list = sf::st_as_sfc(output[["Hmax geom"]], crs = 2180)
  max_list = sf::st_sf(geom = max_list, elev = sf::st_coordinates(max_list)[, 3])

  df = rbind(min_list, max_list)
  df = sf::st_zm(df) # drop Z from geometry

  return(df)
}
