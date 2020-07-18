pointDTM_get = function(polygon) {

  if (nrow(polygon) != 1) {
    stop("polygon must contain one object")
  }

  # input EPSG must be 2180
  if (!sf::st_crs(polygon)$epsg == 2180) {
    # maybe it would be good to add a warning here..
    polygon = sf::st_transform(polygon, 2180)
  }

  if (as.vector(sf::st_area(polygon)) > 200000){
    stop("maximum area is 20 ha") # [m^2]
  }

  base_URL = "https://services.gugik.gov.pl/nmt/?request=GetHByPointList&list="

  pts = sf::st_make_grid(polygon, cellsize = 1, what = "corners") # source DTM is 1 x 1 m resolution
  pts = sf::st_coordinates(pts)
  pts = apply(pts, 2, as.integer) # make it integer
  pts = as.data.frame(pts)

  # initial empty character vector
  empty_output = character()

  # request may only contain 500 points
  iter = floor(nrow(pts) / 500)
  n_last = nrow(pts) %% 500

  n_attempts = iter / 2
  attempt = 0
  i = 0

  while (i < iter + 1) {

    if (attempt == n_attempts){
      stop("server does not return values, try again later")
    }

    writeLines(paste0(i, "/", iter))

    if (i < iter) {
      sel_pts = pts[(i * 500 + 1):(i * 500 + 500), ]
      str_pts = paste(sel_pts[, 2], sel_pts[, 1]) # X, Y coordinates are inverted
      str_pts = paste(str_pts, collapse = ",")
      prepared_URL = paste0(base_URL, str_pts)
      str_output = readLines(prepared_URL, warn = FALSE)
      str_output = unlist(strsplit(str_output, ","))
      str_output = unlist(strsplit(str_output, " "))
      elev = str_output[1:(length(str_output) / 3) * 3] # take every 3rd element (elevation)
      i = i + 1

      if (all(elev %in% "0.0")) {
        warning("empty return, next attempt", immediate. = TRUE)
        i = i - 1
        attempt = attempt + 1
        Sys.sleep(2) # wait 2 sec
        next
      }
      empty_output = c(empty_output, elev)
      Sys.sleep(2) # wait 2 sec
    } else {
      sel_pts = pts[(i * 500 + 1):(i * 500 + n_last), ]
      str_pts = paste(sel_pts[, 2], sel_pts[, 1]) # X, Y coordinates are inverted
      str_pts = paste(str_pts, collapse = ",")
      prepared_URL = paste0(base_URL, str_pts)
      str_output = readLines(prepared_URL, warn = FALSE)
      str_output = unlist(strsplit(str_output, ","))
      str_output = unlist(strsplit(str_output, " "))
      elev = str_output[1:(length(str_output) / 3) * 3] # take every 3rd element (elevation)
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
