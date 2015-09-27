#   n y c - p r o p e r t y  
A tool to help piece together useful New York City property sale data

## Usage Instructions

1. Run `download-sale-data.r` to download sale data from the Department of Finance. You can extend the script to include more years.
2. Make sure you decompress `data/dof/property-info/bblsqft.csv.gz` (or follow the instructions below to re-create it).
3. Run `merge-sales-sqft.r` to create `data/output/sale-data.csv` which will have sale data merged with gross square footage data.

## Notes

For reference, this repository includes a gzipped version of `sale-data.csv` created on Sept. 27, 2015 in `data/output`.

## Data

The sales data is posted on the New York City Department of Finance's website. For inexplicable reasons, the DOF splits its files into two categories: annualized sale data and a weird "rolling" sales file that captures every sale in the previous 12-month period. As a result, there's a bit of overlap that needs to be dealt with.

1. "Rolling" sales: http://www1.nyc.gov/site/finance/taxes/property-rolling-sales-data.page
2. Historical sales: http://www1.nyc.gov/site/finance/taxes/property-annualized-sales-update.page

Of course, this being the largest residential market in the United States, it makes sense that there would be absolutely no information in the sales data about condo square footage. That information must be obtained from the city's [valuation/assessment archives](http://www1.nyc.gov/site/finance/taxes/property-assessment-roll-archives.page). It comes in Access files. I've parsed them into CSV files (though left .txt extension on them because... Access...)
 
## Reference

The building code lookup table is located [here](http://nycserv.nyc.gov/nycproperty/help/hlpbldgcode.html).
