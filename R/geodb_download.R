#' downloads General Geographic Databases for entire voivodeships
#'
#' @param voivodeships selected voivodeships in Polish or English, or TERC
#' (function 'voivodeship_names' can by helpful)
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
#' and technical standards for making maps
#' http://www.gugik.gov.pl/__data/assets/pdf_file/0005/208661/rozp_BDOT10k_BDOO.pdf
#'
#' @examples
#' \donttest{
#' geodb_download(c("mazowieckie", "wielkopolskie"))
#' geodb_download(c("Subcarpathian", "Silesian"))
#' geodb_download(c("02", "16"))
#' }
geodb_download = function(voivodeships, ...) {

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

  URLs = c(
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.02.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.04.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.06.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.08.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.10.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.12.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.14.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.16.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.18.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.20.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.22.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.24.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.26.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.28.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.30.zip",
    "http://opendata.geoportal.gov.pl/bdoo/PL.PZGiK.201.32.zip"
  )

  df_names = cbind(df_names, URL = URLs)

  df_names = df_names[sel_vector, ]

  for (i in seq_len(nrow(df_names))) {
    filename = paste0(df_names[i, type], ".zip")
    utils::download.file(df_names[i, "URL"], filename, mode = "wb", ...)
    utils::unzip(filename)
  }

}
