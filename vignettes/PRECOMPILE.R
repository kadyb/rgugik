# Vignettes that depend on internet access have been precompiled

library(knitr)
setwd("vignettes/")
knit("orthophotomap.Rmd.orig", "orthophotomap.Rmd")
knit("DEM.Rmd.orig", "DEM.Rmd")
