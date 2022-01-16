#' @title Download State Register of Borders
#'
#' @param type "administrative units", "special units" or "addresses"
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return a selected data type in SHP format
#'
#' @export
#'
#' @examples
#' \dontrun{
#' borders_download("administrative units") # 375 MB
#' }
borders_download = function(type, outdir = ".", unzip = TRUE, ...) {

  if (length(type) > 1) {
    stop("input only one type")
  }

  correct_type = c("administrative units", "special units", "addresses")
  if (!all(type %in% correct_type)) {
    stop("incorrect type")
  }

  if (type == "administrative units") {
    URL = "ftp://91.223.135.109/prg/jednostki_administracyjne.zip"
  }

  if (type == "special units") {
    URL = "ftp://91.223.135.109/prg/granice_specjalne_shp.zip"
  }

  if (type == "addresses") {
    URL = "https://opendata.geoportal.gov.pl/prg/adresy/PunktyAdresowe/POLSKA.zip"
  }

  if (!dir.exists(outdir)) dir.create(outdir)

  filename = paste0(outdir, "/", type, ".zip")
  status = tryGet(utils::download.file(URL, filename, mode = "wb", ...))

  if (any(status %in% c("error", "warning"))) {
    err_print()
    return(invisible("connection error"))
  }

  if (unzip) {
    utils::unzip(filename, exdir = outdir)
    file.remove(filename)
  }

  # compatibility with download.file() return
  return(invisible(0L))
}
