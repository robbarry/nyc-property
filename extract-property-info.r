
# You don't need to run this file. Its output is already in this repository
# Just decompress:
# data/dof/property-info/bblsqft.csv.gz
#
# Use this script to parse out the useful fields from the city's
# valuation/assessment archives.
#
# To refresh, you'll need to download both tax class 1 and tax classes 2-4 from
# the city's valuation/assessment archives. As of this wrting, this data is located here:
# http://www1.nyc.gov/site/finance/taxes/property-assessment-roll-archives.page

data1 <- read.csv("data/dof/property-info/tc1.txt")
data2 <- read.csv("data/dof/property-info/tc234.txt")
data.master <-
  rbind(
    data1,
    data2
  )

ClipIt(subset(data.master, BORO == 4 & BLOCK == 30 & LOT == 1034))

fields.to.keep <-
  c("BORO", "BLOCK", "LOT", "GR_SQFT")

write.csv(data.master[, fields.to.keep], file = "data/dof/property-info/bblsqft.csv", row.names = F)
