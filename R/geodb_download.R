#' @title Download General Geographic Databases for entire voivodeships
#'
#' @param voivodeships selected voivodeships in Polish or English, or TERC
#' (object [`voivodeship_names`] can by helpful)
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return a database in Geography Markup Language format (.GML),
#' the content and detail level corresponds to the general
#' geographic map in the scale of 1:250000
#'
#' @export
#'
#' @references
#' description of topographical and general geographical databases,
#' and technical standards for making maps (in Polish):
#' \url{https://isap.sejm.gov.pl/isap.nsf/download.xsp/WDU20210001412/O/D20211412.pdf}
#'
#' brief description of categories and layer names (in English and Polish):
#' \url{https://kadyb.github.io/rgugik/articles/articles/spatialdb_description.html}
#'
#' @examples
#' \dontrun{
#' geodb_download(c("opolskie", "lubuskie")) # 12.7 MB
#' geodb_download(c("Opole", "Lubusz")) # 12.7 MB
#' geodb_download(c("16", "08")) # 12.7 MB
#' }
geodb_download = function(voivodeships, outdir = ".", unzip = TRUE, ...) {

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
    stop("invalid names or TERC, please use 'voivodeship_names()' function")
  }

  # generate URLs using voivodeship TERC
  URLs = paste0("http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.",
                df_names$TERC, ".zip")

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
