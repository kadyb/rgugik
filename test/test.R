library("sf")

polygon = read_sf("poligon.gpkg")


req_df1 = request(polygon = polygon)

req_df2 = request(polygon = polygon, where = "kolor LIKE 'CIR'")

req_df3 = request(polygon = polygon, where = "piksel <= 0.25")

req_df4 = request(polygon = polygon, where = "akt_rok >= 2016")


# download only first image
download.file(req_df1[1, "url_do_pobrania"], paste0(req_df1[1, "nazwa_pliku"], ".tif"), mode = "wb")
