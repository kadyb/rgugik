#' @title Download Register of Towns, Streets and Addresses for communes
#'
#' @param commune commune name in Polish. Check [`commune_names()`] function.
#' @param TERYT county ID (7 characters)
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return a register in SHP format
#'
#' @export
#'
#' @examples
#' \dontrun{
#' emuia_download(commune = "Kotla") # 38 KB
#' emuia_download(TERYT = c("0203042", "2412032")) # 75 KB
#' }
emuia_download = function(commune = NULL, TERYT = NULL, outdir = ".",
                          unzip = TRUE, ...) {

  df_names = rgugik::commune_names

  if (is.null(commune) && is.null(TERYT)) {
    stop("'commune' and 'TERYT' are empty")
  }

  if (!is.null(commune) && !is.null(TERYT)) {
    stop("use only one input")
  }

  if (!all(commune %in% df_names$NAME)) {
    stop("incorrect county name")
  }

  if (!is.null(TERYT) && any(nchar(TERYT) != 7)) {
    stop("incorrect TERYT")
  }

  if (!is.null(commune)) {
    sel_vector = df_names[["NAME"]] %in% commune
    df_names = df_names[sel_vector, ]
  } else {
    sel_vector = df_names[["TERYT"]] %in% TERYT
    df_names = df_names[sel_vector, ]
  }

  # first 6 characters are significant (required)
  df_names$TERYT = substr(df_names$TERYT, 1, 6)

  URLs = paste0("https://integracja.gugik.gov.pl/PRG/pobierz.php?teryt=",
                df_names$TERYT, "&adresy")

  df_names = cbind(df_names, URL = URLs, stringsAsFactors = FALSE)

  if (!dir.exists(outdir)) dir.create(outdir)

  for (i in seq_len(nrow(df_names))) {
    filename = paste0(outdir, "/", df_names[i, "TERYT"], ".zip")
    status = tryGet(utils::download.file(df_names[i, "URL"], filename, mode = "wb", ...))

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
