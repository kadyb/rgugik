#' @title Download digital terrain models for voivodeships (100 m resolution)
#'
#' @param voivodeships selected voivodeships in Polish or English, or TERC
#' (function [`voivodeship_names()`] can by helpful)
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return text files with X, Y, Z columns (EPSG:2180)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' pointDTM100_download(c("opolskie", "świętokrzyskie")) # 8.5 MB
#' pointDTM100_download(c("Opole", "Swietokrzyskie")) # 8.5 MB
#' pointDTM100_download(c("16", "26")) # 8.5 MB
#' }
pointDTM100_download = function(voivodeships, outdir = ".", unzip = TRUE, ...) {

  if (!is.character(voivodeships) | length(voivodeships) == 0) {
    stop("enter names or TERC")
  }

  df_names = rgugik::voivodeship_names

  type = character()
  sel_vector = logical()

  if (all(voivodeships %in% df_names[, "NAME_PL"])) {

    sel_vector = df_names[, "NAME_PL"] %in% voivodeships
    type = "NAME_PL"

  } else if (all(voivodeships %in% df_names[, "NAME_EN"])) {

    sel_vector = df_names[, "NAME_EN"] %in% voivodeships
    type = "NAME_EN"

  } else if (all(voivodeships %in% df_names[, "TERC"])) {

    sel_vector = df_names[, "TERC"] %in% voivodeships
    type = "TERC"

  } else {
    stop("invalid names or TERC, please use 'voivodeships_names' function")
  }

  # generate URLs using voivodeship NAME_PL
  # first convert polish characters to ASCII
  df_names$NAME_PL = iconv(df_names$NAME_PL, "WINDOWS-1250", "ASCII//TRANSLIT")
  URLs = paste0("https://opendata.geoportal.gov.pl/NumDaneWys/NMT_100/ASCII_XYZ/",
                df_names$NAME_PL, "_grid100.zip")

  df_names = cbind(df_names, URL = URLs, stringsAsFactors = FALSE)

  df_names = df_names[sel_vector, ]

  if (!dir.exists(outdir)) dir.create(outdir)

  for (i in seq_len(nrow(df_names))) {
    filename = paste0(outdir, "/", df_names[i, type], ".zip")
    status = tryGet(utils::download.file(df_names[i, "URL"], filename, mode = "wb", ...))

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
