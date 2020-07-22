#' returns a data frame with Polish and English names of voivodeships and their TERC
#'
#' @return a data frame with Polish and English names of voivodeships and their TERC
#' TERC - territorial division units (voivodeship level, 2 digits)
#' @export
#'
#' @examples
#' df_names = voivodeships_names()
voivodeships_names = function() {

  PL = c("dolnośląskie",
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

  EN = c("Lower Silesia",
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
  
  TERC = as.character(seq(2, 32, by = 2))
  TERC = ifelse(nchar(TERC) == 1, paste0("0", TERC), TERC)

  df_voivodeships = data.frame(PL, EN, TERC)

  return(df_voivodeships)

}
