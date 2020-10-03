# Vignettes that depend on internet access have been precompiled
# Must manually move image files from rgugik/ to rgugik/vignettes/ after knit

library(knitr)
knit("vignettes/orthophotomap.Rmd.orig", "vignettes/orthophotomap.Rmd")

library(devtools)
build_vignettes()
