remotes::install_github("kadyb/rgugik@outdir")

library("rgugik")


# geodb_download
geodb_download(c("16", "18"), outdir = "test", unzip = FALSE)
geodb_download("16", outdir = "C:/Users/Krzysztof/Desktop/test2", unzip = TRUE)


# geonames_download
geonames_download(type = "object", format = c("GML", "XLSX"),
                  outdir = "test", unzip = FALSE)
geonames_download(type = "place", format = c("GML", "SHP"),
                  outdir = "C:/Users/Krzysztof/Desktop/test2", unzip = TRUE)


# models3D_download
models3D_download(TERYT = c("2462", "0401"), LOD = "LOD1", outdir = "test", unzip = FALSE)
models3D_download(TERYT = c("2462", "0401"), LOD = "LOD1",
                  outdir = "C:/Users/Krzysztof/Desktop/test2", unzip = TRUE)
# they are unzipped to one folder ("Modele_3D"), but have
# different archives names ("0401_gml" and "2462_gml")


# pointDTM100_download
pointDTM100_download(c("02", "16"), outdir = "test", unzip = FALSE)
pointDTM100_download(c("opolskie", "wielkopolskie"),
                     outdir = "C:/Users/Krzysztof/Desktop/test2", unzip = TRUE)


# tile_download (orto_request)
library(sf)
polygon_path = system.file("datasets/search_area.gpkg", package = "rgugik")
polygon = read_sf(polygon_path)
req_df = orto_request(polygon)

tile_download(req_df[1:2, ], check_SHA = TRUE)
tile_download(req_df[1:2, ], outdir = "test", check_SHA = TRUE)
tile_download(req_df[1:2, ], outdir = "C:/Users/Krzysztof/Desktop/test2",
              check_SHA = TRUE)


models3D_download(TERYT = c("2462", "0401"), LOD = "LOD1",
                  outdir = "C:/Users/Krzysztof/Desktop/test1", unzip = FALSE)

models3D_download(TERYT = c("2462", "0401"), LOD = "LOD1",
                  outdir = "C:/Users/Krzysztof/Desktop/test2", unzip = TRUE)

models3D_download(TERYT = c("2462", "0401"), LOD = "LOD1",
                  outdir = "test1", unzip = FALSE)

models3D_download(TERYT = c("2462", "0401"), LOD = "LOD1",
                  outdir = "test2", unzip = TRUE)

### orto
req_df = orto_request(polygon)
tile_download(req_df[1, ], check_SHA = TRUE)
req_df[1, "sha1"]
as.character(openssl::sha1(file("41_3756_N-33-130-D-b-2-3.tif")))

### DEM 1 (zip)
req_df = DEM_request(polygon)
req_df$sha1[1] = "XXX" # fake SHA
tile_download(req_df[1, ], outdir = "test", check_SHA = TRUE)
# should return warning

### DEM 2 (asc)
tile_download(req_df[3, ], outdir = "test", check_SHA = TRUE)
req_df[3, "sha1"]
as.character(openssl::sha1(file("test/2730_318577_N-33-130-D-b-2-3.asc")))

### DEM 3 (zip)
tile_download(req_df[7, ], outdir = "test", check_SHA = TRUE, unzip = FALSE)
req_df[7, "sha1"]
as.character(openssl::sha1(file("test/5132_384975_N-33-130-D-b-2_asc.zip")))
