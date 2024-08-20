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

# Survey of Market Participants SMP \url{https://www.newyorkfed.org/markets/survey_market_participants.html}
# Survey of Primary Dealers \url{https://www.newyorkfed.org/markets/primarydealer_survey_questions}
# Survey of Professional Forecasters \ulr{https://www.philadelphiafed.org/surveys-and-data/real-time-data-research/survey-of-professional-forecasters}
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

# FIND DELETE chatgpt code for this
#ONE OFF CORRECTION DONT RERUN  
# add 3 month Treasury bill to data frame UPDATE DATA RDS ----------------------
dataupdate<-read.csv("C:/Users/Owner/Documents/Research/OvernightRates/Final data files/NYFedReferenceRates_12172023v5.csv",header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE)
m3tbill<-dataupdate$X3mbill[1:1957]
spread_no_na$m3tbill<-m3tbill
DPCREDIT<-dataupdate$DPCREDIT
sd_effr<-dataupdate$sd_eff
# I added DPCREDIT, h, and st_effr
spread_no_na$DPCREDIT<-DPCREDIT[1:1957]
spread_no_na$sd_effr<-sd_effr[1:1957]
spread_no_na$dummy_h<-NULL
spread_no_na$h<-h
str(spread_no_na)
#spread$sd_effr[1:1957]
#my_envmp$spread_no_na <-spread_no_na
#saveRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envmp.RDS")
#str( my_envmp$spread_no_na)
#-----------------------------------------


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



# Plot time series of SOFR, EFFR, IOR, RRP, 3 month Treasury
library(tidyverse)
Three_mon_Tbill<-spread_no_na$m3tbill*100
arbrates<-c(EFFR, SOFR, IORR, RRPONTSYAWARD, Three_mon_Tbill)
arbrates$Three_mon_Tbill[is.na(arbrates$Three_mon_Tbill)] <- 0
# Ensure spread_no_na contains the updated m3tbillbp column
mxrates<-max(arbrates[,2:6])
maxtbill<-max(arbrates$Three_mon_Tbill)

# Reshape the dataframe from wide to long format
arbrates_long <- arbrates %>%
  pivot_longer(cols = c(EFFR, SOFR, IORR, RRPONTSYAWARD, Three_mon_Tbill),
               names_to = "variable", values_to = "value")

# Calculate max rates for y-axis scaling
mxrates <- max(arbrates_long$value, na.rm = TRUE)
arb_rates <- ggplot(arbrates_long, aes(x = sdate, y = value, colour = variable, group = variable)) + 
  geom_point(size = 1, shape = 16) +
  labs(caption = "Sample rates 3/4/2016-12/14/2023",x = "", y = "Key rates", color = "", shape = "") +  
  scale_y_continuous(breaks = seq(0, mxrates, by = 50), limits = c(0, mxrates)) + 
  theme_minimal() + 
  guides(shape = guide_legend(title = "")) +
  scale_color_manual(values = c("EFFR" = "red",
                                "SOFR" = "magenta",
                                "IORR" = "blue",
                                "RRPONTSYAWARD" = "aquamarine",
                                "Three_mon_Tbill" = "yellow"))
  print(arb_rates)
                                

# Create the plot
# arb_rates <- ggplot(arbrates_long, aes(x = sdate, y = value, colour = variable, group = variable)) + 
#   geom_point(size = 1, shape = 16) +
#   labs(x = "", y = "Key rates", color = "", shape = "") +  
#   scale_y_continuous(breaks = seq(0, mxrates, by = 50), limits = c(0, mxrates)) + 
#   theme_minimal() + 
#   guides(shape = guide_legend(title = "")) +
#   scale_color_manual(values = c("EFFR" = "color1",
#                                 "SOFR" = "color2",
#                                 "IORR" = "color3",
#                                 "RRPONTSYAWARD" = "color4",
#                                 "m3tbillbp" = "color5"),
#                      labels = c("EFFR" = "EFFR",
#                                 "SOFR" = "SOFR",
#                                 "IORR" = "IORR",
#                                 "RRPONTSYAWARD" = "RRPONTSYAWARD",
#                                 "m3tbillbp" = "Three month Tbill"))
# 
# # Print the plot
print(arb_rates)

library(tidyverse)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_rates.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_rates.png")

# Repeat arbrates for regimes
begn<-c(1,859,923,1014,1519,1)
endn<-c(858,922,1013,1518,1957,1957)

# 1. normalcy              3/4/2016-7/31/2019    
# 2. mid cycle adjustment  8/1/2019-10/31/2019
# 3. covid                11/1/2019-3/16/2020   
# 4. zero lower bound      3/17/2020-3/16/2022
# 5. Taming inflation      3/17/2022-12/14/2023

#Normalcy
k=1
bgn=begn[k]
edn=endn[k]
arbrates_long <- arbrates[bgn:edn,] %>%
  pivot_longer(cols = c(EFFR, SOFR, IORR, RRPONTSYAWARD, Three_mon_Tbill),
               names_to = "variable", values_to = "value")
# Calculate max rates for y-axis scaling
mxrates <- max(arbrates_long$value, na.rm = TRUE)

arb_ratesnorm <- ggplot(arbrates_long, aes(x = sdate, y = value, colour = variable, group = variable)) + 
  geom_point(size = 1, shape = 16) +
  labs(caption = "Normalcy 3/4/2016--7/31/2019",x = "", y = "Key rates", color = "", shape = "") +  
  scale_y_continuous(breaks = seq(0, mxrates, by = 50), limits = c(0, mxrates)) + 
  theme_minimal() + 
  guides(shape = guide_legend(title = ""))+
  scale_color_manual(values = c("EFFR" = "red",
                                "SOFR" = "magenta",
                                "IORR" = "blue",
                                "RRPONTSYAWARD" = "aquamarine",
                                "Three_mon_Tbill" = "yellow"))

# Print the plot
print(arb_ratesnorm)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratesnorm.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratesnorm.png")


#Adjust
k=2
bgn=begn[k]
edn=endn[k]
arbrates_long <- arbrates[bgn:edn,] %>%
  pivot_longer(cols = c(EFFR, SOFR, IORR, RRPONTSYAWARD, Three_mon_Tbill),
               names_to = "variable", values_to = "value")
# Calculate max rates for y-axis scaling
mxrates <- max(arbrates_long$value, na.rm = TRUE)

arb_ratesadjust <- ggplot(arbrates_long, aes(x = sdate, y = value, colour = variable, group = variable)) + 
  geom_point(size = 1, shape = 16) +
  labs(caption = " Mid cycle adjustment  8/1/2019-10/31/2019",x = "", y = "Key rates", color = "", shape = "") +  
  scale_y_continuous(breaks = seq(0, mxrates, by = 50), limits = c(0, mxrates)) + 
  theme_minimal() + 
  guides(shape = guide_legend(title = ""))+
  scale_color_manual(values = c("EFFR" = "red",
                                "SOFR" = "magenta",
                                "IORR" = "blue",
                                "RRPONTSYAWARD" = "aquamarine",
                                "Three_mon_Tbill" = "yellow"))
print(arb_ratesadjust)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratesadjust.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratesadjust.png")


#Covid
k=3
bgn=begn[k]
edn=endn[k]
arbrates_long <- arbrates[bgn:edn,] %>%
  pivot_longer(cols = c(EFFR, SOFR, IORR, RRPONTSYAWARD, Three_mon_Tbill),
               names_to = "variable", values_to = "value")
# Calculate max rates for y-axis scaling
mxrates <- max(arbrates_long$value, na.rm = TRUE)

arb_ratescovid <- ggplot(arbrates_long, aes(x = sdate, y = value, colour = variable, group = variable)) + 
  geom_point(size = 1, shape = 16) +
  labs(caption = "Covid 11/1/2019-3/16/2020",x = "", y = "Key rates", color = "", shape = "") +  
  scale_y_continuous(breaks = seq(0, mxrates, by = 50), limits = c(0, mxrates)) + 
  theme_minimal() + 
  guides(shape = guide_legend(title = ""))+
  scale_color_manual(values = c("EFFR" = "red",
                                "SOFR" = "magenta",
                                "IORR" = "blue",
                                "RRPONTSYAWARD" = "aquamarine",
                                "Three_mon_Tbill" = "yellow"))
print(arb_ratescovid)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratescovid.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratescovid.png")

#zlb
k=4
bgn=begn[k]
edn=endn[k]
arbrates_long <- arbrates[bgn:edn,] %>%
  pivot_longer(cols = c(EFFR, SOFR, IORR, RRPONTSYAWARD,Three_mon_Tbill),
               names_to = "variable", values_to = "value")
# Calculate max rates for y-axis scaling
mxrates <- max(arbrates_long$value, na.rm = TRUE)

arb_rateszlb <- ggplot(arbrates_long, aes(x = sdate, y = value, colour = variable, group = variable)) + 
  geom_point(size = 1, shape = 16) +
  labs(caption = "Zero lower bound 3/17/2020-3/16/2022",x = "", y = "Key rates", color = "", shape = "") +  
  scale_y_continuous(breaks = seq(0, mxrates, by = 50), limits = c(0, mxrates)) + 
  theme_minimal() + 
  guides(shape = guide_legend(title = ""))+
  scale_color_manual(values = c("EFFR" = "red",
                                "SOFR" = "magenta",
                                "IORR" = "blue",
                                "RRPONTSYAWARD" = "aquamarine",
                                "Three_mon_Tbill" = "yellow"))

print(arb_rateszlb)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_rateszlb.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_rateszlb.png")

#Inflation
k=5
bgn=begn[k]
edn=endn[k]
arbrates_long <- arbrates[bgn:edn,] %>%
  pivot_longer(cols = c(EFFR, SOFR, IORR, RRPONTSYAWARD, Three_mon_Tbill),
               names_to = "variable", values_to = "value")
# Calculate max rates for y-axis scaling
mxrates <- max(arbrates_long$value, na.rm = TRUE)

arb_ratesinflation <- ggplot(arbrates_long, aes(x = sdate, y = value, colour = variable, group = variable)) + 
  geom_point(size = 1, shape = 16) +
  labs(caption = "Taming inflation      3/17/2022-12/14/2023",x = "", y = "Key rates", color = "", shape = "") +  
  scale_y_continuous(breaks = seq(0, mxrates, by = 50), limits = c(0, mxrates)) + 
  theme_minimal() + 
  guides(shape = guide_legend(title = ""))+
  scale_color_manual(values = c("EFFR" = "red",
                                "SOFR" = "magenta",
                                "IORR" = "blue",
                                "RRPONTSYAWARD" = "aquamarine",
                                "Three_mon_Tbill" = "yellow"))
print(arb_ratesinflation)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratesinflation.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/arb_ratesinflation.png")
  
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
#sdate<-as.Date(spread$Date,format="%m/%d/%Y")
# but really %Y-%m-%d
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
# sdate <- sdate[1:T]

# Define the start and end dates using sdate
start_date <- sdate[1]
end_date <- sdate[T]
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


# 'data.frame':	1957 obs. of  12 variables:
#   $ sdate                 : Date, format: "2016-03-04" "2016-03-07" "2016-03-08" "2016-03-09" ...
# $ holiday               : num  0 0 0 0 0 0 0 0 0 0 ...
# $ oneday_beforeholiday  : num  0 0 0 0 0 0 0 0 0 0 ...
# $ threeday_beforeholiday: num  0 0 0 0 0 0 0 0 0 0 ...
# $ oneday_afterholiday   : num  0 0 0 0 0 0 0 0 0 0 ...
# $ threeday_afterholiday : num  0 0 0 0 0 0 0 0 0 0 ...
# $ endquarter            : num  0 0 0 0 0 0 0 0 0 0 ...
# $ endyear               : num  0 0 0 0 0 0 0 0 0 0 ...
# $ around_qtr            : num  0 0 0 0 0 0 0 0 0 0 ...
# $ around_yr             : num  0 0 0 0 0 0 0 0 0 0 ...
# $ Monday                : num  0 1 0 0 0 0 1 0 0 0 ...
# $ Friday                : num  1 0 0 0 0 1 0 0 0 0 ...


# non trading dates ----------------------------------------------------
# Load necessary packages
if (!require("timeDate")) install.packages("timeDate")
#if (!require("dplyr")) install.packages("dplyr")

library(timeDate)
#library(dplyr)

# Example list of public holidays (you can customize this list)
#public_holidays <- as.Date(c("2024-01-01", "2024-12-25", "2024-07-04"))

# Function to calculate non-trading days
non_trading_days <- function(start_date, end_date, holidays) {
  # Generate sequence of dates between start_date and end_date
  date_seq <- seq.Date(start_date, end_date, by = "day")
  
  # Identify weekends
  weekends <- weekdays(date_seq) %in% c("Saturday", "Sunday")
  
  # Identify public holidays
  holidays <- date_seq %in% holidays
  
  # Combine weekends and holidays
  non_trading <- weekends | holidays
  
  # Count non-trading days
  non_trading_count <- sum(non_trading)
  
  return(non_trading_count)
}

# Function to calculate non-trading days between pairs of dates---------------------------
#function(start_date, end_date, holidays)
non_trading_days_pairs <- function(dates, holidays) {
  n <- length(sdate)
  non_trading_counts <- numeric(n-1)
  
  for (i in 2:n) {
    start_date <- sdate[i - 1]
    end_date <- sdate[i]
    
    # Generate sequence of dates between start_date and end_date
    date_seq <- seq.Date(start_date, end_date, by = "day")
    
    # Identify weekends
    weekends <- weekdays(date_seq) %in% c("Saturday", "Sunday")
    
    # Identify public holidays
    holidays <- date_seq %in% holidays
    
    # Combine weekends and holidays
    non_trading <- weekends | holidays
    
    # Count non-trading days
    non_trading_counts[i - 1] <- sum(non_trading)
  }
  
  return(non_trading_counts)
}
# Example usage
#start_date <- as.Date("2024-07-01")
#end_date <- as.Date("2024-07-15")
public_holidays<-h$holidays
num_non_trading_days <- non_trading_days(start_date, end_date, public_holidays)
print(num_non_trading_days)
date_seq <- seq.Date(start_date, end_date, by = "day")

# CUSTOM end of quarters 1-3---------------------------------------------------
eq2017q3<-which(sdate == as.Date("2017-09-29")) 
h[eq2017q3,7]=1
# 
eq2018q1<-which(sdate == as.Date("2018-03-30"))
h[eq2018q1,7]=1
# 
eq2018q2<-which(sdate == as.Date("2018-06-29")) 
h[eq2018q2,7]=1
# 
eq2018q3<-which(sdate == as.Date("2018-09-29")) 
h[eq2018q3,7]=1
# 
eq2019q1<-which(sdate == as.Date("2019-03-19")) 
h[eq2019q1,7]=1
# 
eq2019q2<-which(sdate == as.Date("2019-06-28")) 
h[eq2019q2,7]=1
# 
eq2020q3<-which(sdate == as.Date("2020-09-28")) 
h[eq2020q3,7]=1
# 
eq11<- which(sdate == as.Date("2016-03-31")) 
h[eq11,7]=1
# 
eq2023q3<-which(sdate == as.Date("2023-09-29")) 
h[eq2023q3,7]=1
# 
# # customized end of year, end of quarter 4
# ey2016<- which(sdate == as.Date("2016-03-30")) 
# h[ey2016,1:8]
# 
ey2016<- which(sdate == as.Date("2016-12-30")) 
# h[ey2016,1:8]
h[ey2016,7:8]=1
# 
ey2017<- which(sdate == as.Date("2017-12-29")) 
# h[ey2017,1:8]
h[ey2017,7:8]=1
# 
ey2018<- which(sdate == as.Date("2018-12-31")) 
h[ey2018,7:8]=1
# 
ey2019<- which(sdate == as.Date("2019-12-31")) 
h[ey2019,7:8]=1
# 
ey2020<- which(sdate == as.Date("2020-12-31")) 
h[ey2020,7:8]=1
# 
ey2021<- which(sdate == as.Date("2021-12-31")) 
h[ey2021,7:8]=1
# 
ey2022<- which(sdate == as.Date("2022-12-30")) 
h[ey2022,7:8]=1

ey2023<- which(sdate == as.Date("2023-12-14")) 
h[ey2023,7:8]=1
#-----------------------------------------------------

# Chat version 2
# Load necessary package
library(lubridate)

# Example dataset with dates

# Define the start and end dates for the seven years
start_date <- as.Date("2016-03-04")
end_date <- as.Date("2023-12-14")

h <- data.frame(sdate = seq.Date(from = start_date, to = end_date, by = "month"))

# Function to check if a date is the end of a quarter
is_end_of_quarter <- function(date) {
  month(date) %in% c(3, 6, 9, 12) && day(date) == days_in_month(date)
}

# Determine the first end-of-quarter date from the start_date
if (is_end_of_quarter(start_date)) {
  first_quarter_end <- start_date
} else {
  # Get the next quarter's ceiling date
  next_quarter_date <- ceiling_date(start_date, "quarter")
  # Rollback to the last day of the previous month
  first_quarter_end <- rollback(next_quarter_date)
}

# Generate end-of-quarter dates for the date range
end_quarter_dates <- seq(from = first_quarter_end, to = end_date, by = "quarter")

# Check if the dates in h$sdate are end-of-quarter dates
h$endquarter <- h$sdate %in% end_quarter_dates

# str(h)
# 'data.frame':	1957 obs. of  12 variables:
#   $ sdate                 : Date, format: "2016-03-04" "2016-03-07" "2016-03-08" "2016-03-09" ...
# $ holiday               : num  0 0 0 0 0 0 0 0 0 0 ...
# $ oneday_beforeholiday  : num  0 0 0 0 0 0 0 0 0 0 ...
# $ threeday_beforeholiday: num  0 0 0 0 0 0 0 0 0 0 ...
# $ oneday_afterholiday   : num  0 0 0 0 0 0 0 0 0 0 ...
# $ threeday_afterholiday : num  0 0 0 0 0 0 0 0 0 0 ...
# $ endquarter            : num  0 0 0 0 0 0 0 0 0 0 ...
# $ endyear               : num  0 0 0 0 0 0 0 0 0 0 ...
# $ around_qtr            : num  0 0 0 0 0 0 0 0 0 0 ...
# $ around_yr             : num  0 0 0 0 0 0 0 0 0 0 ...
# $ Monday                : num  0 1 0 0 0 0 1 0 0 0 ...
# $ Friday                : num  1 0 0 0 0 1 0 0 0 0 ...

# CHATend
  
# EGARCH ----------------------------------------------------------------
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
  
```
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
  spread_no_na$h<-h
  dummy_h <- spread_no_na$h
  #dummy_h <- dummy_h[, -which(names(dummy_h) == "sdate")]  # Remove the sdate column if present
  dummy_h_matrix <- as.matrix(dummy_h)
  str(dummy_h)
  spread_no_na$dummy_h<-dummy_h
  
  # create fomc d
  #ta in h
  # Sample data frame for fomc
  fomc <- data.frame(
    Date = c("14-Dec-16", "15-Mar-17", "14-Jun-17", "13-Dec-17", "21-Mar-18", "13-Jun-18", "26-Sep-18", "19-Dec-18", 
             "31-Jul-19", "18-Sep-19", "30-Oct-19", "3-Mar-20", "15-Mar-20", "19-Mar-20", "23-Mar-20", "31-Mar-20", 
             "29-Apr-20", "10-Jun-20", "29-Jul-20", "27-Aug-20", "16-Sep-20", "5-Nov-20", "16-Mar-22", "4-May-22", 
             "15-Jun-22", "27-Jul-22", "21-Sep-22", "2-Nov-22", "14-Dec-22", "1-Feb-23", "22-Mar-23", "3-May-23", 
             "14-Jun-23", "26-Jul-23", "20-Sep-23", "1-Nov-23", "13-Dec-23"),
    From = c(0.50, 0.75, 1.00, 1.25, 1.50, 1.75, 2.00, 2.20, 2.00, 1.75, 1.50, 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
             0.00, 0.00, 0.00, 0.00, 0.25, 0.75, 1.50, 2.25, 3.00, 3.75, 4.25, 4.50, 4.75, 5.00, 5.00, 5.25, 5.25, 5.25, 5.25),
    To = c(0.75, 1.00, 1.25, 1.50, 1.75, 2.00, 2.25, 2.50, 2.25, 2.00, 1.75, 1.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 
           0.25, 0.25, 0.25, 0.25, 0.50, 1.00, 1.75, 2.50, 3.25, 4.00, 4.50, 4.75, 5.00, 5.25, 5.25, 5.50, 5.50, 5.50, 5.50),
    Basis.points = c(25, 25, 25, 25, 25, 25, 25, 25, -25, 25, -25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 
                     25, 25, 25, 25, 25, 25, 25, 25, 0, 25, 0, 0, 0),
    Discount.rate = c(0.0125, 0.0150, 0.0175, 0.0200, 0.0225, 0.0250, 0.0275, 0.0300, 0.0275, 0.0275, 0.0275, 0.0275, 
                      0.0025, 0.0025, 0.0025, 0.0025, 0.0025, 0.0025, 0.0025, 0.0025, 0.0025, 0.0025, 0.0050, 0.0100, 
                      0.0175, 0.0250, 0.0325, 0.0400, 0.0450, 0.0475, 0.0500, 0.0525, 0.0525, 0.0550, 0.0550, 0.0550, 0.0550)
  )
    
  #      Votes = c("10–0", "9–1", "8–1", "7–2", "8–0", "8–0", "9–0", "10–0", "8–2", "7–3", "8–2", "10–0", "9–1", "", "", "", 
  #             "", "", "", "unanimous", "", "", "8–1", "9–0", "8–1", "12–0", "12–0", "12–0", "12–0", "12–0", "11–0", 
  #             "11–0", "11–0", "12–0", "12–0", "12–0")
  # )
 
  # ------------------------------------- NEW DELETE its done
  # # Ensure dates are in the same format
  # fomc$Date <- as.Date(fomc$Date, format = "%d-%b-%y")
  # dummy_h$sdate <- as.Date(dummy_h$sdate)
  # 
  # # Initialize the new column with default values (e.g., 0)
  # dummy_h$fomc <- rep(0, nrow(dummy_h))
  # 
  # # Find the matching indices
  # match_indices <- match(dummy_h$sdate, fomc$Date)
  # 
  # # Insert the Basis.points values at the matched indices
  # dummy_h$fomc[!is.na(match_indices)] <- fomc$Basis.points[match_indices[!is.na(match_indices)]]
  # 
  # # Check the resulting dataframe
  # print(dummy_h)
  # 
  # 
  # # Create the dummy variable
  # # Method 1
  # # The ifelse function in R is a vectorized conditional function that takes three arguments:
  # # 1. A logical condition.
  # # 2.The value to return if the condition is TRUE.
  # # 3. The value to return if the condition is FALSE.
  # # In the code ifelse(dummy_h2$fomc == 0, 0, 1), the condition dummy_h2$fomc == 0 
  # # is checked for each element in dummy_h2$fomc. If the condition is TRUE (i.e., dummy_h2$fomc is 0), 
  # # it returns 0. Otherwise (i.e., dummy_h2$fomc is not 0), it returns 1.
  # 
  # dummy_h$fomcindex <- ifelse(dummy_h$fomc == 0, 0, 1)
  # 
  # # Check the resulting dataframe
  # print(dummy_h)
  # 
  # # Method 2
  # # Initialize the new column with default values (e.g., 0)
  # #dummy_h$fomcindex <- rep(0, nrow(dummy_h))
  # 
  # # Set the value to 1 where fomc is not equal to 0
  # #dummy_h$fomcindex[dummy_h$fomc != 0] <- 1
  # 
  # # Check the resulting dataframe
  # #print(dummy_h)
  #--------------------------------------------------------------
  h<-spread_no_na$h
  str(h)
  h$around_qtr <- NULL
  h$around_yr <- NULL
  h$holiday <- NULL
  h$threeday_afterholiday<- NULL  # only zeros --> check data
  str(h)
  #---------------------------------------------------------
  

  # Generate T observations for sd_effr from a normal distribution
  set.seed(123)  # Setting seed for reproducibility
  
  # Generate penalty function (z)
  # Assuming h and z are known and have T-1 observations
  T <- nrow(spread_no_na) #number of observations
  target<-.5*(spread_no_na$TargetDe+spread_no_na$TargetUe)
  z<- 1- target/(spread_no_na$DPCREDIT*100)
  sd_effr<-spread_no_na$sd_effr*100
  log_sd_effr_squared <- log(sd_effr^2)
  mu <- 0
  sigma <- 1
  #nu <- rnorm(T, mean = mu, sd = sigma)
  nu<-rt(T, df = 5)
  #abs(\nu_{t-1})+ \theta \nu_{t-1}
  absnu<-abs(nu)

  
  # Log function for non-trading days---------------------------------
  #non_trading_days <- non_trading_days_pairs(dates, holidays)
  # Define the holidays vector
  holidays <- as.Date(c(
    "2016-01-01", "2016-01-18", "2016-02-15", "2016-03-25", "2016-05-30", 
    "2016-07-04", "2016-09-05", "2016-11-24", "2016-12-26", "2017-01-02", 
    "2017-01-16", "2017-02-20", "2017-04-14", "2017-05-29", "2017-07-04", 
    "2017-09-04", "2017-11-23", "2017-12-25", "2018-01-01", "2018-01-15", 
    "2018-02-19", "2018-03-30", "2018-05-28", "2018-07-04", "2018-09-03", 
    "2018-11-22", "2018-12-25", "2019-01-01", "2019-01-21", "2019-02-18", 
    "2019-04-19", "2019-05-27", "2019-07-04", "2019-09-02", "2019-11-28", 
    "2019-12-25", "2020-01-01", "2020-01-20", "2020-02-17", "2020-04-10", 
    "2020-05-25", "2020-07-03", "2020-09-07", "2020-11-26", "2020-12-25", 
    "2021-01-01", "2021-01-18", "2021-02-15", "2021-04-02", "2021-05-31", 
    "2021-07-05", "2021-09-06", "2021-11-25", "2021-12-24", "2022-01-17", 
    "2022-02-21", "2022-04-15", "2022-05-30", "2022-06-20", "2022-07-04", 
    "2022-09-05", "2022-11-24", "2022-12-26", "2023-01-02", "2023-01-16", 
    "2023-02-20", "2023-04-07", "2023-05-29", "2023-06-19", "2023-07-04", 
    "2023-09-04", "2023-11-23", "2023-12-25", "2016-11-11", "2017-11-11", 
    "2018-11-11", "2019-11-11", "202X0-11-11", "2021-11-11", "2022-11-11", 
    "2023-11-11", "2016-10-10", "2017-10-09", "2018-10-08", "2019-10-14", 
    "2020-10-12", "2021-10-11", "2022-10-10", "2023-10-09", "2020-07-04", 
    "2021-07-04", "2016-12-25", "2021-12-25", "2022-12-25"
  ))
  
  # --------------------------------------------------------------
  non_trading_counts <- non_trading_days_pairs(dates, holidays)
  nontradingdays<-non_trading_counts
  
  log_nontradingdays <- function(gamma, nontradingdays) {
    return(log(1 - gamma * nontradingdays))
  }
  
  # Negative log-likelihood function
  if (!require("stats4")) install.packages("stats4")
  library(stats4)
 
  #length(non_trading_counts) #1957
  #length(log_sd_effr_squared[2:T]) #1956

  neg_log_likelihood <- function(gamma) {
    if (any(1 - gamma * non_trading_counts <= 0)) {
      return(Inf)
    }
    X <- log(1 - gamma * non_trading_counts)
    model <- lm(log_sd_effr_squared ~ X)
    residuals <- residuals(model)
    log_likelihood <- -sum(dnorm(residuals, mean = 0, sd = sd(residuals), log = TRUE))
    return(log_likelihood)
  }
  
  gamma <- 0.01  # Assign a specific value to gamma
  log_nontradingdays(gamma, non_trading_counts)
  result <- neg_log_likelihood(gamma)
  
  
# EXPLANATION of this code:
#   1. What does the log_nontradingdays function do?
#     r
#   Copy code
#   log_nontradingdays <- function(gamma, nontradingdays) {
#     return(log(1 - gamma * nontradingdays))
#   }
#   This function takes two arguments:
#     
#     gamma: A parameter that you are likely estimating or optimizing.
#   nontradingdays: A variable representing the number of non-trading days (or possibly a proportion, depending on your context).
#   The function computes the natural logarithm of 1 - gamma * nontradingdays. The idea here is likely related to some transformation or modeling of the relationship between gamma and the nontradingdays.
#   
#   2. Does the code use this log_nontradingdays function?
#     The log_nontradingdays function is not directly used in the neg_log_likelihood function in the code you've provided. However, the logic of log_nontradingdays is effectively replicated in the neg_log_likelihood function:
# 
# r
# Copy code
# X <- log(1 - gamma * non_trading_counts)
# This line does exactly what log_nontradingdays(gamma, non_trading_counts) would do if the log_nontradingdays function were used directly. However, the code directly implements the logic rather than calling the log_nontradingdays function. This could be because the author (or you) decided to simplify or optimize the code by avoiding an additional function call.
# 
# Why is nontradingdays not an argument in neg_log_likelihood?
# The reason nontradingdays (or non_trading_counts in the context of neg_log_likelihood) is not an argument in the neg_log_likelihood function is likely because it is being treated as a global variable. The function neg_log_likelihood only takes gamma as an argument and assumes that non_trading_counts (or whatever name you are using) is defined elsewhere in your script or environment.
# 
# Summary
# The log_nontradingdays function computes the log-transformation of 1 - gamma * nontradingdays.
# The logic of log_nontradingdays is replicated within neg_log_likelihood, but the function itself is not used.
# nontradingdays is not an argument in neg_log_likelihood because the function relies on the global variable non_trading_counts instead.
# 


#----------------------------------------------------------------------  

  external_regressors <- cbind(h[,2:ncol(h)], z,nt,absnu, nu)
  
  # Ensure there are no non-finite values in the cleaned data
  stopifnot(!any(is.na(log_sd_effr_squared)))
  stopifnot(!any(is.infinite(log_sd_effr_squared)))
  #stopifnot(!any(is.na(external_regressors_cleaned)))
  stopifnot(!any(is.na(external_regressors)))
  stopifnot(!any(is.infinite(as.matrix(external_regressors_cleaned))))
  
  # Calculate correlation matrix
  cor_matrix<- cor(external_regressors, use = "complete.obs")
  # Warning message:
  #   In cor(external_regressors, use = "complete.obs") :
  #   the standard deviation is zero
  print(cor_matrix)

  
  # str(external_regressors)
  # 'data.frame':	1957 obs. of  11 variables:
  #   $ holiday               : num  0 0 0 0 0 0 0 0 0 0 ...
  # $ oneday_beforeholiday  : num  0 0 0 0 0 0 0 0 0 0 ...
  # $ threeday_beforeholiday: num  0 0 0 0 0 0 0 0 0 0 ...
  # $ oneday_afterholiday   : num  0 0 0 0 0 0 0 0 0 0 ...
  # $ endquarter            : num  0 0 0 0 0 0 0 0 0 0 ...
  # $ endyear               : num  0 0 0 0 0 0 0 0 0 0 ...
  # $ Monday                : num  0 1 0 0 0 0 1 0 0 0 ...
  # $ Friday                : num  1 0 0 0 0 1 0 0 0 0 ...
  # $ z                     : num  0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.625 ...
  # $ absnu                 : num  1.14 0.341 1.271 1.846 0.272 ...
  # $ nu                    : num  1.14 -0.341 -1.271 1.846 0.272 ...
  
  # Create a zoo object for log_sd_effr_squared with sdate as the index
  log_sd_effr_squared_zoo <- zoo(log_sd_effr_squared, order.by = spread_no_na$sdate)
  
  # Fit an ARIMA model with cleaned external regressors using CSS
  arima_model <- arima(coredata(log_sd_effr_squared_zoo), order = c(1, 0, 0), xreg = external_regressors, method = "CSS")
  
  # 1. Extract parameters and residuals --------------------------------------------
  arima_params <- arima_model$coef
  arima_residuals <- residuals(arima_model)
  
  print("ARIMA Model Parameters:")
  print(arima_params)
  
  arima_params <- arima_model$coef
  vcov_matrix <- vcov(arima_model)
  std_errors <- sqrt(diag(vcov_matrix))
  results <- data.frame(Coefficients = arima_params, StdErrors = std_errors)
  
  row_labels <- c("ar1", "intercept", "oneday_beforeholiday", "threeday_beforeholiday", 
                  "oneday_afterholiday", "endquarter", "endyear", "Monday", "Friday", "fomc","fomcindex","z", 
                  "nt", "absnu", "nu")  
  
  # Print the results
  print(results)     
  # Convert the parameter_estimates to a data frame
  arima_params <- as.data.frame(results)
  #cat("DailyEFFR 2016-2023\n")
  
# 2.Create vectors for Bertolini et al 1994 no FOMC ARIMA params 
# BBP post 1994 no fomc ------------------------------------------------------------------
coefficients <- c(0.6, NA, NA, NA, NA, 2.081, 2.913, NA, NA, 0.783, NA, 1.24, NA, 0.718, 0.276)
std_errors <- c(0.038, NA, NA, NA, NA, 0.181, 0.331, NA, NA, 0.262, NA, 0.465, NA, 0.069, 0.042)

# Create the dataframe without row labels as a separate column
bbp1994_params <- data.frame(Coefficients = coefficients, `Std Errors` = std_errors, row.names = row_labels)

# Print the title and the dataframe
#cat("BBP post 1994 no FOMC\n")
#print(bbp1994_params)

# DONT USE SECTION UNTIL SLOVED TITLE PLACEMENT
# NO success adding titles and subheadings to params tables  it makes title another column
  # Combine arima_params_df and bbp1994_params--------------------------------
  # Add a title column to each dataframe
  arima_params$title <- "DailyEFFR 2016-2023"
  bbp1994_params$title <- "BBP post 1994 no FOMC"
  
  # Ensure column names match
  # Both dataframes should have exactly: "Coefficients", "StdErrors", "title"
  colnames(arima_params) <- c("Coefficients", "StdErrors")
  colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
  
  # Add the title column if not already added
  if (!"title" %in% colnames(arima_params)) {
    arima_params$title <- "DailyEFFR 2016-2023"
    # To delete, use 1. arima_params$title <- NULL
    # or 2.library(dplyr) arima_params <- arima_params %>% select(-title)
  }
  if (!"title" %in% colnames(bbp1994_params)) {
    #bbp1994_params$title <- "BBP post 1994 no FOMC"
    #  bbp1994_params$title <- NULL
  }
  # ----------------------------------------------------------
  
  #Created combined arima_bbp2 table.  Both my reproduced results and bbp.
  #Need to fix  figure caption and sub headings above columns
  
  # Ensure both dataframes have the same column names
  colnames(arima_params) <- c("Coefficients", "StdErrors")
  colnames(bbp1994_params) <- c("Coefficients", "StdErrors")

  # Combine the dataframes for any further analysis if needed
  combined_params <- cbind(arima_params, bbp1994_params)
  
  # Print the titles and dataframes separately for clear output
  cat("DailyEFFR 2016-2023\n")
  print(arima_params_df)
  cat("\nBBP post 1994 no FOMC\n")
  print(bbp1994_params)
  
  # Create a table using xtable-------------------- for overnight EFFR
  combined_arimas_table <- xtable(combined_params)
  
  # Print a separator line (optional)
  cat("\n-----------------------\n")
  
  FIX TITLE!---------------------------------------------------
  # Print the combined dataframe if needed for further analysis
  cat("\nCombined DataFrame:\n")
  print(combined_params)
  
  # Custom print function to visually align titles above columns
  print_with_titles <- function(df1, df2, title1, title2) {
    # Print the titles
    cat(title1, "\t\t\t", title2, "\n")
    
    # Print the column names
    cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
    
    # Print the data row by row
    for (i in 1:nrow(arima_params_df)) {
      cat(paste(arima_params[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
    }
  }
  
  # IGNORE: BBP fill sample----------------------------------------
  # row labels should be. go back, change variable definition in arima
  # row_labels <- c("ar1", "intercept", "oneday_beforeholiday", "threeday_beforeholiday", 
  #                   "oneday_afterholiday", "endquarter", "endyear", "Monday", "Friday", "FOMC","FOMCindex","penalty", 
  #                   "non trading days", "abs_nu", "nu")
  
  row_labels <- c("endyear","endquarter", oneday_beforeholiday", "threeday_beforeholiday",oneday_afterholiday", "threeday_afterholiday",)
  coefficients <- c(-.186, .206,-0.026, -0.018,0.052,0.209)
  std_errors_full <- c(0.078.0.034,0.017,0.008,0.018,0.013)
  # COrrect order
  row_labels_full <- c( oneday_beforeholiday", "threeday_beforeholiday",oneday_afterholiday", "threeday_afterholiday","endquarter","endyear",)
  coefficients_full <- c(-0.026, -0.018,0.052,0.209, 0.206,-0.186)
  std_errors_full <- c(0.017,0.008,0.018,0.013,0.034,0.078)
  
  
  
  t.test(arima_params, y = NULL,
         alternative = c("two.sided", "less", "greater"),
         mu = 0, paired = FALSE, var.equal = FALSE,
         conf.level = 0.95)
  
  # One Sample t-test
  # data:  arima_params
  # t = 1.0425, df = 10, p-value = 0.3217
  # alternative hypothesis: true mean is not equal to 0
  # 95 percent confidence interval:
  #   -0.2472958  0.6821528
  # sample estimates:
  #   mean of x 
  # 0.2174285 
  
  # Specify the EGARCH model --------------------------------------
  spec <- ugarchspec(
    variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
    mean.model = list(armaOrder = c(0, 0), include.mean = FALSE),
    distribution.model = "std" 
  )
  #"norm"
  # Fit the EGARCH model on the residuals from the ARIMA model
  fit <- ugarchfit(spec = spec, data = arima_residuals)
  
  # Print the EGARCH model parameters
  print("EGARCH Model Parameters:")
  print(coef(fit))
  
  coefficients <- coef(fit)
  
  # Extract the variance-covariance matrix
  vcov_matrix <- vcov(fit)
  
  # Calculate standard errors from the diagonal of the vcov matrix
  std_errors <- sqrt(diag(vcov_matrix))
  
  # Combine coefficients and standard errors into a data frame
  results <- data.frame(Coefficients = coefficients, StdErrors = std_errors)
  
  # Print the results
  print(results)
  
  # Convert the parameter_estimates to a data frame
  coefgarch_df <- as.data.frame(results)
  
  # Create a table using xtable
  coefgarch_table <- xtable(coefgarch_df)
  
  # Print the table
  print(coefgarch_table)
  
  residuals_bbp <- residuals(fit)
  plot(residuals_bbp)
  #ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/egarch_bbp.pdf")
  #ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/egarch_bbp.png")
  
  
  #joint table on garcg and bbp
  
  # GARCH--------------------------------
  # Notes
  # \url{https://vlab.stern.nyu.edu/docs/volatility/EGARCH}
  # coefficient $\alpha_j$ captures the sign effect and $\gamma_j$ the size effect
  # persistence effect $\sum_{j=1}{p} \beta_j$
  # The unconditional variance and half life follow from the persistence parameter and are calculated
  # as in Section 2.2.1.
  # Shape?
  
  # V-Lab estimates all the parameters 
  # simultaneously, by maximizing the log likelihood. The assumption that 
  # is Gaussian does not imply the returns are Gaussian. Even though their conditional distribution is Gaussian, it can be proved that their unconditional distribution presents excess kurtosis (fat tails). In fact, assuming that the conditional distribution is Gaussian is not as restrictive as it seems: even if the true distribution is different, the so-called Quasi-Maximum Likelihood (QML) estimator is still consistent, under fairly mild regularity conditions.
  # 
  # Besides leptokurtic returns, the 
  # model, as the 
  # model, captures other stylized facts in financial time series, like volatility clustering. The volatility is more likely to be high at time 
  # if it was also high at time 
  # . Another way of seeing this is noting that a shock at time
  # also impacts the variance at time 
  # 
  # Tsay

  # versus weakness of ARCH, GARCH responds  to positive aqnd negative shocks
  # For a log rturn r, we assume thaaat the mean equationof the porcess can be adequately described by an ARMA model. 
  # see top page 94
  
# Repeat of 2?  Where is 3: arimas+new rrbp1994nofomc  rrbp1994
  row_labels <- c("omega","alpha1", "beta1", "gamma1","shape")
  colnames(garch_params) <- c("Coefficients", "StdErrors")
  colnames(bbp1994garch_params) <- c("Coefficients", "StdErrors")
  
   
coefficients <- c(0.6, NA, NA, NA, NA, 2.081, 2.913, NA, NA, 0.783, NA, 1.24, NA, 0.718, 0.276)
std_errors <- c(0.038, NA, NA, NA, NA, 0.181, 0.331, NA, NA, 0.262, NA, 0.465, NA, 0.069, 0.042)

# Create the dataframe without row labels as a separate column
bbp1994_params <- data.frame(Coefficients = coefficients, `Std Errors` = std_errors, row.names = row_labels)

          sign  alpha1 0.028 (0.085)  0.329 0.742
persistance     beta1  0.656 (0.043) 15.264 0.000
size            gamma1  2.157 (0.764)  2.825 0.0047


halflife=-log(2)/log(garch_params[3,1])
print(halflife) # 1.642238
condvar =garch_params[1,1]/(1-garch_params[3,1])
print(condvar) #-0.0008741995

# Define the text data without row labels and with modified column header
text_data <- "
                  Estimate Std_Error t_Value Pr_abs_t
                  -0.000301 0.241476 -0.001246 0.999006
                  0.027822 0.084668 0.328600 0.742458
                  0.655685 0.042956 15.264051 0.000000
                  2.157099 0.763514 2.825224 0.004725
                  2.100000 0.077000 27.272755 0.000000
                  "

# Convert the text data to a dataframe with a placeholder for the problematic column name
garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)

# Rename the columns to their intended names
colnames(garch_params) <- c("Estimate", "Std_Error", "t_Value", "Pr(> abs(t))")

print(garch_params)

##--------------------------------------------------------------
+     # Print the titles
  +     cat(title1, "\t\t", title2, "\n")
+     
  +     # Print the column names
  +     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
+     
  +     # Print the data row by row
  +     for (i in 1:nrow(df1)) {
    +         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
    +     }
+ }
> 
  > # Use the custom print function
  > print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
  > # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> 
  > # Print the combined dataframe for any further analysis if needed
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> 
  > # Print the column names
  > cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
Coefficients	StdErrors 	 Coefficients	StdErrors 
> 
  > # Print the data row by row
  > for (i in 1:nrow(arima_params_df)) {
    +     cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
    + }
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> }
Error: unexpected '}' in "}"
> # Use the custom print function
  > print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
  > # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> 
  > # Print the combined dataframe for any further analysis if needed
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
  > # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> 
  > # Print the combined dataframe for any further analysis if needed
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> 
  > # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> 
  > # Print the combined dataframe for any further analysis if needed
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
  > 
  > # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> 
  > 
  > # Print the combined dataframe for any further analysis if needed
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> colnames(arima_params_df) <- c("Coefficients", "StdErrors")
> colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
> 
  > 
  > # Custom print function to visually align titles above columns
  > print_with_titles <- function(df1, df2, title1, title2) {
    +     # Print the titles
      +     cat(title1, "\t\t", title2, "\n")
    +     
      +     # Print the column names
      +     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
    +     
      +     # Print the data row by row
      +     for (i in 1:nrow(arima_params_df)) {
        +         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
        +     }
    + }
> 
  > # Use the custom print function
  > print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
  > 
  > # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> 
  > 
  > # Print the combined dataframe for any further analysis if needed
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> 
  > colnames(arima_params_df) <- c("Coefficients", "StdErrors")
> colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
> 
  > 
  > # Custom print function to visually align titles above columns
  > print_with_titles <- function(df1, df2, title1, title2) {
    +     # Print the titles
      +     cat(title1, "\t\t\t", title2, "\n")
    +     
      +     # Print the column names
      +     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
    +     
      +     # Print the data row by row
      +     for (i in 1:nrow(arima_params_df)) {
        +         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
        +     }
    + }
> 
  > # Use the custom print function
  > print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 			 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
  > 
  > # Combine the dataframes using cbind for further analysis
  > combined_df <- cbind(arima_params_df, bbp1994_params)
> 
  > 
  > # Print the combined dataframe for any further analysis if needed
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> combined_arimas_table <- xtable(combined_df)
> combined_arimas_table
% latex table generated in R 4.3.2 by xtable 1.8-4 package
% Thu Jul 18 17:34:35 2024
\begin{table}[ht]
\centering
\begin{tabular}{rrrrr}
\hline
& Coefficients & StdErrors & Coefficients & StdErrors \\ 
\hline
ar1 & 0.84 & 0.01 & 0.06 & 0.04 \\ 
intercept & 2.01 & 0.11 &  &  \\ 
oneday\_beforeholiday & 0.10 & 0.13 &  &  \\ 
threeday\_beforeholiday & -0.10 & 0.05 &  &  \\ 
oneday\_afterholiday & 0.04 & 0.13 &  &  \\ 
endquarter & 0.11 & 0.14 & 2.08 & 0.18 \\ 
endyear & 0.07 & 0.17 & 2.91 & 0.33 \\ 
Monday & 0.00 & 0.06 &  &  \\ 
Friday & -0.01 & 0.02 &  &  \\ 
fomc & 0.01 & 0.01 & 0.78 & 0.26 \\ 
fomcindex & -0.28 & 0.15 &  &  \\ 
z & -0.70 & 0.22 & 1.24 & 0.46 \\ 
nt & 0.06 & 0.09 &  &  \\ 
absnu & -0.00 & 0.01 & 0.72 & 0.07 \\ 
nu & -0.01 & 0.01 & 0.28 & 0.04 \\ 
\hline
\end{tabular}
\end{table}
> # Define your dataframes arima_params_df and bbp1994_params
  > # Assuming they are already defined
  > 
  > # Ensure both dataframes have the same column names
  > colnames(arima_params_df) <- c("Coefficients", "StdErrors")
> colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
> 
  > # Print the title and the arima_params_df dataframe
  > cat("DailyEFFR 2016-2023\n")
DailyEFFR 2016-2023
> print(arima_params_df)
Coefficients   StdErrors
ar1                     0.844237998 0.013053850
intercept               2.014386816 0.107115536
oneday_beforeholiday    0.100839203 0.132623548
threeday_beforeholiday -0.095986648 0.045628642
oneday_afterholiday     0.035191454 0.129995377
endquarter              0.114887391 0.142475753
endyear                 0.066116640 0.173470169
Monday                  0.004691872 0.061329648
Friday                 -0.011205695 0.023676676
fomc                    0.009640622 0.005993818
fomcindex              -0.282124740 0.149256602
z                      -0.700007226 0.221871277
nt                      0.061577943 0.091488156
absnu                  -0.002429300 0.011621492
nu                     -0.007706428 0.007626636
> 
  > # Print a separator line (optional)
  > cat("\n-----------------------\n")

-----------------------
  > 
  > # Print the title and the bbp1994_params dataframe
  > cat("BBP post 1994 no FOMC\n")
BBP post 1994 no FOMC
> print(bbp1994_params)
Coefficients StdErrors
ar1                           0.060     0.038
intercept                        NA        NA
oneday_beforeholiday             NA        NA
threeday_beforeholiday           NA        NA
oneday_afterholiday              NA        NA
endquarter                    2.081     0.181
endyear                       2.913     0.331
Monday                           NA        NA
Friday                           NA        NA
fomc                          0.783     0.262
fomcindex                        NA        NA
z                             1.240     0.465
nt                               NA        NA
absnu                         0.718     0.069
nu                            0.276     0.042
> 
*---------------------------------*
  *          GARCH Model Fit        *
  *---------------------------------*
  
  Conditional Variance Dynamics 	
-----------------------------------
  GARCH Model	: eGARCH(1,1)
Mean Model	: ARFIMA(0,0,0)
Distribution	: std 

Optimal Parameters
------------------------------------
  Estimate  Std. Error   t value Pr(>|t|)
omega  -0.000301    0.241476 -0.001246 0.999006
alpha1  0.027822    0.084668  0.328600 0.742458
beta1   0.655685    0.042956 15.264051 0.000000
gamma1  2.157099    0.763514  2.825224 0.004725
shape   2.100000    0.077000 27.272755 0.000000

Robust Standard Errors:
  Estimate  Std. Error   t value Pr(>|t|)
omega  -0.000301    0.308840 -0.000974 0.999222
alpha1  0.027822    0.090948  0.305910 0.759673
beta1   0.655685    0.081888  8.007135 0.000000
gamma1  2.157099    1.063278  2.028726 0.042486
shape   2.100000    0.110032 19.085410 0.000000

LogLikelihood : -934.457 

Information Criteria
------------------------------------
  
  Akaike       0.96010
Bayes        0.97435
Shibata      0.96009
Hannan-Quinn 0.96534

Weighted Ljung-Box Test on Standardized Residuals
------------------------------------
  statistic   p-value
Lag[1]                      18.82 1.438e-05
Lag[2*(p+q)+(p+q)-1][2]     19.35 6.582e-06
Lag[4*(p+q)+(p+q)-1][5]     22.33 4.424e-06
d.o.f=0
H0 : No serial correlation

Weighted Ljung-Box Test on Standardized Squared Residuals
------------------------------------
  statistic p-value
Lag[1]                      4.780 0.02880
Lag[2*(p+q)+(p+q)-1][5]     8.545 0.02155
Lag[4*(p+q)+(p+q)-1][9]    10.231 0.04476
d.o.f=2

Weighted ARCH LM Tests
------------------------------------
  Statistic Shape Scale P-Value
ARCH Lag[3]    0.8985 0.500 2.000  0.3432
ARCH Lag[5]    2.5240 1.440 1.667  0.3667
ARCH Lag[7]    3.2554 2.315 1.543  0.4667

Nyblom stability test
------------------------------------
  Joint Statistic:  9.5528
Individual Statistics:             
  omega  0.8725
alpha1 0.1574
beta1  1.4955
gamma1 0.1894
shape  0.5291

Asymptotic Critical Values (10% 5% 1%)
Joint Statistic:     	 1.28 1.47 1.88
Individual Statistic:	 0.35 0.47 0.75

Sign Bias Test
------------------------------------
  t-value      prob sig
Sign Bias           4.3329 1.547e-05 ***
  Negative Sign Bias  4.9619 7.587e-07 ***
  Positive Sign Bias  0.9451 3.447e-01    
Joint Effect       35.1222 1.148e-07 ***
  
  
  Adjusted Pearson Goodness-of-Fit Test:
  ------------------------------------
  group statistic p-value(g-1)
1    20     240.5    2.585e-40
2    30     282.5    2.343e-43
3    40     306.5    3.033e-43
4    50     344.9    4.334e-46


Elapsed time : 1.682015 

> 
  > text_data <- "
+                   Estimate  Std. Error   t value Pr(>|t|)
+                   omega  -0.000301    0.241476 -0.001246 0.999006
+                   alpha1  0.027822    0.084668  0.328600 0.742458
+                   beta1   0.655685    0.042956 15.264051 0.000000
+                   gamma1  2.157099    0.763514  2.825224 0.004725
+                   shape   2.100000    0.077000 27.272755 0.000000
+                   "
> 
  > garch_params <- read.table(text = text_data, header = TRUE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
                line 1 did not have 6 elements
              > # Define the text data with a placeholder name for the row labels
                > text_data <- "
+ Parameter  Estimate  Std. Error   t value Pr(>|t|)
+ omega  -0.000301    0.241476 -0.001246 0.999006
+ alpha1  0.027822    0.084668  0.328600 0.742458
+ beta1   0.655685    0.042956 15.264051 0.000000
+ gamma1  2.157099    0.763514  2.825224 0.004725
+ shape   2.100000    0.077000 27.272755 0.000000
+ "
              > 
                > # Convert the text data to a dataframe
                > garch_params <- read.table(text = text_data, header = TRUE)
              Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
                              line 1 did not have 7 elements
                            > # Define the text data without row labels
                              > text_data <- "
+ Estimate  Std. Error   t value Pr(>|t|)
+ -0.000301    0.241476 -0.001246 0.999006
+ 0.027822    0.084668  0.328600 0.742458
+ 0.655685    0.042956 15.264051 0.000000
+ 2.157099    0.763514  2.825224 0.004725
+ 2.100000    0.077000 27.272755 0.000000
+ "
                            > 
   
> # Convert the text data to a dataframe
> garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 5 elements
> 
> 
> text_data <- "
                                                                      + Estimate Std_Error t_Value Pr_abs_t
                                                                      + -0.000301 0.241476 -0.001246 0.999006
                                                                      + 0.027822 0.084668 0.328600 0.742458
                                                                      + 0.655685 0.042956 15.264051 0.000000
                                                                      + 2.157099 0.763514 2.825224 0.004725
                                                                      + 2.100000 0.077000 27.272755 0.000000
                                                                      + "
> 
> # Convert the text data to a dataframe with a placeholder for the problematic column name
> garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
> 
> # Rename the columns to their intended names
> colnames(garch_params) <- c("Estimate", "Std_Error", "t_Value", "Pr(> abs(t))")
> 
> print(garch_params)
   Estimate Std_Error   t_Value Pr(> abs(t))
1 -0.000301  0.241476 -0.001246     0.999006
2  0.027822  0.084668  0.328600     0.742458
3  0.655685  0.042956 15.264051     0.000000
4  2.157099  0.763514  2.825224     0.004725
5  2.100000  0.077000 27.272755     0.000000
> 
> text_databbp <- "
                                                                      +   Estimate Std_Error 
                                                                      +   	0.06	0.038
                                                                      +   	0.718	0.069
                                                                      +     0.276	0.042
                                                                      +   "
> bbp1994garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
> # Rename the columns to their intended names
> colnames(bbp1994garch_params) <- c("Estimate", "Std_Error"
+                                    
+                                    print(bbp1994garch_params)
Error: unexpected symbol in:
"                                   
                                                                      print"
> bbp1994garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
> # Rename the columns to their intended names
> colnames(bbp1994garch_params) <- c("Estimate", "Std_Error")
> 
> print(bbp1994garch_params)
   Estimate Std_Error        NA       NA
1 -0.000301  0.241476 -0.001246 0.999006
2  0.027822  0.084668  0.328600 0.742458
3  0.655685  0.042956 15.264051 0.000000
4  2.157099  0.763514  2.825224 0.004725
5  2.100000  0.077000 27.272755 0.000000
> text_databbp <- "
                                                                      +   Estimate Std_Error 
                                                                      +   	0.06	0.038
                                                                      +   	0.718	0.069
                                                                      +     0.276	0.042
                                                                      +   "
> bbp1994garch_params <- read.table(text = text_databbp, header = TRUE, check.names = FALSE)
> # Rename the columns to their intended names
> colnames(bbp1994garch_params) <- c("Estimate", "Std_Error")
> 
> print(bbp1994garch_params)
  Estimate Std_Error
1    0.060     0.038
2    0.718     0.069
3    0.276     0.042
> 
> colnames(arima_params_df) <- c("Coefficients", "StdErrors")
> colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
> 
> 
> # Custom print function to visually align titles above columns
> print_with_titles <- function(df1, df2, title1, title2) {
+     # Print the titles
+     cat(title1, "\t\t\t", title2, "\n")
+     
+     # Print the column names
+     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
+     
+     # Print the data row by row
+     for (i in 1:nrow(arima_params_df)) {
+         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
+     }
+ }



##--------------------------------------------------------------
+     # Print the titles
+     cat(title1, "\t\t", title2, "\n")
+     
+     # Print the column names
+     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
+     
+     # Print the data row by row
+     for (i in 1:nrow(df1)) {
+         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
+     }
+ }
> 
> # Use the custom print function
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df)
                       Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> 
> # Print the column names
> cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
Coefficients	StdErrors 	 Coefficients	StdErrors 
> 
> # Print the data row by row
> for (i in 1:nrow(arima_params_df)) {
+     cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
+ }
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> }
Error: unexpected '}' in "}"
> # Use the custom print function
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df)
                       Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.06	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df)
                       Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.060     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df)
                       Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850        0.60     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.6	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> 
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df)
                       Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850         0.60     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> colnames(arima_params_df) <- c("Coefficients", "StdErrors")
> colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
> 
> 
> # Custom print function to visually align titles above columns
> print_with_titles <- function(df1, df2, title1, title2) {
+     # Print the titles
+     cat(title1, "\t\t", title2, "\n")
+     
+     # Print the column names
+     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
+     
+     # Print the data row by row
+     for (i in 1:nrow(arima_params_df)) {
+         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
+     }
+ }
> 
> # Use the custom print function IS THIS THE ONE WITH 3 RUNS?
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 		 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.6	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> 
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df)
                       Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850         0.60     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> 
> colnames(arima_params_df) <- c("Coefficients", "StdErrors")
> colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
> 
> 
> # Custom print function to visually align titles above columns
> print_with_titles <- function(df1, df2, title1, title2) {
+     # Print the titles
+     cat(title1, "\t\t\t", title2, "\n")
+     
+     # Print the column names
+     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
+     
+     # Print the data row by row
+     for (i in 1:nrow(arima_params_df)) {
+         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
+     }
+ }

> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params_df, bbp1994_params)
> 
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df) # Correct 
# But my results, missing BBP full sample (end year -.185) BBP post 1994 no FOMC
                       Coefficients   StdErrors Coefficients StdErrors
ar1                     0.844237998 0.013053850         0.60     0.038
intercept               2.014386816 0.107115536           NA        NA
oneday_beforeholiday    0.100839203 0.132623548           NA        NA
threeday_beforeholiday -0.095986648 0.045628642           NA        NA
oneday_afterholiday     0.035191454 0.129995377           NA        NA
endquarter              0.114887391 0.142475753        2.081     0.181
endyear                 0.066116640 0.173470169        2.913     0.331
Monday                  0.004691872 0.061329648           NA        NA
Friday                 -0.011205695 0.023676676           NA        NA
fomc                    0.009640622 0.005993818        0.783     0.262
fomcindex              -0.282124740 0.149256602           NA        NA
z                      -0.700007226 0.221871277        1.240     0.465
nt                      0.061577943 0.091488156           NA        NA
absnu                  -0.002429300 0.011621492        0.718     0.069
nu                     -0.007706428 0.007626636        0.276     0.042
> combined_arimas_table <- xtable(combined_df)
> combined_arimas_table
% latex table generated in R 4.3.2 by xtable 1.8-4 package
% Thu Jul 18 17:34:35 2024
\begin{table}[ht]
\centering
\begin{tabular}{rrrrr}
  \hline
 & Coefficients & StdErrors & Coefficients & StdErrors \\ 
  \hline
ar1 & 0.84 & 0.01 & 0.06 & 0.04 \\ 
  intercept & 2.01 & 0.11 &  &  \\ 
  oneday\_beforeholiday & 0.10 & 0.13 &  &  \\ 
  threeday\_beforeholiday & -0.10 & 0.05 &  &  \\ 
  oneday\_afterholiday & 0.04 & 0.13 &  &  \\ 
  endquarter & 0.11 & 0.14 & 2.08 & 0.18 \\ 
  endyear & 0.07 & 0.17 & 2.91 & 0.33 \\ 
  Monday & 0.00 & 0.06 &  &  \\ 
  Friday & -0.01 & 0.02 &  &  \\ 
  fomc & 0.01 & 0.01 & 0.78 & 0.26 \\ 
  fomcindex & -0.28 & 0.15 &  &  \\ 
  z & -0.70 & 0.22 & 1.24 & 0.46 \\ 
  nt & 0.06 & 0.09 &  &  \\ 
  absnu & -0.00 & 0.01 & 0.72 & 0.07 \\ 
  nu & -0.01 & 0.01 & 0.28 & 0.04 \\ 
   \hline
\end{tabular}
\end{table}


*---------------------------------*
*          GARCH Model Fit        *
*---------------------------------*

Conditional Variance Dynamics 	
-----------------------------------
GARCH Model	: eGARCH(1,1)
Mean Model	: ARFIMA(0,0,0)
Distribution	: std 

Optimal Parameters
------------------------------------
        Estimate  Std. Error   t value Pr(>|t|)
omega  -0.000301    0.241476 -0.001246 0.999006
alpha1  0.027822    0.084668  0.328600 0.742458
beta1   0.655685    0.042956 15.264051 0.000000
gamma1  2.157099    0.763514  2.825224 0.004725
shape   2.100000    0.077000 27.272755 0.000000

Robust Standard Errors:
        Estimate  Std. Error   t value Pr(>|t|)
omega  -0.000301    0.308840 -0.000974 0.999222
alpha1  0.027822    0.090948  0.305910 0.759673
beta1   0.655685    0.081888  8.007135 0.000000
gamma1  2.157099    1.063278  2.028726 0.042486
shape   2.100000    0.110032 19.085410 0.000000

LogLikelihood : -934.457 

Information Criteria
------------------------------------
                    
Akaike       0.96010
Bayes        0.97435
Shibata      0.96009
Hannan-Quinn 0.96534

Weighted Ljung-Box Test on Standardized Residuals
------------------------------------
                        statistic   p-value
Lag[1]                      18.82 1.438e-05
Lag[2*(p+q)+(p+q)-1][2]     19.35 6.582e-06
Lag[4*(p+q)+(p+q)-1][5]     22.33 4.424e-06
d.o.f=0
H0 : No serial correlation

Weighted Ljung-Box Test on Standardized Squared Residuals
------------------------------------
                        statistic p-value
Lag[1]                      4.780 0.02880
Lag[2*(p+q)+(p+q)-1][5]     8.545 0.02155
Lag[4*(p+q)+(p+q)-1][9]    10.231 0.04476
d.o.f=2

Weighted ARCH LM Tests
------------------------------------
            Statistic Shape Scale P-Value
ARCH Lag[3]    0.8985 0.500 2.000  0.3432
ARCH Lag[5]    2.5240 1.440 1.667  0.3667
ARCH Lag[7]    3.2554 2.315 1.543  0.4667

Nyblom stability test
------------------------------------
Joint Statistic:  9.5528
Individual Statistics:             
omega  0.8725
alpha1 0.1574
beta1  1.4955
gamma1 0.1894
shape  0.5291

Asymptotic Critical Values (10% 5% 1%)
Joint Statistic:     	 1.28 1.47 1.88
Individual Statistic:	 0.35 0.47 0.75

Sign Bias Test
------------------------------------
                   t-value      prob sig
Sign Bias           4.3329 1.547e-05 ***
Negative Sign Bias  4.9619 7.587e-07 ***
Positive Sign Bias  0.9451 3.447e-01    
Joint Effect       35.1222 1.148e-07 ***


Adjusted Pearson Goodness-of-Fit Test:
------------------------------------
  group statistic p-value(g-1)
1    20     240.5    2.585e-40
2    30     282.5    2.343e-43
3    40     306.5    3.033e-43
4    50     344.9    4.334e-46


Elapsed time : 1.682015 
<!--Not sure what this is 08182024-->
> garch_params <- read.table(text = text_data, header = TRUE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 6 elements
> # Define the text data with a placeholder name for the row labels
> text_data <- "
+ Parameter  Estimate  Std. Error   t value Pr(>|t|)
+ omega  -0.000301    0.241476 -0.001246 0.999006
+ alpha1  0.027822    0.084668  0.328600 0.742458
+ beta1   0.655685    0.042956 15.264051 0.000000
+ gamma1  2.157099    0.763514  2.825224 0.004725
+ shape   2.100000    0.077000 27.272755 0.000000
+ "
> 
> # Convert the text data to a dataframe
> garch_params <- read.table(text = text_data, header = TRUE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 7 elements
> # Define the text data without row labels
> text_data <- "
+ Estimate  Std. Error   t value Pr(>|t|)
+ -0.000301    0.241476 -0.001246 0.999006
+ 0.027822    0.084668  0.328600 0.742458
+ 0.655685    0.042956 15.264051 0.000000
+ 2.157099    0.763514  2.825224 0.004725
+ 2.100000    0.077000 27.272755 0.000000
+ "
> 
>
> 
> # Convert the text data to a dataframe
> garch_params <- read.table(text = text_data, header = TRUE)
> 
> # Print the dataframe
> print(garch_params)
  Estimate Std_Error  t_value     X.P.. abs.t...
1    omega -0.000301 0.241476 -0.001246 0.999006
2   alpha1  0.027822 0.084668  0.328600 0.742458
3    beta1  0.655685 0.042956 15.264051 0.000000
4   gamma1  2.157099 0.763514  2.825224 0.004725
5    shape  2.100000 0.077000 27.272755 0.000000

> # Convert the text data to a dataframe
> garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 5 elements
> 
> 
> text_data <- "
+ Estimate Std_Error t_Value Pr_abs_t
+ -0.000301 0.241476 -0.001246 0.999006
+ 0.027822 0.084668 0.328600 0.742458
+ 0.655685 0.042956 15.264051 0.000000
+ 2.157099 0.763514 2.825224 0.004725
+ 2.100000 0.077000 27.272755 0.000000
+ "
> 
> # Convert the text data to a dataframe with a placeholder for the problematic column name
> garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
> 
> # Rename the columns to their intended names
> colnames(garch_params) <- c("Estimate", "Std_Error", "t_Value", "Pr(> abs(t))")
> 
> print(garch_params)
   Estimate Std_Error   t_Value Pr(> abs(t))
1 -0.000301  0.241476 -0.001246     0.999006
2  0.027822  0.084668  0.328600     0.742458
3  0.655685  0.042956 15.264051     0.000000
4  2.157099  0.763514  2.825224     0.004725
5  2.100000  0.077000 27.272755     0.000000
> 
> text_databbp <- "
+   Estimate Std_Error 
+   	0.06	0.038
+   	0.718	0.069
+     0.276	0.042
+   "
> bbp1994garch_params <- read.table(text = text_databbp, header = TRUE, check.names = FALSE)
> # Rename the columns to their intended names
> colnames(bbp1994garch_params) <- c("Estimate", "Std_Error"
+                                    
+                                    print(bbp1994garch_params)
Error: unexpected symbol in:
"                                   
                                   print"

+   "
> bbp1994garch_params <- read.table(text = text_databbp, header = TRUE, check.names = FALSE)
> # Rename the columns to their intended names
> colnames(bbp1994garch_params) <- c("Estimate", "Std_Error")
> 
> print(bbp1994garch_params)
  Estimate Std_Error
1    0.060     0.038
2    0.718     0.069
3    0.276     0.042
> 
> colnames(arima_params_df) <- c("Coefficients", "StdErrors")
> colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
> 
> 
> # Custom print function to visually align titles above columns
> print_with_titles <- function(df1, df2, title1, title2) {
+     # Print the titles
+     cat(title1, "\t\t\t", title2, "\n")
+     
+     # Print the column names
+     cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
+     
+     # Print the data row by row
+     for (i in 1:nrow(arima_params_df)) {
+         cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
+     }
+ }
> 
> # Use the custom print function
> print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
DailyEFFR 2016-2023 			 BBP post 1994 no FOMC 
Coefficients	StdErrors 	 Coefficients	StdErrors 
0.844237998164641	0.0130538504416614 	 0.6	0.038 
2.01438681553527	0.107115535571069 	 NA	NA 
0.100839202622712	0.132623547739493 	 NA	NA 
-0.0959866481019678	0.0456286415809881 	 NA	NA 
0.0351914536744334	0.129995376807891 	 NA	NA 
0.114887391248271	0.142475752704719 	 2.081	0.181 
0.0661166396781707	0.173470168680794 	 2.913	0.331 
0.00469187199601059	0.06132964761596 	 NA	NA 
-0.0112056948520733	0.0236766763762414 	 NA	NA 
0.00964062227751304	0.00599381769600368 	 0.783	0.262 
-0.282124739984309	0.149256601613901 	 NA	NA 
-0.70000722590789	0.221871277399153 	 1.24	0.465 
0.0615779428904553	0.0914881562145888 	 NA	NA 
-0.00242930024829802	0.0116214923036203 	 0.718	0.069 
-0.00770642769776277	0.00762663582846746 	 0.276	0.042 
> 
> 
> # Combine the dataframes using cbind for further analysis
> combined_df <- cbind(arima_params, bbp1994_params)
> 
> 
> # Print the combined dataframe for any further analysis if needed
> cat("\nCombined DataFrame:\n")



# *---------------------------------*
# *          GARCH Model Fit        *
# *---------------------------------*
# 
# Conditional Variance Dynamics 	
# -----------------------------------
# GARCH Model	: eGARCH(1,1)
# Mean Model	: ARFIMA(0,0,0)
# Distribution	: std 
# 
# Optimal Parameters
# ------------------------------------
#         Estimate  Std. Error   t value Pr(>|t|)
# omega  -0.000301    0.241476 -0.001246 0.999006
# alpha1  0.027822    0.084668  0.328600 0.742458
# beta1   0.655685    0.042956 15.264051 0.000000
# gamma1  2.157099    0.763514  2.825224 0.004725
# shape   2.100000    0.077000 27.272755 0.000000
# 
# Robust Standard Errors:
#         Estimate  Std. Error   t value Pr(>|t|)
# omega  -0.000301    0.308840 -0.000974 0.999222
# alpha1  0.027822    0.090948  0.305910 0.759673
# beta1   0.655685    0.081888  8.007135 0.000000
# gamma1  2.157099    1.063278  2.028726 0.042486
# shape   2.100000    0.110032 19.085410 0.000000
# 
# LogLikelihood : -934.457 
# 
# Information Criteria
# ------------------------------------
#                     
# Akaike       0.96010
# Bayes        0.97435
# Shibata      0.96009
# Hannan-Quinn 0.96534
# 
# Weighted Ljung-Box Test on Standardized Residuals
# ------------------------------------
#                         statistic   p-value
# Lag[1]                      18.82 1.438e-05
# Lag[2*(p+q)+(p+q)-1][2]     19.35 6.582e-06
# Lag[4*(p+q)+(p+q)-1][5]     22.33 4.424e-06
# d.o.f=0
# H0 : No serial correlation
# 
# Weighted Ljung-Box Test on Standardized Squared Residuals
# ------------------------------------
#                         statistic p-value
# Lag[1]                      4.780 0.02880
# Lag[2*(p+q)+(p+q)-1][5]     8.545 0.02155
# Lag[4*(p+q)+(p+q)-1][9]    10.231 0.04476
# d.o.f=2
# 
# Weighted ARCH LM Tests
# ------------------------------------
#             Statistic Shape Scale P-Value
# ARCH Lag[3]    0.8985 0.500 2.000  0.3432
# ARCH Lag[5]    2.5240 1.440 1.667  0.3667
# ARCH Lag[7]    3.2554 2.315 1.543  0.4667
# 
# Nyblom stability test
# ------------------------------------
# Joint Statistic:  9.5528
# Individual Statistics:             
# omega  0.8725
# alpha1 0.1574
# beta1  1.4955
# gamma1 0.1894
# shape  0.5291
# 
# Asymptotic Critical Values (10% 5% 1%)
# Joint Statistic:     	 1.28 1.47 1.88
# Individual Statistic:	 0.35 0.47 0.75
# 
# Sign Bias Test
# ------------------------------------
#                    t-value      prob sig
# Sign Bias           4.3329 1.547e-05 ***
# Negative Sign Bias  4.9619 7.587e-07 ***
# Positive Sign Bias  0.9451 3.447e-01    
# Joint Effect       35.1222 1.148e-07 ***
# 
# 
# Adjusted Pearson Goodness-of-Fit Test:
# ------------------------------------
#   group statistic p-value(g-1)
# 1    20     240.5    2.585e-40
# 2    30     282.5    2.343e-43
# 3    40     306.5    3.033e-43
# 4    50     344.9    4.334e-46
# 
# 
# Elapsed time : 1.682015 


##--------------------------------------------------------------
# Bertolini GARCH
 #row_labels <- c("omega","alpha1", "beta1", "gamma1","shape)
  # Find correspondence to AR1 abs_nu  nu
  
  
  text_databbp <- "
  Estimate Std_Error 
  	0.06	0.038
  	0.718	0.069
    0.276	0.042
  "
  bbp1994garch_params <- read.table(text = text_databbp, header = TRUE, check.names = FALSE)
  # Rename the columns to their intended names
  colnames(bbp1994garch_params) <- c("Estimate", "Std_Error")
  
  print(bbp1994garch_params)

  
# OLD ----------------------------------------------------------
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
  
  
# Simple model EFFR ---------------------------------------------
rrbp.z = zoo(x=rrbp$EFFR, order.by=rrbp$sdate)
#Calculate log returns and remove first NA value
return.effr<-Return.calculate(rrbp.z, method = "log")[-1]
#fit EGARCH model
spec_effr = ugarchspec(variance.model=list(model="eGARCH",
                                           garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(1,0)),distribution.model="ged")
egarch_effrsimple=ugarchfit(data = return.effr,spec=spec_effr)


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
$ \mu_t=r_{t-1}+\gamma_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
$ \mu_t=r_{t-1}+\Phi(r_{t-1}=r_{t-2})+ \Phi(r_{t-2}=r_{t-3}) +gamma_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
\end{align*}                                                                                               

#1
mu_t <- r_t_minus_1 + gamma_s_t
mu_t <- Kappa_prime * k_t + iota * (asterisk_r_t - as_r_t_minus_1)

#2
mu_t <- r_t_minus_1 + Phi(r_t_minus_1 == r_t_minus_2) + Phi(r_t_minus_2 == r_t_minus_3) + gamma_s_t
mu_t <- Kappa_prime * k_t + iota * (asterisk_r_t - as_r_t_minus_1)


#3
Variance of the EFFR $\sigma^2_t=E[(r_t-\mu_t)^2]$
  sigma2_t <- mean((r_t - mu_t)^2)
In this code:
  
#   sigma2_t represents the variable for 
# r_t and mu_t should be replaced with your actual variables representing 
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


