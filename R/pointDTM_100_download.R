#' Title
#'
#' @param voivodeship
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
pointDTM_100_download = function(voivodeship, ...) {

  voivodeship_pl = c("dolnośląskie",
                     "kujawsko-pomorskie",
                     "lubelskie",
                     "lubuskie",
                     "łódzkie",
                     "małopolskie",
                     "mazowieckie",
                     "opolskie",
                     "podkarpackie",
                     "podlaskie",
                     "pomorskie",
                     "śląskie",
                     "świętokrzyskie",
                     "warmińsko-mazurskie",
                     "wielkopolskie",
                     "zachodniopomorskie")

  voivodeship_en = c("Lower Silesia",
                     "Kuyavian-Pomeranian",
                     "Lublin",
                     "Lubusz",
                     "Lodz",
                     "Lesser Poland",
                     "Mazovian",
                     "Opole",
                     "Subcarpathian",
                     "Podlaskie",
                     "Pomeranian",
                     "Silesian",
                     "Swietokrzyskie",
                     "Warmian-Masurian",
                     "Greater Poland",
                     "West Pomeranian")

  local = character()
  if (all(voivodeship %in% voivodeship_pl)) {
    local = "PL"
  } else if (all(voivodeship %in% voivodeship_en)) {
    local = "EN"
  } else {
    stop("incorrect voivodeship names, check the documentation")
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

  df_voivodeship = data.frame(pl = voivodeship_pl, en = voivodeship_en, URL = URLs)

  download = function(df, local_col, ...) {
    filename = paste0(local_col[i], ".zip")
    utils::download.file(df[i, "URL"], filename, mode = "wb", ...)
    utils::unzip(filename)
  }

  if (local == "PL") {
    df_sel = df_voivodeship[df_voivodeship$pl %in% voivodeship, ]
    for (i in seq_len(nrow(df_sel))) {
      download(df_sel, df_sel$pl)
    }
  } else {
    df_sel = df_voivodeship[df_voivodeship$en %in% voivodeship, ]
    for (i in seq_len(nrow(df_sel))) {
      download(df_sel, df_sel$en)
    }
  }

}
