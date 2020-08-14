
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rgugik

<!-- badges: start -->

[![R build
status](https://github.com/kadyb/rgugik/workflows/rcmdcheck/badge.svg)](https://github.com/kadyb/rgugik/actions)
<!-- badges: end -->

**rgugik** is an R package for downloading open data from resources of
[Polish Head Office of Geodesy and
Cartography](http://www.gugik.gov.pl). Currently you can download:

  - [Orthophotomaps](http://www.gugik.gov.pl/pzgik/zamow-dane/ortofotomapa)
  - [Digital Terrain
    Models](http://www.gugik.gov.pl/pzgik/zamow-dane/numeryczny-model-terenu)
    as XYZ vector points with 1 m resolution
  - Digital Terrain Models as XYZ text files with 100 m resolution for
    entire voivodeships
  - [General Geographic
    Database](http://www.gugik.gov.pl/pzgik/zamow-dane/baza-danych-obiektow-ogolnogeograficznych)
  - [State Register of Geographical
    Names](http://www.gugik.gov.pl/pzgik/zamow-dane/panstwowy-rejestr-nazw-geograficznych)
  - Location (geometry) of cadastral parcels using TERYT (parcel ID) or
    coordinates
  - 3D models of buildings (LOD1, LOD2)

It is also possible to geocode addresses or objects using the
`geocodePL_get` function.

**Corresponding functions**

| Dastaset PL                               | Dataset EN                           | Function                             | Input                  |
| :---------------------------------------- | :----------------------------------- | :----------------------------------- | :--------------------- |
| Ortofotomapa                              | Orthophotomap                        | orto\_request, orto\_download        | polygon                |
| Numeryczny Model Terenu                   | Digital Terrain Model                | pointDTM\_get, pointDTM100\_download | polygon, voivodeship   |
| Baza Danych Obiektów Ogólnogeograficznych | General Geographic Database          | geodb\_download                      | voivodeship            |
| Państwowy Rejestr Nazw Geograficznych     | State Register of Geographical Names | geonames\_download                   | place, object          |
| Lokalizacja działek katastralnych         | Location of cadastral parcels        | parcel\_get                          | parcel ID, coordinates |
| Modele 3D budynków                        | 3D models of buildings               | models3D\_download                   | county                 |

## Installation

<!-- You can install the released version of rgugik from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("rgugik") -->

<!-- ``` -->

You can install the development version from
[GitHub](https://github.com) with:

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
library(raster)

polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)

req_df = orto_request(polygon)

# show metadata and download the first image only
t(req_df[1, ])
#>                    1                                                                               
#> godlo              "N-33-130-D-b-2-3"                                                              
#> akt_rok            "2001"                                                                          
#> piksel             "1"                                                                             
#> kolor              "RGB"                                                                           
#> zrDanych           "Scena sat."                                                                    
#> ukladXY            "PL-1992"                                                                       
#> czy_ark_wypelniony "TAK"                                                                           
#> url_do_pobrania    "https://opendata.geoportal.gov.pl/ortofotomapa/41/41_3756_N-33-130-D-b-2-3.tif"
#> idSerie            "41"                                                                            
#> sha1               "312c81963a31e268fc20c442733c48e1aa33838f"                                      
#> nazwa_pliku        "41_3756_N-33-130-D-b-2-3"
orto_download(req_df[1, ])

img = brick("41_3756_N-33-130-D-b-2-3.tif")
plotRGB(img)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

### DTM (as XYZ)

``` r
library(rgugik)
library(sf)

polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)

DTM = pointDTM_get(polygon)
#> 0/10
#> 1/10
#> 2/10
#> 3/10
#> 4/10
#> 5/10
#> 6/10
#> 7/10
#> 8/10
#> 9/10
#> 10/10

plot(DTM, pal = terrain.colors, pch = 20, main = "Elevation [m]")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

## Acknowledgment

<!-- please add the content here-->

## Contribution

Contributions to this package are welcome. The preferred method of
contribution is through a GitHub pull request. Feel also free to contact
us by creating [an issue](https://github.com/kadyb/rgugik/issues).

## Related project

If you don’t feel familiar with R, there are similar tools to
[QGIS](https://www.qgis.org) in the
[EnviroSolutions](https://github.com/envirosolutionspl) repository.
