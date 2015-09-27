
# Download NYC sale data

source("setup.r")

download.sale.data <- function(data.files) {
  for (i in 1:nrow(data.files)) {
    record <- data.files[i, ]
    local.file <- paste0(dest.path, record$local.filename)
    if (!file.exists(local.file)) {
      print(record$remote.filename)
      download.file(record$remote.filename, destfile = local.file, method = "curl")    
    }
      
  }
}

download.sale.data(data.files)

