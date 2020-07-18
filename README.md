
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rgugik

<!-- badges: start -->

<!-- badges: end -->

**rgugik** is an R package for downloading open data from resources of
[Polish Head Office of Geodesy and
Cartography](http://www.gugik.gov.pl/). Currently you can download:

  - [Orthophotomaps](http://www.gugik.gov.pl/pzgik/zamow-dane/ortofotomapa)
  - [Digital Terrain
    Models](http://www.gugik.gov.pl/pzgik/zamow-dane/numeryczny-model-terenu)
    as XYZ vector points with 1 m resolution

## Installation

<!-- You can install the released version of rgugik from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("rgugik") -->

<!-- ``` -->

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("kadyb/rgugik")
```

## Usage

### Ortophotomap

  - `orto_request()` - returns a data frame with metadata and links to
    the orthoimages in a given polygon
  - `orto_download()` - downloads orthoimages based on the data frame
    obtained using the `orto_request()` function

<!-- end list -->

``` r
library(rgugik)
library(sf)
#> Linking to GEOS 3.8.1, GDAL 3.0.4, PROJ 6.3.2
library(raster)
#> Loading required package: sp
polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
req_df = orto_request(polygon)
str(req_df)
#> 'data.frame':    15 obs. of  9 variables:
#>  $ godlo          : chr  "N-33-130-D-b-2-3" "N-33-130-D-b-2-3" "N-33-130-D-b-2-3" "N-33-130-D-b-2-3" ...
#>  $ akt_rok        : int  2001 2007 2011 2011 2012 2012 2017 2017 2017 2014 ...
#>  $ piksel         : num  1 0.5 0.25 0.25 0.1 0.1 0.25 0.25 0.25 0.25 ...
#>  $ kolor          : chr  "RGB" "RGB" "CIR" "RGB" ...
#>  $ zrDanych       : chr  "Scena sat." "Zdj. analogowe" "Zdj. cyfrowe" "Zdj. cyfrowe" ...
#>  $ url_do_pobrania: chr  "https://opendata.geoportal.gov.pl/ortofotomapa/41/41_3756_N-33-130-D-b-2-3.tif" "https://opendata.geoportal.gov.pl/ortofotomapa/45/45_68485_N-33-130-D-b-2-3.tif" "https://opendata.geoportal.gov.pl/ortofotomapa/69749/69749_128813_N-33-130-D-b-2-3.tif" "https://opendata.geoportal.gov.pl/ortofotomapa/69750/69750_140010_N-33-130-D-b-2-3.tif" ...
#>  $ idSerie        : int  41 45 69749 69750 229 64923 69883 69884 66266 70086 ...
#>  $ sha1           : chr  "312c81963a31e268fc20c442733c48e1aa33838f" "163ee031bd0f1511bed96c579167951f2dd9acca" "ac120d34bab91855976d0f0700b75f8e416369c3" "959b66a5b71c7c05a1b4826de7f6c56942de371c" ...
#>  $ nazwa_pliku    : chr  "41_3756_N-33-130-D-b-2-3" "45_68485_N-33-130-D-b-2-3" "69749_128813_N-33-130-D-b-2-3" "69750_140010_N-33-130-D-b-2-3" ...
orto_download(req_df[1, ]) # download the first image only
img = brick("41_3756_N-33-130-D-b-2-3.tif")
#> Warning in showSRID(uprojargs, format = "PROJ", multiline = "NO"): Discarded
#> datum Unknown based on GRS80 ellipsoid in CRS definition
plotRGB(img)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

### DTM (as XYZ)

``` r
library(rgugik)
library(sf)
polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
DTM = pointDTM_get(polygon)
summary(DTM$elev)
plot(DTM, pal = terrain.colors, pch = 20, main = "Elevation [m]")
```

## Acknowledgment

<!-- please add the content here-->

## Contribution

Contributions to this package are welcome. The preferred method of
contribution is through a GitHub pull request. Feel also free to contact
us by creating [an issue](https://github.com/%20kadyb/rgugik/issues).
