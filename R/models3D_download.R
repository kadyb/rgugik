#' downloads 3D models of buildings for counties
#'
#' @param county county name in Polish
#' @param TERYT county ID (4 characters)
#' @param LOD level of detail for building models ("LOD1" or "LOD2").
#' "LOD1" is default. "LOD2" is only available for ten voivodeships
#' (TERC: "04", "06", "12", "14", "16", "18", "20", "24", "26", "28").
#' Check 'voivodeships_names' function.
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return models of buildings in Geography Markup Language format (.GML)
#'
#' @export
#'
#' @examples
#' \donttest{
#' models3D_download(county = "Toruń")
#' models3D_download(TERYT = c("2462", "0401"), LOD = "LOD2")
#' }
models3D_download = function(county = NULL, TERYT = NULL, LOD = "LOD1", ...) {

  load("data/TERYT_county.rda", package = "rgugik")

  if (is.null(county) && is.null(TERYT)) {
    stop("'county' and 'TERYT' are empty")
  }

  if (!is.null(county) && !is.null(TERYT)) {
    stop("use only one input")
  }

  if (!all(county %in% TERYT_county$NAZWA)) {
    stop("incorrect county name")
  }

  if (!is.null(TERYT) && any(nchar(TERYT) != 4)) {
    stop("incorrect TERYT")
  }

  if (!LOD %in% c("LOD1", "LOD2")) {
    stop("inncorect LOD, should be 'LOD1' or 'LOD2'")
  }

  if (LOD == "LOD1") {
    base_URL = "https://integracja.gugik.gov.pl/Budynki3D/pobierz.php?plik=powiaty/lod1/"
  } else {
    # LOD 2
    base_URL = "https://integracja.gugik.gov.pl/Budynki3D/pobierz.php?plik=powiaty/"
  }

  if (!is.null(county)) {
    sel_vector = TERYT_county[, "NAZWA"] %in% county
    TERYT_county = TERYT_county[sel_vector, ]
  } else {
    sel_vector = TERYT_county[, "TERYT"] %in% TERYT
    TERYT_county = TERYT_county[sel_vector, ]
  }

  # detect missing LOD2 counties
  if (LOD == "LOD2" && sum(TERYT_county$LOD2) != nrow(TERYT_county)) {
    warning("LOD2 is unavibile, trying drop missing counties", immediate. = TRUE)
    TERYT_county = TERYT_county[TERYT_county$LOD2 == TRUE, ]
    if (nrow(TERYT_county == 0)) {
      stop("LOD2 is unavibile, use 'LOD1'")
    }
  }

  for (i in seq_len(nrow(TERYT_county))) {
    prepared_URL = paste0(base_URL, TERYT_county[i, "TERYT"], "_gml.zip")
    filename = paste0(TERYT_county[i, "TERYT"], "_gml.zip")
    utils::download.file(prepared_URL, filename, mode = "wb", ...)
    utils::unzip(filename)
  }

}
