#' returns a sf data.frame for given an administrative unit or TERYT (ID)
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
#' @export
#'
#' @examples
#' \dontrun{
#' voivodeship_geom = borders_get(voivodeship = "lubuskie")
#' county_geom = borders_get(county = "Sopot")
#' commune_geom = borders_get(commune = c("Hel", "Krynica Morska"))
#' commune_geom = borders_get(TERYT = c("2211011", "2210011"))
#' }
borders_get = function(voivodeship = NULL, county = NULL, commune = NULL,
                       TERYT = NULL) {

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

  if (!is.null(TERYT)) {

    if (!nchar(TERYT) %in% c(2, 4, 7)) {
      stop("'TERYT' length should be 2, 4 or 7")
    }

    if (nchar(TERYT) == 2) {
      request = "GetVoivodeshipById"
    }

    if (nchar(TERYT) == 4) {
      request = "GetCountyById"
    }

    if (nchar(TERYT) == 7) {
      # process commune TERYT to specific form (XXXXXX_X)
      ID = paste0(substr(TERYT, 1, 6), "_", substr(TERYT, 7, 7))
      request = "GetCommuneById"
    }

  }

  result = "geom_wkb"
  geometry = st_sfc(st_polygon(), crs = 2180)

  for (i in seq_len(length(ID))) {

    prepared_URL = paste0("https://uldk.gugik.gov.pl/?request=", request,
                          "&id=", ID[i],
                          "&result=", result)

    output = readLines(prepared_URL, warn = FALSE)
    output = output[2]
    wkb = structure(list(output), class = "WKB")
    single_geom = sf::st_as_sfc(wkb, EWKB = TRUE, crs = 2180)
    geometry = c(geometry, single_geom)

  }

  df_geom = sf::st_sf(geometry)
  df_geom = df_geom[-1, ] # drop empty geometry

  # geometry is returned in EPSG: 2180
  return(df_geom)
}
