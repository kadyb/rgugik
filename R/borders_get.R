#' @title Get the boundaries of administrative units
#'
#' @param voivodeship selected voivodeships in Polish.
#' Check [`voivodeship_names()`] function
#' @param county county names in Polish.
#' Check [`county_names()`] function
#' @param commune commune names in Polish.
#' Check [`commune_names()`] function
#' @param TERYT voivodeships, counties or communes (2, 4 or 7 characters)
#'
#' @return a sf data.frame (EPSG: 2180)
#'
#' @details If all arguments are NULL (default),
#' the boundary of Poland will be returned.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' voivodeship_geom = borders_get(voivodeship = "lubuskie") # 494 KB
#' county_geom = borders_get(county = "Sopot") # 18 KB
#' commune_geom = borders_get(commune = c("Hel", "Krynica Morska")) # 11 KB
#' poland_geom = borders_get() # 1124.3 KB
#' }
borders_get = function(voivodeship = NULL, county = NULL, commune = NULL,
                       TERYT = NULL) {

  if (all(is.null(c(voivodeship, county, commune, TERYT)))) {

    poland = borders_get(voivodeship = rgugik::voivodeship_names[, 1])
    poland = sf::st_union(poland, is_coverage = TRUE)
    return(sf::st_sf(geom = poland))

  } else {

    if (!is.null(voivodeship)) {

      request = "GetVoivodeshipById"
      df_names = rgugik::voivodeship_names
      sel_vector = df_names[["NAME_PL"]] %in% voivodeship
      ID = df_names[sel_vector, "TERC", drop = TRUE]

    }

    if (!is.null(county)) {

      request = "GetCountyById"
      df_names = rgugik::county_names
      sel_vector = df_names[["NAME"]] %in% county
      ID = df_names[sel_vector, "TERYT", drop = TRUE]

    }

    if (!is.null(commune)) {

      request = "GetCommuneById"
      df_names = rgugik::commune_names
      sel_vector = df_names[["NAME"]] %in% commune
      ID = df_names[sel_vector, "TERYT", drop = TRUE]

    }

    # TERYT and ID are the same but inside fun must be as different objects
    if (!is.null(TERYT)) {

      if (!all(nchar(TERYT) %in% c(2, 4, 7))) {
        stop("'TERYT' length should be 2, 4 or 7")
      }

      if (all(nchar(TERYT) == 2)) {
        request = "GetVoivodeshipById"
        ID = TERYT
      }

      if (all(nchar(TERYT) == 4)) {
        request = "GetCountyById"
        ID = TERYT
      }

      if (all(nchar(TERYT) == 7)) {
        # process commune TERYT to specific form (XXXXXX_X)
        ID = paste0(substr(TERYT, 1, 6), "_", substr(TERYT, 7, 7))
        request = "GetCommuneById"
      }

    }

    result = "geom_wkb"
    geometry = vector("list", length(ID))

    for (i in seq_len(length(ID))) {

      prepared_URL = paste0("https://uldk.gugik.gov.pl/?request=", request,
                            "&id=", ID[i],
                            "&result=", result)

      output = tryGet(readLines(prepared_URL, warn = FALSE))

      if (any(output %in% c("error", "warning"))) {
        return(invisible("connection error"))
      }

      output = output[2]
      wkb = structure(list(output), class = "WKB")
      geometry[[i]] = sf::st_as_sfc(wkb, EWKB = TRUE, crs = 2180)

    }

    df_geom = do.call(c, geometry)
    df_geom = sf::st_sf(geom = df_geom)
    df_geom = cbind(df_geom, TERYT = ID)

    # geometry is returned in EPSG: 2180
    return(df_geom)
  }
}
