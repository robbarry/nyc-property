
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

# What types of properties are selling for $0?
extract <- subset(sale.data, sale.price == 0)
t1 <- table(extract$bldg.class.sale)
t2 <- table(sale.data$bldg.class.sale)
t1_per <- t1 / sum(t1)
t2_per <- t2 / sum(t2)

share_diff <- t1_per - t2_per[names(t1_per)]
plot(share_diff, ylim = c(min(share_diff), max(share_diff)))
# Not a lot of over-representation here... it's pretty spread out.
share_diff[order(share_diff, decreasing = T)][1:5]
# On the underrepresentation side, it's clearly four groups: D4, R4, C6 and R9
share_diff[order(share_diff)][1:4]
# That's elevator condos & co-ops, walk-up co-ops and co-ops in condos.

#####################################
# What do nonzero prices look like? #
#####################################

# There are too many sales priced at 10^0, 10^1, 10^2 & 10^3...
dens <-
  with(subset(sale.data, sale.price > 0),
       density(log(sale.price, 10), na.rm = T)
  )
plot(dens)
pts <- unlist(lapply(0:3, function(z) { which.min(abs(dens$x - z)) } ))
points(dens$x[pts], dens$y[pts], col = "red")

# If we focus just on sales under $100,000, the problems with the
# distribution are even more clear.

dens <-
  with(subset(sale.data, sale.price > 0 & sale.price < 100000),
       density(log(sale.price, 10), na.rm = T)
       )
plot(dens)
pts <- unlist(lapply(0:5, function(z) { which.min(abs(dens$x - z)) } ))
points(dens$x[pts], dens$y[pts], col = "red")

# What about sales between $10,000 and $190,000?
dens <-
  with(subset(sale.data, sale.price > 10000 & sale.price < 190000),
       density(log(sale.price, 10), na.rm = T, n = 1024)
  )
plot(dens)
# The local maxima are clustered around $20K, $25K, $35K, $50K.
delta <- diff(dens$y)
cm <- c(F, sign(delta[-1]) == -1 & sign(delta[-length(delta)]) == 1)
points(dens$x[cm], dens$y[cm], col = "red")
10^dens$x[cm]

# Let's look at buildings between $20K and $50K...
extract <- subset(sale.data, sale.price >= 20000 & sale.price <= 50000)

t1 <- table(extract$bldg.class.sale)
t2 <- table(sale.data$bldg.class.sale)
t1_per <- t1 / sum(t1)
t2_per <- t2 / sum(t2)
# The disproportionate representation...
share_diff <- t1_per - t2_per[names(t1_per)]
plot(share_diff, ylim = c(min(share_diff), max(share_diff)))
# Two groups are heavily overy represented: R5 and H2.
# That's condo miscellaneous commercial and luxury hotels built after
# 1960.
share_diff[order(share_diff, decreasing = T)][1:2]

# On the other side, the conspiciously absent codes are R4 and D4:
# elevator condos and elevator co-ops.
share_diff[order(share_diff)][1:2]

# There are 329,326 sales with a zero-dollar consideration.
# Of the remaining sales, 71,893 (9% of non-zero sales) were
# for under $100K.
nrow(subset(sale.data, sale.price == 0)) # 329,326
nrow(subset(sale.data, sale.price < 100000 & sale.price > 0)) # 71,893
nrow(subset(sale.data, sale.price > 0)) # 773,177

#######################
# SQUARE FOOTAGE DATA #
#######################

# I suspect we'll have fewer historical sales with square footage data
# given the current setup for this analysis. Let's check if that's true.
# At some point, gonna have to figure out all those NA values...
extract <- subset(sale.data, !is.na(sale.year))

pdata <-
  ddply(extract,
        c("sale.year"),
        summarise,
        percent_no_sqft = sum(is.na(gr.sqft)) / length(sale.date)
        )

# These are not the results I was expecting...
plot(pdata$sale.year, pdata$percent_no_sqft, type = "h", lwd = 20, lend = 1,
     frame = F)

# Let's do it by year built...
pdata <-
  ddply(subset(extract, year.built > 1800),
        c("year.built"),
        summarise,
        percent_no_sqft = sum(is.na(gr.sqft)) / length(sale.date)
  )

plot(pdata$year.built, pdata$percent_no_sqft, type = "h", lwd = 2, lend = 1,
     frame = F)

# So it's mostly very old and very new stuff... the very new stuff could be
# extremely problematic...
pdata <-
  ddply(subset(extract, year.built >= 2000),
        c("year.built"),
        summarise,
        percent_no_sqft = sum(is.na(gr.sqft)) / length(sale.date)
  )

# The spike begins in 2012. Fewer than 50% of buildings built in 2015 have
# square footage data associated with them...
plot(pdata$year.built, pdata$percent_no_sqft, type = "h", lwd = 20, lend = 1,
     frame = F)



#########################
# SOME CURSORY ANALYSIS #
#########################

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


