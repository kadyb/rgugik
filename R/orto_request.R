orto_request = function(polygon, where = NULL) {

  if (!is.null(where) && !is.character(where)){
    stop("'where' must be string")
  }
  if (nrow(polygon) == 0) {
    stop("no geometries")
  }

  selected_cols = c("godlo", "akt_rok", "piksel", "kolor", "zrDanych",
                  "url_do_pobrania", "idSerie", "sha1", "nazwa_pliku")
  selected_cols = paste(selected_cols, collapse = ",")

  epsg = sf::st_crs(polygon)$epsg

  # hard coded URL and parameters
  base_URL = "https://mapy.geoportal.gov.pl/gprest/services/SkorowidzeFOTOMF/MapServer/0/query?"
  geometryType = "&geometryType=esriGeometryEnvelope"
  spatialRel = "&spatialRel=esriSpatialRelIntersects"
  outFields = paste0("&outFields=", selected_cols)
  returnGeometry = "&returnGeometry=false"
  file = "&f=json"

  # user input
  empty_where = "&where="
  if (!is.null(where)) {
    empty_where = paste0(empty_where, where)
  }

  # initial empty df (columns must be identical as in 'selected_cols')
  empty_df = data.frame(godlo = character(),
                        akt_rok = integer(),
                        piksel = numeric(),
                        kolor = character(),
                        zrDanych = character(),
                        #ukladXY = character(),
                        #modulArch = character(),
                        #nrZglosz = character(),
                        #czy_ark_wypelniony = character(),
                        #daneAktualne = integer(),
                        #daneAktDo10cm = integer(),
                        #lok_orto = character(),
                        url_do_pobrania = character(),
                        idSerie = integer(),
                        sha1 = character(),
                        #akt_data = numeric(),
                        #idorto = integer(),
                        nazwa_pliku = character()
                        #ESRI_OID = integer()
  )

  for (i in 1:nrow(polygon)) {
    bbox = sf::st_bbox(sf::st_geometry(polygon)[[i]])

    # user input
    geometry = paste0("geometry={'xmin':", bbox[1], ", 'ymin':", bbox[2], ", 'xmax':", bbox[3], ", 'ymax':", bbox[4], ", 'spatialReference':{'wkid':", epsg, "}}")

    prepared_URL = paste0(base_URL, geometry, geometryType, spatialRel, outFields,
                          returnGeometry, file, empty_where)

    output = jsonlite::fromJSON(prepared_URL)
    output = output$features[[1]]

    # MaxRecordCount: 1000
    if (nrow(output) == 1000) {
      warning("maximum number of records, reduce the area or add filtering")
    }

    empty_df = rbind(empty_df, output)
  }

  # remove duplicated images
  empty_df = empty_df[!duplicated(empty_df$nazwa_pliku), ]
  return(empty_df)
}
