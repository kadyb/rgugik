#' @title Download requested tiles
#'
#' @param df_req a data frame obtained using the [`ortho_request()`] and
#' [`DEM_request()`] functions
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed; only suitable for certain elevation data
#' @param print_iter print the current iteration of all
#' (logical, TRUE default)
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
#' options(timeout = 600)
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#'
#' req_df = ortho_request(polygon)
#' tile_download(req_df[1, ]) # download the first image only
#'
#' req_df = DEM_request(polygon)
#' tile_download(req_df[1, ]) # download the first DEM only
#' }
tile_download = function(df_req, outdir = ".", unzip = TRUE, print_iter = TRUE, ...) {

  if (!"URL" %in% names(df_req)) {
    stop("data frame should come from 'request_ortho'")
  }

  if (!"filename" %in% names(df_req)) {
    stop("data frame should come from 'request_ortho'")
  }

  if (nrow(df_req) == 0) {
    stop("empty df")
  }

  # create output names from URLs
  basenames = basename(df_req$URL)

  if (!dir.exists(outdir)) dir.create(outdir)

  # only download files
  for (i in seq_len(nrow(df_req))) {

    if (print_iter) {
      writeLines(paste0(i, "/", nrow(df_req)))
    }

    filepath = paste0(outdir, "/", basenames[i])
    status = tryGet(utils::download.file(df_req[i, "URL"], filepath, mode = "wb", ...))

    if (any(status %in% c("error", "warning"))) {
      err_print()
      return(invisible("connection error"))
    }

    # get file extension and unzip
    ext = substr(df_req[i, "URL"], nchar(df_req[i, "URL"]) - 2, nchar(df_req[i, "URL"]))
    if (unzip && ext == "zip") {
      utils::unzip(filepath, exdir = outdir)
      file.remove(filepath)
    }

  }
}
