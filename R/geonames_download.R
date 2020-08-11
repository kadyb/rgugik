#' downloads State Register of Geographical Names
#'
#' @param type names of places ("place") and/or physiographic objects ("object")
#' @param format data format ("GML", "SHP" and/or "XLSX")
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return a selected data type in the specified format
#'
#' @export
#'
#' @references
#' \url{http://isap.sejm.gov.pl/isap.nsf/download.xsp/WDU20150000219/O/D20150219.pdf}
#'
#' @examples
#' \donttest{
#' geonames_download(type = c("place", "object"), format = "SHP")
#' geonames_download(type = "object", format = c("GML", "XSLX"))
#' }
geonames_download = function(type, format, ...) {

  if (!any(type %in% c("place", "object"))) {
    stop("incorrect type, should be 'place' or 'object'")
  }

  if (!any(format %in% c("GML", "SHP", "XLSX"))) {
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

  for (i in seq_len(nrow(df))) {
    filename = paste0(df[i, "type"], "_", df[i, "format"], ".zip")
    utils::download.file(df[i, "URL"], filename, mode = "wb", ...)
    utils::unzip(filename)
  }

}
