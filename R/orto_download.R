#' downloads orthoimages based on the data frame obtained using 
#' the orto_request() function
#'
#' @param df_req a data frame obtained using the orto_request() function
#' @param check_SHA check the integrity of downloaded files 
#' (logical parameter, default = FALSE)
#' @param ...
#'
#' @return georeferenced orthoimages .tif with properties 
#' (resolution, composition, etc.) as specified in the input data frame
#' @export
#'
#' @examples
#' library(sf)
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#' req_df = orto_request(polygon)
#' orto_download(req_df[1, ]) # download the first image only
orto_download = function(df_req, check_SHA = FALSE, ...) {

  if (!all(c("url_do_pobrania", "nazwa_pliku") %in% names(df_req))) {
    stop("data frame should come from 'request_orto'")
  }

  if (check_SHA == TRUE && !"sha1" %in% names(df_req)) {
    stop("'sha1' column not found")
  }

  if (nrow(df_req) == 0) {
    stop("empty df")
  }

  if (!check_SHA) {
    # only download files
    for (i in seq_len(nrow(df_req))) {
      name_file = paste0(df_req[i, "nazwa_pliku"], ".tif")
      utils::download.file(df_req[i, "url_do_pobrania"], name_file, mode = "wb", ...)
    }
  } else {
    # download files and check their checksum
    for (i in seq_len(nrow(df_req))) {
      name_file = paste0(df_req[i, "nazwa_pliku"], ".tif")
      utils::download.file(df_req[i, "url_do_pobrania"], name_file, mode = "wb", ...)
      # reference checksum is SHA-1
      tmp_SHA = as.character(openssl::sha1(file(name_file)))

      if (!tmp_SHA == df_req[i, "sha1"]) {
        warning(paste(name_file, "incorrect SHA"), immediate. = TRUE)
      }
    }
  }

}
