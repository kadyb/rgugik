library(testthat)
library(rgugik)

print(Sys.getenv())
print(Sys.getenv("USER"))
test_check("rgugik")
