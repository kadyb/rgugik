#' downloads tiles based on the data frame obtained using
#' the orto_request() and DEM_request() functions
#'
#' @param df_req a data frame obtained using the [`orto_request()`] and
#' [`DEM_request()`] functions
#' @param outdir (optional) name of the output directory;
#' by default, files are saved in the working directory
#' @param unzip TRUE (default) or FALSE, when TRUE the downloaded archive will
#' be extracted and removed; only suitable for certain elevation data
#' @param check_SHA check the integrity of downloaded files
#' (logical, FALSE default)
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
#' polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
#' polygon = read_sf(polygon_path)
#'
#' req_df = orto_request(polygon)
#' tile_download(req_df[1, ]) # download the first image only
#'
#' req_df = DEM_request(polygon)
#' tile_download(req_df[1, ]) # download the first DEM only
#' }
tile_download = function(df_req, outdir = ".", unzip = TRUE, check_SHA = FALSE,
                         print_iter = TRUE, ...) {

  if (!"URL" %in% names(df_req)) {
    stop("data frame should come from 'request_orto'")
  }

  if (!"filename" %in% names(df_req)) {
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

    if (print_iter) {
      writeLines(paste0(i, "/", nrow(df_req)))
    }

    filepath = paste0(outdir, "/",
                      unlist(strsplit(df_req[i, "URL"], "/"))[idx_name])
    status = tryGet(utils::download.file(df_req[i, "URL"], filepath, mode = "wb", ...))

    if (any(status %in% c("error", "warning"))) {
      return("connection error")
    }

    # compare checksums (reference is SHA-1)
    if (check_SHA) {
      checkSHA_fun(refSHA = df_req[i, "sha1"], filename = df_req[i, "filename"],
                   filepath = filepath)
    }

    # get file extension and unzip
    ext = substr(df_req[i, "URL"], nchar(df_req[i, "URL"]) - 2, nchar(df_req[i, "URL"]))
    if (unzip && ext == "zip") {
      utils::unzip(filepath, exdir = outdir)
      file.remove(filepath)
    }

  }
}


# check SHA function
checkSHA_fun = function(refSHA, filename, filepath) {

  fileSHA = as.character(openssl::sha1(file(filepath)))

  if (!fileSHA == refSHA) {
    warning(paste(filename, "incorrect SHA"), call. = FALSE, immediate. = TRUE)
  }

}
