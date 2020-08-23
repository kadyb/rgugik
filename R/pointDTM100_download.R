#' downloads Digital Terrain Models with 100 m resolution for entire voivodeships
#'
#' @param voivodeships selected voivodeships in Polish or English, or TERC
#' (function 'voivodeship_names' can by helpful)
#' @param outdir (optional) name of the output directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will be extracted and removed
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return text files with X, Y, Z columns (EPSG:2180)
#'
#' @export
#'
#' @examples
#' \donttest{
#' pointDTM100_download(c("mazowieckie", "wielkopolskie"))
#' pointDTM100_download(c("Subcarpathian", "Silesian"))
#' pointDTM100_download(c("02", "16"))
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

  URLs = c("ftp://91.223.135.109/nmt/dolnoslaskie_grid100.zip",
           "ftp://91.223.135.109/nmt/kujawsko-pomorskie_grid100.zip",
           "ftp://91.223.135.109/nmt/lubelskie_grid100.zip",
           "ftp://91.223.135.109/nmt/lubuskie_grid100.zip",
           "ftp://91.223.135.109/nmt/lodzkie_grid100.zip",
           "ftp://91.223.135.109/nmt/malopolskie_grid100.zip",
           "ftp://91.223.135.109/nmt/mazowieckie_grid100.zip",
           "ftp://91.223.135.109/nmt/opolskie_grid100.zip",
           "ftp://91.223.135.109/nmt/podkarpackie_grid100.zip",
           "ftp://91.223.135.109/nmt/podlaskie_grid100.zip",
           "ftp://91.223.135.109/nmt/pomorskie_grid100.zip",
           "ftp://91.223.135.109/nmt/slaskie_grid100.zip",
           "ftp://91.223.135.109/nmt/swietokrzyskie_grid100.zip",
           "ftp://91.223.135.109/nmt/warminsko-mazurskie_grid100.zip",
           "ftp://91.223.135.109/nmt/wielkopolskie_grid100.zip",
           "ftp://91.223.135.109/nmt/zachodniopomorskie_grid100.zip")

  df_names = cbind(df_names, URL = URLs)

  df_names = df_names[sel_vector, ]

  if (!dir.exists(outdir)) dir.create(outdir)

  for (i in seq_len(nrow(df_names))) {
    filename = paste0(outdir, "/", df_names[i, type], ".zip")
    utils::download.file(df_names[i, "URL"], filename, mode = "wb", ...)
    if (unzip) {
      utils::unzip(filename, exdir = outdir)
      file.remove(filename)
    }
  }

}
