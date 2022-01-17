#' @title Get metadata and links to available digital elevation models
#'
#' @param x an `sf`, `sfc` or `SpatVector` object with one or more features
#' (requests are based on the bounding boxes of the provided features)
#'
#' @return a data frame with metadata and links to the digital elevation models
#' (different formats of digital terrain model, digital surface model and
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
DEM_request = function(x) {

  if (inherits(x, "sf")) x = sf::st_geometry(x)
  if (length(x) == 0) stop("no geometries")

  if (inherits(x, "SpatVector")) {
    epsg = terra::crs(x, describe = TRUE)$epsg
  } else {
    epsg = sf::st_crs(x)$epsg
  }

  selected_cols = c("godlo", "akt_rok", "format", "charPrzest", "bladSrWys",
                    "ukladXY", "ukladH", "czy_ark_wypelniony", "url_do_pobrania",
                    "nazwa_pliku", "idSerie", "sha1", "asortyment")
  selected_cols = paste(selected_cols, collapse = ",")

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

  for (i in seq_along(x)) {

    if (inherits(x, "SpatVector")) {
      bbox = as.vector(terra::ext(x[i]))
    } else {
      # sfc class
      bbox = sf::st_bbox(x[i])
    }

    # user input
    geometry = paste0("geometry={'xmin':", bbox["xmin"], ",", "'ymin':",
                      bbox["ymin"], ",", "'xmax':", bbox["xmax"], ",", "'ymax':",
                      bbox["ymax"], ",", "'spatialReference':{'wkid':", epsg, "}}")

    prepared_URL = paste0(base_URL, geometry, geometryType, spatialRel, outFields,
                          returnGeometry, file)

    output = tryGet(jsonlite::fromJSON(prepared_URL))

    if (any(output %in% c("error", "warning"))) {
      return(invisible("connection error"))
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
