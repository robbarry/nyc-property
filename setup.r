# Initial setup file

source("https://raw.githubusercontent.com/robbarry/r-lib/master/base.r")
usePackage("readxl")
usePackage("plyr")

repos <- "r:/repos"
dest.path <- "data/dof/downloads/"
setwd(paste(repos, "nyc-property", sep = "/"))

boros <- c("queens", "brooklyn", "bronx", "manhattan", "si")
years <- 2014:2015

data.files <- expand.grid(years, boros, stringsAsFactors = F)
colnames(data.files) <- c("year", "boro")
data.files$year <- as.character(data.files$year)

# Because Department of Finance...
data.files$use.year <- 
  ifelse(data.files$year < "2007",
         substr(data.files$year, 3, 4),
         data.files$year)

# AND because of the Department of Finance...
data.files$use.boro <- ifelse(data.files$year > "2013" & data.files$boro == "si", "statenisland", data.files$boro)

# And also because these guys!
data.files$remote.filename <-
  apply(data.files, 1, function(x) {
    if (x["year"] == "2014") {
      return(
        paste0("http://www1.nyc.gov/assets/finance/downloads/pdf/rolling_sales/annualized-sales/",
               x["year"], "/", x["year"], "_", x["use.boro"], ".xls")
      )
    } else if (x["year"] == "2015") {
      paste0("http://www1.nyc.gov/assets/finance/downloads/pdf/rolling_sales/rollingsales_",
             x["use.boro"], ".xls")
    }
  })

data.files$local.filename <- paste0(data.files$year, "-", data.files$boro, ".xls")
