
library("plyr")
library(tidyverse)
#library(ggplot2)
library(dslabs)
#library(lubridate)
#library(vrtest)
#library('matlab')
#library(openai)
#library(tseries)
library(kableExtra)
library(lattice)
library(knitr)
library(xtable)
library(quarto)
#library(zoo)
library(gridExtra)
library(e1071)
library(ggridges)
library(viridis)
library(Rfast)
library(car)
library(MASS)
library(fitdistrplus)
library(reshape2)
library(timeDate)
library(bizdays)


# Rmd path
file_path <- "C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11182023.rmd"

# code path
file_path <- "C:/Users/Owner/Documents/Research/MonetaryPolicy/Code/CodeMI/shocks.r"
# Grant read permissions using icaclsCode
command <- paste("icacls", file_path_quoted, "/grant", shQuote("Everyone:(R)"), collapse = " ")
system(command, intern = TRUE)


# DAILY DATA
filepath<-"C:/Users/Owner/Documents/Research//MonetaryPolicy/Data/Final data file
fed <- read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/shocksv4.csv', header = TRUE, sep = ",", dec = ".", stringsAsFactors = FALSE)
# Set column names based on the first row
colnames(fed) <- names(fed)
sdate<-as.Date(fed$Date,"%m/%d/%Y")
rdate<-as.Date(fed$Dater,"%m/%d/%Y")
# Find the row number for the beginning and end dates of the sample: where  "3/4/2016" occurs and 12/29/2022 for the first time
# Check which index corresponds to the specified dates
begs <- which(sdate == as.Date("2016-03-04"))
ends <- which(sdate == as.Date("2023-12-14")) 
print(begs) #[1] 4
print(ends) #[1] 1960
fed=fed[begs:ends,]
sdate=sdate[begs:ends]
rdate=rdate[begs:ends]
str(fed)


# --------------- Final
fed_no_na <- fed
fed_no_na <- mutate(fed_no_na, sdate = as.Date(Date, format = "%m/%d/%Y")) 
#, rdate = as.Date(Dater, format = "%m/%d/%Y"))
fed_no_na[is.na(fed_no_na)] <- 0

# Check fed before mutating to see if variables are in basis points
# Convert RRPONTSYAWARD to numeric, handling non-numeric values
fed_no_na$RRPONTSYAWARD <- as.numeric(fed_no_na$RRPONTSYAWARD)

# Replace NA and non-numeric values with a default value (e.g., 0)
fed_no_na$RRPONTSYAWARD <- coalesce(fed_no_na$RRPONTSYAWARD, 0)

# Columns to exclude
columns_to_exclude <- c("sdate","Date", "Dater")
# "rdate",

# Multiply numeric columns by 100 but check to see if already in bp
fed_no_na <- fed_no_na %>%
  #mutate(across(-all_of(columns_to_exclude), ~ . *0.01))
  mutate(across(.cols = -columns_to_exclude, ~ ifelse(is.numeric(.), . * 100, .)))
str(fed_no_na)

# Send dataframe data to rmarkdown--------------------------------
# Create a new environment
my_env <- new.env()

# Store your data frame in the environment
my_envmp$fed_no_na <-fed_no_na

# Save the environment to an RDS file at end of job
saveRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/my_environmentmp.RDS")
#  rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates12112023.Rmd",envir= my_envmp)

# Remove weekends and holidays --------------------------------------
dts[lubridate::wday(dts) < 6]
sdate2 <- as.POSIXlt(sdate,format="%Y-%m-%d")

holidayNYSE(2016:2023)
sdate2$wday

# Subset Business Days at NYSE:
holidayNYSE()
isBizday(tS, holidayNYSE())
tS[isBizday(tS, holidayNYSE(2016:2023))]


wday(x, label = FALSE, abbr = TRUE, ordered = FALSE)
wday(sdate2, label = TRUE, abbr = TRUE, ordered = TRUE)
wday(sdate2, label = TRUE)
# wday()
# mday() and yday()
# promising 
library(dplyr)
library(timeDate)

# Assuming 'fed_no_na' is your data frame
# This works but destroys EFFR, SOFR so take subset of fed_no_na, recombine later
fed_no_na2<- fed_no_na[-c(5:8)]
str(fed_no_na2)
fed_no_na_filtered <- fed_no_na2 %>%
  filter(sdate %in% fed_no_na2$sdate[isBizday(fed_no_na2$sdate, holidayNYSE(2016:2023))])

# Display the modified dataframe
str(fed_no_na_filtered)
# 'data.frame':	2029 obs. of  5 variables:
#   $ Date    : chr  "3/4/2016" "3/7/2016" "3/8/2016" "3/9/2016" ...
# $ DFEDTARL: num  25 25 25 25 25 25 25 25 25 25 ...
# $ DFEDTARU: num  50 50 50 50 50 50 50 50 50 50 ...
# $ IORR    : num  50 50 50 50 50 50 50 50 50 50 ...
# $ sdate   : Date, format: "2016-03-04" "2016-03-07" "2016-03-08" "2016-03-09" ...

print(fed_no_na_filtered)

fed_no_na3<- fed_no_na[1:1960,5:8]
str(fed_no_na3)
# 'data.frame':	2842 obs. of  4 variables:
#   $ Dater        : chr  "3/4/2016" "3/7/2016" "3/8/2016" "3/9/2016" ...
# $ SOFR         : num  0 0 0 0 0 0 0 0 0 0 ...
# $ EFFR         : num  36 36 36 36 36 36 36 36 36 36 ...
# $ RRPONTSYAWARD: num  25 25 25 25 25 25 25 25 25 25 ...

fed_no_na_filtered[1:10,]
# Date DFEDTARL DFEDTARU IORR      sdate
# 1   3/4/2016       25       50   50 2016-03-04
# 2   3/7/2016       25       50   50 2016-03-07
# 3   3/8/2016       25       50   50 2016-03-08
# 4   3/9/2016       25       50   50 2016-03-09
# 5  3/10/2016       25       50   50 2016-03-10
# 6  3/11/2016       25       50   50 2016-03-11
# 7  3/14/2016       25       50   50 2016-03-14
# 8  3/15/2016       25       50   50 2016-03-15
# 9  3/16/2016       25       50   50 2016-03-16
# 10 3/17/2016       25       50   50 2016-03-17
fed_no_na3[1:10,]
# Dater SOFR EFFR RRPONTSYAWARD
# 4   3/4/2016    0   36            25
# 5   3/7/2016    0   36            25
# 6   3/8/2016    0   36            25
# 7   3/9/2016    0   36            25
# 8  3/10/2016    0   36            25
# 9  3/11/2016    0   36            25
# 10 3/14/2016    0   36            25
# 11 3/15/2016    0   36            25
# 12 3/16/2016    0   36            25
# 13 3/17/2016    0   36            25

tail(fed_no_na_filtered)
tail(fed_no_na3)
print(fed_no_na3[1955:1960,])
# Dater SOFR EFFR RRPONTSYAWARD
# 1958 12/12/2023    0   36            25
# 1959 12/13/2023    0   36            25
# 1960 12/14/2023    0   36            25

newfed<-dplyr::bind_cols(fed_no_na_filtered,fed_no_na3) 
# Error in `dplyr::bind_cols()`:
#   ! Can't recycle `..1` (size 2029) to match `..2` (size 1960).
# Run `rlang::last_trace()` to see where the error occurred.
# 
write.csv(fed_no_na_filtered, "C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/fedfiltered.csv", row.names=FALSE)
# Discrepancy in observations				
# start	end		
# filtered	2	2030	2028	
# sofr	2	1958	1956	72
# incident 5 times 8 years = 40 
# guess: days before or after holiday?
fed_no_na_filtered$weekday <- weekdays(fed_no_na_filtered$sdate)

str(fed_no_na_filtered)

# --------------------------------------
# 
# chatgpt
#   seems like you've pasted a large set of dates that were not filtered correctly. Unfortunately, the list is extensive, making it challenging to analyze in this format. However, I can provide some general guidance on how to address the issue.
# 
# Here are some steps you can take to troubleshoot and correct the filtering problem:
# 
# Check Filter Conditions: Review the conditions you are using for filtering. Ensure that the logic is correct and that you are not inadvertently excluding the dates you want to include.
# 
# Inspect Data Types: Confirm that the data types of the date columns match the types expected by your filtering logic. Sometimes, issues arise due to data type mismatches.
# 
# Debugging Output: Insert print statements or use a debugger to output intermediate results during the filtering process. This can help you identify where the filtering logic is going wrong.
# 
# Manual Inspection: Pick a few dates that you believe should be included based on your filtering conditions. Manually check these dates against your filtering logic to see if they match.
# 
# Handle Time Zones: If your dates include time information, be cautious about time zone differences. Ensure that your filtering logic considers the correct time zone.
# 
# 
# Display the dates that are not being filtered correctly
# > print(not_filtered_dates)
# date  date_char
# 1   2016-03-05 2016-03-05
# 2   2016-03-06 2016-03-06
# 3   2016-03-12 2016-03-12
# 4   2016-03-13 2016-03-13
# 5   2016-03-19 2016-03-19
# 6   2016-03-20 2016-03-20
# 7   2016-03-26 2016-03-26
# 8   2016-03-27 2016-03-27
# 9   2016-04-02 2016-04-02
# 10  2016-04-03 2016-04-03
# 11  2016-04-09 2016-04-09
# 12  2016-04-10 2016-04-10
# 13  2016-04-16 2016-04-16
# 14  2016-04-17 2016-04-17
# 15  2016-04-23 2016-04-23
# 16  2016-04-24 2016-04-24
# 17  2016-04-30 2016-04-30
# 18  2016-05-01 2016-05-01
# 19  2016-05-07 2016-05-07
# 20  2016-05-08 2016-05-08
# 21  2016-05-14 2016-05-14
# 22  2016-05-15 2016-05-15
# 23  2016-05-21 2016-05-21
# 24  2016-05-22 2016-05-22
# 25  2016-05-28 2016-05-28
# 26  2016-05-29 2016-05-29
# 27  2016-06-04 2016-06-04
# 28  2016-06-05 2016-06-05
# 29  2016-06-11 2016-06-11
# 30  2016-06-12 2016-06-12
# 31  2016-06-18 2016-06-18
# 32  2016-06-19 2016-06-19
# 33  2016-06-25 2016-06-25
# 34  2016-06-26 2016-06-26
# 35  2016-07-02 2016-07-02
# 36  2016-07-03 2016-07-03
# 37  2016-07-04 2016-07-04



# no idea if this is needed -----------------------

set.seed(123)
#date_column <- seq(as.Date("2023-01-01"), as.Date("2023-01-10"), by = "days")
date_column <- seq(as.Date("03/04/2016"), as.Date("12/14/2023"), by = "days")
value_column <- rnorm(10)
df <- data.frame(Date = date_column, Value = value_column)

# Identify weekends and holidays
weekends <- df[wday(df$Date) %in% c(1, 7), ]  # 1 is Sunday, 7 is Saturday
#holidays <- df[df$Date %in% as.Date(c("2023-01-02", "2023-01-06")), ]  # Example holidays
holidays <- df[df$Date %in% as.Date(c("03/01/2016", "12/14/2023")), ]  # Example holidays

# Find day of week -------------------------------------------
# Install and load the lubridate package
# Specify the date
wdate <- as.Date("2016-05-30") # Monday

# Get the day of the week
day_of_week <- weekdays(date)

# Print the result
print(day_of_week)

# Find day if holiday -------------------------------------------
# Install and load the timeDate package
install.packages("timeDate")

wdate <- as.Date("2016-05-30")

# Define a vector of US holidays
us_holidays <- as.Date(c("2016-01-01", "2016-07-04", "2016-12-25"))

# Check if the date is a business day (not a holiday)
is_bizday <- !isWeekend(wdate) & !wdate %in% us_holidays

# Print the result
 print(is_bizday)
# 2016-05-30 TRUE 


# Combine indices of weekends and holidays-------------------------
exclude_indices <- union(weekends$Date, holidays$Date)

# Remove rows corresponding to weekends and holidays
filtered_df <- df[!(df$Date %in% exclude_indices), ]

# View the result
print(filtered_df)


# Define shocks between entries t and t+1 as 0 if no change ----------------------
fedshocks<-c(DF# Example data frame fedshocks
fedshocks <- data.frame(
  DFEDTARL = c(1.5, 1.7, 1.8, 2.0),
  DFEDTARU = c(2.0, 2.2, 2.3, 2.5),
  RRPONTSYAWARD = c(3.5, 3.7, 3.8, 4.0),
  IORR = c(4.0, 4.2, 4.3, 4.5)
)

# Calculate the changes between successive values
changes <- lapply(fedshocks, function(x) c(NA, diff(x)))

# Create a new data frame with the changes
changes_df <- data.frame(changes)

# Print the result
print(changes_df)

