#' @title Download Land and Building Register (EGiB) layers
#'
#' @param county County name in Polish. Check [`county_names()`] function.
#' @param TERYT County ID (4 characters).
#' @param layer Requested layer, `parcels` default. Other common layer is `buildings` (budynki).
#' You can check available layers by [`egib_layers()`] data set.
#' @param outdir name of the output directory where the data has to be stored,
#' current directory by default. If you don't want to download data, pass a `NULL` value.
#' @param ... any other parameter passed to [`sf::read_sf()`] function
#'
#' @return Simple feature data frame of objects for requested layer.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' parcels <- egib_download(county = "Świętochłowice", layer = "parcels", outdir = NULL) # 3.9 MB
#' egib_download(TERYT = c("2476", "2264"), layer = "buildings", outdir = ".") # 2.2 + 2.6 MB
#' }
#'
#' @references
#' The EGiB data (Ewidencja Gruntów i Budynków) consist of 2 primary layers:
#' cadastral data (parcels, "dzialki" in Polish) and buildings footprints (budynki).
#' The data is maintained on county level, which results in 380 units/different
#' sources of data. It may contain additional layers like points of detailed
#' horizontal and vertical geodetic control network (osnowa_pozioma
#' and osnowa_pionowa respectively).
#'
#' \url{https://www.geoportal.gov.pl/en/data/land-and-building-register-egib/}
#' \url{https://www.geoportal.gov.pl/en/data/detailed-control-network-database-bdsog/}

egib_download <- function(county = NULL, TERYT = NULL, layer = "parcels", outdir = ".", ...) {

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

  switch(layer,
         parcels = {
           layer <- "dzialki" },
         buildings = {
           layer <- "budynki" },
         {
           layer <- layer
         }
  )

  if (!is.null(county)) {
    sel_vector <- layer_names[, "NAME"] %in% county
    layer_names <- layer_names[sel_vector, ]
    layer_names <- layer_names[match(county, layer_names$NAME),]

    if(any(duplicated(layer_names$NAME))) {
      dup <- which(duplicated(layer_names$NAME))

      message("There are counties with the same name, both will be downloaded.")
      message("If you would like to avoid it, please provide TERYT instead.")

      layer_names[layer_names$NAME == layer_names[dup, "NAME"], 1:2]
    }

  } else {
    sel_vector <- layer_names[, "TERYT"] %in% TERYT
    layer_names = layer_names[sel_vector, ]
    layer_names <- layer_names[match(TERYT, layer_names$TERYT),]

  }

  if(nrow(layer_names > 1L) & is.null(outdir)) {
    message("There is more than one county provided, however you didn't specified the output directory.")
    message("Only the first will be taken.")
    layer_names <- layer_names[1, ]
  }

  for (k in seq_len(nrow(layer_names))) {
    print(k)

    TERYT <- layer_names[k, "TERYT"]
    county_name <- layer_names[k, "NAME"]

    layers <- layer_names[k, "LAYERS"] |>
      strsplit(split = ", ") |>
      as.list()
    layers <- layers[[1]]

    egib_url <- layer_names[k, "URL"]

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

      message(paste("Downloading layer", layer, "for", county_name, "county. TERYT:", TERYT))

      output <- tryGet(sf::read_sf(dsn = egib_url, layer = layer,
                                   options = "CONSIDER_EPSG_AS_URN=YES", ...))

      if (any(output %in% c("error", "warning"))) {
        return(invisible("connection error"))
      }

      if(!is.null(outdir)) {
        outfile <- paste0(outdir, "/", TERYT, ".gpkg")
        message(paste("Writing the data to", outfile))
        sf::write_sf(output, dsn = outfile, layer = layer, append = FALSE)
      }
    }
  }
  return(output)
}
