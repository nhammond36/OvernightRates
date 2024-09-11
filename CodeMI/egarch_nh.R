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

# EGARCH (Exponential GARCH) The EGARCH model was developed by Nelson (1991). The
# model explicitly allows for asymmetries in the relationship between return and volatility (see also
#                                                                                            GJR and TGARCH). In particular, let denote the standardized innovations. The
# EGARCH(1,1) model may then be expressed as:
#   .
# For negative shocks will obviously have a bigger impact on future volatility than positive
# shocks of the same magnitude. This effect, which is typically observed empirically with equity
# index returns, is often referred to as a “leverage effect,” although it is now widely agreed that the
# apparent asymmetry has little to do with actual financial leverage. By parameterizing the
# Electronic copy available at: https://ssrn.com/abstract=1263250
# -11-
#   logarithm of the conditional variance as opposed to the conditional variance, the EGARCH
# model also avoids complications from having to ensure that the process remains positive.
# Meanwhile, the logarithmic transformation complicates the construction of unbiased forecasts for
# the level of future variances (see also GARCH and log-GARCH).
# 
# ###installing and loading multiple packages
# list.packages<-c("fGarch", "PerformanceAnalytics","rugarch","tseries","xts","FinTS", "urca")
# new.packages <- list.packages[!(list.packages %in% installed.packages()[,"Package"])]
# if(length(new.packages)) install.packages(new.packages)
# #Loading Packages
# invisible(lapply(list.packages, require, character.only = TRUE))

#  ----------------- Github repository
# see https://rfortherestofus.com/2021/02/how-to-use-git-github-with-r/
# https://github.com/nhammond36/OvernightRates.git
# The most straightforward way to use RStudio and GitHub together is to create 
# - a repo on GitHub first. Create the repo, 
# - then when you start a new project in RStudio, use the version control option, enter your repo URL, and you're good to go.

# Load rate data
my_envmp <- readRDS("C:/Users/Owner/Documents/Research/OvernightRates/my_envmp.RDS")#Access the data frame stored in the environment
spread_no_na <- my_envmp$spread_no_na
str(spread_no_na)


# CALENDAR EFECTS ------------------------------------------------------------------
# NO NEED TO REDO. NOW INCLUDED IN DF spread_no_na
execpart <- FALSE #and change to TRUE if you do want to execute
Then wrap the whole part of your script which should only be executed situationally in:
  
  if(execpart){
    ## your script
    
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
    
    
    new_days <- c("holiday","oneday_beforeholiday", "threeday_beforeholiday", "oneday_afterholiday", "threeday_afterholiday", "endquarter","endyear","around_qtr","around_yr","Monday","Friday","sdate")
    names(h) <- new_days
    str(new_days)
    
    # Load necessary library
    library(timeDate)
    
    # Sample data: sdate variable excluding weekends
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
  } # end skip execution of code that contains h definition section


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


# # Example usage
# #start_date <- as.Date("2024-07-01")
# #end_date <- as.Date("2024-07-15")
# public_holidays<-h$holidays
# num_non_trading_days <- non_trading_days(start_date, end_date, public_holidays)
# print(num_non_trading_days)
# date_seq <- seq.Date(start_date, end_date, by = "day")
# 
# 
# 
# # Chat version 2
# # Load necessary package
# library(lubridate)
# 
# # Example dataset with dates
# 
# # Define the start and end dates for the seven years
# start_date <- as.Date("2016-03-04")
# end_date <- as.Date("2023-12-14")
# 
# h <- data.frame(sdate = seq.Date(from = start_date, to = end_date, by = "month"))
# 
# # Function to check if a date is the end of a quarter
# is_end_of_quarter <- function(date) {
#   month(date) %in% c(3, 6, 9, 12) && day(date) == days_in_month(date)
# }
# 
# # Determine the first end-of-quarter date from the start_date
# if (is_end_of_quarter(start_date)) {
#   first_quarter_end <- start_date
# } else {
#   # Get the next quarter's ceiling date
#   next_quarter_date <- ceiling_date(start_date, "quarter")
#   # Rollback to the last day of the previous month
#   first_quarter_end <- rollback(next_quarter_date)
# }
# 
# # Generate end-of-quarter dates for the date range
# end_quarter_dates <- seq(from = first_quarter_end, to = end_date, by = "quarter")
# 

# EGARCH ----------------------------------------------------------------
#https://blog.devgenius.io/volatility-modeling-with-r-asymmetric-garch-models-85ee02f8b6e8
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
# specify Bartolini mean equation
# $r_t = \mu_t + \sigma_t \nu_t$
# $\mu_t=r_{t-1}+\delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\ast(r{_t-1})$
# mufr<-rbt[2:T,1]+ rbt[1:T-1,1]- rbt[2:T,1]
# r<- mufr + sdfr*nu
# specify the variance equation
#$log(\sigma^2_t) +\omega h_t +\zeta z_t = \lambda(log(\sigma^2_{t-1}) +\omega h_{t-1} +\zeta z_{t-1} ) + abs(\nu_{t-1})+ \theta \nu_{t-1}

#DUPLICATE OF log sd2
# Create AR(1)----------------------------
# Initialize the AR(1) process
# log_sd_effr_squared <- log(sd_effr[1:(T-1)]^2)
# 
# # Specify the AR(1) equation
# ar1_process <- numeric(T-1)  # Create an empty vector to store the AR(1) process values
# 
# # Compute the AR(1) process
# for (t in 1:(T-1)) {
#   ar1_process[t] <- log_sd_effr_squared[t] + h[t,] + z[t]
# }
# 
# # Print the AR(1) process values
# print(ar1_process)
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
# spread_no_na$h<-h
# dummy_h <- spread_no_na$h
# #dummy_h <- dummy_h[, -which(names(dummy_h) == "sdate")]  # Remove the sdate column if present
# dummy_h_matrix <- as.matrix(dummy_h)
# str(dummy_h)
# spread_no_na$dummy_h<-dummy_h

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
# Only in Piazzesi and Benzoni.  I had an observed intraday sd (source?)
set.seed(123)  # Setting seed for reproducibility


# ATTENTION: length(non_trading_counts) 1956, the length of these variables 1957
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

#length(non_trading_counts) #1956
#length(log_sd_effr_squared[2:T]) #1956

neg_log_likelihood <- function(gamma) {
  if (any(1 - gamma * non_trading_counts <= 0)) {
    return(Inf)
  }
  X <- log(1 - gamma * non_trading_counts)
  model <- lm(log_sd_effr_squared[2:T] ~ X)
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

# Summary
# The log_nontradingdays function computes the log-transformation of 1 - gamma * nontradingdays.
# The logic of log_nontradingdays is replicated within neg_log_likelihood, but the function itself is not used.
# nontradingdays is not an argument in neg_log_likelihood because the function relies on the global variable non_trading_counts instead.
# 


#----------------------------------------------------------------------  

# Initial guess for gamma
gamma_start <- 0.01

# Use optimize to find the best gamma within a reasonable range
result <- optimize(neg_log_likelihood, interval = c(0, 1))

gamma_estimated <- result$minimum
print(gamma_estimated) # 0.6180798 0.2361138

# Update the nt calculation with the estimated gamma
non_trading_counts <- c(0, non_trading_counts)
nt <- log(1 - gamma_estimated * non_trading_counts)
print(nt)

# Bertola et al
# MEAN OF THR EFFR
# $r_t = \mu_t + \sigma_t \nu_t$

# $ \mu_t=r_{t-1}+\delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
# $ \mu_t=r_{t-1}+\Phi(r_{t-1}=r_{t-2})+ \Phi(r_{t-2}=r_{t-3}) +delta_s_t=\Kappa' k_t + \iota(\ast(r_t)-\as(r{_t-1})$
#                                                                                               
# Variance of the FFR $\sigma^2_t=E[(r_t-\mu_t)^2]$
# $log(\sigma^2_t) +\omega h_t +\zeta z_t = \lambda(log(\sigma^2_{t-1}) +\omega h_{t-1} +\zeta z_{t-1} ) + abs(\nu_{t-1})+ \theta \nu_{t-1
#  
# Piazzesi jump process

# Benzoni jump process

external_regressors <- cbind(h[,2:ncol(h)], z,nt,absnu, nu) #1957 by 13
str(external_regressors)
# 'data.frame':	1957 obs. of  13 variables:
#   $ oneday_beforeholiday  : num  0 0 0 0 0 0 0 0 0 0 ...
# $ threeday_beforeholiday: num  0 0 0 0 0 0 0 0 0 0 ...
# $ oneday_afterholiday   : num  0 0 0 0 0 0 0 0 0 0 ...
# $ endquarter            : num  0 0 0 0 0 0 0 0 0 0 ...
# $ endyear               : num  0 0 0 0 0 0 0 0 0 0 ...
# $ Monday                : num  0 1 0 0 0 0 1 0 0 0 ...
# $ Friday                : num  1 0 0 0 0 1 0 0 0 0 ...
# $ fomc                  : num  0 0 0 0 0 0 0 0 0 0 ...
# $ fomcindex             : num  0 0 0 0 0 0 0 0 0 0 ...
# $ z                     : num  0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.625 ...
# $ nt                    : num  0 -0.0202 0 0 0 ...
# $ absnu                 : num  1.0964 0.6168 0.0501 1.0396 0.4991 ...
# $ nu                    : num  1.0964 -0.6168 0.0501 -1.0396 0.4991 ...

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



# Create a zoo object for log_sd_effr_squared with sdate as the index
log_sd_effr_squared_zoo <- zoo(log_sd_effr_squared, order.by = spread_no_na$sdate)

# Fit an ARIMA model with cleaned external regressors using CSS
arima_model <- arima(coredata(log_sd_effr_squared_zoo), order = c(1, 0, 0), xreg = external_regressors, method = "CSS")

# Extract parameters and residuals
arima_params <- arima_model$coef
arima_residuals <- residuals(arima_model)

print("ARIMA Model Parameters:")
print(arima_params)

vcov_matrix <- vcov(arima_model)
std_errors <- sqrt(diag(vcov_matrix))
results <- data.frame(Coefficients = arima_params, StdErrors = std_errors)

row_labels <- c("ar1", "intercept", "oneday_beforeholiday", "threeday_beforeholiday", 
                "oneday_afterholiday", "endquarter",
                # Print the results
                print(results)     
                
                
                # Convert the parameter_estimates to a data frame
                arima_params_df <- as.data.frame(results)
                cat("DailyEFFR 2016-2023\n")
                
                # Create vectors for Bertolini et al 1994 no FOMC ARIMA params 
                # ar1   
                # intercept  
                # oneday_beforeholiday
                # threeday_beforeholiday
                # oneday_afterholiday 
                # endquarter 
                # endyear  
                # Monday  
                # Friday                 
                # FOMC
                # FOMCindex
                # z
                # non trading days
                # abs_nu
                # nu
                
                row_labels <- c("ar1", "intercept", "oneday_beforeholiday", "threeday_beforeholiday", 
                                "oneday_afterholiday", "endquarter", "endyear", "Monday", "Friday", "fomc","fomcindex","z", 
                                "nt", "absnu", "nu")  
                # row labels should be. go back, change variable definition in arima
                # row_labels <- c("ar1", "intercept", "oneday_beforeholiday", "threeday_beforeholiday", 
                #                   "oneday_afterholiday", "endquarter", "endyear", "Monday", "Friday", "FOMC","FOMCindex","penalty", 
                #                   "non trading days", "abs_nu", "nu")
                
                coefficients <- c(0.06, NA, NA, NA, NA, 2.081, 2.913, NA, NA, 0.783, NA, 1.24, NA, 0.718, 0.276)
                std_errors <- c(0.038, NA, NA, NA, NA, 0.181, 0.331, NA, NA, 0.262, NA, 0.465, NA, 0.069, 0.042)
                
                # Create the dataframe without row labels as a separate column
                bbp1994_params <- data.frame(Coefficients = coefficients, `Std Errors` = std_errors, row.names = row_labels)
                
                # Print the title and the dataframe
                cat("BBP post 1994 no FOMC\n")
                print( bbp1994_params)
                
                
                # Combine arima_params_df and bbp1994_params--------------------------------
                # Add a title column to each dataframe
                arima_params_df$title <- "DailyEFFR 2016-2023"
                bbp1994_params$title <- "BBP post 1994 no FOMC"
                
                # Ensure column names match
                # Both dataframes should have exactly: "Coefficients", "StdErrors", "title"
                colnames(arima_params_df) <- c("Coefficients", "StdErrors")
                colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
                
                # Add the title column if not already added
                if (!"title" %in% colnames(arima_params_df)) {
                  arima_params_df$title <- "DailyEFFR 2016-2023"
                }
                if (!"title" %in% colnames(bbp1994_params)) {
                  bbp1994_params$title <- "BBP post 1994 no FOMC"
                }
                # try 5--------------------------------------------------------------
                # Ensure both dataframes have the same column names
                colnames(arima_params_df) <- c("Coefficients", "StdErrors")
                colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
                
                # Combine the dataframes for any further analysis if needed
                combined_df <- cbind(arima_params_df, bbp1994_params)
                
                # Print the titles and dataframes separately for clear output
                cat("DailyEFFR 2016-2023\n")
                print(arima_params_df)
                cat("\nBBP post 1994 no FOMC\n")
                print(bbp1994_params)
                
                # Print a separator line (optional)
                cat("\n-----------------------\n")
                
                # Print the combined dataframe if needed for further analysis
                cat("\nCombined DataFrame:\n")
                print(combined_df)
                
                # If you still need to print the combined dataframe
                cat("\nCombined DataFrame:\n")
                print(combined_df)
                
                # try 6 --------------------------------------------------
                colnames(arima_params_df) <- c("Coefficients", "StdErrors")
                colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
                
                
                # Custom print function to visually align titles above columns
                print_with_titles <- function(df1, df2, title1, title2) {
                  # Print the titles
                  cat(title1, "\t\t\t", title2, "\n")
                  
                  # Print the column names
                  cat(paste(colnames(arima_params_df), collapse = "\t"), "\t", paste(colnames(bbp1994_params), collapse = "\t"), "\n")
                  
                  # Print the data row by row
                  for (i in 1:nrow(arima_params_df)) {
                    cat(paste(arima_params_df[i, ], collapse = "\t"), "\t", paste(bbp1994_params[i, ], collapse = "\t"), "\n")
                  }
                }
                
                # Use the custom print function
                print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
                
                
                # Combine the dataframes using cbind for further analysis
                combined_df <- cbind(arima_params_df, bbp1994_params)
                
                
                # Print the combined dataframe for any further analysis if needed
                cat("\nCombined DataFrame:\n")
                print(combined_df)
                
                # Create a table using xtable-------------------- for overnight EFFR
                combined_arimas_table <- xtable(combined_df)
                
                # Tyr 7 -------------------------------------------------------------
                # Ensure both dataframes have the same column names
                colnames(arima_params_df) <- c("Coefficients", "StdErrors")
                colnames(bbp1994_params) <- c("Coefficients", "StdErrors")
                
                # Custom print function to visually align titles above columns
                print_with_titles <- function(df1, df2, title1, title2) {
                  # Print the titles
                  cat(title1, "\t\t\t", title2, "\n")
                  
                  # Print the column names
                  cat(paste(colnames(df1), collapse = "\t"), "\t", paste(colnames(df2), collapse = "\t"), "\n")
                  
                  # Print the data row by row
                  for (i in 1:nrow(df1)) {
                    cat(paste(df1[i, ], collapse = "\t"), "\t", paste(df2[i, ], collapse = "\t"), "\n")
                  }
                }
                
                # Use the custom print function
                print_with_titles(arima_params_df, bbp1994_params, "DailyEFFR 2016-2023", "BBP post 1994 no FOMC")
                
                # Combine the dataframes using cbind for further analysis
                combined_df <- cbind(arima_params_df, bbp1994_params)
                
                # Print the combined dataframe for any further analysis if needed
                cat("\nCombined DataFrame:\n")
                print(combined_df)
                #-------------------------------------------
                # Delete column 3 and 6 or else fix title issue
                str(combined_df)
                'data.frame':	15 obs. of  6 variables:
                  $ Coefficients: num  0.8442 2.0144 0.1008 -0.096 0.0352 ...
                $ StdErrors   : num  0.0131 0.1071 0.1326 0.0456 0.13 ...
                $ title       : chr  "DailyEFFR 2016-2023" "DailyEFFR 2016-2023" "DailyEFFR 2016-2023" "DailyEFFR 2016-2023" ...
                $ Coefficients: num  0.06 NA NA NA NA ...
                $ StdErrors   : num  0.038 NA NA NA NA 0.181 0.331 NA NA 0.262 ...
                $ title       : chr  "BBP post 1994 no FOMC" "BBP post 1994 no FOMC" "BBP post 1994 no FOMC" "BBP post 1994 no FOMC" ...
                
                
                
                # Correct data frames----------------------------
                ncol(arima_params_df) #4
                ncol(bbp1994_params)  #3
                print(colnames(arima_params_df))
                [1] "Coefficients" "StdErrors"    "title"        NA            
                > print(colnames(bbp1994_params))
                [1] "Coefficients" "StdErrors"    "title" 
                #You can set it to NULL.
                
                # Delete columns with titles
                #Data <- Data[,-2] 
                arima_params_df <- arima_params_df[,-3]
                str(arima_params_df)
                bbp1994_params <- bbp1994_params[,-3]
                str(bbp1994_params)
                
                # Create a table using xtable-------------------- for overnight EFFR
                arima_params_table <- xtable(arima_params_df)
                
                # Print the table
                print( arima_params_table)                                 
                
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
                
                
                row_labels <- c("omega","alpha1", "beta1", "gamma1","shape")
                colnames(garch_params) <- c("Coefficients", "StdErrors")
                colnames(bbp1994garch_params) <- c("Coefficients", "StdErrors")
                
                #2 BBP post 1994 no fomc but where is the full sample??   
                coefficients <- c(0.6, NA, NA, NA, NA, 2.081, 2.913, NA, NA, 0.783, NA, 1.24, NA, 0.718, 0.276)
                std_errors <- c(0.038, NA, NA, NA, NA, 0.181, 0.331, NA, NA, 0.262, NA, 0.465, NA, 0.069, 0.042)
                
                # Create the dataframe without row labels as a separate column
                bbp1994_params <- data.frame(Coefficients = coefficients, `Std Errors` = std_errors, row.names = row_labels)
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
  > # Combine the dataframes for any further analysis if needed
  > combined_df <- rbind(arima_params_df, bbp1994_params)
> 
  > # If you still need to print the combined dataframe
  > cat("\nCombined DataFrame:\n")

Combined DataFrame:
  > print(combined_df)
Coefficients   StdErrors
ar1                      0.844237998 0.013053850
intercept                2.014386816 0.107115536
oneday_beforeholiday     0.100839203 0.132623548
threeday_beforeholiday  -0.095986648 0.045628642
oneday_afterholiday      0.035191454 0.129995377
endquarter               0.114887391 0.142475753
endyear                  0.066116640 0.173470169
Monday                   0.004691872 0.061329648
Friday                  -0.011205695 0.023676676
fomc                     0.009640622 0.005993818
fomcindex               -0.282124740 0.149256602
z                       -0.700007226 0.221871277
nt                       0.061577943 0.091488156
absnu                   -0.002429300 0.011621492
nu                      -0.007706428 0.007626636
ar11                     0.060000000 0.038000000
intercept1                        NA          NA
oneday_beforeholiday1             NA          NA
threeday_beforeholiday1           NA          NA
oneday_afterholiday1              NA          NA
endquarter1              2.081000000 0.181000000
endyear1                 2.913000000 0.331000000
Monday1                           NA          NA
Friday1                           NA          NA
fomc1                    0.783000000 0.262000000
fomcindex1                        NA          NA
z1                       1.240000000 0.465000000
nt1                               NA          NA
absnu1                   0.718000000 0.069000000
nu1                      0.276000000 0.042000000
> 
  > results
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
> fit

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
                              > garch_params <- read.table(text = text_data, header = TRUE)
                            Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
                                            line 1 did not have 6 elements
                                          > 
                                            > 
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
                                            > garch_params <- read.table(text = text_data, header = TRUE)
                                          Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
                                                          line 1 did not have 6 elements
                                                        > 
                                                          > 
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
                                                          > garch_params <- read.table(text = text_data, header = TRUE)
                                                        Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
                                                                        line 1 did not have 6 elements
                                                                      > text_data <- "
+                   Estimate  Std_Error   t_value $P(\Gt abs(t))$
Error: '\G' is an unrecognized escape in character string (<input>:2:53)
> # Define the text data
> text_data <- "
                                                                      +                   Estimate  Std_Error   t_value $P(> abs(t))$
                                                                        +                   omega  -0.000301    0.241476 -0.001246 0.999006
                                                                      +                   alpha1  0.027822    0.084668  0.328600 0.742458
                                                                      +                   beta1   0.655685    0.042956 15.264051 0.000000
                                                                      +                   gamma1  2.157099    0.763514  2.825224 0.004725
                                                                      +                   shape   2.100000    0.077000 27.272755 0.000000
                                                                      +                   "
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
> text_data <- "
                                                                      +                   Estimate  Std_Error   t_Value Pr(> abs(t)) 
                                                                      +                   -0.000301    0.241476 -0.001246 0.999006
                                                                      +                   0.027822    0.084668  0.328600 0.742458
                                                                      +                   0.655685    0.042956 15.264051 0.000000
                                                                      +                   2.157099    0.763514  2.825224 0.004725
                                                                      +                   2.100000    0.077000 27.272755 0.000000
                                                                      +                   "
> 
> # Convert the text data to a dataframe
> garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 5 elements
> 
> 
> 
> text_data <- "
                                                                      + Estimate Std_Error t_Value Pr(> abs(t)) 
                                                                      + -0.000301 0.241476 -0.001246 0.999006
                                                                      + 0.027822 0.084668 0.328600 0.742458
                                                                      + 0.655685 0.042956 15.264051 0.000000
                                                                      + 2.157099 0.763514 2.825224 0.004725
                                                                      + 2.100000 0.077000 27.272755 0.000000
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
> beta = garch_params[1,2]
> beta
[1] 0.241476
> beta = garch_params[2,1]
> beta
[1] 0.027822
> beta=log(garch_params[3,1]
+ )
> beta
[1] -0.4220748
> beta=log(garch_params[1,3]
+ )
Warning message:
In log(garch_params[1, 3]) : NaNs produced
> beta
[1] NaN
> beta=garch_params[3,1]
> beta
[1] 0.655685
> garch_params[1,1]
[1] -0.000301
> 
> halflife=log(2)/log(garch_params[3,1])
> print(halflife)
[1] -1.642238
> condvar =garch_params[1,1]/(1-garch_params[3,1])
> print(condvar)
[1] -0.0008741995
> 
>           results                                            
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
> fit



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
> # Combine the dataframes for any further analysis if needed
> combined_df <- rbind(arima_params_df, bbp1994_params)
> 
> # If you still need to print the combined dataframe
> cat("\nCombined DataFrame:\n")

Combined DataFrame:
> print(combined_df)
                        Coefficients   StdErrors
ar1                      0.844237998 0.013053850
intercept                2.014386816 0.107115536
oneday_beforeholiday     0.100839203 0.132623548
threeday_beforeholiday  -0.095986648 0.045628642
oneday_afterholiday      0.035191454 0.129995377
endquarter               0.114887391 0.142475753
endyear                  0.066116640 0.173470169
Monday                   0.004691872 0.061329648
Friday                  -0.011205695 0.023676676
fomc                     0.009640622 0.005993818
fomcindex               -0.282124740 0.149256602
z                       -0.700007226 0.221871277
nt                       0.061577943 0.091488156
absnu                   -0.002429300 0.011621492
nu                      -0.007706428 0.007626636
ar11                     0.060000000 0.038000000
intercept1                        NA          NA
oneday_beforeholiday1             NA          NA
threeday_beforeholiday1           NA          NA
oneday_afterholiday1              NA          NA
endquarter1              2.081000000 0.181000000
endyear1                 2.913000000 0.331000000
Monday1                           NA          NA
Friday1                           NA          NA
fomc1                    0.783000000 0.262000000
fomcindex1                        NA          NA
z1                       1.240000000 0.465000000
nt1                               NA          NA
absnu1                   0.718000000 0.069000000
nu1                      0.276000000 0.042000000
> 
> results
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
> fit

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
> garch_params <- read.table(text = text_data, header = TRUE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 6 elements
> 
> 
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
> garch_params <- read.table(text = text_data, header = TRUE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 6 elements
> 
> 
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
> garch_params <- read.table(text = text_data, header = TRUE)
Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
  line 1 did not have 6 elements
> text_data <- "
+                   Estimate  Std_Error   t_value $P(\Gt abs(t))$
  Error: '\G' is an unrecognized escape in character string (<input>:2:53)
> # Define the text data
  > text_data <- "
+                   Estimate  Std_Error   t_value $P(> abs(t))$
+                   omega  -0.000301    0.241476 -0.001246 0.999006
+                   alpha1  0.027822    0.084668  0.328600 0.742458
+                   beta1   0.655685    0.042956 15.264051 0.000000
+                   gamma1  2.157099    0.763514  2.825224 0.004725
+                   shape   2.100000    0.077000 27.272755 0.000000
+                   "
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
    > text_data <- "
+                   Estimate  Std_Error   t_Value Pr(> abs(t)) 
+                   -0.000301    0.241476 -0.001246 0.999006
+                   0.027822    0.084668  0.328600 0.742458
+                   0.655685    0.042956 15.264051 0.000000
+                   2.157099    0.763514  2.825224 0.004725
+                   2.100000    0.077000 27.272755 0.000000
+                   "
    > 
      > # Convert the text data to a dataframe
      > garch_params <- read.table(text = text_data, header = TRUE, check.names = FALSE)
    Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
                    line 1 did not have 5 elements
                  > 
                    > 
                    > 
                    > text_data <- "
+ Estimate Std_Error t_Value Pr(> abs(t)) 
+ -0.000301 0.241476 -0.001246 0.999006
+ 0.027822 0.084668 0.328600 0.742458
+ 0.655685 0.042956 15.264051 0.000000
+ 2.157099 0.763514 2.825224 0.004725
+ 2.100000 0.077000 27.272755 0.000000
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
                                                                       > beta = garch_params[1,2]
                                                                       > beta
                                                                       [1] 0.241476
                                                                       > beta = garch_params[2,1]
                                                                       > beta
                                                                       [1] 0.027822
                                                                       > beta=log(garch_params[3,1]
                                                                                  + )
                                                                       > beta
                                                                       [1] -0.4220748
                                                                       > beta=log(garch_params[1,3]
                                                                                  + )
                                                                       Warning message:
                                                                         In log(garch_params[1, 3]) : NaNs produced
                                                                       > beta
                                                                       [1] NaN
                                                                       > beta=garch_params[3,1]
                                                                       > beta
                                                                       [1] 0.655685
                                                                       > garch_params[1,1]
                                                                       [1] -0.000301
                                                                       > 
                                                                         > halflife=log(2)/log(garch_params[3,1])
                                                                       > print(halflife)
                                                                       [1] -1.642238
                                                                       > condvar =garch_params[1,1]/(1-garch_params[3,1])
                                                                       > print(condvar)
                                                                       [1] -0.0008741995
                                                                       > 
                                                                         >           results                                            
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
                                                                       > fit
                                                                       
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
                                                                                            
                                                                                            
                                                                                            