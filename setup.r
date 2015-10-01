# Initial setup file

source("https://raw.githubusercontent.com/robbarry/r-lib/master/base.r")
usePackage("readxl")
usePackage("plyr")

# Function to download all the sale data files, returns a data.frame with
# details about each file. Will not download files twice.
get.data.files <- function() {
  boros <- c("queens", "brooklyn", "bronx", "manhattan", "si")
  years <- 2004:2015
  
  data.files <- expand.grid(years, boros, stringsAsFactors = F)
  colnames(data.files) <- c("year", "boro")
  data.files$year <- as.character(data.files$year)
  
  # Because Department of Finance...
  data.files$use.year <- 
    ifelse(data.files$year < "2007",
           substr(data.files$year, 3, 4),
           data.files$year)
  
  # AND because of the Department of Finance...
  data.files$use.boro <- ifelse(data.files$year > "2006" & data.files$boro == "si", "statenisland", data.files$boro)
  
  # And also because these guys! They change the URL like every year...
  data.files$remote.filename <-
    apply(data.files,
          1,
          function(x) {
            if (x["year"] %in% as.character(2004:2006)) {
              # 2004-2006 format: http://www1.nyc.gov/assets/finance/downloads/sales_manhattan_06.xls
              paste0("http://www1.nyc.gov/assets/finance/downloads/sales_",
                     x["use.boro"], "_", x["use.year"], ".xls")
            } else if (x["year"] == "2007") {
              # 2007 format: http://www1.nyc.gov/assets/finance/downloads/excel/rolling_sales/sales_2007_manhattan.xls
              paste0("http://www1.nyc.gov/assets/finance/downloads/excel/rolling_sales/sales_",
                     x["use.year"], "_", x["use.boro"], ".xls")
            } else if (x["year"] == "2008") {
              # 2008 format: http://www1.nyc.gov/assets/finance/downloads/pdf/09pdf/rolling_sales/sales_2008_manhattan.xls
              paste0("http://www1.nyc.gov/assets/finance/downloads/pdf/09pdf/rolling_sales/sales_",
                     x["use.year"], "_", x["use.boro"], ".xls")
            } else if (x["year"] == "2009") {
              # 2009 format: http://www1.nyc.gov/assets/finance/downloads/pdf/rolling_sales/annualized-sales/2009_manhattan.xls
              paste0("http://www1.nyc.gov/assets/finance/downloads/pdf/rolling_sales/annualized-sales/",
                     x["use.year"], "_", x["use.boro"], ".xls")
              
            } else if (x["year"] %in% as.character(2010:2014)) {
              # 2010-2014 format: http://www1.nyc.gov/assets/finance/downloads/pdf/rolling_sales/annualized-sales/2014/2014_manhattan.xls
              paste0("http://www1.nyc.gov/assets/finance/downloads/pdf/rolling_sales/annualized-sales/",
                     x["year"], "/", x["year"], "_", x["use.boro"], ".xls")
              
            } else if (x["year"] == "2015") {
              # Rolling format: 
              paste0("http://www1.nyc.gov/assets/finance/downloads/pdf/rolling_sales/rollingsales_",
                     x["use.boro"], ".xls")
            } else {
              NA
            }
          })
  
  data.files$local.filename <- paste0(data.files$year, "-", data.files$boro, ".xls")
  return(data.files)
}

# R vs. R Studio path insanity. Is there a better way to do this?
script.dir <- dirname(sys.frame(1)$ofile)
dest.path <- "data/dof/downloads/"
setwd(paste(script.dir, sep = "/"))

