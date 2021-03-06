#   n y c - p r o p e r t y  
A tool to help piece together useful New York City property sale data.

## The Problem

New York City's Department of Finance publishes fairly detailed, transaction-level data going back to 2004 on all real estate sales in the city. The problem is, this data is spread across at least 60 Excel spreadsheets and is missing critical pieces of information.

## Solution

This set of scripts downloads all the Excel files, stiches them together using `readxl`, merges them with square footage data and writes them to a friendly CSV file. It also takes care of errors it encounters in the source data, such as weirdly encoded characters that crop up in the address field.

![Sale data](https://raw.githubusercontent.com/robbarry/nyc-property/master/img/example-1.png) 

## Usage Instructions

1. Run `download-sale-data.r` to download sale data from the Department of Finance from 2004-2015.
2. Make sure you decompress `data/dof/property-info/bblsqft.csv.gz` (or follow the instructions below to re-create it).
3. Run `merge-sales-sqft.r` to create `data/output/sale-data.csv` which will have sale data merged with gross square footage data.

## Data

The sales data is posted on the New York City Department of Finance's website. For inexplicable reasons, the DOF splits its files into two categories: annualized sale data and a weird "rolling" sales file that captures every sale in the previous 12-month period. As a result, there's a bit of overlap that needs to be dealt with.

The sales data is also lacking some key information! For instance, among the 150,424 R4 (condo with elevator) sales between 2004 and the end of August 2015, just 15 had any square footage data. This makes any kind of practical analysis nearly impossible. To at least partially address the problem, I've parsed the city' valuation/assessment archives into a file here called `bblsqft.csv.gz` (bbl stands for borough/block/lot). There may be other data in the valuation/assessment archives but thus far the only piece of it I'm extracting is gross square footage.

1. "Rolling" sales: http://www1.nyc.gov/site/finance/taxes/property-rolling-sales-data.page
2. Historical sales: http://www1.nyc.gov/site/finance/taxes/property-annualized-sales-update.page
3. Valuation/assessment archives: http://www1.nyc.gov/site/finance/taxes/property-assessment-roll-archives.page
 
## Notes

* For reference, this repository includes `sale-data.csv.gz` generated from data downloaded on Sept. 27, 2015 in `data/output`.
* The building code lookup table is located [here](http://nycserv.nyc.gov/nycproperty/help/hlpbldgcode.html).
