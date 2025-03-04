#' @title Download State Register of Geographical Names
#'
#' @param type names of places ("place") and/or physiographic objects ("object")
#' @param format data format ("GML", "SHP" (default) and/or "XLSX")
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return a selected data type in the specified format
#'
#' @export
#'
#' @references
#' \url{https://isap.sejm.gov.pl/isap.nsf/download.xsp/WDU20150000219/O/D20150219.pdf}
#'
#' @examples
#' \dontrun{
#' geonames_download(type = "place", format = "SHP") # 18.2 MB
#' }
geonames_download = function(type, format = "SHP", outdir = ".", unzip = TRUE, ...) {

  if (!all(type %in% c("place", "object"))) {
    stop("incorrect type, should be 'place' or 'object'")
  }

  if (!all(format %in% c("GML", "SHP", "XLSX"))) {
    stop("incorrect format, should be 'GML', 'SHP' or 'XLSX'")
  }

  formats = c("GML", "SHP", "XLSX")
  types = c("place", "object")
  place_URL = "ftp://91.223.135.109/prng/PRNG_MIEJSCOWOSCI_" # missing format
  object_URL = "ftp://91.223.135.109/prng/PRNG_OBIEKTY_FIZJOGRAFICZNE_" # missing format

  # prepare correct URLs
  df = data.frame(type = rep(types, each = 3),
                  format = rep(formats, times = 2),
                  URL = c(paste0(place_URL, formats, ".zip"),
                          paste0(object_URL, formats, ".zip"))
                  )

  sel = (df[, "type"] %in% type) * (df[, "format"] %in% format)
  sel = as.logical(sel)

  df = df[sel, ]

  if (!dir.exists(outdir)) dir.create(outdir)

  for (i in seq_len(nrow(df))) {
    filename = paste0(outdir, "/", df[i, "type"], "_",
                      df[i, "format"], ".zip")
    status = tryGet(utils::download.file(df[i, "URL"], filename, mode = "wb", ...))

    if (any(status %in% c("error", "warning"))) {
      err_print()
      return(invisible("connection error"))
    }

    if (unzip) {
      utils::unzip(filename, exdir = outdir)
      file.remove(filename)
    }
  }

}
