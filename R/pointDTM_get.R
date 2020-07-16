pointDTM_get = function(polygon) {

  if (nrow(polygon) != 1) stop("polygon must contain one object")
  
  # input EPSG must be 2180
  if (!st_crs(polygon)$epsg == 2180) {
    polygon = st_transform(sfc, 2180)
  }
  
  if (st_area(polygon) > 500000) stop("maximum area is 50 ha") # [m^2]
  
  base_URL = "https://services.gugik.gov.pl/nmt/?request=GetHByPointList&list="
  
  pts = st_make_grid(polygon, cellsize = 1, what = "corners") # source DTM is 1 x 1 m resolution
  pts = st_coordinates(pts)
  pts = apply(pts, 2, as.integer) # make it integer

  pts_string = paste(pts[, 1], pts[, 2])
  pts_string = paste(pts_string, collapse = ",")
  
  prepared_URL = paste0(base_URL, pts_string)
  
  return()
  
  # TODO:
  # czy usluga moze zwrocic NA (pewnie tak, dla obszarów spoza Polski)?
  # wysokość jest zwracana w układzie PL-KRON86-NH
  # MOZNA MAKSYMALNIE PRZEKAZAC 500 PUNKTOW W JEDYNM ZAPYTANIU (!)
  # czy przed 'as.integer' powinno byc 'round'?
  # dodac iteracje po poligonach i punktach
  # moze dodac sprawdzenie czy poligon lezy w bboxie Polski?
  # dodac 'wait' pomiedzy iteracjami
}

#############
### test

base_URL = "https://services.gugik.gov.pl/nmt/?request=GetHByPointList&list="

library("sf")
polygon = read_sf("poligon.gpkg")
pts = st_make_grid(polygon, cellsize = 1, what = "corners")
pts = st_coordinates(pts)
pts = apply(pts, 2, as.integer)

# initial empty character vector
empty_output = character()

# request may only contain 500 points
iter = ceiling(nrow(pts) / 500)
n_last = nrow(pts) %% 500

for (i in 0:iter) {
  if (i < iter) {
    sel_pts = pts[(i * 500 + 1):(i * 500 + 500), ]
    str_pts = paste(sel_pts[, 1], sel_pts[, 2])
    str_pts = paste(str_pts, collapse = ",")
    prepared_URL = paste0(base_URL, str_pts)
    str_output = readLines(prepared_URL, warn = FALSE)
    str_output = unlist(strsplit(str_output, ","))
    str_output = unlist(strsplit(str_output, " "))
    elev = str_output[1:(length(str_output) / 3) * 3] # take every 3rd element (elevation)
    empty_output = c(empty_output, elev)
  } else {
    sel_pts = pts[(i * 500 + 1):(i * 500 + n_last), ]
    str_pts = paste(sel_pts[, 1], sel_pts[, 2])
    str_pts = paste(str_pts, collapse = ",")
    prepared_URL = paste0(base_URL, str_pts)
    str_output = readLines(prepared_URL, warn = FALSE)
    str_output = unlist(strsplit(str_output, ","))
    str_output = unlist(strsplit(str_output, " "))
    elev = str_output[1:(length(str_output) / 3) * 3] # take every 3rd element (elevation)
    empty_output = c(empty_output, elev)
  }
  Sys.sleep(2) # wait 2 sec
}

length(empty_output) == nrow(pts) # WRONG!
empty_output = as.numeric(elev)


