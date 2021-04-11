#' @title Get metadata and links to available orthoimages
#'
#' @param x an sf/sfc object with one or more features (requests are based
#' on the bounding boxes of the provided features)
#'
#' @return a data frame with metadata and links to the orthoimages
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#' req_df = ortho_request(polygon)
#'
#' # simple filtering by attributes
#' req_df = req_df[req_df$composition == "CIR", ]
#' req_df = req_df[req_df$resolution <= 0.25 & req_df$year >= 2016, ]
#' }
ortho_request = function(x) {

  if (length(sf::st_geometry(x)) == 0) {
    stop("no geometries")
  }

  selected_cols = c("godlo", "akt_rok", "piksel", "kolor", "zrDanych", "ukladXY",
                    "czy_ark_wypelniony", "url_do_pobrania", "idSerie", "sha1", "akt_data",
                    "nazwa_pliku")
  selected_cols = paste(selected_cols, collapse = ",")

  epsg = sf::st_crs(x)$epsg

  # hard coded URL and parameters
  base_URL = "https://mapy.geoportal.gov.pl/gprest/services/SkorowidzeFOTOMF/MapServer/0/query?"
  geometryType = "&geometryType=esriGeometryEnvelope"
  spatialRel = "&spatialRel=esriSpatialRelIntersects"
  outFields = paste0("&outFields=", selected_cols)
  returnGeometry = "&returnGeometry=false"
  file = "&f=json"

  # initial empty df (columns must be identical as in 'selected_cols')
  empty_df = data.frame(godlo = character(),
                        akt_rok = integer(),
                        piksel = numeric(),
                        kolor = character(),
                        zrDanych = character(),
                        ukladXY = character(),
                        #modulArch = character(),
                        #nrZglosz = character(),
                        czy_ark_wypelniony = character(),
                        #daneAktualne = integer(),
                        #daneAktDo10cm = integer(),
                        #lok_orto = character(),
                        url_do_pobrania = character(),
                        idSerie = integer(),
                        sha1 = character(),
                        akt_data = numeric(),
                        #idorto = integer(),
                        nazwa_pliku = character()
                        #ESRI_OID = integer()
  )

  for (i in seq_along(sf::st_geometry(x))) {
    bbox = sf::st_bbox(sf::st_geometry(x)[[i]])

    # user input
    geometry = paste0("geometry={'xmin':", bbox[1], ", 'ymin':", bbox[2], ", ",
                      "'xmax':", bbox[3], ", 'ymax':", bbox[4], ", ",
                      "'spatialReference':{'wkid':", epsg, "}}")

    prepared_URL = paste0(base_URL, geometry, geometryType, spatialRel, outFields,
                          returnGeometry, file)

    output = tryGet(jsonlite::fromJSON(prepared_URL))

    if (any(output %in% c("error", "warning"))) {
      return("connection error")
    }

    output = output$features[[1]]

    # MaxRecordCount: 1000
    if (nrow(output) == 1000) {
      warning("maximum number of records, reduce the area")
    }

    empty_df = rbind(empty_df, output)
  }

  # remove duplicated images
  empty_df = empty_df[!duplicated(empty_df$nazwa_pliku), ]

  # postprocessing
  colnames(empty_df) = c("sheetID", "year", "resolution", "composition",
                         "sensor", "CRS", "isFilled", "URL", "seriesID",
                         "sha1", "date", "filename")
  empty_df$composition = as.factor(empty_df$composition)
  empty_df$date = as.Date(as.POSIXct(empty_df$date / 1000, origin = "1970-01-01", tz = "CET"))
  empty_df$CRS = as.factor(empty_df$CRS)
  empty_df$isFilled = ifelse(empty_df$isFilled == "TAK", TRUE, FALSE)
  empty_df$sensor = factor(empty_df$sensor,
             levels = c("Scena sat.", "Zdj. analogowe", "Zdj. cyfrowe"),
             labels = c("Satellite", "Analog", "Digital"))

  return(empty_df)
}

#' @rdname ortho_request
#' @export
orto_request = ortho_request
