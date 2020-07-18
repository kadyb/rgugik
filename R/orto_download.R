orto_download = function(df_req) {

  if (!all(c("url_do_pobrania", "nazwa_pliku") %in% names(df_req)))
    stop("data frame should come from 'request_orto'")
  if (nrow(df_req) == 0) stop("empty df")

  for (i in 1:nrow(df_req)) {
    download.file(df_req[i, "url_do_pobrania"],
                  paste0(df_req[i, "nazwa_pliku"], ".tif"),
                  mode = "wb")
  }

}
