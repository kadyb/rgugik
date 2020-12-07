# Vignettes that depend on internet access have been precompiled

library(knitr)
oldwd = getwd()
setwd("vignettes/")
knit("orthophotomap.Rmd.orig", "orthophotomap.Rmd")
knit("DEM.Rmd.orig", "DEM.Rmd")
knit("topodb.Rmd.orig", "topodb.Rmd")
setwd(oldwd)
