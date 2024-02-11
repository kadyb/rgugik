#' @title Get metadata and links to available orthoimages
#'
#' @param x an `sf`, `sfc` or `SpatVector` object with one or more features
#' (requests are based on the bounding boxes of the provided features)
#'
#' @details
#' The server can return a maximum of 1000 records in a single query.
#' If your area of interest exceeds this limit, you can generate a grid of
#' smaller polygons ([`sf::st_make_grid()`]) or a regular grid of points
#' ([`sf::st_sample()`]).
#'
#' @return a data frame with metadata and links to the orthoimages
#'
#' @seealso [`tile_download()`]
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

  if (inherits(x, "sf")) x = sf::st_geometry(x)
  if (length(x) == 0) stop("no geometries")

  if (inherits(x, "SpatVector")) {
    epsg = terra::crs(x, describe = TRUE)$epsg
  } else {
    epsg = sf::st_crs(x)$epsg
  }

  selected_cols = c("godlo", "akt_rok", "piksel", "kolor", "zr_danych", "uklad_xy",
                    "akt_data", "czy_ark_wypelniony", "url_do_pobrania",
                    "nazwa_pliku", "id_serie")
  selected_cols = paste(selected_cols, collapse = ",")

  # hard coded URL and parameters
  base_URL = "https://mapy.geoportal.gov.pl/gprest/services/SkorowidzeFOTOMF/MapServer/3/query?"
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
                        zr_danych = character(),
                        uklad_xy = character(),
                        #modul_arch = character(),
                        #nr_zglosz = character(),
                        akt_data = numeric(),
                        #akt_dzien = character(),
                        czy_ark_wypelniony = character(),
                        #dane_aktualne = integer(),
                        #dane_aktualne_do_10cm = integer(),
                        #lok_orto = character(),
                        url_do_pobrania = character(),
                        nazwa_pliku = character(),
                        #url_zfs = character(),
                        #id_orto = integer(),
                        id_serie = integer(),
                        stringsAsFactors = FALSE
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
  colnames(empty_df) = c("sheetID", "year", "resolution", "composition",
                         "sensor", "CRS", "date", "isFilled", "URL",
                         "filename", "seriesID")
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
