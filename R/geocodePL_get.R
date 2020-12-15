#' returns a sf data.frame with metadata for a given type of input
#' (geocoding addresses and objects)
#'
#' @param address place with or without street and house number
#' @param road road number with or without mileage
#' @param rail_crossing rail crossing identifier
#' (11 characters including 2 spaces, format: "XXX XXX XXX")
#' @param geoname name of the geographical object from State Register
#' of Geographical Names (function [`geonames_download()`])
#'
#' @return a sf data.frame (EPSG: 2180) with metadata
#'
#' @export
#'
#' @examples
#' \dontrun{
#' geocodePL_get(address = "Marki") # place
#' geocodePL_get(address = "Marki, Andersa") # place and street
#' geocodePL_get(address = "Marki, Andersa 1") # place, street and house number
#' geocodePL_get(address = "Królewskie Brzeziny 13") # place and house number
#'
#' geocodePL_get(road = "632") # road number
#' geocodePL_get(road = "632 55") # road number and mileage
#'
#' geocodePL_get(rail_crossing = "001 018 478")
#'
#' geocodePL_get(geoname = "Las Mierzei") # physiographic object
#' }
geocodePL_get = function(address = NULL, road = NULL, rail_crossing = NULL, geoname = NULL) {

  # geocode address
  if (!is.null(address)) {

    base_URL = "https://services.gugik.gov.pl/uug/?request=GetAddress&address="
    prepared_URL = paste0(base_URL, address)
    prepared_URL = gsub(" ", "%20", prepared_URL)
    output = tryGet(jsonlite::fromJSON(prepared_URL))

    if (any(output %in% c("error", "warning"))) {
      return("connection error")
    }

    output = output[["results"]]

    if (!is.null(output)) {

      # replace NULLs with NAs
      for (i in seq_len(length(output))) {

        null_vec = sapply(output[[i]], is.null)
        output[[i]][null_vec] = NA

      }

      df_output = do.call(rbind.data.frame, output)
      df_output = sf::st_as_sf(df_output, wkt = "geometry_wkt", crs = 2180)
      return(df_output)
    }
  }

  # geocode road
  if (!is.null(road)) {

    base_URL = "https://services.gugik.gov.pl/uug?request=GetRoadMarker&location="
    prepared_URL = paste0(base_URL, road)
    prepared_URL = gsub(" ", "%20", prepared_URL)
    output = tryGet(jsonlite::fromJSON(prepared_URL))

    if (any(output %in% c("error", "warning"))) {
      return("connection error")
    }

    output = output[["results"]]

    if (!is.null(output)) {
      df_output = do.call(rbind.data.frame, output)
      df_output = sf::st_as_sf(df_output, wkt = "geometry_wkt", crs = 2180)
      return(df_output)
    }
  }

  # geocode rail crossing
  if (!is.null(rail_crossing)) {

    if (!nchar(rail_crossing) == 11) {
      stop("rail crossing ID must be 11 characters long")
    } else {

      base_URL = "https://services.gugik.gov.pl/uug/?request=GetLevelCrossing&location="
      prepared_URL = paste0(base_URL, rail_crossing)
      prepared_URL = gsub(" ", "%20", prepared_URL)
      output = tryGet(jsonlite::fromJSON(prepared_URL))

      if (any(output %in% c("error", "warning"))) {
        return("connection error")
      }

      output = output[["results"]]

      if (!is.null(output)) {
        df_output = do.call(rbind.data.frame, output)
        df_output = sf::st_as_sf(df_output, wkt = "geometry_wkt", crs = 2180)
        return(df_output)
      }
    }
  }

  # geocode geographical name
  if (!is.null(geoname)) {

    base_URL = "https://services.gugik.gov.pl/uug/?request=GetLocation&location="
    prepared_URL = paste0(base_URL, geoname)
    prepared_URL = gsub(" ", "%20", prepared_URL)
    output = tryGet(jsonlite::fromJSON(prepared_URL))

    if (any(output %in% c("error", "warning"))) {
      return("connection error")
    }

    output = output[["results"]]

    if (!is.null(output)) {

      # drop "notes" attribute
      output = lapply(output, function(x) {
        x["notes"] = NULL
        return(x)
      })

      df_output = do.call(rbind.data.frame, output)
      df_output = sf::st_as_sf(df_output, wkt = "geometry_wkt", crs = 2180)
      return(df_output)
    }
  }

  # "output" must exist in env
  if (exists("output", inherits = FALSE) && is.null(output)) {
    return("object not found")
  }

  # user did not enter any argument
  stop("all inputs are empty")

}
