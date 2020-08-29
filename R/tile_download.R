#' downloads tiles based on the data frame obtained using
#' the orto_request() and DEM_request() functions
#'
#' @param df_req a data frame obtained using the orto_request() and
#' DEM_request() functions
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed; only suitable for certain elevation data
#' @param check_SHA check the integrity of downloaded files
#' (logical parameter, default = FALSE)
#' @param ... additional argument for [`utils::download.file()`]
#'
#' @return georeferenced tiles with properties (resolution, year, etc.)
#' as specified in the input data frame
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#'
#' req_df = orto_request(polygon)
#' tile_download(req_df[1, ]) # download the first image only
#'
#' req_df = DEM_request(polygon)
#' tile_download(req_df[1, ]) # download the first DEM only
#' }
tile_download = function(df_req, outdir = ".", unzip = TRUE, check_SHA = FALSE, ...) {

  if (!"URL" %in% names(df_req)) {
    stop("data frame should come from 'request_orto'")
  }

  if (check_SHA == TRUE && !"sha1" %in% names(df_req)) {
    stop("'sha1' column not found")
  }

  if (nrow(df_req) == 0) {
    stop("empty df")
  }

  # get name index from URL
  idx_name = length(unlist(strsplit(df_req[1, "URL"], "/")))

  if (!dir.exists(outdir)) dir.create(outdir)

  # only download files
  for (i in seq_len(nrow(df_req))) {
    filename = paste0(outdir, "/",
                      unlist(strsplit(df_req[i, "URL"], "/"))[idx_name])
    utils::download.file(df_req[i, "URL"], filename, mode = "wb", ...)

    # compare checksums (reference is SHA-1)
    if (check_SHA) {
      tmp_SHA = as.character(openssl::sha1(file(filename)))

      if (!tmp_SHA == df_req[i, "sha1"]) {
        warning(paste(df_req[i, "filename"], "incorrect SHA"), immediate. = TRUE)
      }
    }

    # get file extension and unzip
    ext = substr(df_req[i, "URL"], nchar(df_req[i, "URL"]) - 2, nchar(df_req[i, "URL"]))
    if (unzip && ext == "zip") {
      utils::unzip(filename, exdir = outdir)
      file.remove(filename)
    }

  }
}
