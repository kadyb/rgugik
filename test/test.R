library("sf")

polygon = read_sf("poligon.gpkg")

req_df = request(polygon = polygon)
str(req_df)

# download only first image
download.file(req_df[1, "url_do_pobrania"], paste0(req_df[1, "nazwa_pliku"], ".tif"), mode = "wb")
