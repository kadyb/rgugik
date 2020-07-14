request = function(polygon, where = NULL) {

  if (!is.null(where) && !is.character(where)) stop("'where' must be string")
  if (nrow(polygon) == 0) stop("no geometries")

  epsg = sf::st_crs(polygon)$epsg

  # hard coded URL and parameters
  base_URL = "https://mapy.geoportal.gov.pl/gprest/services/SkorowidzeFOTOMF/MapServer/0/query?"
  geometryType = "&geometryType=esriGeometryEnvelope"
  spatialRel = "&spatialRel=esriSpatialRelIntersects"
  outFields = "&outFields=*"
  returnGeometry = "&returnGeometry=false"
  file = "&f=json"

  # user input
  empty_where = "&where="
  if (!is.null(where)) {
    empty_where = paste0(empty_where, where)
  }

  # initial empty df
  empty_df = data.frame(godlo = character(),
                        akt_rok = integer(),
                        piksel = numeric(),
                        kolor = character(),
                        zrDanych = character(),
                        ukladXY = character(),
                        modulArch = character(),
                        nrZglosz = character(),
                        czy_ark_wypelniony = character(),
                        daneAktualne = integer(),
                        daneAktDo10cm = integer(),
                        lok_orto = character(),
                        url_do_pobrania = character(),
                        idSerie = integer(),
                        sha1 = character(),
                        akt_data = numeric(),
                        idorto = integer(),
                        nazwa_pliku = character(),
                        ESRI_OID = integer()
  )

  for (i in 1:nrow(polygon)) {
    bbox = sf::st_bbox(st_geometry(polygon)[[i]])

    # user input
    geometry = paste0("geometry={'xmin':", bbox[1], ", 'ymin':", bbox[2], ", 'xmax':", bbox[3], ", 'ymax':", bbox[4], ", 'spatialReference':{'wkid':", epsg, "}}")

    prepared_URL = paste0(base_URL, geometry, geometryType, spatialRel, outFields,
                          returnGeometry, file, empty_where)

    output = jsonlite::fromJSON(prepared_URL)
    output = output$features[[1]]
    empty_df = rbind(empty_df, output)
  }

  # remove duplicated images
  empty_df = empty_df[!duplicated(empty_df$nazwa_pliku), ]
  return(empty_df)
}
