#' downloads 3D models of buildings for counties
#'
#' @param county county name in Polish. Check [`county_names()`] function.
#' @param TERYT county ID (4 characters)
#' @param LOD level of detail for building models ("LOD1" or "LOD2").
#' "LOD1" is default. "LOD2" is only available for ten voivodeships
#' (TERC: "04", "06", "12", "14", "16", "18", "20", "24", "26", "28").
#' Check [`voivodeship_names()`] function.
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return models of buildings in Geography Markup Language format (.GML)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' models3D_download(TERYT = c("2476", "2264")) # 3.6 MB
#' models3D_download(county = "sejneński", LOD = "LOD2") # 7.0 MB
#' }
models3D_download = function(county = NULL, TERYT = NULL, LOD = "LOD1",
                             outdir = ".", unzip = TRUE, ...) {

  df_names = rgugik::county_names

  if (is.null(county) && is.null(TERYT)) {
    stop("'county' and 'TERYT' are empty")
  }

  if (!is.null(county) && !is.null(TERYT)) {
    stop("use only one input")
  }

  if (!all(county %in% df_names$NAME)) {
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
    sel_vector = df_names[, "NAME"] %in% county
    df_names = df_names[sel_vector, ]
  } else {
    sel_vector = df_names[, "TERYT"] %in% TERYT
    df_names = df_names[sel_vector, ]
  }

  # detect missing LOD2 counties
  if (LOD == "LOD2" && sum(df_names$LOD2) != nrow(df_names)) {
    warning("LOD2 is unavibile, trying drop missing counties", immediate. = TRUE)
    df_names = df_names[df_names$LOD2 == TRUE, ]
    if (nrow(df_names == 0)) {
      stop("LOD2 is unavibile, use 'LOD1'")
    }
  }

  if (!dir.exists(outdir)) dir.create(outdir)

  for (i in seq_len(nrow(df_names))) {
    prepared_URL = paste0(base_URL, df_names[i, "TERYT"], "_gml.zip")
    filename = paste0(outdir, "/", df_names[i, "TERYT"], "_gml.zip")
    status = tryGet(utils::download.file(prepared_URL, filename, mode = "wb", ...))

    if (any(status %in% c("error", "warning"))) {
      return("connection error")
    }

    if (unzip) {
      # remove ".zip" from filename and use it as exdir
      exdir_name = substr(filename, 1, nchar(filename) - 4)
      utils::unzip(filename, exdir = exdir_name, junkpaths = TRUE)
      file.remove(filename)
    }
  }

}
