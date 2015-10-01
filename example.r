
# Plot sales in new, elevator-equipped condos
source("r:/repos/nyc-property/setup.r")
usePackage("ggplot2")
usePackage("lubridate")

sale.data <- read.csv("data/output/sale-data.csv")

sale.data$sale.year <- year(sale.data$sale.date)
sale.data$ppsqft <- with(sale.data, sale.price / gr.sqft)

# Let's just look at elevator equipped condos built within 10 years of the current
# sales year.
extract <- subset(sale.data,
                  bldg.class.sale == "R4"
                  & total.units == 1
                  & res.units == 1
                  & year.built >= sale.year - 10
                  & sale.price > 10000
                  & gr.sqft > 0)

analysis <-
  ddply(
    extract,
    c("sale.year", "boro"),
    summarise,
    median.ppsqft = median(ppsqft)
  )


plt <- ggplot(analysis,
              aes(x = sale.year, y = median.ppsqft,
                  color = factor(boro, labels =
                                   c("Manhattan", "Bronx", "Brooklyn",
                                     "Queens", "Staten Island"))))
plt <- plt + geom_line(size = 2)
plt <- plt + theme_bw()
plt <- plt + ggtitle("Median Price Per Sqft\nNew, elevator-equipped condos")
plt <- plt + theme(legend.title = element_blank())
plt


