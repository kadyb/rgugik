# rgugik development version

* Fixed "*Error in if (nrow(output) == 1000) { : argument is of length zero*"
in `ortho_request()` and `DEM_request()`.

* Updated data sources in `borders_download()` function.

* Added `egib_download()` function for downloading Land and Building Register
layers (EGiB). Thanks to Grzegorz Sapijaszko.

* The list of communes has been updated (as of 06 January 2025).

* Updated BDOO (`geodb_download()`) and BDOT10K (`topodb_download()`)
database sources.

# rgugik 0.4.1

* The list of communes has been updated (as of 02 January 2024).

* Update product names in `DEM_request()`.

# rgugik 0.4.0

* The `ortho_request()` and `DEM_request()` functions have been updated
to the new API version. Now you can download the latest orthophotomaps
and DEM products.

* Due to the lack of information about SHA in the database, the `checkSHA`
argument in the `tile_download()` function has been deprecated.
