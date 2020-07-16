pointDTM_get = function(polygon) {

  base_URL = "https://services.gugik.gov.pl/nmt/?request=GetHByPointList&list="
  
  # input EPSG must be 2180
  if (!st_crs(polygon)$epsg == 2180) {
    polygon = st_transform(sfc, 2180)
  }
  
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
}

#############
### test

library("sf")
polygon = read_sf("poligon.gpkg")
pts = st_make_grid(polygon, cellsize = 1, what = "corners")
pts = st_coordinates(pts)
pts = apply(pts, 2, as.integer)
pts = pts[1:500, ] # can use only 500 points

f = paste(pts[, 1], pts[, 2])
f = paste(f, collapse = ",")

base_URL = "https://services.gugik.gov.pl/nmt/?request=GetHByPointList&list="
prepared_URL = paste0(base_URL, f)


str_output = readLines(prepared_URL, warn = FALSE)
str_output = unlist(strsplit(str_output, ","))
str_output = unlist(strsplit(str_output, " "))
elev = str_output[1:(length(str_output)/3)*3] # take every 3rd element
elev = as.numeric(elev)

iter = ceiling(nrow(pts) / 500)

for (i in 1:iter) {
  
}