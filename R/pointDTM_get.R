#' @title Get terrain elevation for a given polygon
#'
#' @param polygon the polygon layer with only one object
#' (its area is limited to the 20 ha * distance parameter),
#' the input coordinate system must be EPSG:2180
#' @param distance distance between points in meters
#' (must be integer and greater than 1)
#' @param print_iter print the current iteration of all
#' (logical, TRUE default)
#'
#' @return a data frame with vector points and terrain elevation
#' (EPSG:2180, Vertical Reference System:PL-KRON86-NH)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#' DTM = pointDTM_get(polygon, distance = 2)
#' }
pointDTM_get = function(polygon, distance = 1, print_iter = TRUE) {

  if (nrow(polygon) != 1) {
    stop("polygon must contain one object")
  }

  # input EPSG must be 2180
  if (!sf::st_crs(polygon)$epsg == 2180) {
    warning("input EPSG must be 2180, trying to transform", immediate. = TRUE)
    polygon = sf::st_transform(polygon, 2180)
  }

  if (distance < 1) {
    stop("distance between the points cannot be less than 1 m")
  }

  if (!as.integer(distance) == distance) {
    stop("'distance' must contain an integer")
  }

  # the greater distance between points, the larger area can be used
  # input area unit is [m^2]
  if (as.vector(sf::st_area(polygon)) > 200000 * distance) {
    stop(paste("maximum area is", 20 * distance, "ha"))
  }

  base_URL = "https://services.gugik.gov.pl/nmt/?request=GetHByPointList&list="

  # source DTM is 1 x 1 m resolution
  pts = sf::st_make_grid(polygon, cellsize = distance, what = "corners")
  pts = pts[polygon] # intersects with polygon
  pts = sf::st_coordinates(pts)
  pts = apply(pts, 2, as.integer) # make it integer because minimum distance is 1 m
  pts = as.data.frame(pts)

  # initial empty character vector
  empty_output = character()

  # helper function (get elevation values from URL)
  get_elev = function(points, URL) {
    str_pts = paste(sel_pts[, 2], sel_pts[, 1]) # X, Y coordinates are inverted
    str_pts = paste(str_pts, collapse = ",")
    prepared_URL = paste0(base_URL, str_pts)
    prepared_URL = gsub(" ", "%20", prepared_URL)
    str_output = tryGet(readLines(prepared_URL, warn = FALSE))

    if (any(str_output %in% c("error", "warning"))) {
      return(NULL)
    }

    str_output = unlist(strsplit(str_output, ","))
    str_output = unlist(strsplit(str_output, " "))
    elev = str_output[1:(length(str_output) / 3) * 3] # take every 3rd element (elevation)
    return(elev)
    }

  # request may only contain 500 points
  iter = floor(nrow(pts) / 500)
  n_last = nrow(pts) %% 500

  n_attempts = iter / 2
  attempt = 0
  i = 0

  while (i < iter + 1) {

    if (attempt == n_attempts) {
      return(invisible("connection error"))
    }

    if (print_iter) {
      writeLines(paste0(i, "/", iter))
    }

    if (i < iter) {
      sel_pts = pts[(i * 500 + 1):(i * 500 + 500), ]
      elev = get_elev(sel_pts, base_URL)
      if (is.null(elev)) return(invisible("connection error"))
      i = i + 1

      if (all(elev %in% "0.0")) {
        # warning("empty return, next attempt", immediate. = TRUE)
        i = i - 1
        attempt = attempt + 1
        Sys.sleep(2) # wait 2 sec
        next
      }

      empty_output = c(empty_output, elev)
      Sys.sleep(2) # wait 2 sec

    } else {
      sel_pts = pts[(i * 500 + 1):(i * 500 + n_last), ]
      elev = get_elev(sel_pts, base_URL)
      if (is.null(elev)) return(invisible("connection error"))
      empty_output = c(empty_output, elev)
      i = i + 1
    }
  }

  empty_output = as.numeric(empty_output)
  pts = cbind(pts, Z = empty_output)
  pts = sf::st_as_sf(pts, coords = c("X", "Y"), crs = 2180)

  # elevation is returned in 'PL-KRON86-NH' Vertical Reference System
  return(pts)

}
