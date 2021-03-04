tryGet = function(code) {
  tryCatch(code,
           error = function(c) "error",
           warning = function(c) "warning"
  )
}

err_print = function() {
  msg = paste0("Conection error.", "\n", "If the problem persists, ",
               "try a different download method from 'download.file()'.")
  message(msg)
}
