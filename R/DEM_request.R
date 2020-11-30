#' returns a data frame with metadata and links to the Digital Elevation Models
#' in a given polygon
#'
#' @param polygon the polygon layer (may consist of n objects)
#'
#' @return a data frame with metadata and links to the Digital Elevation Models
#' (different formats of Digital Terrain Model, Digital Surface Model and
#' point clouds)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#' req_df = DEM_request(polygon)
#'
#' # simple filtering by attributes
#' req_df = req_df[req_df$year > 2018, ]
#' req_df = req_df[req_df$product == "PointCloud" & req_df$format == "LAS", ]
#' }
DEM_request = function(polygon) {

  if (nrow(polygon) == 0) {
    stop("no geometries")
  }

  selected_cols = c("godlo", "akt_rok", "format", "charPrzest", "bladSrWys",
                    "ukladXY", "ukladH", "czy_ark_wypelniony", "url_do_pobrania",
                    "nazwa_pliku", "idSerie", "sha1", "asortyment")
  selected_cols = paste(selected_cols, collapse = ",")

  epsg = sf::st_crs(polygon)$epsg

  # hard coded URL and parameters
  base_URL = "https://mapy.geoportal.gov.pl/gprest/services/SkorowidzeFOTOMF/MapServer/1/query?"
  geometryType = "&geometryType=esriGeometryEnvelope"
  spatialRel = "&spatialRel=esriSpatialRelIntersects"
  outFields = paste0("&outFields=", selected_cols)
  returnGeometry = "&returnGeometry=false"
  file = "&f=json"

  # initial empty df (columns must be identical as in 'selected_cols')
  empty_df = data.frame(godlo = character(),
                        akt_rok = integer(),
                        format = character(),
                        charPrzest = character(),
                        bladSrWys = numeric(),
                        ukladXY = character(),
                        #modulArch = character(),
                        ukladH = character(),
                        #nrZglosz = character(),
                        czy_ark_wypelniony = character(),
                        #daneAktualne = integer(),
                        #lok_nmt = character(),
                        url_do_pobrania = character(),
                        nazwa_pliku = character(),
                        #idNmt = integer(),
                        idSerie = integer(),
                        sha1 = character(),
                        asortyment = character()
  )

  for (i in seq_len(nrow(polygon))) {
    bbox = sf::st_bbox(sf::st_geometry(polygon)[[i]])

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
  colnames(empty_df) = c("sheetID", "year", "format", "resolution", "avgElevErr",
                         "CRS", "VRS", "isFilled", "URL", "filename", "seriesID",
                         "sha1", "product")
  empty_df$CRS = as.factor(empty_df$CRS)
  empty_df$VRS = as.factor(empty_df$VRS)
  empty_df$isFilled = ifelse(empty_df$isFilled == "TAK", TRUE, FALSE)
  empty_df$product = factor(empty_df$product,
                            levels = c("Dane NMPT", "Dane NMT", "Dane pomiarowe NMT"),
                            labels = c("DSM", "DTM", "PointCloud"))

  return(empty_df)
}
