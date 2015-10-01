
# Merge sales and square footage data and output a single CSV
# Run this after you've downloaded sales. Make sure you've also
# got the square footage data in data/property-info
source("r:/repos/nyc-property/setup.r")

read.sales.file <- function(boro, year, current.year = 2015, skip = 4) {
  data <- read_excel(paste0("data/dof/downloads/", year, "-", boro, ".xls"), skip = skip)
  colnames(data) <- c("boro", "neighborhood",
                      "bldg.class.category", "tax.class.now",
                      "block", "lot", "eastment",
                      "bldg.class.now", "address",
                      "apartment", "zipcode", "res.units",
                      "com.units", "total.units",
                      "land.sqft", "gross.sqft",
                      "year.built", "tax.class.sale",
                      "bldg.class.sale", "sale.price",
                      "sale.date")
  data$sale.date <- as.Date(data$sale.date)
  
  # Because the city's most recent data is actually a year's worth of
  # rolling sales, we'll have duplicates if we don't do this...
  if (year == current.year)
    data <- subset(data, sale.date >= as.Date(paste0(current.year, "-01-01")))
  
  # In one particular year, there's a malformed address that causes
  # a lot of stuff to break. Fix it this way:
  data$address <- gsub("\032", "", data$address)
  return(data)
}

get.all.sales <- function(data.files) {
  sale.data <- NULL
  for (i in 1:nrow(data.files)) {
    sale.data <-
      rbind(sale.data,
            read.sales.file(data.files[i, "boro"], data.files[i, "year"])
      )
  }
  return(sale.data)
}

data.files <- get.data.files()
sale.data <- get.all.sales(data.files)

sqft.data <- read.csv("data/dof/property-info/bblsqft.csv")
colnames(sqft.data) <- tolower(colnames(sqft.data))
colnames(sqft.data)[4] <- "gr.sqft"

sale.data.sqft <- merge(sale.data, sqft.data, all.x = T, all.y = F)
write.csv(sale.data, "data/output/sale-data.csv", row.names = F)
