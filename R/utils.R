tryGet = function(code) {
  tryCatch(code,
           error = function(c) {
             message(c)
             return("error")
           },
           warning = function(c) {
             message(c)
             return("warning")
           }
  )
}

err_print = function() {
  msg = paste0("Conection error.", "\n", "If the problem persists, ",
               "try a different download method from 'download.file()'.")
  message(msg)
}
