request = function(polygon, composition = NULL, year = NULL, resolution = NULL) {
  require("sf")
  require("jsonlite")

  if (!is.null(composition) && !(composition %in% c("B/W", "RGB", "CIR"))) stop("incorrect composition (should be 'B/W', 'RGB' or 'CIR'")

  epsg = st_crs(polygon)$epsg
  bbox = st_bbox(polygon)

  # hard coded URL and parameters
  base_URL = "https://mapy.geoportal.gov.pl/gprest/services/SkorowidzeFOTOMF/MapServer/0/query?"
  geometryType = "&geometryType=esriGeometryEnvelope"
  spatialRel = "&spatialRel=esriSpatialRelIntersects"
  outFields = "&outFields=*"
  returnGeometry = "&returnGeometry=false"
  file = "&f=json"

  # user input
  geometry = paste0("geometry={'xmin':", bbox[1], ", 'ymin':", bbox[2], ", 'xmax':", bbox[3], ", 'ymax':", bbox[4], ", 'spatialReference':{'wkid':", epsg, "}}")

  prepared_URL = paste0(base_URL, geometry, geometryType, spatialRel, outFields,
                        returnGeometry, file)

  outputJSON = fromJSON(prepared_URL)
  return(outputJSON$features[[1]])
}

