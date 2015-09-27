
# Download NYC sale data

source("setup.r")

download.sale.data <- function(data.files) {
  for (i in 1:nrow(data.files)) {
    record <- raw.files[i, ]
    local.file <- paste0(dest.path, record$local.filename)
    if (!file.exists(local.file)) 
      download.file(record$remote.filename, destfile = local.file, method = "curl")    
  }
}

download.sale.data(data.files)
