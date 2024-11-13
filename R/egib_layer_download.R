#' @title Download Land and Building Register (EGiB) layers
#'
#' @param county County name in Polish. Check [`county_names()`] function.
#' @param TERYT County ID (4 characters).
#' @param layer Requested layer, `dzialki` (parcels)default. Other common layer is `budynki` (buildings).
#' You can check available layers by [`egib_layers()`] data set.
#' @param outdir (Optional) name of the output directory where the data has to be stored;
#' NULL by default.
#' @param ... any other parameter passed to [`sf::st_read()`] function
#'
#' @return Simple feature data frame of objects for requested layer.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' parcels <- egib_layer_download(county = "wołowski", layer = "dzialki")
#' buildings <- egib_layer_download(county = "milicki", layer = "budynki", outdir = ".")
#' }
#'
#' @references
#' The EGiB data (Ewidencja Gruntów i Budynków) consist of 2 primary layers:
#' cadastral data (often called dzialki) and buildings footprints (budynki).
#' The data is maintained on county level, which results in 380 units/different
#' sources of data. It may contain additional layers like points of detailed
#' horizontal and vertical geodetic control network (osnowa_pozioma
#' and osnowa_pionowa respectively).
#'
#' \url{https://www.geoportal.gov.pl/en/data/land-and-building-register-egib/}
#' \url{https://www.geoportal.gov.pl/en/data/detailed-control-network-database-bdsog/}
#'


# county <- "trzebnicki"
# # # county <- "Łomża"
# TERYT <- NULL
# layer <- "Osnowa"
# outdir <- "~/Downloads/"

egib_layer_download <- function(county = NULL, TERYT = NULL, layer = "dzialki", outdir = NULL, ...) {

  layer_names = rgugik::egib_layers

  if (is.null(county) && is.null(TERYT)) {
    stop("'county' and 'TERYT' are empty")
  }

  if (!is.null(county) && !is.null(TERYT)) {
    stop("use only one input")
  }

  if (!all(county %in% layer_names$NAME)) {
    stop("incorrect county name")
  }

  if (!is.null(TERYT) && any(nchar(TERYT) != 4)) {
    stop("incorrect TERYT")
  }

  if (length(layer) > 1L) {
    stop("please provide only one layer at time")
  }

  if (is.null(TERYT)) {
    TERYT <- layer_names$TERYT[layer_names$NAME == county]
  }

  layers <- layer_names$LAYERS[layer_names$TERYT == TERYT] |>
    strsplit(split = ", ") |>
    as.list()
  layers <- layers[[1]]

  egib_url <- layer_names$URL[layer_names$TERYT == TERYT]

  if (all(is.na(layers))) {
    a <- ""
    if(!is.na(egib_url)) {
      a <- paste("You might try to check", egib_url, "using st_layers() directly.")
    }
    stop(paste0("there is no layers available for time being\n", a))
  }

  if(!any(grepl(layer, layers))) {
    stop(paste("Can't find", layer, "in", paste0(unlist(layers),  collapse = ", ")))
  }

  if(any(grepl(layer, layers))) {
    layer <- layers[which(grepl(layer, layers))]
    if(length(layer) > 1L) {
      stop(paste0("There is more than 1 layer simillar to requested: ",
                    paste0(unlist(layer), collapse = ", "), ". Please specify."))
    }
    egib_url <- paste0("WFS:", egib_url)
    output <- tryGet(sf::st_read(dsn = egib_url, layer = layer,
                                 options = "CONSIDER_EPSG_AS_URN=YES", ...))

    if (any(output %in% c("error", "warning"))) {
      return(invisible("connection error"))
    }

    if(!is.null(outdir)) {
      outfile <- paste0(outdir, "/", TERYT, ".gpkg")
      message(paste("Writing the data to", outfile))
      sf::st_write(output, dsn = outfile, layer = layer, append = FALSE)
    }
  }
  return(output)
}
