
# Plot sales in new, elevator-equipped condos
source("r:/repos/nyc-property/setup.r")
usePackage("ggplot2")
usePackage("lubridate")
usePackage("scales")
usePackage("reshape2")

sale.data <- read.csv("data/output/sale-data.csv")

# Set some basic variables, including the year and price per square foot
sale.data$sale.year <- year(sale.data$sale.date)
sale.data$sale.month <- year(sale.data$sale.date) + (month(sale.data$sale.date) - 1) / 12
sale.data$ppsqft <- with(sale.data, sale.price / gr.sqft)

#############################
# How many sales each year? #
#############################

plot(table(sale.data$sale.year), frame = F,
     lwd = 20, lend = 1,
     xlab = "Year", ylab = "Sales",
     main = "Sales Per Year")

###############################
# How many sales have prices? #
###############################

pdata <-
  ddply(sale.data,
        c("sale.year"),
        summarise,
        price_nonzero = sum(sale.price > 0) / length(sale.price),
        price_zero = sum(sale.price == 0) / length(sale.price))

# There are some NA records. We'll worry about them later.
plt <- ggplot(melt(pdata, id.vars = "sale.year"),
              aes(x = sale.year, y = value, fill = variable))
plt <- plt + geom_bar(stat = "identity")
plt <- plt + scale_y_continuous(labels = percent)
plt <- plt + ggtitle("Percent of sales with zero price")
plt <- plt + xlab("Sale Year") + ylab("Percent")
plt <- plt + theme_bw()
plt

#####################################
# What do nonzero prices look like? #
#####################################

# There are too many sale prices at 10^0, 10^1, 10^2 & 10^3...
dens <-
  with(subset(sale.data, sale.price > 0),
       density(log(sale.price, 10), na.rm = T)
  )
plot(dens)
pts <- unlist(lapply(0:3, function(z) { which.min(abs(dens$x - z)) } ))
points(dens$x[pts], dens$y[pts], col = "red")

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
    c("sale.month", "boro"),
    summarise,
    median.ppsqft = median(ppsqft)
  )


plt <- ggplot(analysis,
              aes(x = sale.month, y = median.ppsqft,
                  color = factor(boro, labels =
                                   c("Manhattan", "Bronx", "Brooklyn",
                                     "Queens", "Staten Island"))))
plt <- plt + geom_line(size = 1.4)
plt <- plt + theme_bw()
plt <- plt + ggtitle("Median Price Per Sqft\nNew, elevator-equipped condos")
plt <- plt + theme(legend.title = element_blank())
plt <- plt + xlab("Sale date")
plt <- plt + ylab("Median price per square foot")
plt <- plt + scale_y_continuous(labels = dollar)
plt


