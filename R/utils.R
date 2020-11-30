tryGet = function(code) {
  tryCatch(code,
           error = function(c) "error",
           warning = function(c) "warning"
  )
}
