#' @title Download Topographic Databases for counties
#'
#' @param county county name in Polish. Check [`county_names()`] function.
#' @param TERYT county ID (4 characters)
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return a database in Geography Markup Language format (.GML),
#' the content and detail level corresponds to the topographic map
#' in the scale of 1:10000
#'
#' @export
#'
#' @references
#' description of topographical and general geographical databases,
#' and technical standards for making maps (in Polish):
#' \url{http://www.gugik.gov.pl/__data/assets/pdf_file/0005/208661/rozp_BDOT10k_BDOO.pdf}
#'
#' brief description of categories and layer names (in English and Polish):
#' \url{https://kadyb.github.io/rgugik/articles/articles/spatialdb_description.html}
#'
#' @examples
#' \dontrun{
#' topodb_download(county = "Świętochłowice") # 2.4 MB
#' topodb_download(TERYT = c("2476", "2264")) # 4.8 MB
#' }
topodb_download = function(county = NULL, TERYT = NULL, outdir = ".",
                           unzip = TRUE, ...) {

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

  base_URL = "https://opendata.geoportal.gov.pl/bdot10k/"

  if (!is.null(county)) {
    sel_vector = df_names[, "NAME"] %in% county
    df_names = df_names[sel_vector, ]
  } else {
    sel_vector = df_names[, "TERYT"] %in% TERYT
    df_names = df_names[sel_vector, ]
  }

  if (!dir.exists(outdir)) dir.create(outdir)

  for (i in seq_len(nrow(df_names))) {

    TERYT_voivodeship = substr(df_names[i, "TERYT"], 1, 2)

    prepared_URL = paste0(base_URL, TERYT_voivodeship, "/",
                          df_names[i, "TERYT"], "_GML.zip")
    filename = paste0(outdir, "/", df_names[i, "TERYT"], ".zip")
    status = tryGet(utils::download.file(prepared_URL, filename, mode = "wb", ...))

    if (any(status %in% c("error", "warning"))) {
      err_print()
      return("connection error")
    }

    if (unzip) {
      utils::unzip(filename, exdir = outdir)
      file.remove(filename)
    }
  }

}
