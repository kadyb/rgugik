library("sf")

polygon = read_sf("poligon.gpkg")


req_df1 = orto_request(polygon = polygon)

req_df2 = orto_request(polygon = polygon, where = "kolor LIKE 'CIR'")

req_df3 = orto_request(polygon = polygon, where = "piksel <= 0.25")

req_df4 = orto_request(polygon = polygon, where = "akt_rok >= 2016")


# take first image only
req_sel = req_df1[1, ]
orto_download(req_sel)
