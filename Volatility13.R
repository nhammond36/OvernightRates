# Loading
library("dplyr")
library(tidyverse)
library(dslabs)
library(lubridate)
library(rugarch)
library(xts)
library(rmgarch)
library(maxLik)
library("plyr")
library(ggplot2)
library(openai)
library(kableExtra)
library(lattice)
library(knitr)
library(xtable)
library(quarto)
library(zoo)
library(gridExtra)
library(e1071)
library(ggridges)
library(viridis)
library(Rfast)
library(car)
library(MASS)
library(fitdistrplus)
library(reshape2)
library(tseries)
library(PerformanceAnalytics)
library(FinTS)
library(urca)
library(timeDate)
library(quantmod)
library(DescTools)
library(chron)
library(patchwork)
library(gridExtra)
library(cowplot)


###installing and loading multiple packages
list.packages<-c("fGarch", "PerformanceAnalytics","rugarch","tseries","xts","FinTS", "urca")
new.packages <- list.packages[!(list.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
#Loading Packages
invisible(lapply(list.packages, require, character.only = TRUE))

#  ----------------- Github repository
# see https://rfortherestofus.com/2021/02/how-to-use-git-github-with-r/
# https://github.com/nhammond36/OvernightRates.git
# The most straightforward way to use RStudio and GitHub together is to create 
# - a repo on GitHub first. Create the repo, 
# - then when you start a new project in RStudio, use the version control option, enter your repo URL, and you're good to go.

# --------------- READ DATA ------------------
redo<-0 # load rate data from RDS files
redo<-1 # redo data 
# Nested if-else statements
if (redo ==0 ) {
  # Load rate data
  my_envmp <- readRDS("C:/Users/Owner/Documents/Research/OvernightRates/my_envmp.RDS")#Access the data frame stored in the environment
  spread_no_na <- my_envmp$spread_no_na
  str(spread_no_na)
} else {
  print("redo==1")
  
# Find outlier-------------------------------
  ue=spread_no_na$TargetUe
  max(ue)
  de=spread_no_na$TargetDe
  max(de)
  # Find row numbers where spread$TargetUE meets a condition (for example, equals 0)
  rownum <- which(spread_no_na$sdate ==  "2019-09-17")
  # Find rows where spread$TargetUE equals 0
  rows_with_zero <- subset(spread_no_na, TargetUe == 0)
  
  rownum <- which(spread_no_na$sdate ==  "2019-09-17")
  > rownum
  [1] 891
  
  
#--------------------------------------------------
# or redo rates data
spread<-read.csv("C:/Users/Owner/Documents/Research/OvernightRates/Final data files/NYFedReferenceRates_12172023v5.csv",header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE)
# Convert to numeric and replace non-numeric values with NA
# spread$IORR <- as.numeric(as.character(spread_no_na$IORR))
# spread$IORR[is.na(spread_no_na$IORR) | spread_no_na$IORR == "#N/A"] <- NA
# spread$RRPONTSYAWARD <- as.numeric(as.character(spread$RRPONTSYAWARD))
spread$RRPONTSYAWARD [is.na(spread$RRPONTSYAWARD) | spread$RRPONTSYAWARD  == "#N/A"] <- NA
print(colnames(spread))
str(spread)
sdate<-as.Date(spread$Date,format="%m/%d/%Y")

# I added DPCREDIT, h, and st_effr
#spread_no_na$sd_effr<-spread$sd_effr[1:1957]
#my_envmp$spread_no_na <-spread_no_na
#saveRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envmp.RDS")
#str( my_envmp$spread_no_na)

# Find the row number for the beginning and end dates of the sample: where  "3/4/2016" occurs and 12/29/2022 for the first time
# Check which index corresponds to the specified dates
begs <- which(sdate == as.Date("2016-03-04")) 
ends <- which(sdate == as.Date("2023-12-14")) 
print(begs) #[1] 4spr
print(ends) #[1] 1960
spread=spread[begs:ends,]
sdate=sdate[begs:ends]sdate
str(spread)

spread_no_na <- spread
spread_no_na <- mutate(spread_no_na, sdate = as.Date(Date, format = "%m/%d/%Y"))
spread_no_na[is.na(spread_no_na)] <- 0
columns_to_exclude <- c("Date","sdate")
spread_no_na <- spread_no_na %>%
  mutate_at(vars(-one_of(columns_to_exclude)), as.numeric)
str(spread_no_na)
#print(spread_no_na)
}

readRDS(my_envepisodes, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envepisodes.RDS")
readRDS(my_envvolatile, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envvolatile.RDS")

# olsgmm 
source("C:/Users/Owner/Documents/Research/OvernightRates/CodeMI/olsgmmv3.R")

jshocks <- read.csv('C:/Users/Owner/Documents/Research/OvernightRates/Final data files/fomc_surprises_jkv2.csv', header=TRUE, sep=",", dec=".",stringsAsFactors=FALSE)
#FF1	FF2	FF3	FF4	MP1	ED1	ED2	ED3	ED4	TFUT02	TFUT05	TFUT10	TFUT30	SP500	SP500FUT
#  str(jshocks)
#'data.frame':	359 obs. of  17 variables:
#mshocks=read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv8.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE,skip=4));
#class(spread)
#mshocks %>% replace(is.na(.),0)
#str(mshocks)


# Daily data frames overnight rates and volumes -rrbp and vold------------------------
# rrbp daily volume weighted median overnight reference rates
rrbp <-  spread_no_na[, c("sdate","EFFR","TGCR","BGCR","SOFR")]
head(rrbp)
str(rrbp)

# Jarocisnski or GSS data set VARs---------------------------------------------------
# Ensure the 'start' column in jshocks is a Date object
jshocks$start <- as.Date(jshocks$start, format = "%m/%d/%Y")
#\url{https://www.federalreserve.gov/econres/feds/do-actions-speak-louder-than-words-the-response-of-asset-prices-to-monetary-policy-actions-and-statements.htm}
# FF1	FF2	FF3	FF4	MP1	ED1	ED2	ED3	ED4	TFUT02	TFUT05	TFUT10	TFUT30	SP500	SP500FUT
# Fed Futures, Eurodollars
# GSS database identifiers. MP1, or the first fed funds future adjusted for
# the number of the remaining days of the month (see GSS for details) is the expected fed
# funds rate after the meeting. ONRUN2 and ONRUN10 are the 2- and 10-year Treasury
# ECB Working Paper Series No 2585 / August 2021 6


# dataset of Gurkaynak et al. (2005) (GSS from now on) updated by Gurkaynak et al. (2022). 
# This dataset contains the changes of financial variables in a 30-minute window around FOMC 
# announcements (from 10 minutes before to 20 minutes after the announcement). 
# The sample studied here contains 241 FOMC announcements from 5 July 1991 to 19 June 2019.

# Merge the dataframes on the date columns
merged_data <- rrbp %>%
  left_join(jshocks, by = c("sdate" = "start"))

# Replace NA values with zero for the jshocks columns
# Assuming the first 6 columns are from rrbp, and the rest are from jshocks
merged_data[is.na(merged_data)] <- 0

# Check the result
str(merged_data)

# Now you can run your simple regression
# Assuming 'rrbp' is one of the variables in the merged data, like 'EFFR'
# Example regression: EFFR ~ some variables from jshocks
lm_model <- lm(EFFR ~ FF1 + FF2 + FF3 + FF4 + MP1 + ED1 + ED2 + ED3 + ED4 + TFUT02 + TFUT05 + TFUT10 + TFUT30 + SP500 + SP500FUT, data = merged_data)

# Check the summary of the regression model
summary(lm_model)


# Var
# Define the moment conditions function
gmm_moments <- function(theta, data) {
  # Extract parameters
  b <- theta[1:length(theta)]
  
  # Define the residuals
  y <- data[, 1]
  X <- data[, -1]
  residuals <- y - X %*% b
  
  # Moment conditions: should be zero on average
  g <- residuals * X
  return(g)
}

# Prepare the data
# Here we assume merged_data is already prepared and cleaned as in the previous example

# Select the relevant columns for the GMM model
gmm_data <- merged_data %>% select(EFFR, FF1, FF2, FF3, FF4, MP1, ED1, ED2, ED3, ED4, TFUT02, TFUT05, TFUT10, TFUT30, SP500, SP500FUT)

# Initial parameter guesses (could be zeros or OLS estimates)
init_params <- rep(0, ncol(gmm_data) - 1)

# Run the GMM model
gmm_model <- gmm(gmm_moments, x = as.matrix(gmm_data), t0 = init_params)

# Summary of the GMM model
summary(gmm_model)


# Define the moment conditions function
gmm_moments <- function(theta, data) {
  # Extract parameters
  b <- theta[1:length(theta)]
  
  # Define the residuals
  y <- data[, 1]
  X <- data[, -1]
  residuals <- y - X %*% b
  
  # Moment conditions: should be zero on average
  g <- residuals * X
  return(g)
}

# Prepare the data
# Here we assume merged_data is already prepared and cleaned as in the previous example

# Select the relevant columns for the GMM model
# Check the column names in merged_data
names(merged_data)

# Select the relevant columns for the independent and dependent variables
y_data <- merged_data %>%
  select(merged_data$EFFR, merged_data$TGCR, merged_data$BGCR, merged_data$SOFR)

x_data <- merged_data %>%
  select(FF1, FF2, FF3, FF4, MP1, ED1, ED2, ED3, ED4, TFUT02, TFUT05, TFUT10, TFUT30, SP500, SP500FUT)

gmm_data <- cbind(y_data, x_data)

# Define the moment conditions function for multiple y variables
gmm_moments <- function(theta, data) {
  # Number of dependent variables
  num_y <- ncol(y_data)
  
  # Extract parameters
  b <- matrix(theta, nrow = ncol(x_data), ncol = num_y)
  
  # Define the residuals
  y <- as.matrix(data[, 1:num_y])
  X <- as.matrix(data[, -(1:num_y)])
  residuals <- y - X %*% b
  
  # Moment conditions: should be zero on average
  g <- residuals * X
  return(as.vector(g))
}




#------------------------------------------------
secured <-  spread_no_na[, c("sdate","TGCR","BGCR","SOFR")]
str(secured)

# Convert VolumeEFFR column to numeric
spread_no_na$VolumeEFFR <- as.numeric(spread_no_na$VolumeEFFR)
# Convert VolumeOBFR column to numeric
spread_no_na$VolumeOBFR <- as.numeric(spread_no_na$VolumeOBFR)

vold <- spread_no_na[, c("sdate","VolumeEFFR", "VolumeOBFR", "VolumeTGCR", "VolumeBGCR", "VolumeSOFR" )]
head(vold)
str(vold)

# Important spreads
sofrior<-spread_no_na$SOFR-spread_no_na$IORR;
sofrrrpp<-spread_no_na$SOFR-spread_no_na$RRPONTSYAWARD;

# target<- select(spread,TargetDe,TargetUe);
vdsum <- colSums(vold[, sapply(vold, is.numeric)], na.rm = TRUE)
# VolumeEFFR VolumeOBFR VolumeTGCR VolumeBGCR VolumeSOFR 
# 154338     415674     579310     607225    1471252        



# Quantiles -------------------------------------------
# Define a color palette  FOLLOW EXAMPLE FOR RRBP
# my_color_palette <- c("EFFR" = "darkblue", "OBFR" = "darkgreen", "TGCR" = "darkred", "BGCR" = "darkcyan", "SOFR" = "darkorange")

quantilesE <- spread_no_na[, c("sdate", "EFFR", "VolumeEFFR", "TargetUe", "TargetDe", "Percentile01_EFFR", "Percentile25_EFFR", "Percentile75_EFFR", "Percentile99_EFFR")]
quantilesO <- spread_no_na[, c("sdate", "OBFR", "VolumeOBFR", "Percentile01_OBFR", "Percentile25_OBFR", "Percentile75_OBFR", "Percentile99_OBFR")]
quantilesT <- spread_no_na[, c("sdate","TGCR","VolumeTGCR","Percentile01_TGCR","Percentile25_TGCR","Percentile75_TGCR","Percentile99_TGCR")]
quantilesB <- spread_no_na[, c("sdate","BGCR","VolumeBGCR","Percentile01_BGCR","Percentile25_BGCR","Percentile75_BGCR","Percentile99_BGCR")]
quantilesS <- spread_no_na[, c("sdate","SOFR","VolumeSOFR","Percentile01_SOFR","Percentile25_SOFR", "Percentile75_SOFR", "Percentile99_SOFR")]



# ----------------------- Different realized volatility measures
  # Use 252 day trailing window of std calculate three ways
  # Volatility is calculated using publicly released weekly snapshots for 
  # 52-week trailing windows, as the standard deviation of the first difference
  # M = movstd(A,k) returns an array of local k-point standard deviation value
  # a. log(r_t)-log(r_{t+1})
  # b. std deviation (log(r_t)-log(r_{t+1}))
  # c. movstd(vol_b,244) with kernel K=244 or 252
  # Both models are estimated via OLS on daily data, using a 260-day rolling window 
  # to allow their parameters to adapt to a changing environment.
  # 
  # Hamilton Figure 1 displays the sample histogram for fid, drawn for comparison with the Normal distribution. Forty-six percent of the observations are exactly zero, 
  # while 25 observations exceed 5 standard deviations. If fid were an i.i.d. Gaussian time series, one would not expect to see even one 5 standard deviation outlier. Often these outliers occur on days that Gurkaynak, Sack, and
  # 
  # While GARCH, FIGARCH and stochastic volatility models propose statistical
  # constructions which mimick volatility clustering in financial time series, they
  # do not provide any economic explanation for it.
  # 
  # Duffie Among our other explanatory variables are measures of the volatility of the federal funds rate and of the 
  # strength of the relationship between pairs of counterparties.
  # To capture the volatility of the federal funds rate, we start with 
  # a dollar-weighted average during a given minute t of the interest rates of all loans made in that minute. 
  # We then measure the time-series sample standard deviation of these minute-by-minute average rates 
  # over the previous 30 minutes, denoted or(t). 
  # The median federal funds rate volatility is about 3 basis points, but ranges from under 1 basis point to 87 basis points, 
  # with a sample standard deviation of 4 basis points. Our measure of sender-receiver relationship strength for a particular 
  # pair (i,j) of counterparties, denoted Sij, is the dollar volume of transactions sent by i to j over the previous month 
  # divided by the dollar volume of all transactions sent by i to the top 100 institutions. The receiver-sender relationship 
  # strength Rij is the dollar volume of transactions received by i from j over the previous month divided by the dollar 
  # volume of all transactions received by i from j
  # 
  # The formal definition of the primary metric I study, market volatility, is the standard deviation of 1
  # minute returns: 
  # si⌃N=sqrt(sum 1 through n(ri -rbar)^2/(n-1))


# Choose full sample or episode

k=6 # full sample
bgn<-begn[k]
edn<-endn[k]

# LOG PERCENT CHANGE OF MEDIAN RATES

# evaluate_episode <- function(episode) {
#   result <- case_when(
#     alternative == 1 ~ "Alternative 1 chosen.",
#     alternative == 2 ~ "Alternative 2 chosen.",
#     alternative == 3 ~ "Alternative 3 chosen.",
#     TRUE ~ "Invalid alternative."
#   )
#   
#   return(result)
# }


# Using a for loop to print numbers from 1 to 5
# Example initialization (adjust based on your data dimensions)
nmat <- 6
ncl <- 5
max_rows <- max(endn - begn) + 1

# Initialize a list to store matrices
# In this example, measure_list1 and measure_list2 are lists where each element 
# corresponds to a different k, and each element is a matrix with dimensions 
# determined by the range of rows and ncl columns. You can access individual 
# matrices for further analysis or visualization.
# 
# This approach provides flexibility and allows you to store matrices with 
# varying dimensions based on the specific requirements for each k.

# Access individual matrices for further analysis or visualization
norm_measure1 <- measure_list1[[1]]
adjust_measure1 <- measure_list1[[2]]
covid_measure1 <- measure_list1[[3]]
zlb_measure1 <- measure_list1[[4]]
inflation_measure1 <- measure_list1[[5]]
sample_measure1 <- measure_list1[[6]]

second_matrix_measure2 <- measure_list2[[2]]
# ... and so on

nmat <- 6
ncl <- 5
max_rows <- max(endn - begn) + 1

# Initialize a list to store matrices
measure_list1 <- vector("list", length = nmat)
measure_list2 <- vector("list", length = nmat)

for (k in 1:nmat) {
  bgn <- begn[k]
  edn <- endn[k]
  
  if (bgn >= 1 & bgn < edn) {
    rows_in_range <- (bgn + 1):edn
    
    # Calculate measures for each k
    measure_list1[[k]] <- log(rrbp[rows_in_range, 2:(1 + ncl)]) - log(rrbp[bgn:(edn - 1), 2:(1 + ncl)])
    measure_list2[[k]] <- abs(rrbp[rows_in_range, 2:(1 + ncl)] - rrbp[bgn:(edn - 1), 2:(1 + ncl)])
  } else {
    print(paste("Invalid indices for k =", k))
  }
}

# Access individual matrices for further analysis or visualization
norm_measure1 <- measure_list1[[1]]
adjust_measure1 <- measure_list1[[2]]
covid_measure1 <- measure_list1[[3]]
zlb_measure1 <- measure_list1[[4]]
inflation_measure1 <- measure_list1[[5]]
sample_measure1 <- measure_list1[[6]]

norm_measure1[is.na(norm_measure1)] <- 0
adjust_measure1[is.na(adjust_measure1)] <- 0
covid_measure1[is.na(covid_measure1)] <- 0
zlb_measure1[is.na(zlb_measure1)] <- 0
inflation_measure1[is.na(inflation_measure1)] <- 0
sample_measure1[is.na(sample_measure1)] <- 0

volmeasuresnorm <- data.frame(
  norm_measure1 = norm_measure1)

volmeasuresadjust <- data.frame(
  adjust_measure1 = adjust_measure1)

volmeasurescovid <- data.frame(
  covid_measure1 = covid_measure1)

volmeasureszlb <- data.frame(
  zlb_measure1 = zlb_measure1)

volmeasuresinflation <- data.frame(
  inflation_measure1 = inflation_measure1)

volmeasuressample <- data.frame(
  sample_measure1 = sample_measure1)

# just ensure that this separation aligns with your analysis or visualization requirements. 
# If you later need to combine these data frames or perform operations across measures,
# you may need to handle the different lengths and possibly use functions like merge or cbind in R

# Assuming first_matrix_measure1 is your matrix
# df <- as.data.frame(first_matrix_measure1)
# 
# # Create a scatter plot using ggplot2
# ggplot(df, aes(x = 1:ncl, y = rownames(df))) +
#   geom_point() +
#   labs(title = "Scatter Plot of first_matrix_measure1",
#        x = "Column Index",
#        y = "Row Index")


library(ggplot2)
library(tidyr)

# Assuming first_matrix_measure1 is your matrix
# Assuming sdate is your date vector

# Assuming col_names is a vector of column names
col_names <- c("sdate","EFFR", "OBFR", "TGCR", "BGCR", "SOFR")

# Assign column names to rrbp
colnames(rrbp) <- col_names
colnames(norm_measure1) <- col_names
colnames(adjust_measure1) <- col_names
colnames(covid_measure1) <- col_names
colnames(zlb_measure1) <- col_names
colnames(inflation_measure1) <- col_names
colnames(sample_measure1) <- col_names


# Add log percent change to env
# my_envvolatile$norm_measure1<-volmeasuresnorm
# my_envvolatile$adjust_measure1<-volmeasuresnormadjust
# my_envvolatile$covid_measure1<-volmeasuresnormcovid
# my_envvolatile$zlb_measure1<-volmeasureszlb
# my_envvolatile$inflation_measure1<-volmeasuresinflation
# my_envvolatile$sample_measure1<-volmeasuressample

my_envvolatile$volnorm<-norm_measure1
my_envvolatile$voladjust<-adjust_measure1
my_envvolatile$volcovid<-covid_measure1
my_envvolatile$volzlb<-zlb_measure1
my_envvolatile$volinflation<-inflation_measure1
my_envvolatile$volsample<-sample_measure1



# sdate<-as.Date(spread$Date,format="%m/%d/%Y")
# Create a dataframe
# Norm episode
df <- as.data.frame(norm_measure1)
df$OBFR <- NULL
k=1
bgn<-begn[k]
edn<-endn[k]-1
start_dates <-sdate[bgn]
end_dates <-sdate[edn]
start_dates_strings <- as.character(start_dates)
end_dates_strings <- as.character(end_dates)
df$sdate <- sdate[bgn:edn]


# temporary for one time error--------------------
# Subset the data frame to exclude the sdate column
#df_without_sdate <- df[, !names(df) %in% "sdate"]
# Multiply all variables in the subsetted data frame by 100
#df_without_sdate <- df_without_sdate * 100
# Combine sdate column back to the modified data frame
#df_modified <- cbind(sdate = df$sdate, df_without_sdate)
#-----------------------------------------------------

# Reshape the data to long format
df_long <- gather(df, key = "Variable", value = "Value", -sdate)
title <- paste("Percent change rates normalcy period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])
#title <- paste("Percent change in rates during normalcy period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])

# Create a scatter plot using ggplot2
logchange_rates_norm<-ggplot(df_long, aes(x = sdate, y = Value, color = Variable)) +
  geom_point() +
  labs(caption = title,
       x = "",
       y = "percent change in basis points",
       color = "Variable") +
  theme_minimal()
print(logchange_rates_norm)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates2_norm.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates2_norm.png")

# adjust episode
sdate<-as.Date(spread$Date,format="%m/%d/%Y")
k=2
df <- as.data.frame(adjust_measure1)
df$OBFR <- NULL
df <- df*100
bgn<-begn[k]
edn<-endn[k]-1
start_dates <-sdate[bgn]
end_dates <-sdate[edn]
start_dates_strings <- as.character(start_dates)
end_dates_strings <- as.character(end_dates)
df$sdate <- sdate[bgn:edn]
title <- paste("Percent change rates adjustment period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])


# Reshape the data to long format
df_long <- gather(df, key = "Variable", value = "Value", -sdate)
logchange_rates_adjust<-ggplot(df_long, aes(x = sdate, y = Value, color = Variable)) +
  geom_point() +
  labs(caption = title,
       x = "",
       y = "percent change in basis points",
       color = "Variable") +
  theme_minimal()
print(logchange_rates_adjust)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_adjust2.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_adjust2.png")
# Problem, month instead of date

# covid episode
sdate<-as.Date(spread$Date,format="%m/%d/%Y")
k=3
df <- as.data.frame(covid_measure1)
df$OBFR <- NULL
df <- df*100
bgn<-begn[k]
edn<-endn[k]-1
start_dates <-sdate[bgn]
end_dates <-sdate[edn]
start_dates_strings <- as.character(start_dates)
end_dates_strings <- as.character(end_dates)
df$sdate <- sdate[bgn:edn]
title <- paste("Percent change rates covid period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])

# Reshape the data to long format
df_long <- gather(df, key = "Variable", value = "Value", -sdate)
# Create a scatter plot using ggplot2
logchange_rates_covid<-ggplot(df_long, aes(x = sdate, y = Value, color = Variable)) +
  geom_point() +
  labs(caption = title,
       x = "",
       y = "percent change in basis points",
       color = "Variable") +
  theme_minimal()
print(logchange_rates_covid)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_covid2.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_covid2.png")
# month instead of date

# zlb episode
sdate<-as.Date(spread$Date,format="%m/%d/%Y")
k=4
df <- as.data.frame(zlb_measure1)
df$OBFR <- NULL
df <- df*100
bgn<-begn[k]
edn<-endn[k]-1
start_dates <-sdate[bgn]
end_dates <-sdate[edn]
start_dates_strings <- as.character(start_dates)
end_dates_strings <- as.character(end_dates)
title <- paste("Percent change rates zero lower bound period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])
df$sdate <- sdate[bgn:edn]

# Reshape the data to long format
df_long <- gather(df, key = "Variable", value = "Value", -sdate)

# Create a scatter plot using ggplot2
logchange_rates_zlb<-ggplot(df_long, aes(x = sdate, y = Value, color = Variable)) +
  geom_point() +
  labs(caption = title,
       x = "",
       y = "percent change in basis points",
       color = "Variable") +
  theme_minimal()
print(logchange_rates_zlb)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_zlb2.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_zlb2.png")

# Inflation episode
sdate<-as.Date(spread$Date,format="%m/%d/%Y")
k=5
df <- as.data.frame(inflation_measure1)
df$OBFR <- NULL
df <- df*100
bgn<-begn[k]
edn<-endn[k]-1
start_dates <-sdate[bgn]
end_dates <-sdate[edn]
start_dates_strings <- as.character(start_dates)
end_dates_strings <- as.character(end_dates)
df$sdate <- sdate[bgn:edn]
title <- paste("Percent change rates during inflation period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])

# Create a scatter plot using ggplot2
df$SOFR[is.infinite(df$SOFR)] <- 0
df$TGCR[is.infinite(df$TGCR)] <- 0
df$BGCR[is.infinite(df$BGCR)] <- 0

# Reshape the data to long format
df_long <- gather(df, key = "Variable", value = "Value", -sdate)
maxr<-max(df[,1:4])
logchange_rates_inflation<- ggplot(df_long, aes(x = sdate, y = Value, color = Variable)) +
  geom_point() +
  labs(caption = title,
       x = "",
       y = "percent change in basis points",
       color = "Variable") +
  scale_y_continuous(breaks = seq(0, maxr, by = 5)) + # Set breaks every 10 basis points
  #scale_y_continuous(breaks = seq(0, maxr, by = 5), limits = c(0, maxr)) + 
  theme_minimal()
  #theme(panel.grid = element_blank()) 
print(logchange_rates_inflation)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_inflation2.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_inflation2.png")

# Full sample
sdate<-as.Date(spread$Date,format="%m/%d/%Y")
k=6
df <- as.data.frame(sample_measure1)
df <- df*100
df$OBFR <- NULL
bgn<-begn[k]
edn<-endn[k]-1
start_dates <-sdate[bgn]
end_dates <-sdate[edn]
start_dates_strings <- as.character(start_dates)
end_dates_strings <- as.character(end_dates)
title <- paste("Percent change in rates during full sample", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])
#figure_number <- 10
#title <- paste("Figure", figure_number, ": Log percent change in rates during normalcy period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])
df$sdate <- sdate[bgn:edn]

# Reshape the data to long format
df_long <- gather(df, key = "Variable", value = "Value", -sdate)
# add figure number

# Center the title and add figure number
# plot_with_title <- plot +
#   labs(title = paste("Log percent change in rates during normalcy period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])) +
#   theme(plot.title = element_text(hjust = 0.5)) +
#   labs(caption = paste("Figure", figure_number))
# Create a scatter plot using ggplot2
logchange_rates_sample<-ggplot(df_long, aes(x = sdate, y = Value, color = Variable)) +
  geom_point() +
  labs(caption = title,
       x = "",
       y = "percent change in basis points",
       color = "Variable") +
  #theme(plot.title = element_text(hjust = 0.5))
  #labs(caption = paste("Figure", figure_number))
  theme_minimal()
print(logchange_rates_sample)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_sample.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/logchange_rates_sample.png")


#p<-(rates_norm | rates_adjust | rates_covid) / (rates_zlb | rates_inflation)
#pctchange<-(logchange_rates_norm | logchange_rates_adjust) / (logchange_rates_covid | logchange_rates_zlb) | logchange_rates_inflation 
#pctchange<-(logchange_rates_norm )/ (logchange_rates_adjust) / (logchange_rates_covid) / (logchange_rates_zlb)/ (logchange_rates_inflation )
#pctchange<-grid.arrange(logchange_rates_norm, logchange_rates_adjust, logchange_rates_covid, logchange_rates_zlb, logchange_rates_inflation, ncol=1 )
#pctchange <- plot_grid(logchange_rates_norm, logchange_rates_adjust, logchange_rates_covid, logchange_rates_zlb, logchange_rates_inflation, ncol = 1)
# Assuming logchange_rates_inflation is a ggplot object
# logchange_rates_inflation <- logchange_rates_inflation + 
#   theme(
#     plot.width = unit(4, "in"),  # Adjust the width as desired
#     plot.height = unit(3, "in")  # Adjust the height as desired
#   )
# print(logchange_rates_inflation

# Assuming logchange_rates_norm, logchange_rates_adjust, logchange_rates_covid, logchange_rates_zlb, and logchange_rates_inflation are ggplot objects
#pctchange <- logchange_rates_norm + logchange_rates_adjust + logchange_rates_covid + logchange_rates_zlb + logchange_rates_inflation
#print(pctchange)


# This works
library(patchwork)
pctchange<-(logchange_rates_norm | logchange_rates_adjust) / (logchange_rates_covid | logchange_rates_zlb) / (logchange_rates_inflation | logchange_rates_sample)
print(pctchange)

pctchange2 <- (logchange_rates_inflation | logchange_rates_sample)
print(pctchange2)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/percentchange.pdf",pctchange2)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/percentchange.png",pctchange2)

ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.pdf", pctchange)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.png", pctchange)



#my_color_palette <- c("EFFR" = "darkblue", "OBFR" = "darkgreen", "TGCR" = "darkred", "BGCR" = "darkcyan", "SOFR" = "darkorange")


# 3)MULTIVARIATE ROLLING STD DEVIATION -------------------
nday <- 5
sdates <- measure1$sdate  # Assuming sdate is the column containing dates

# Select the first five columns of measure1 for calculation, excluding sdate
measure_subset <- measure1[, 1:5]
# Apply rolling standard deviation directly on the data frame
sdrates <- rollapply(measure_subset, width = nday, FUN = sd, align = "right", fill = NA)
sdates[is.na(sdrates)]<-0

# Convert the result to a data frame
sdrates <- as.data.frame(sdrates)

# Print the structure of sdrates
str(sdrates)

# Check against chatgpt DUPLICATE
# Apply rolling standard deviation directly on the data frame
sdrates <- rollapply(measure_subset, width = nday, FUN = sd, align = "right", fill = NA)

# Convert the result to a data frame
sdrates <- as.data.frame(sdrates)

# Print the structure of sdrates
str(sdrates)
sdrates[is.na(sdrates)] <- 0


str(sdrates)
# 'data.frame':	1956 obs. of  5 variables:
# $ EFFR: num  0.0274 0 -0.0274 0 0 ...
# $ OBFR: num  0 0 0 0 0 0 0 0 0 0 ...
# $ TGCR: num  0 0 0 0 0 0 0 0 0 0 ...
# $ BGCR: num  0 0 0 0 0 0 0 0 0 0 ...
# $ SOFR: num  0 0 0 0 0 0 0 0 0 0 ...
nrow(sdrates)

sdrates$sdate<-sdate[1:nrow(sdrates)]
str(sdrates)

mxq = max(sdrates[,1:5])
mnq = min(sdrates[,1:5])
print(mxq) # 1.089607
print(mnq) # 0

my_envvolatile$sdrates

meltsdrates <- melt(sdrates,id="sdate")
plotsdrates <- ggplot(meltsdrates,aes(x=sdate,y=value,colour=variable,group=variable)) + 
  geom_point(size = 1, shape = 16) +
  labs(x="Date",  y = "Pct Change Basis Points (bp)", color = "Std dev pct change", shape = "Std dev pct change") +  
  scale_y_continuous(breaks = seq(0, mxq, by = .05), limits = c(0, mxq)) + 
  theme_minimal() + guides(shape = guide_legend(title = "Pct change"))
# + theme(axis.title.x=element_blank(), axis.text.x= element_text(size=8,vjust =.5))
print(plotsdrates)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/plotsdrates.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/plotsdrates.png")



# DUFFIE KRISHNAMURTHY dispersion index ------------------------------------
# We let yi,t(m) denote the rate at time t on instrument i, maturing in m days. We first
# adjust the rate to remove term-structure effects, 
# obtaining the associated "overnight-equivalent” rate as
# yhat_(i,t) = yi,t(m) − (OISt(m) − OISt(1)), (4.1)
# The dispersion index D at day t as the weighted mean absolute deviation of the cross-sectional adjusted rate
# distribution on that day. That is,
# D_t =1/ (sum_{i}^{}v_{i,t}) times 
# (sum_{i}^{}v_{i,t} |yhat_{i,t} − y¯t|) (4.2)
# where vi,t is the estimated outstanding amount of this instrument on day t, in dollars,
# and y¯t is the volume-weighted mean rate, defined by
# y¯t = [(sum_{i}^{}(v_{i,t}) times yhat_{i,t})]/(sum_{i}^{}v_{i,t})



# Initialize vtot(t) and mrate(t) to zero
# Assuming 'dk' is your data frame or matrix
# Specify the number of columns to sum (e.g., the first 5 columns)


# Initialize vectors to store results
T<-nrow(rrbp)
rcol<-5
meanr<- colMeans(rrbp[,2:rcol])
print(meanr)
# EFFR     OBFR     TGCR     BGCR     SOFR 
# 156.2080 155.5207 132.0189 132.0358 133.2616 
 
#colsumvold <-rowSums(vold[ , c(2,3,4,5,6)], na.rm=TRUE)
colsumvold <-rowSums(vold[ , 2:rcol], na.rm=TRUE)
print(colsumvold)
colsumvold[1:10]
#[1] 1739 1730 1714 1691 1671 1693 1705 1656 1658 1641

# Initialize a w x t array
dk <- array(0, dim = c(T,rcol-1))
nrow(dk) #[1] 1957
dkindex<-array(0,T)
nrow(dkindex) # [1] 1957
 
#vold and rrbp col1=sdate, cols 2:6 EFFR OBFR  TGCR BGCRSOFR
T<-nrow(rrbp)
rcol<-ncol(rrbp)
# Calculate dk(t)
for (t in 1:T) {
  for (i in 2:rcol) {
    dk[t, i-1] <- (1 / colsumvold[t]) * vold[t,i]*abs(rrbp[t, i] - meanr[i-1])
  }
}

# Calculate dkindex(t)
for (t in 1:T) {
  dkindex[t] <- sum(dk[t, 1:rcol-1])
}

dkindexdf <- data.frame(
  sdate = spread_no_na$sdate,
  dkindex,
  TargetDe = spread_no_na$TargetDe,
  TargetUe = spread_no_na$TargetUe,
  EFFR = spread_no_na$EFFR,
  #OBFR = spread_no_na$OBFR,
  TGCR = spread_no_na$TGCR,
  BGCR = spread_no_na$BGCR,
  SOFR = spread_no_na$SOFR
)
str(dkindexdf)
my_envvolatile$dkindex<-dkindexdf

# # Specify columns to remove
# columns_to_remove <- c("Age", "Score")
# # Remove specified columns
# my_data <- my_data[, -which(names(my_data) %in% columns_to_remove)]



mxq = max(dkindex)
mnq = min(dkindex)
print(mxq) #  401.1328  OLD 399.8723
print(mnq) #  10.03117  OLD  10.17096

# meltdkindex <- melt(dkindex,id="sdate")
# dk <- ggplot(meltdkindex,aes(x=sdate,y=value,colour=variable,group=variable)) + 
#   geom_point(size = 1, shape = 16) +
#   labs(x="Date",  y = "Duffie Krishnamurthy index", color = "Dispersion", shape = "Dispersion") +  
#   scale_y_continuous(breaks = seq(0, mxq, by = 10), limits = c(0, mxq)) + 
#   theme_minimal() + guides(shape = guide_legend(title = "Pct change"))
# # + theme(axis.title.x=element_blank(), axis.text.x= element_text(size=8,vjust =.5))
# print(dk)

# Create a variable for group names
# Ensure sdate is of type Date
dkindexdf$sdate <- as.Date(dkindexdf$sdate)

## Friday April 5
library(ggplot2)

# Plotting
ggdkindex<-ggplot(dkindexdf, aes(x = sdate)) +
  
  # Adding TargetDe and TargetUe as ribbons of light gray
  geom_ribbon(aes(ymin = TargetDe, ymax = TargetUe, color = "Target Range"), fill = "lightgray", alpha = 0.5) +
  
  # Adding EFFR, TGCR, BGCR, and SOFR as symbols with different colors
  geom_point(aes(y = EFFR, color = "EFFR"), shape = 16, size = 1) +
  geom_point(aes(y = TGCR, color = "TGCR"), shape = 16, size = 1) +
  geom_point(aes(y = BGCR, color = "BGCR"), shape = 16, size = 1) +
  geom_point(aes(y = SOFR, color = "SOFR"), shape = 16, size = 1) +
  
  # Adding dkindex as red triangles
  geom_point(aes(y = dkindex, color = "Duffie-Krishnamurthy index"), shape = 17) +
  
  # Labels and theme adjustments
  labs(x = "Date", y = "Value", color = "Variable") +
  scale_color_manual(values = c("EFFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "purple", "Duffie-Krishnamurthy index" = "black", "Target Range" = "gray")) +
  
  theme_minimal() +
  theme(legend.position = "right")
print(ggdkindex)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/dkindex2024.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/dkindex2024.png")

# Questions
# -2018 to mid April 2019
# - April 19, 2019  368?
rownum <- which(spread_no_na$sdate =="2019-11-19")
print(rownum) # 934 
dkindex[rownum] # 21.01111
# - March 17, 2020 after spiking 27.5 basis points. Throughout 2020 and 2021, the index was under 1 point.
rownum <- which(spread_no_na$sdate =="2020-03-17")
print(rownum) # 1014
dkindex[rownum] # 83.04092
# - 200 basis points during the last part of December 2022
# - 2023

rownum <- which(spread_no_na$TargetUe >300)
print(rownum)


# Extract data associated with the plot
plot_data <- ggplot_build(plot)$data[[1]]

# Extract coordinates and values of the symbols
coordinates <- plot_data$coordinates
values <- plot_data$y

# Print coordinates and values
print(coordinates)
print(values)
# PLOT I USED:
# Add a column for shape
dkindexdf$shape <- ifelse(dkindexdf$group == "Duffie-Krishnamurthy index", "triangle", "")

# Extract data associated with the plot
plot_data <- ggplot_build(ggdkindex)$data[[1]]
#  [891] 382.98404  is DKindex not target rate sdate[891]  [1] "2019-09-17"

# Extract coordinates and values of the symbols
coordinates <- plot_data$coordinates
values <- plot_data$y

# Print coordinates and values
print(coordinates)
print(values)



# ALONSO ET AL Gara distance EFFR from FOMC targets ------------------------------------------
# Initialize 'g' vector
T=nrow(rrbp)
g <- array(0,T)

# Loop through 't' values

for (t in 1:T) {
  if (!is.na(spread_no_na$TargetUe[t]) && !is.na(rrbp[t, 2])) {
    if (spread_no_na$TargetUe[t] < rrbp[t, 2]) {
      # Upper target
      g[t] <- rrbp[t, 2] - spread_no_na$TargetUe[t]
    } else if (!is.na(spread_no_na$TargetDe[t]) && rrbp[t, 2] < spread_no_na$TargetDe[t]) {
      # Lower target
      g[t] <- rrbp[t, 3] - spread_no_na$TargetDe[t]
    } else {
      # Handle other cases (if neither condition is met)
      # You can assign a default value to 'g[t]' or handle it as needed
    }
  } else {
    # Handle cases where 'spread$TargetUe_EFFR[t]' or 'rrbp[t, 2]' is NA
    # You can assign a default value to 'g[t]' or handle it as needed
  }
}


garaindexdf <- data.frame(
  sdate = spread_no_na$sdate,
  g,
  TargetDe = spread_no_na$TargetDe,
  TargetUe = spread_no_na$TargetUe,
  EFFR = spread_no_na$EFFR,
  OBFR = spread_no_na$OBFR,
  TGCR = spread_no_na$TGCR,
  BGCR = spread_no_na$BGCR,
  SOFR = spread_no_na$SOFR
)


my_envvolatile$garaindex<-garaindexdf

# Ensure sdate is of type Date
garaindexdf$sdate <- as.Date(garaindexdf$sdate)

# Create a variable for group names
garaindexdf$group <- rep(c("Alonso index", "Lower target FFR", "Upper target FFR", "EFFR", "TGCR", "BGCR", "SOFR"), length.out = nrow(dkindexdf))

# Create a named vector for colors
colors <- c("Alonso index" = "black",
            "Lower target FFR" = "blue",
            "Upper target FFR" = "green",
            "EFFR" = "black",
            "TGCR" = "green",
            "BGCR" = "orange",
            "SOFR" = "red")

ggara <- ggplot(dkindexdf, aes(x = sdate, y = dkindex, color = group)) +
  geom_point(shape = 16, size = 1) +
  labs(x = "Date", y = "Basis points (bp)", color = "Lines") +
  scale_color_manual(name = "Legend Title", values = colors) +
  theme_minimal()
print(ggara)

ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/garaindex2024.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/garaindex2024.png")


# Save the environment to an RDS file
#saveRDS(my_envvolatile, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envvolatile.RDS")

# CALENDAR EFECTS ------------------------------------------------------------------
# Set day criteria h Hamilton (1996)
# Set your desired number of observations (N)
N <- nrow(spread_no_na)

# Create a dataframe with 7 columns and N observations, initialized to zero
h <- data.frame(matrix(0, nrow = N, ncol = 11))

# The vector $h_t$ is a collection of zero-one dummy variables incorporating calendar effects.
# Calendar effects nine elements of h_t :
#   t holidays (as captured by the first four elements of ht) matter for
# the mean parameters (I) but not for the variance parameters (K). By
# contrast, the end-of-quarter and end-of-year effects on the variance
# were very dramatic
# date t:

# 1 precedes a 1-day holiday
# 2 precedes a 3-day holiday
# 3 follows a 1-day holiday
# 4 follows a 3-day holiday
# 5 the last day of quarter 1, 2, 3, or 4
# 6 the last day of the year
# 7 the day before, on, or after the last day of quarter 1,2, or 3
# 8 2 days before, 1 day before, on, 1 day after, or 2 days after the end of the year
# 9 Monday
#10 Friday

h$sdate<-sdate
# CHAT
h <- data.frame(matrix(0, nrow = N, ncol = 11))
h$sdate <- sdate

# Define new column names
new_days <- c("holiday", "oneday_beforeholiday", "threeday_beforeholiday", "oneday_afterholiday", 
              "threeday_afterholiday", "endquarter", "endyear", "around_qtr", 
              "around_yr", "Monday", "Friday", "sdate")
names(h) <- new_days

# Function to check if a date is near a holiday
is_near_holiday <- function(dates, holidays, offset) {
  sapply(dates, function(date) any(abs(as.numeric(difftime(date, holidays, units = "days"))) <= offset))
}

# Generate dummy variables
h$holiday <- h$sdate %in% holidays
h$oneday_beforeholiday <- c(FALSE, head(h$sdate, -1) %in% holidays)
h$threeday_beforeholiday <- is_near_holiday(h$sdate, holidays, 3)
h$oneday_afterholiday <- c(tail(h$sdate, -1) %in% holidays, FALSE)
h$threeday_afterholiday <- is_near_holiday(h$sdate, holidays, -3)



#-------------------
new_days <- c("holiday","oneday_beforeholiday", "threeday_beforeholiday", "oneday_afterholiday", "threeday_afterholiday", "endquarter","endyear","around_qtr","around_yr","Monday","Friday","sdate")
names(h) <- new_days
str(new_days)


# CHAT
# Load necessary library
library(timeDate)

# Sample data: sdate variable excluding weekends
# sdate <- seq(as.Date("2023-01-01"), by = "day", length.out = 3000)
# sdate <- sdate[!weekdays(sdate) %in% c("Saturday", "Sunday")]
# sdate <- sdate[1:1957]

# Define the start and end dates using sdate
start_date <- sdate[1]
end_date <- sdate[1957]
# Generate holidays for the given date range
us_holidays <- function(start_date, end_date) {
  years <- seq(as.integer(format(start_date, "%Y")), as.integer(format(end_date, "%Y")))
  holidays <- unique(c(
    as.character(holidayNYSE(years)),
    as.character(USLaborDay(years)),
    as.character(USMLKingsBirthday(years)),
    as.character(USMemorialDay(years)),
    as.character(USPresidentsDay(years)),
    as.character(USVeteransDay(years)),
    as.character(USColumbusDay(years)),
    as.character(USIndependenceDay(years)),
    as.character(USThanksgivingDay(years)),
    as.character(USChristmasDay(years))
  ))
  as.Date(holidays)
}

holidays <- us_holidays(start_date, end_date)

# Create a dataframe with the dates
N <- length(sdate)
h <- data.frame(sdate = sdate)

# Define new column names
new_days <- c("holiday", "oneday_beforeholiday", "threeday_beforeholiday", "oneday_afterholiday", 
              "threeday_afterholiday", "endquarter", "endyear", "around_qtr", 
              "around_yr", "Monday", "Friday")
h[new_days] <- 0

# Helper function to generate sequences for end of quarter and end of year
generate_end_dates <- function(years, month_day) {
  as.Date(paste0(years, "-", month_day))
}

# Generate sequences for relevant dates
years <- unique(format(sdate, "%Y"))
end_quarter_dates <- unlist(lapply(c("03-31", "06-30", "09-30", "12-31"), generate_end_dates, years = years))
end_year_dates <- generate_end_dates(years, "12-31")
around_qtr_dates <- unlist(lapply(c("03-30", "03-31", "04-01", "06-29", "06-30", "07-01", "09-29", "09-30", "10-01", "12-30", "12-31", "01-01"), generate_end_dates, years = years))
around_yr_dates <- unlist(lapply(c("12-30", "12-31", "01-01", "01-02"), generate_end_dates, years = years))

# Generate dummy variables
h$holiday <- h$sdate %in% holidays
h$oneday_beforeholiday <- c(FALSE, head(h$sdate, -1) %in% holidays)
h$threeday_beforeholiday <- sapply(h$sdate, function(date) any(abs(as.numeric(difftime(date, holidays, units = "days"))) <= 3))
h$oneday_afterholiday <- c(tail(h$sdate, -1) %in% holidays, FALSE)
h$threeday_afterholiday <- sapply(h$sdate, function(date) any(abs(as.numeric(difftime(date, holidays, units = "days"))) <= -3))

h$endquarter <- h$sdate %in% end_quarter_dates
h$endyear <- h$sdate %in% end_year_dates
h$around_qtr <- h$sdate %in% around_qtr_dates
h$around_yr <- h$sdate %in% around_yr_dates

# Day of the week
h$Monday <- weekdays(h$sdate) == "Monday"
h$Friday <- weekdays(h$sdate) == "Friday"

# View the dataframe
head(h)

str(h)
# 'data.frame':	1957 obs. of  12 variables:
#   $ sdate                 : Date, format: "2016-03-04" "2016-03-07" "2016-03-08" ...
# $ holiday               : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ oneday_beforeholiday  : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ threeday_beforeholiday: logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ oneday_afterholiday   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ threeday_afterholiday : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ endquarter            : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ endyear               : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ around_qtr            : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ around_yr             : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ Monday                : logi  FALSE TRUE FALSE FALSE FALSE FALSE ...
# $ Friday                : logi  TRUE FALSE FALSE FALSE FALSE TRUE ...
# # end CHAT

# COnvert h to dummy variable 1 if TRUE, 0 if FALSE
# Convert logical columns to numeric (1 if TRUE, 0 if FALSE)
h$holiday <- as.numeric(h$holiday)
h$oneday_beforeholiday <- as.numeric(h$oneday_beforeholiday)
h$threeday_beforeholiday <- as.numeric(h$threeday_beforeholiday)
h$oneday_afterholiday <- as.numeric(h$oneday_afterholiday)
h$threeday_afterholiday <- as.numeric(h$threeday_afterholiday)
h$endquarter <- as.numeric(h$endquarter)
h$endyear <- as.numeric(h$endyear)
h$around_qtr <- as.numeric(h$around_qtr)
h$around_yr <- as.numeric(h$around_yr)
h$Monday <- as.numeric(h$Monday)
h$Friday <- as.numeric(h$Friday)

# View the dataframe
head(h)
# head(h)
# sdate holiday oneday_beforeholiday threeday_beforeholiday oneday_afterholiday threeday_afterholiday
# 1 2016-03-04       0                    0                      0                   0                     0
# 2 2016-03-07       0                    0                      0                   0                     0
# 3 2016-03-08       0                    0                      0                   0                     0
# 4 2016-03-09       0                    0                      0                   0                     0
# 5 2016-03-10       0                    0                      0                   0                     0
# 6 2016-03-11       0                    0                      0                   0                     0
# endquarter endyear around_qtr around_yr Monday Friday
# 1          0       0          0         0      0      1
# 2          0       0          0         0      1      0
# 3          0       0          0         0      0      0
# 4          0       0          0         0      0      0
# 5          0       0          0         0      0      0
# 6          0       0          0         0      0      1


# CHATend


  
# EGARCH ----------------------------------------------------------------
# 1) ------------------- univariate garch Older work
simpleegarch_spec <- ugarchspec(variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
                       mean.model = list(armaOrder = c(0, 0)),
                       distribution.model = "norm")

# Define the EGARCH model specification
 egarch_spec <- ugarchspec(
   variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
   mean.model = list(armaOrder = c(0, 0)),
   distribution.model = "std"
 )

## Fit the EGARCH model to your financial data
egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbp[,2])

simple_fit<-ugarchfit(spec=simpleegarch_spec,data=rrbp,solver="hybrid")
summary(simple_fit) # View model summary

## Fit the EGARCH model to your financial data
# > egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbp[,2])
# Warning message:
#   In .egarchfit(spec = spec, data = data, out.sample = out.sample,  : 
#                   ugarchfit-->warning: solver failer to converge.
#                 > 
#                   > simple_fit<-ugarchfit(spec=simpleegarch_spec,data=rrbp,solver="hybrid")
#                 Error in h(simpleError(msg, call)) : 
#                   error in evaluating the argument 'spec' in selecting a method for function 'ugarchfit': object 'simpleegarch_spec' not found

# forecast<-ugarchforecast(simple_fit,data=rrbp,n.ahead=22)
# egarch30d<-mean(forecast@forecast$sigmaFor)*sqrt(252)
# forecast<-ugarchforecast(simple_fit,data=rrbp,n.ahead=22)
# Error in h(simpleError(msg, call)) : 
#   error in evaluating the argument 'fitORspec' in selecting a method for function 'ugarchforecast': object 'simple_fit' not found

# see stockoverflow
# y ~ x + I(x^2) ???


# EFFR with external regressors
quantilesE_no_na<-quantilesE
# str(quantilesE)
# 'data.frame':	1957 obs. of  9 variables:
#   $ sdate            : Date, format: "2016-03-04" "2016-03-07" "2016-03-08" ...
# $ EFFR             : num  36 36 36 36 36 36 36 37 37 37 ...
# $ VolumeEFFR       : num  75 72 72 75 72 68 67 67 63 63 ...
# $ TargetUe         : num  50 50 50 50 50 50 50 50 50 50 ...
# $ TargetDe         : num  25 25 25 25 25 25 25 25 25 25 ...
# $ Percentile01_EFFR: num  34 34 32 34 35 35 35 35 35 36 ...
# $ Percentile25_EFFR: num  36 36 36 36 36 36 36 36 36 36 ...
# $ Percentile75_EFFR: num  37 37 37 37 37 37 37 37 37 37 ...
# $ Percentile99_EFFR: num  52 50 50 52 75 50 50 50 50 50 ...

quantilesE_no_na[is.na(quantilesE_no_na)] <- 0

# Shouldnt EFFR be in edata?
edata<-quantilesE_no_na[,3:9]
str(edata)
# 'data.frame':	1957 obs. of  7 variables:
#   $ VolumeEFFR       : int  76 75 75 75 72 72 75 72 68 67 ...
# $ TargetUe_EFFR    : num  50 50 50 50 50 50 50 50 50 50 ...
# $ TargetDe_EFFR    : num  25 25 25 25 25 25 25 25 25 25 ...
# $ Percentile01_EFFR: num  34 33 34 34 34 32 34 35 35 35 ...
# $ Percentile25_EFFR: num  36 36 36 36 36 36 36 36 36 36 ...
# $ Percentile75_EFFR: num  37 37 37 37 37 37 37 37 37 37 ...
# $ Percentile99_EFFR: num  50 45 50 52 50 50 52 75 50 50 ...
edata$IQR<- edata$Percentile75_EFFR- edata$Percentile25_EFFR
edata$range<- edata$Percentile99_EFFR- edata$Percentile01_EFFR


# Simplify the Model:
#   Try simplifying the model by reducing the complexity of the GARCH parameters or removing external regressors temporarily. This can help identify whether the convergence issue is related to the model complexity.
# 
# Check for Stationarity:
#   Ensure that your financial time series is stationary. Non-stationary series can sometimes lead to convergence problems.
# 
# Consider Other Models:
#   If GARCH continues to be problematic, consider exploring other time series models like ARIMA or more advanced models such as conditional autoregressive value at risk (CAViaR).
# 
# Consult Documentation and Literature:
#   Review the documentation for the rugarch package and literature on GARCH modeling. There may be specific recommendations for handling convergence issues.
# 
# Remember to iterate and experiment with different approaches, and don't hesitate to consult resources like forums or academic papers for additional insights into handling convergence problems in GARCH modeling.


# -----------------------------------------------
#https://blog.devgenius.io/volatility-modeling-with-r-asymmetric-garch-models-85ee02f8b6e8
# -----------------------------------------------------------------
# Bertolini:
#   $\nu_t$ is a mean zero, unit variance, i.i.d. error term
# The empirical Fed Funds rate
# $r_t = \mu_t + \sigma_t \nu_t$

# $ \mu_t=r_{t-1}+\delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
# $ \mu_t=r_{t-1}+\Phi(r_{t-1}=r_{t-2})+ \Phi(r_{t-2}=r_{t-3}) +delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
#                                                                                               
# Variance of the FFR $\sigma^2_t=E[(r_t-\mu_t)^2]$
# $log(\sigma^2_t) +\omega h_t +\zeta z_t = \lambda(log(\sigma^2_{t-1}) +\omega h_{t-1} +\zeta z_{t-1} ) + abs(\nu_{t-1})+ \theta \nu_{t-1
#                                                                                               
# Introduce exponential Garch effects, EGARCH (Nelson 1991)
# Allow for deviations of persistent log of conditional variance from its unconditional expected value $-\omega h_t -\psi \nu_t -(1+\gamma N_t)$. Add day if maintenance period effects
#                                                                                             
# The resulting variance for the FFR is
# $log(\sigma^2_t -\omega h_t -\psi \nu_t -(1+\gamma N_t)=\sigma^2_{t=1}  -\omega h_{t-1} -\psi \nu_{t-1}  -(1+\gamma N_{t-1} )+\alpha \abs(\nu_{t-1} ) + \Theta \nu_{t-1} 
# Assume t distributions for innovations $\nu$
#                                             
# The EGARCH model allows for assymetric effects of lagged inovations $\nu_{t-1}$ on each day's variance.# The EGARCH(1,1) allows for persistent deviations of the log of its conditional variance from its unconditional variance
# \omega h_t +\zeta z_t OR as in their paper
# \xi+  \omega h_t +\zeta z_t +log{1+\gamma N_t})
# Maintenance day effects + calendar day effects + target/penalty rate + N_t the number of trading days between t and t-1
# Bertolini model EFFR --------------------------------
#Mean
# $r_t = \mu_t + \sigma_t \nu_t$
#   
# $ \mu_t=r_{t-1}+\delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
#Variance
#$log(\sigma^2_t) +\omega h_t +\zeta z_t = \lambda(log(\sigma^2_{t-1}) +\omega h_{t-1} +\zeta z_{t-1} ) + abs(\nu_{t-1})+ \theta \nu_{t-1


#---------------------------------
# specify the mean equation
# $r_t = \mu_t + \sigma_t \nu_t$
# $\mu_t=r_{t-1}+\delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\ast(r{_t-1})$
# mufr<-rbt[2:T,1]+ rbt[1:T-1,1]- rbt[2:T,1]
# r<- mufr + sdfr*nu
# specify the variance equation
#$log(\sigma^2_t) +\omega h_t +\zeta z_t = \lambda(log(\sigma^2_{t-1}) +\omega h_{t-1} +\zeta z_{t-1} ) + abs(\nu_{t-1})+ \theta \nu_{t-1}
  
# Create AR(1)----------------------------
  # Initialize the AR(1) process
  log_sd_effr_squared <- log(sd_effr[1:(T-1)]^2)
  
  # Specify the AR(1) equation
  ar1_process <- numeric(T-1)  # Create an empty vector to store the AR(1) process values
  
  # Compute the AR(1) process
  for (t in 1:(T-1)) {
    ar1_process[t] <- log_sd_effr_squared[t] + h[t,] + z[t]
  }
  
  # Print the AR(1) process values
  print(ar1_process)
#-----------------------------------------  
  
# --------- CHAT with external variables in the ARIMA
  # Explanation:
  # AR(1) Model:
  #   
  #   Fit using the arima function in R.
  # The arima function uses maximum likelihood estimation (MLE) by default to determine the model parameters.
  # The residuals from this model capture the deviations that the AR(1) model does not explain.
  # GARCH(1,1) Model:
  #   
  #   Fit using the garchFit function from the fGarch package.
  # This model is applied to the residuals from the AR(1) model.
  # The GARCH model helps model the changing variance (volatility) of the residuals over time.
  # This two-step process (first fitting the AR(1) model, then modeling the residuals with a GARCH model) is a common approach to handle time series data with both autoregressive and volatility clustering properties.  
  

#   Yes, the rugarch package in R is a great choice for fitting various types of GARCH models, including EGARCH (Exponential GARCH). The rugarch package is highly flexible and offers a wide range of GARCH model specifications.
#   
#   Here's how you can use the rugarch package to fit an AR(1) model followed by an EGARCH model:
# 
# Step 1: Fit an AR(1) model using MLE
# We'll first fit an AR(1) model to the log of the squared values of sd_effr and obtain the residuals.
#   
#   Step 2: Fit an EGARCH model using the residuals from the AR(1) model
#   #   AR(1) Model:
  
  
  #   
  #   The arima function fits an AR(1) model to the log_sd_effr_squared series.
  # We obtain the parameters and residuals from this model.
  # EGARCH Model:
  #   
  #   The ugarchspec function specifies an EGARCH(1,1) model. We set armaOrder to (0, 0) and include.mean to FALSE because we are modeling the residuals, which have a zero mean by construction.
  # The ugarchfit function fits the specified EGARCH model to the residuals from the AR(1) model.
  # 
  
  
  # Load necessary libraries
  library(forecast)
  library(rugarch)
  library(stats)
  #library(arima2)  dont need?
  
  # one time correct spread_no_na ---------------------
  dummy_h <- spread_no_na$h
  dummy_h <- dummy_h[, -which(names(dummy_h) == "sdate")]  # Remove the sdate column if present
  dummy_h_matrix <- as.matrix(dummy_h)
  str(dummy_h)
  spread_no_na$dummy_h<-dummy_h
  spread_no_na$h <- NULL
  # ------------------------------------------
  
  # Define the number of observations
  T <- 100  # You can change this to any number of observations you need
  
  # Generate T observations for sd_effr from a normal distribution
  set.seed(123)  # Setting seed for reproducibility
  
  # Generate dummy variables (h) and penalty function (z)
  # Assuming h and z are known and have T-1 observations
  T <- nrow(spread_no_na)
  dummy_h<-spread_no_na$dummy_h
  z<- 1- rrbp[,2]/(spread_no_na$DPCREDIT*100)
  sd_effr<-spread_no_na$sd_effr*100
  log_sd_effr_squared <- log(sd_effr^2)
  mu <- 0
  sigma <- 1
  nu <- rnorm(T, mean = mu, sd = sigma)
  #abs(\nu_{t-1})+ \theta \nu_{t-1}
  absnu<-abs(nu)
  
  external_regressors <- cbind(dummy_h[,2:11], z,absnu, nu)
  #external_regressors <- cbind(dummy_h[,2:11], z)
  
  # Ensure sdate is a Date object and use it as an index
  #spread_no_na$sdate <- as.Date(spread_no_na$sdate, format = "%Y-%m-%d")
  
  # Create a zoo object for log_sd_effr_squared with sdate as the index
  log_sd_effr_squared_zoo <- zoo(log_sd_effr_squared, order.by = spread_no_na$sdate)
  # Fit an ARIMA model with external regressors using MLE
  arima_model <- arima(coredata(log_sd_effr_squared_zoo), order = c(1, 0, 0), xreg = external_regressors,method="CSS")
  arima_params <- arima_model$coef
  arima_residuals <- residuals(arima_model)
  #--
  # see \url{https://stats.stackexchange.com/questions/84330/errors-in-optim-when-fitting-arima-model-in-r}
  # Error in stats::optim(init[mask], armaCSS, method = optim.method, hessian = FALSE,  : 
  #                         non-finite value supplied by optim
  # 
  # after adding method="CSS")
  # Error in stats::optim(init[mask], armaCSS, method = optim.method, hessian = TRUE,  : 
  #                         non-finite value supplied by optim
  # Print the ARIMA model parameters
  print("ARIMA Model Parameters:")
  print(arima_params)
  
  # Specify the EGARCH model
  spec <- ugarchspec(
    variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
    mean.model = list(armaOrder = c(0, 0), include.mean = FALSE),
    distribution.model = "norm"
  )
  
  # Fit the EGARCH model on the residuals from the ARIMA model
  fit <- ugarchfit(spec = spec, data = arima_residuals)
  
  # Print the EGARCH model parameters
  print("EGARCH Model Parameters:")
  print(coef(fit))
  
  # Show the summary of the EGARCH model fit
  summary(fit)
  
#-----------------------------------------------------  

ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_BBP.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_BBP.png")



# -----------------------------

# OLD ---------------------------------------------------------
#--------------------------


# What model was this
#fit EGARCH model
edatabbp <- select(edata, "VolumeEFFR" ,"TargetUe_EFFR","TargetDe_EFFR")
edatabbp$policy<-"TargetUe_EFFR[2:T]"-"TargetUe_EFFR[1:T-1]"
# Model EFFR with external data
exte.z = zoo(x=edatabbp, order.by=rrbp$sdate)
ext_effrbbp<-Return.calculate(exte.z, method = "log")[-1]
egarch_effrBBP=ugarchfit(data = return.effr,external.data=matrix(ext_effrbbp),spec=spec_effr)
residuals_effrBBP <- residuals(egarch_effrBBP)
plot(residuals_effrBBP)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_BBP.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_BBP.png")


#   resources
# \url{https://stackoverflow.com/questions/35035857/multivariate-garch1-1-in-r}
# \url{https://www.unstarched.net/2013/01/03/the-garch-dcc-model-and-2-stage-dccmvt-estimation/}
# \url{https://www.unstarched.net/r-examples/rugarch/a-short-introduction-to-the-rugarch-package/}
# 
# Symbols math in rmarkdown \url{https://rpruim.github.io/s341/S19/from-class/MathinRmd.html}

#\url{https://stackoverflow.com/questions/58354207/interpreting-coefficients-of-rugarch-package-in-r}
# eta11 is the rotation parameter, i.e. when you do decomposition of the residuals inside the equation for the conditional variance, you can allow a shift (eta2) or/and rotation (eta1) in the news impact curve.
# alpha1 is the ARCH(q) parameter. In your case, q is 1.
# beta1 is the GARCH(p) parameter. In your case, p is 1.
# Additional information:
  
#  You are looking at the following family of GARCH equations, collectively called fGARCH in rugarch package:
#   \begin{align*}
# \sigma{^\lambda}_t &= \left(\omega + \sum_{j=1}^{m}\zeta_j\nu_jt \right) +  \left(\sum_{j=1}^{q}\psi_j \alpha_j \sigma{^\lambda}_{t-j} (abs(z_{t-j}-\eda_2j)- \eda_1j(z_{t-j}-\eda_2j))^\delta \right) +  \left(\sum_{j=1}^{p}\beta_j \sigma{^\lambda}_{t-j} \right) 
#    \\
# a+b &= 10 
# \end{align*}
#   
# \url{https://www.quantargo.com/help/r/latest/packages/rugarch/1.4-4/ugarchspec-methods}
# Mean Model
# mu constant
# ar1  AR term
# 
# Distribution Model
# skew: skew
# shape: shape
# ghlambda: lambda (for GHYP distribution)
# 
# power term1(shock): delta
# 
# Distribution Model
# skew: skew
# shape: shape
# ghlambda: lambda (for GHYP distribution)
# 
# Variance Model (GJR, EGARCH)
# assymetry term: gamma1
# constant: omega
# 
# # full list
# Mean Model
# constant: mu
# AR term: ar1
# MA term: ma1
# ARCH-in-mean: archm
# exogenous regressors: mxreg1
# arfima: arfima
# 
# Variance Model (common specs)
# constant: omega
# ARCH term: alpha1
# GARCH term: beta1
# Variance Model (GJR, EGARCH)
# assymetry term: gamma1
# 
# exogenous regressors: vxreg1
# 
# Variance Model (GJR, EGARCH)
# assymetry term: gamma1
# 
# Variance Model (APARCH)
# assymetry term: gamma1
# 
# power term: delta
# 
# Variance Model (FGARCH)
# assymetry term1 (rotation): eta11
# assymetry term2 (shift): eta21
# 
# power term1(shock): delta
# power term2(variance): lambda
# 
# Variance Model (csGARCH)
# permanent component autoregressive term (rho): eta11
# 
# permanent component shock term (phi): eta21
# permanent component intercept: omega
# transitory component ARCH term: alpha1
# transitory component GARCH term: beta1
# 
# The terms defined above are better explained in the vignette which provides each model's specification and exact representation. For instance, in the eGARCH model, both alpha and gamma jointly determine the assymetry, and relate to the magnitude and sign of the standardized innovations.

# $t=frac{H_a-H_0}{s/n^.5)}$
# df=n-1
# A one tailed test is signifcant when the t is in the bottom or top alpha percent of the probability distribution
# Say alpha= .05 Reject $H_0=0$ when t Pr(>|t)
# If there is less than a 5 pct chance of a result as extreme as the sample mean if the null were true, then the null is rejected
#  

# Simple model EFFR ---------------------------------------------
rrbp.z = zoo(x=rrbp$EFFR, order.by=rrbp$sdate)
#Calculate log returns and remove first NA value
return.effr<-Return.calculate(rrbp.z, method = "log")[-1]
#fit EGARCH model
spec_effr = ugarchspec(variance.model=list(model="eGARCH",
                                           garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(1,0)),distribution.model="ged")
egarch_effrsimple=ugarchfit(data = return.effr,spec=spec_effr)
residuals_effrsimple <- residuals(egarch_effrsimple)
plot(residuals_effrsimple)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/egarch_effr_simple.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/egarch_effr_simple.png")

# *---------------------------------*
#   *          GARCH Model Fit        *
#   *---------------------------------*
#   
#   Conditional Variance Dynamics 	
# -----------------------------------
#   GARCH Model	: eGARCH(1,1)
# Mean Model	: ARFIMA(1,0,0)
# Distribution	: ged 
# 
# Optimal Parameters
# ------------------------------------
#   Estimate  Std. Error    t value Pr(>|t|)
# mu      0.000000    0.000000  -0.039541 0.968459
# ar1     0.000004    0.000001   4.321618 0.000015
# omega  -0.371230    0.020183 -18.393482 0.000000
# alpha1 -0.549327    0.109437  -5.019562 0.000001
# beta1   0.902594    0.003121 289.239919 0.000000
# gamma1  0.824669    0.067281  12.257104 0.000000
# shape   0.116152    0.000920 126.214854 0.000000
# 
# Robust Standard Errors:
#   Estimate  Std. Error   t value Pr(>|t|)
# mu      0.000000    0.000023 -0.000177 0.999858
# ar1     0.000004    0.000012  0.368683 0.712364
# omega  -0.371230    0.078737 -4.714833 0.000002
# alpha1 -0.549327    0.488556 -1.124389 0.260848
# beta1   0.902594    0.013265 68.041405 0.000000
# gamma1  0.824669    0.258930  3.184906 0.001448
# shape   0.116152    0.004538 25.593203 0.000000
# 
# LogLikelihood : 18509.08 
# 
# Information Criteria
# ------------------------------------
#   
#   Akaike       -18.918
# Bayes        -18.898
# Shibata      -18.918
# Hannan-Quinn -18.911
# 
# Weighted Ljung-Box Test on Standardized Residuals
# ------------------------------------
#   statistic  p-value
# Lag[1]                      3.843 0.049948
# Lag[2*(p+q)+(p+q)-1][2]     3.844 0.006057
# Lag[4*(p+q)+(p+q)-1][5]     3.886 0.244214
# d.o.f=1
# H0 : No serial correlation
# 
# Weighted Ljung-Box Test on Standardized Squared Residuals
# ------------------------------------
#   statistic p-value
# Lag[1]                    0.01278  0.9100
# Lag[2*(p+q)+(p+q)-1][5]   0.04599  0.9996
# Lag[4*(p+q)+(p+q)-1][9]   0.07660  1.0000
# d.o.f=2
# 
# Weighted ARCH LM Tests
# ------------------------------------
#   Statistic Shape Scale P-Value
# ARCH Lag[3]   0.01583 0.500 2.000  0.8999
# ARCH Lag[5]   0.03967 1.440 1.667  0.9964
# ARCH Lag[7]   0.05913 2.315 1.543  0.9998
# 
# Nyblom stability test
# ------------------------------------
#   Joint Statistic:  626.1059
# Individual Statistics:              
#   mu       3.762
# ar1     62.180
# omega  298.413
# alpha1   6.771
# beta1  252.101
# gamma1   2.952
# shape  482.013
# 
# Asymptotic Critical Values (10% 5% 1%)
# Joint Statistic:     	 1.69 1.9 2.35
# Individual Statistic:	 0.35 0.47 0.75
# 
# Sign Bias Test
# ------------------------------------
#   t-value   prob sig
# Sign Bias          0.17646 0.8600    
# Negative Sign Bias 0.09015 0.9282    
# Positive Sign Bias 0.34341 0.7313    
# Joint Effect       0.16946 0.9824    
# 
# 
# Adjusted Pearson Goodness-of-Fit Test:
#   ------------------------------------
#   group statistic p-value(g-1)
# 1    20     24191            0
# 2    30     37228            0
# 3    40     50268            0
# 4    50     63278            0

# EGARCH EFFR + vOlume, FOMC rates, PERCENTILES


# EGARCH EFFR + vOlume, FOMC rates, percentiles ---------------------------------
rrbp.z = zoo(x=rrbp$EFFR, order.by=rrbp$sdate)
#Calculate log returns and remove first NA value
return.effr<-Return.calculate(rrbp.z, method = "log")[-1]

edata <- quantilesE
edata$iqr<-quantilesE$Percentile75_EFFR-quantilesE$Percentile25_EFFR
edata$range<-quantilesE$Percentile99_EFFR-quantilesE$Percentile01_EFFR
edata_1<-select(edata, "VolumeEFFR" ,"TargetUe_EFFR","TargetDe_EFFR","IQR","range")
str(edata)
spec_effr = ugarchspec(variance.model=list(model="eGARCH",
                                           garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(1,0)),distribution.model="ged")
# #MODEL 1 Model EFFR with external data
exte.z = zoo(x=edata, order.by=rrbp$sdate)
ext_effr<-Return.calculate(exte.z, method = "log")[-1]

#fit EGARCH model
egarch_effrsimple=ugarchfit(data = return.effr,external.=matrix(ext_effr),spec=spec_effr)
residuals_effr <- residuals(egarch_effrsimple)
plot(residuals_effr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_per.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_per.png")

edata2 <- subset(edata, select = c(VolumeEFFR,TargetUe,TargetDe, iqr, range))
edata2 <- subset(edata, select = c(VolumeEFFR, iqr, range))
#edata2 <- edata[, c("VolumeEFFR", "TargetUe", "TargetDe", "iqr", "range")]


#MODEL 2----------------------------------
edata2.z <- zoo(edata2, order.by = edata$sdate)

# Combine edata2 and return.effr using their common index
ratesplus <- merge(edata2.z, return.effr, all = FALSE)

# Convert the combined zoo object back to a data frame, if needed
ratesplus_df <- data.frame(date = index(ratesplus), coredata(ratesplus))
                           
                           
egarch_effrv2<-ugarchfit(data = ratesplus_df,external.=matrix(ext_effr),spec=spec_effr)
residuals_effr <- residuals(egarch_effrsimple)
plot(residuals_effr)
# model <- arima(your_time_series, order = c(0, 0, 0))
# The armaOrder parameter specifies the autoregressive (AR) and moving average (MA) 
# components of an ARMA (AutoRegressive Moving Average) model.

#EGARCH with GED distribution -----------------Volume, FOMC, IQR, range
#Specify EGARCH models:  IQR
spec_effr = ugarchspec(variance.model=list(model="eGARCH",
                                      garchOrder=c(1,1)),
                  mean.model=list(armaOrder=c(1,0)),distribution.model="ged")

#How to include variance in the mean model?
#fit EGARCH model
egarch_effr=ugarchfit(data = return.effr,external.data=matrix(ext_effr),spec=spec_effr)
residuals_effr <- residuals(egarch_effr)
plot(residuals_effr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_iqr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/egarch_effr_iqr.png")

# 
# # Plot the residuals to check for patterns and autocorrelation
# plot(residuals)
# Box.test(residuals, lag = 20, type = "Ljung-Box")

# MODEL Bertola, Prati

# OTHER RATES ----------------------------------------------------
# TGCR
# Simple model EFFR
rrbp.z = zoo(x=rrbp$TGCR, order.by=rrbp$sdate)
#Calculate log retruns and remove first NA value
return.tgcrr<-Return.calculate(rrbp.z, method = "log")[-1]

# Model EFFR with external data
exte.z = zoo(x=edata, order.by=rrbp$sdate)
ext_effr<-Return.calculate(exte.z, method = "log")[-1]


#EGARCH with GED distribution
#Specify EGARCH models:
spec_tgcr = ugarchspec(variance.model=list(model="eGARCH",
                                           garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(0,0)),distribution.model="ged")
#fit EGARCH model
egarch_tgcrr.t=ugarchfit(data = return.tgcr,external.data=matrix(ext_tgcr),spec=spec_tgcr)
residuals_tgcr <- residuals(egarch_tgcr)
plot(residuals_tgcr)
# 
# # Plot the residuals to check for patterns and autocorrelation
# plot(residuals_tgcr)
# Box.test(residuals_tgcr, lag = 20, type = "Ljung-Box")

# BGCR
# Simple model EFFR
rrbp.z = zoo(x=rrbp$BGCR, order.by=rrbp$sdate)
#Calculate log retruns and remove first NA value
return.bgcr<-Return.calculate(rrbp.z, method = "log")[-1]

# Model bgcr with external data
exte.z = zoo(x=edata, order.by=rrbp$sdate)
ext_bgcr<-Return.calculate(exte.z, method = "log")[-1]


#EGARCH with GED distribution
#Specify EGARCH models:
spec_bgcr = ugarchspec(variance.model=list(model="eGARCH",
                                           garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(0,0)),distribution.model="ged")
#fit EGARCH model
egarch-bgcr.t=ugarchfit(data = return.bgcr,external.data=matrix(ext_bgcr),spec=spec_bgcr)
residuals_bgcr <- residuals(egarch_bgcr)
plot(residuals_bgcr)
# 
# # Plot the residuals to check for patterns and autocorrelation
# plot(residuals_bgcr)
# Box.test(residuals_bgcr, lag = 20, type = "Ljung-Box")

# SOFR
# Simple model EFFR
rrbp.z = zoo(x=rrbp$SOFR[526:T], order.by=rrbp$sdate[526:T])
#Calculate log returns and remove first NA value
return.sofr<-Return.calculate(rrbp.z, method = "log")[-1]

# Model sofr with external data
exte.z = zoo(x=sdata[526:T,], order.by=rrbp$sdate[526:T])
ext_sofr<-Return.calculate(exte.z, method = "log")[-1]


#EGARCH with GED distribution
#Specify EGARCH models:
spec_sofr = ugarchspec(variance.model=list(model="eGARCH",
                                           garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(0,0)),distribution.model="ged")
#fit EGARCH model
egarch-sofr.t=ugarchfit(data = return.sofr,spec=spec_sofr)
#egarch-sofr.t=ugarchfit(data = return.sofr,external.data=matrix(ext_sofr),spec=spec_sofr)
residuals_sofr <- residuals(egarch_sofr)
plot(residuals_sofr)
# 
# # Plot the residuals to check for patterns and autocorrelation
# plot(residuals)
# Box.test(residuals, lag = 20, type = "Ljung-Box")

#egarch-sofr.t=ugarchfit(data = return.sofr,spec=spec_sofr)
#Error in if (mean(data) == 0) { : missing value where TRUE/FALSE needed

# 2) ------------------- Multivariate garch -  with Chatgpt 1/18/2024
# https://www.rdocumentation.org/packages/rmgarch/versions/1.3-9
# https://stats.stackexchange.com/questions/568328/egarch-using-rugarch-package-in-r
# Create a multivariate specification for five assets
# Statement to jointly fit 5 models
multireturn_fit <- list(fit1, fit5)

# stackoverflow example https://stackoverflow.com/questions/54293924/rugarch-external-regressors-in-mean-variance
# garch.spec <- ugarchspec(
#   variance.model = list(model = "sGARCH", garchOrder = c(1, 1), external.regressors = matrix(df$regressor)),
#   mean.model = list(armaOrder = c(2, 0), include.mean = TRUE))
# ugarchfit(garch.spec, df$dependent)


# EGARCH EFFR + volumn, FOMC rates, oercentilss
# *---------------------------------*
#   *          GARCH Model Fit        *
#   *---------------------------------*
#   
#   Conditional Variance Dynamics 	
# -----------------------------------
#   GARCH Model	: eGARCH(1,1)
# Mean Model	: ARFIMA(0,0,0)
# Distribution	: ged 
# 
# Optimal Parameters
# ------------------------------------
#   Estimate  Std. Error    t value Pr(>|t|)
# mu      0.000000    0.000000  -0.030449 0.975709
# omega  -1.142564    0.040679 -28.087519 0.000000
# alpha1  0.003428    0.000924   3.710594 0.000207
# beta1   0.921293    0.006256 147.261596 0.000000
# gamma1  0.020497    0.004979   4.116443 0.000038
# shape   0.102644    0.011212   9.155058 0.000000
# 
#  Model with volume, fomc targets, all percentiles
# Robust Standard Errors:
#   Estimate  Std. Error   t value Pr(>|t|)
# mu      0.000000    0.000032 -0.000071  0.99994
# omega  -1.142564    4.551594 -0.251025  0.80180
# alpha1  0.003428    0.042127  0.081368  0.93515
# beta1   0.921293    0.711101  1.295588  0.19512
# gamma1  0.020497    0.565357  0.036255  0.97108
# shape   0.102644    1.258998  0.081528  0.93502

# Model with volume, fomc targets, IQR, range
# Robust Standard Errors:
#   Estimate  Std. Error   t value Pr(>|t|)
# mu      0.000000    0.000023 -0.000177 0.999858
# ar1     0.000004    0.000012  0.368683 0.712364
# omega  -0.371230    0.078737 -4.714833 0.000002
# alpha1 -0.549327    0.488556 -1.124389 0.260848
# beta1   0.902594    0.013265 68.041405 0.000000
# gamma1  0.824669    0.258930  3.184906 0.001448
# shape   0.116152    0.004538 25.593203 0.000000
# LogLikelihood : 18509.08


# LogLikelihood : 23663.95 
# 
# Information Criteria
# ------------------------------------
#   
# Akaike       -24.190
#    Akaike’s information criterion (AIC) compares the quality of a set of statistical models to each othe
#    \url{https://www.statisticshowto.com/akaikes-information-criterion/}
#    AIC = -2(log-likelihood) + 2K
#    K number of model parameters plus the intercept
#    Log-likelihood measure of model fit. The higher the number, the better the fit.

# Bayes        -24.173
# Bayesian Information Criterion
# The BIC is a well-known general approach to model selection that favors more parsimonious models over more complex models (i.e., it adds a penalty based on the number of parameters being estimated in the model) (Schwarz, 1978; Raftery, 1995). One form for calculating the BIC is given by
# (7) $BIC=T_m -df_m log()$
#   
# \url{https://www.sciencedirect.com/topics/social-sciences/bayesian-information-criterion}
# where Tm is the chi-square statistic for the hypothesized model. 
# BIC > 0 favors the saturated model (i.e., the model that allows all observed variables to be intercorrelated with no assumed model structure)
# BIC < 0 favors the hypothesized model. 
# Furthermore, the BIC can be used to assess two competing models.
# between BICs od the two models is 0–2, ‘weak’ evidence in favor of the model with the smaller BIC; 
# between 2 and 6 constitutes ‘positive’ evidence; 
# between 6 and 10 constitutes ‘strong’ evidence;

# Shibata      -24.190 see pdf in Papers, VOlatility

# Hannan-Quinn -24.184 \url{https://www.rdocumentation.org/packages/qpcR/versions/1.3-7.1/topics/HQIC}
# with $\mathcal{L}_{max}$ = maximum likelihood, $k$ = number of parameters and $n$ = number of observations.
# $HQIC= -2 log(L_{max} + 2k log(log(n))$
# The Determination of the Order of an Autoregression. Hannan EJ & Quinn BG. J Roy Stat Soc B (1979), 41: 190-195.

# Weighted Ljung-Box Test on Standardized Residuals
# ------------------------------------
#   statistic p-value
# Lag[1]                      1.551  0.2130
# Lag[2*(p+q)+(p+q)-1][2]     1.551  0.3495
# Lag[4*(p+q)+(p+q)-1][5]     1.551  0.7272
# d.o.f=0
# H0 : No serial correlation
# 
# Weighted Ljung-Box Test on Standardized Squared Residuals
# \url{https://stats.stackexchange.com/questions/468768/interpretation-of-ljung-box-tests-for-garch-models-from-the-rugarch-package-in}
# A GARCH model assumes the standardized errors (shocks, innovations) are i.i.d. with zero mean and unit variance. 
# After having fit a GARCH model, it makes sense to test whether this is the case. Some common checks are to examine presence of a
# utocorrelation and/or autoregressive conditional heteroskedasticity in the standardized errors; under the i.i.d. assumption, there should be none. 
# If any is found, the model assumptions are violated, so the face value of the modeling results cannot be trusted.
# 
# Ljung-Box (LB) test on standardized residuals tests for autocorrelation in standardized errors, while LB test on standardized squared residuals and 
# ARCH-LM test test for autoregressive conditional heteroskedasticity. Autocorrelation and autoregressive conditional heteroskedasticity are not the same. 
# You can have one, the other or both in a time series. Hence, you should not be surprised if some tests find presence of one but not the other.
# A problem with applying any of these tests to standardized (squared) residuals from a GARCH model is that the test statistics have nonstandard distributions 
# under the null. (They have their standard null distributions when applied to raw data, but not when applied to residuals of a GARCH model.)* 
# As far as I know, this is not accounted for in the rugarch package. Hence, you should take the test results with a grain of salt.
# *There are papers and (I think) textbooks showing that ARCH-LM test should be substituted by Li-Mak test to have the correct distribution 
# under the null if the mean of the process is modelled as a constant (not as ARMA as in your case). Similar corrections are needed for the LB tests. 
# When the mean is not modelled as a constant, I am not sure whether there exists any test at all with a known null distribution. See my answer in the thread "Remaining heteroskedasticity even after GARCH estimation" for some references.
# ------------------------------------
#   statistic p-value
# Lag[1]                   0.002779   0.958
# Lag[2*(p+q)+(p+q)-1][5]  0.009022   1.000
# Lag[4*(p+q)+(p+q)-1][9]  0.014712   1.000
# d.o.f=2
# 
# Weighted ARCH LM Tests
# ------------------------------------
#   Statistic Shape Scale P-Value
# ARCH Lag[3]  0.003121 0.500 2.000  0.9554
# ARCH Lag[5]  0.007492 1.440 1.667  0.9997
# ARCH Lag[7]  0.011130 2.315 1.543  1.0000
# 
# Nyblom stability test
#\url{https://stats.stackexchange.com/questions/201165/garch-model-diagnostics-how-to-interpret-test-results}
# A good source of information on diagnostic testing of univariate GARCH models is "rugarch" vignette by Alexios Ghalanos.
# ------------------------------------
#   Joint Statistic:  601.2937
# Individual Statistics:              
#   mu      10.225
# omega    2.348
# alpha1  11.500
# beta1    1.860
# gamma1  14.953
# shape  444.381
# 
# Asymptotic Critical Values (10% 5% 1%)
# Joint Statistic:     	 1.49 1.68 2.12
# Individual Statistic:	 0.35 0.47 0.75
# 
# Sign Bias Test
# ------------------------------------
#   t-value   prob sig
# Sign Bias           0.2978 0.7659    
# Negative Sign Bias  0.0212 0.9831    
# Positive Sign Bias  0.2321 0.8165    
# Joint Effect        0.1622 0.9834    
# 
# 
# Adjusted Pearson Goodness-of-Fit Test:
#   ------------------------------------
#   group statistic p-value(g-1)
# 1    20     27898            0
# 2    30     42825            0
# 3    40     57742            0
# 4    50     72666            0



##
egarch.fit2.t=ugarchfit(data = return.effr,spec=spec_effr)
##summary of EGARCH fit
##summary of EGARCH fit
egarch.fit.tstr()

# Perform Engle and Ng sign and size bias tests
signbias(egarch.fit)


# EGARCH EFFR + volume, FOMC rates, IQR and range
# Optimal Parameters
# ------------------------------------
#   Estimate  Std. Error    t value Pr(>|t|)
# mu      0.000000    0.000000  -0.030449 0.975709
# omega  -1.142564    0.040679 -28.087519 0.000000
# alpha1  0.003428    0.000924   3.710594 0.000207
# beta1   0.921293    0.006256 147.261596 0.000000
# gamma1  0.020497    0.004979   4.116443 0.000038
# shape   0.102644    0.011212   9.155058 0.000000
# 
# Robust Standard Errors:
#   Estimate  Std. Error   t value Pr(>|t|)
# mu      0.000000    0.000032 -0.000071  0.99994
# omega  -1.142564    4.551594 -0.251025  0.80180
# alpha1  0.003428    0.042127  0.081368  0.93515
# beta1   0.921293    0.711101  1.295588  0.19512
# gamma1  0.020497    0.565357  0.036255  0.97108
# shape   0.102644    1.258998  0.081528  0.93502
# 
# LogLikelihood : 23663.95 
# 
# Information Criteria
# ------------------------------------
#   
# Akaike       -24.190
# Bayes        -24.173
# Shibata      -24.190
# Hannan-Quinn -24.184
# 
# Weighted Ljung-Box Test on Standardized Residuals
# ------------------------------------
#   statistic p-value
# Lag[1]                      1.551  0.2130
# Lag[2*(p+q)+(p+q)-1][2]     1.551  0.3495
# Lag[4*(p+q)+(p+q)-1][5]     1.551  0.7272
# d.o.f=0
# H0 : No serial correlation
# 
# Weighted Ljung-Box Test on Standardized Squared Residuals
# ------------------------------------
#   statistic p-value
# Lag[1]                   0.002779   0.958
# Lag[2*(p+q)+(p+q)-1][5]  0.009022   1.000
# Lag[4*(p+q)+(p+q)-1][9]  0.014712   1.000
# d.o.f=2
# 
# Weighted ARCH LM Tests
# ------------------------------------
#   Statistic Shape Scale P-Value
# ARCH Lag[3]  0.003121 0.500 2.000  0.9554
# ARCH Lag[5]  0.007492 1.440 1.667  0.9997
# ARCH Lag[7]  0.011130 2.315 1.543  1.0000
# 
# Nyblom stability test
# ------------------------------------
#   Joint Statistic:  601.2937
# Individual Statistics:              
#   mu      10.225
# omega    2.348
# alpha1  11.500
# beta1    1.860
# gamma1  14.953
# shape  444.381
# 
# Asymptotic Critical Values (10% 5% 1%)
# Joint Statistic:     	 1.49 1.68 2.12
# Individual Statistic:	 0.35 0.47 0.75
# 
# Sign Bias Test
# ------------------------------------
#   t-value   prob sig
# Sign Bias           0.2978 0.7659    
# Negative Sign Bias  0.0212 0.9831    
# Positive Sign Bias  0.2321 0.8165    
# Joint Effect        0.1622 0.9834    
# 
# 
# Adjusted Pearson Goodness-of-Fit Test:
#   ------------------------------------
#   group statistic p-value(g-1)
# 1    20     27898            0
# 2    30     42825            0
# 3    40     57742            0
# 4    50     72666            0


# -----------------------------------------------  
signbias(egarch.fit)
# Analyze the model residuals and check for goodness-of-fit:
#   R
# Copy code
# # Extract the residuals from the model fit
# residuals <- residuals(egarch_fit)
# 
# # Plot the residuals to check for patterns and autocorrelation
# plot(residuals)
# Box.test(residuals, lag = 20, type = "Ljung-Box")


# Stuff to edit/delete ----------------------------------------
#2.  Stack overchange model https://stats.stackexchange.com/questions/568328/egarch-using-rugarch-package-in-r
garchMod <- ugarchspec(
  variance.model = list(
    model = "eGARCH",
    garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0)),
  distribution.model = "norm")

fit <- ugarchfit(spec = garchMod, data = rrbp, solver = "hybrid")
forecast <- ugarchforecast(fit, data = rrbp, n.ahead = 22)
egarch30d <- mean(forecast@forecast$sigmaFor) * sqrt(252)



# 3. Combine the returns data into a multivariate time series
#multivariate_returns <- merge(asset1_returns, asset2_returns)
#multivariate_returns <- merge(rrbp[,1],rrbp[,2],rrbp[,3],rrbp[,4],rrbp[,5])
# Assuming rrbp is a data frame with multiple columns
# For example, columns 1 to 5 are the returns of different assets

# Extract the relevant columns
effr <- rrbp[, 2]
obfr <- rrbp[, 3]
tgcr <- rrbp[, 4]
bgcr <- rrbp[, 5]
sofr <- rrbp[, 6]

# Combine the returns into a multivariate data frame
multivariate_returns <- data.frame(
  effr,
  obfr,
  tgcr,
  bgcr,
  sofr
)

str(multivariate_returns)
# 'data.frame':	1957 obs. of  5 variables:
# $ effr: num  36 37 37 36 36 36 36 36 36 36 ...
# $ obfr: num  37 37 37 37 37 37 37 37 37 37 ...
# $ tgcr: num  0 0 0 0 0 0 0 0 0 0 ...
# $ bgcr: num  0 0 0 0 0 0 0 0 0 0 ...
# $ sofr: num  0 0 0 0 0 0 0 0 0 0 ...

# Create an xts object with the time index
multivariate_returns_xts <- xts(multivariate_returns, order.by = sdate)


# Create a multivariate DCC-GARCH model specification Worked but what is it?
multivar_dcc_garch_spec <- dccspec(
  uspec = multispec(
    replicate(
      5,
      ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)))
    )
  ),
  dccOrder = c(1, 1),
  distribution = "mvnorm"
)

# Fit the multivariate DCC-GARCH model
multifit <- dccfit(multivar_dcc_garch_spec, data = multivariate_returns_xts)


summary(multifit)
# Length  Class   Mode 
# 1 DCCfit     S4 


# I got to here 1/18/2024
conditional_correlation <- rcor(multifit)
parameter_estimates <- coef(multifit)
log_likelihood <- logLik(multifit)
str(multifit)
# Error in UseMethod("logLik") : 
# no applicable method for 'logLik' applied to an object of class "c('DCCfit', 'mGARCHfit', 'GARCHfit', 'rGARCH')"


# parameter_estimates <- coef(multifit)
# > parameter_estimates 
# [effr].mu    [effr].ar1    [effr].ma1  [effr].omega [effr].alpha1  [effr].beta1     [obfr].mu    [obfr].ar1 
# 7.810890e+00  1.000000e+00 -3.309566e-01  1.871555e+01  3.021599e-01  2.192484e-01  4.999556e+00  1.000000e+00 
# [obfr].ma1  [obfr].omega [obfr].alpha1  [obfr].beta1     [tgcr].mu    [tgcr].ar1    [tgcr].ma1  [tgcr].omega 
# -4.221516e-01  2.156197e+01  3.507719e-01  1.516064e-01  1.070882e+02  1.000000e+00 -6.633867e-01  3.124971e+01 
# [tgcr].alpha1  [tgcr].beta1     [bgcr].mu    [bgcr].ar1    [bgcr].ma1  [bgcr].omega [bgcr].alpha1  [bgcr].beta1 
# 9.989626e-01  8.171744e-07  5.294456e+01  1.000000e+00 -6.394461e-01  2.554456e+01  7.819888e-01  5.824750e-02 
# [sofr].mu    [sofr].ar1    [sofr].ma1  [sofr].omega [sofr].alpha1  [sofr].beta1  [Joint]dcca1  [Joint]dccb1 
# 5

# Convert the parameter_estimates to a data frame
parameter_estimates_df <- as.data.frame(parameter_estimates)


# Create a table using xtable
parameter_estimates_table <- xtable(parameter_estimates_df)

# Print the table
print(parameter_estimates_table)

# 3) ------------------- Multivariate garch - add penalty, Duffie-Krishnamurth indes, IOR spreads?

# NOTE: ADD BERTOLINI DAYS VARIABLE h

# Combine the returns into a multivariate data frame
# multivariate_returns <- data.frame(
#   effr,
#   obfr,
#   tgcr,
#   bgcr,
#   sofr
# )

discount = 1.02
penalty<-1- rrbp[,2]/discount;

# add #dkindex
multivariate_returns3 <- data.frame(
  effr,
  obfr,
  tgcr,
  bgcr,
  sofr,
  penalty,
  iorsofr,
  rrppsofr,
)


# Create an xts object with the time index library(zoo)
multivariate_returns_xts3 <- xts(multivariate_returns3, order.by = sdate)


# Create a multivariate DCC-GARCH model specification
multivar_dcc_garch_spec3 <- dccspec(
  uspec = multispec(
    replicate(
      5,
      ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)))
    )
  ),
  dccOrder = c(1, 1),
  distribution = "mvnorm"
)

# Fit the multivariate DCC-GARCH model
multifit3 <- dccfit(multivar_dcc_garch_spec3, data = multivariate_returns_xts3)


summary(multifit3)
# Length  Class   Mode 
# 1 DCCfit     S4 

conditional_correlation <- rcor(multifit3)
parameter_estimates <- coef(multifit3)
log_likelihood <- logLik(multifit3)
str(multifit)



# 2.2 EGARCH 
# The exponential GARCH (EGARCH) may generally be specified as 
# This model differs from the GARCH variance structure because of the log of the variance. 
# The following specification also has been used in the financial literature (Dhamija and 
#                                                                             Bhalla [24]). 
# see Dan Nelson

# \epsilon[t]<--\sigma[t]*z[t]
# log(\sigma^2[t}])<=\omega + $\sum_{i=1}^{p}\alpha[i]*\epsilon^2[t-i] + $\sum_{j=1}^{q} \beta[j] log(\sigma^2[t-j}])$
#   
#   or
# 
# \epsilon[t]<--\sigma[t]*z[t]
# log(\sigma^2[t}])<-\omega + \alpha[i] \epsilon[t-i+ \sum_{j=1}^{p}\lamba[j]*\epsilon^2[t-j] + \sum_{i=1}^{p} \gamma[i] (\frac{\|epsilon[t-i]|}{sigma[t-i}}-\sqrt(\frac{2}{n}})])$
#   
# Bertolini, Prati --------------------------------------
# Bertolini et al Time series methodology: 
#   volatility of interest rates - rises in advance of reserve
# settlement days - declines in high rate regimes - biweekly periodicity when Fed is perceived as committed to
# keeping rates close to the target. 
# 
# $\nu_t$ is a mean zero, unit variance, i.i.d. error term
# The emoirical Fed Funds rate
# $r_t = \mu_t + \sigma_t \nu_t$

\begin{align*}  
$ \mu_t=r_{t-1}+\delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
$ \mu_t=r_{t-1}+\Phi(r_{t-1}=r_{t-2})+ \Phi(r_{t-2}=r_{t-3}) +delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
\end{align*}                                                                                               

#1
mu_t <- r_t_minus_1 + delta_s_t
mu_t <- Kappa_prime * k_t + iota * (asterisk_r_t - as_r_t_minus_1)

#2
mu_t <- r_t_minus_1 + Phi(r_t_minus_1 == r_t_minus_2) + Phi(r_t_minus_2 == r_t_minus_3) + delta_s_t
mu_t <- Kappa_prime * k_t + iota * (asterisk_r_t - as_r_t_minus_1)


#3
Variance of the EFFR $\sigma^2_t=E[(r_t-\mu_t)^2]$
  sigma2_t <- mean((r_t - mu_t)^2)
In this code:
  
#   sigma2_t represents the variable for 
# r_t and mu_t should be replaced with your actual variables representing 
# �
# # �
# # r 
# # t
# # ​
# # and 
# # �
# # �
# # μ 
# # t
# # ​
# # , respectively.
# # This code calculates the variance 
# # �
# # �
# # 2
# # σ 
# # t
# # 2
# # ​
# # using the formula 
# # �
# [
#   (
#     �
#     �
#     −
#     �
#     �
#   )
#   2
# ]
# E[(r 
#    t
#    ​
#    −μ 
#    t
#    ​
# ) 
# 2
# ], where mean calculates the expected value by averaging the squared differences between r_t and mu_t.
                                                                                              
#Introduce exponential Garch effects, EGARCH (Nelson 1991)
#Allow for deviations of persistent log of conditional variance from its unconditional expected value 
#4
#   $ -\omega h_t -\psi \nu_t -(1+\gamma N_t)$. Add day if maintenance period effects
# equation1_result <- -omega * h_t - psi * nu_t - (1 + gamma * N_t)
# 
#                                                                                             
# #The resulting variance for the FFR is
# #4
# equation2_result <- log(sigma2_t - omega * h_t - psi * nu_t - (1 + gamma * N_t)) == 
#   sigma2_t_minus_1 - omega * h_t_minus_1 - psi * nu_t_minus_1 - 
#   (1 + gamma * N_t_minus_1) + alpha * abs(nu_t_minus_1) + Theta * nu_t_minus_1
# 
#     $$log(\sigma^2_t -\omega h_t -\psi \nu_t -(1+\gamma N_t)=\sigma^2_{t=1}  -\omega h_{t-1} -\psi \nu_{t-1}  -(1+\gamma N_{t-1} )+\alpha \abs(\nu_{t-1} ) + \Theta \nu_{t-1} 
#                                                                                                   
# #Assume t distributions for innovations $\nu$
# # Obtain maximum likelihood of the parameters, including the degrees of freedom of the t distribution,  by numerical optimization
# 
# # -------------------- SIMPLE MODELS see Mean reversion setup og olsgmm
# xx1<-rrbp[(bgn+1):edn,2:6]
# xx2=[rrbp[(bgn+1:edn,2:6] ,SOFR_IOR[(bgn+1):edn], EFFR_IOR[(bgn+1):edn], ONRRP_IOR[(bgn+1):edn]]
# xx3=[rrbp[(bgn+1:edn,2:6] IOR[(bgn+1):edn] ONRRP[(bgn+1):edn]]
# #be=rrbplbgn:(edn-1),1)/rrbp(bgn+1:endn(k),1)
# 
# #Rates
# [theta1,sec1,R2,R2adj,vcv,F1] = olsgmm(rrbp(bgn:endn(k)-1,:),xx1,nlag,nw);  % constant
# #param1 = [theta1 sec1,R2,R2adj,F1]
# vcv1
# 
# [theta2,sec2,R2,R2adj,vcv,F2] = olsgmm(rrbp(bgn:endn(k)-1,:),xx2,nlag,nw);  % constant
# %param2 = [theta2 sec2,R2,R2adj,F2]
# vcv
# 
# [theta3,sec3,R2,R2adj,vcv,F3] = olsgmm(rrbp(bgn:endn(k)-1,:), xx2,nlag,nw)
# %param3 = [theta3 sec3 R2,R2adj,vcv,F3]
# 
# # ------------ Bertolini EFARCH
# The resulting variance for the FFR is
# 
# r <-rrbp
# mu <-mean(r)
# rstar <- targetbp
# aigma2 <- square(r-mu)
# $$log(\sigma^2_t -\omega h_t -\psi \nu_t -(1+\gamma N_t)=\sigma^2_{t=1}  -\omega h_{t-1} -\psi \nu_{t-1}  -(1+\gamma N_{t-1} )+\alpha \abs(\nu_{t-1} ) + \Theta \nu_{t-1} 
#       
      
# -----------------Note  
#Add to garch
# Analyze the model residuals and check for goodness-of-fit:
#   R
# Copy code
# # Extract the residuals from the model fit
# residuals <- residuals(egarch_fit)
# 
# # Plot the residuals to check for patterns and autocorrelation
# plot(residuals)
# Box.test(residuals, lag = 20, type = "Ljung-Box")


# # Conduct Ljung-Box test to assess residual autocorrelation
# Box.test(residuals, lag = 20, type = "Ljung-Box")
# The Box.test function tests the null hypothesis that the residuals are independently distributed.
# 
# Remember that fitting and interpreting time series models, including EGARCH models, require careful consideration of the underlying data and potential model assumptions. It's essential to validate the model and assess its adequacy for your specific use case.

# egarch_spec <- ugarchspec(variance.model = list(model = "eGARCH"), mean.model = list(armaOrder = c(0, 0)))
# egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbpts)
# egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbpts)
# residuals <- residuals(egarch_fit)
# 
      
# --------------- Notes ---------------------
# is the matrix of element by element products and
#> A %*% B is the matrix product. 
#> If x is a vector, then
#> x %*% A %*% x is a quadratic form.16
# 
# > if (expr_1) expr_2 else expr_3
# > for (name in expr_1) expr_2
#
# > xc <- split(x, ind)
#> yc <- split(y, ind)
#> for (i in 1:length(yc)) {
#  plot(xc[[i]], yc[[i]])
#  abline(lsfit(xc[[i]], yc[[i]]))
#


