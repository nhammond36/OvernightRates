# Loading
library("plyr")
library(tidyverse)
library(ggplot2)
library(dslabs)
library(lubridate)
#library(vrtest)
library('matlab')
#library(openai)
library(tseries)
library(kableExtra)
#library(lattice)
#library(writexl)
library(knitr)
#library(tables)
library(xtable)
library(quarto)
library(zoo)
library(tidyr)
library(gridExtra)
library(e1071)
#library(ggridges)
library(viridis)
#library(Rfast)
library(tidyr)
library(dplyr)

# Render the R Markdown document
#rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11292023b.Rmd",envir= my_envmp)
#rmarkdown::render("C:/Users/Owner/Documents/Research/OvernightRates/ONrates03072024v3.Rmd",envir= my_envmp)
#rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11292023.Rmd", clean = TRUE)


# --------------------- GET DATA
# Read your data frame in the environment
readRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envmp.RDS")

spread_no_na<- my_envmp$spread_no_na
str(spread_no_na)

readRDS(my_envepisodes, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envepisodes.RDS")
readRDS(my_envvolatile, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envvolatile.RDS")

# olsgmm 
source("C:/Users/Owner/Documents/Research/OvernightRates/CodeMI/olsgmmv3.R")

# To use gmm
# olsgmm <- function(parameters) {
#   # Your function implementation here
# }
# 
# olsgmmv2 <- function(
#     lhv,
#     rhv,
#     lags,
#     weight){

# FIND THIS FILE
jshocks <- read.csv('C:/Users/Owner/Documents/Research/OvernightRates/Final data files/fomc_surprises_jkv2.csv', header=TRUE, sep=",", dec=".",stringsAsFactors=FALSE)
#FF1	FF2	FF3	FF4	MP1	ED1	ED2	ED3	ED4	TFUT02	TFUT05	TFUT10	TFUT30	SP500	SP500FUT
#  str(jshocks)
#'data.frame':	359 obs. of  17 variables:
# GET DATA ---------------------------------------------------
# GET FOMC DATA
filepath<-"C:/Users/Owner/Documents/Research/overnightRates/Final data file
#fomc <- read.csv('C:/Users/Owner/Documents/Research/OvernightRates/Final data files/FOMCrates_sampleFinalv2.csv', header = TRUE, sep = ",", dec = ".", stringsAsFactors = FALSE)
fomc <- read.csv('C:/Users/Owner/Documents/Research/OvernightRates/Final data files/FOMCrates_sampleFinalv2.csv', header = TRUE, sep = ",", dec = ".", stringsAsFactors = FALSE, nrows = 39)
#C:/Users/Owner/Documents/Research/overnightRates/Finalxtable data files/Final data files/FOMCrates_sampleFinal.csv', header = TRUE, sep = ",", dec = ".", stringsAsFactors = FALSE)
# Set column names based on the first row
colnames(fomc) <- names(fomc)
print(colnames)
fdate<-as.Date(fomc$Date,"%d/%m/%Y")
#Create xtable
library(xtable)
xtable_fomc <- xtable(fomc)
print(xtable_fomc)
                                                       

# GET RATE AND VOLUME DAILY DATA--------------- 
filepath<-"C:/Users/Owner/Documents/Research/OvernightRatesFinal data file"
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
spread <- read.csv('C:/Users/Owner/Documents/Research/OvernightRates/Final data files/NYFedReferenceRates_12172023v3.csv', header = TRUE, sep = ",", dec = ".", stringsAsFactors = FALSE)
colnames(spread) <- names(spread)
print(colnames)
sdate<-as.Date(spread_no_na$Date,"%m/%d/%Y")

# Find the row number for the beginning and end dates of the sample: where  "3/4/2016" occurs and 12/29/2022 for the first time
# Check which index corresponds to the specified dates
begs <- which(sdate == as.Date("2016-03-04")) 
ends <- which(sdate == as.Date("2023-12-14")) 
print(begs) #[1] 4
print(ends) #[1] 1960
spread=spread[begs:ends,]
sdate=sdate[begs:ends]
str(spread)

# Final data wrangling --------------- 
spread_no_na <- spread
spread_no_na <- mutate(spread_no_na, sdate = as.Date(Date, format = "%m/%d/%Y")
spread_no_na[is.na(spread_no_na)] <- 0
columns_to_exclude <- c("Date","sdate", "Volume_EFFR","Volume_OBFR","Volume_TGCR", "Volume_BGCR","Volume_SOFR")  
# Add other column names to exclude
# Check spread before mutating to see if variables are in basis points
spread_no_na <- spread_no_na %>%
#mutate(across(-all_of(columns_to_exclude), ~ . *0.01))
mutate(across(.cols = -columns_to_exclude, ~ . * 100))
str(spread_no_na)

CHECK
IORR<-spread$IORR;
IORR %>% replace(is.na(.),0)
ior<-IORR*100
#ior<-mutate(spread,IORR*100);
RRPONTSYAWARD<-spread$RRPONTSYAWARD;
RRPONTSYAWARD %>% replace(is.na(.),0)
rrpreward<-RRPONTSYAWARD*100;
#target<- mutate(spread,TargetDe*100,TargetUe*100);
targetdbp<-spread$TargetDe*100
targetubp<-spread$TargetUe*100
#iorsofr<-ior-rrbp[,k[5]];
#rrppsofr<-rrpreward-rrbp[,k[5]];
# TargetDe <-TargetDe*100
# TargetUe <-TargetUe*100
}         

# Daily data frames overnight rates and volumes -rrbp and vold------------------------
# rrbp daily volume weighted median overnight reference rates
rrbp <-  spread_no_na[, c("sdate","EFFR","OBFR","TGCR","BGCR","SOFR")]
head(rrbp)
rrbp <- subset(rrbp, select = -OBFR)
rrbp$sdate<-sdate
str(rrbp)

secured <-  spread_no_na[, c("sdate","TGCR","BGCR","SOFR")]
str(secured)


# vold daily volumes 
vold <- spread_no_na[, c("sdate","VolumeEFFR", "VolumeOBFR", "VolumeTGCR", "VolumeBGCR", "VolumeSOFR" )]
head(vold)
vold$sdate <- as.Date(rrbp$sdate)
vold <- subset(vold, select = -VolumeOBFR)
str(vold)

# Arbitrage
sofr_ior<-spread_no_na$SOFR- spread_no_na$IORR
sofr_rrpp<-spread_no_na$SOFR- spread_no_na$RRPONTSYAWARD 
# t bills and SOFR

#Episode definition
# 1. normalcy              3/4/2016-7/31/2019    
# 2. mid cycle adjustment  8/1/2019-10/31/2019
# 3. covid                11/1/2019-3/16/2020   
# 4. zero lower bound      3/17/2020-3/16/2022
# 5. Taming inflation      3/17/2022-12/14/2023


begn<-c(1,859,923,1014,1519,1)
endn<-c(858,922,1013,1518,1957,1957)

#vdsum=sum(vold(1:1711,1:5),2); #wrates1(:,2:2:10),2);                
#begintarget = 789-447+1;

# Quantiles -------------------------------------------
# my_color_palette <- c("EFFR" = "darkblue", "TGCR" = "darkred", "BGCR" = "darkcyan", "SOFR" = "darkorange")
quantilesE<-my_envepisodes$quantilesE
quantilesT<-my_envepisodes$quantilesT
quantilesB<-my_envepisodes$quantilesB
quantilesS<-my_envepisodes$quantilesS
# if need to recreate
#quantilesE<-spread_no_na[, c("sdate","EFFR","VolumeEFFR","TargetUe","TargetDe","Percentile01_EFFR","Percentile25_EFFR","Percentile75_EFFR","Percentile99_EFFR")]
#quantilesO<-spread_no_na[, c("sdate","OBFR","VolumeOBFR","Percentile01_OBFR","Percentile25_OBFR","Percentile75_OBFR","Percentile99_OBFR")]
#quantilesT<-spread_no_na[, c("sdate","TGCR","VolumeTGCR","Percentile01_TGCR","Percentile25_TGCR","Percentile75_TGCR","Percentile99_TGCR")]
#quantilesB<-spread_no_na[, c("sdate","BGCR","VolumeBGCR","Percentile01_BGCR","Percentile25_BGCR","Percentile75_BGCR","Percentile99_BGCR")]
#quantilesS<-spread_no_na[, c("sdate","SOFR","VolumeSOFR","Percentile01_SOFR","Percentile25_SOFR","Percentile75_SOFR","Percentile99_SOFR")]



# --------------------------------DAILY DATA
# Plot daily rates sample 2016-2022
dailyrates<-ggplot(rrbp, aes(x = sdate)) +
   geom_point(aes(y = rrbp[,1], color = "EFFR"), shape = 16, size = 1) + 
   geom_point(aes(y = rrbp[,2], color = "OBFR"), shape = 16, size = 1) + 
   geom_point(aes(y = rrbp[,3], color = "TGCR"), shape = 16, size = 1) + 
   geom_point(aes(y = rrbp[,4], color = "BGCR"), shape = 16, size = 1) + 
   geom_point(aes(y = rrbp[,5], color = "SOFR"), shape = 16, size = 1) + 
   labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
   scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) + 
   theme_minimal()
print(dailyrates)
#ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/dailyrates.pdf")
#ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/dailyrates.png")
# 16 circle, 17 triangle, 15 squares  18


# OLS GMM VARs of overnight rates
# ------------------------ OLSGMM VAR FOR FAMA FRENCH MEAN REVERSION TEST
#[shocks, txt2, raws2] = xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv7.xlsx', 'Shockdata', 'A455:P1716');
# Vars
# get olsgmm for R
# https://loualiche.gitlab.io/www/data/olsgmm.html
# add a constant
# xx1<-c(rrbp);
# xx2=[rrbp(begn(k)-1:endn(k),:) SOFR_IOR(begn(k)-1:endn(k)) EFFR_IOR(begn(k)-1:begn(k)) ONRRP_IOR(begn(k)-1:begn(k))]
# xx3=[rrbp(begn(k)-1:endn(k),:) IOR(begn(k)-1:endn(k)) ONRRP(begn(k)-1:endn(k))]
# be=rrbp(begn(k):begn(k)-1,1)/rrbp(begn(k)-1:begn(k),1)
# %
# % Rates
# [theta1,sec1,R2,R2adj,vcv,F1] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx1,nlag,nw);  % constant
# param1 = [theta1 sec1,R2,R2adj,vcv,F1]
# 
# [theta2,sec2,R2,R2adj,vcv,F2] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx2,nlag,nw);  % constant
# param2 = [theta2 sec2,R2,R2adj,vcv,F2]
# 
# [theta3,sec3,R2,R2adj,vcv,F3] = olsgmm(rrbp(begn(k):endn(k)-1,:), xx2,nlag,nw)
# param3 = [theta3 sec3 R2,R2adj,vcv,F3]
# 
# % Volatility
# xx4 = [SOFR_IOR(1:end-1) EFFR_IOR(1:end-1) ONRRP_IOR(1:end-1)]
# [theta,sec,R2,R2adj,vcv,F] = olsgmm(volrate(2:endind,4),volrates(1:endind-1,3),nlag,nw);  % constant
# param = [theta sec,R2,R2adj,vcv,F]



# Combine the rates and constant into a dataset
#! /usr/bin/R
#
# olsgmm.R
#
# This code is directly adapted from John Cochrane olsgmm.m matlab program
# See Cochrane's website:
# https://faculty.chicagobooth.edu/john.cochrane/teaching/35150_advanced_investments/olsgmm.m
#
# Created       on December 14th 2016
# Last modified on December 14th 2016
#
# ---------------------------------------------------------
# OLSGMM
                
                                      
#https://medium.com/codex/generalized-method-of-moments-gmm-in-r-part-1-of-3-c65f41b6199
# SEE https://github.com/AlfredSAM/medium_blogs/blob/main/GMM_in_R/GMM_in_R.ipynb
#res0 <- gmm(g0, x, c(mu = 0, sig = 0)))
# Reproducible
# set.seed(123)
# # Generate the data from normal distribution
# n <- 200
# x <- rnorm(n, mean = 4, sd = 2)
# 
# 
# # set up the moment conditions for comparison
# 
# # MM (just identified)
# g0 <- function(tet, x) {
#   m1 <- (tet[1] - x)
#   m2 <- (tet[2]^2 - (x - tet[1])^2)
#   f <- cbind(m1, m2)
#   return(f)
# }
# 
# # GMM (over identified)
# g1 <- function(tet, x) {
#   m1 <- (tet[1] - x)
#   m2 <- (tet[2]^2 - (x - tet[1])^2)
#   m3 <- x^3 - tet[1] * (tet[1]^2 + 3 * tet[2]^2)
#   f <- cbind(m1, m2, m3)
#   return(f)
# }
# 
# print(res0 <- gmm(g0, x, c(mu = 0, sig = 0)))

# Credit SUISSE DISPERSION
#https://research-doc.credit-suisse.com/docView?language=ENG&format=PDF&source_id=csplusresearchcp&document_id=805810360&serialid=7b0hziYR8YC9WgdgSZceFVZcmKHnCBinVkLwiTRHqKU%3D&cspId=null
# For example, if a father is 76 inches tall, the mean height of men is 70 inches, and the r = 0.50 between the
# heights of fathers and sons, the expected height of the son is 73 inches, determined as follows:13
# 73 = 0.50(76 – 70) + 70
# saveRDS(olsgmm, file = "olsgmm_function.Rds")

                                      
#Fama French equations------------------------
  # r(t,t+k) =a + b_k r(t-k,t) +e(t+k)
  # k=1 r(2,3) = a +b_1 r(1,2)
  # k=2 r(3,5) = a +b_1 r(1,3)
  # k=5 r(6,11) = a +b_1 r(1,6)
  # k=10 r(11,21) = a +b_1 r(1,11)
                                      
                                      
# Assuming rrbp is your matrix of daily return observations
                                      
                                      # Assuming rrbp is your matrix of daily return observations
                                      # Extract the daily returns from the matrix
                                      # daily_returns <- rrbp[2:1710, 1:5]
                                      # 
                                      # # Calculate 2-day average returns
                                      # two_day_avg_returns <- rowMeans(matrix(daily_returns, ncol = 5, byrow = TRUE), na.rm = TRUE)
                                      # 
                                      # # Calculate 5-day average returns
                                      # five_day_avg_returns <- rowMeans(matrix(daily_returns, ncol = 5, byrow = TRUE, nrow = 5), na.rm = TRUE)
                                      # 
                                      # # Calculate 10-day average returns
                                      # ten_day_avg_returns <- rowMeans(matrix(daily_returns, ncol = 5, byrow = TRUE, nrow = 10), na.rm = TRUE)
                                      # 
                                     
                                      # # Print the results
                                      # print(two_day_avg_returns)
                                      # print(five_day_avg_returns)
                                      # print(ten_day_avg_returns)
                                      # 
  

# Extract the daily returns from the matrix
#daily_returns <- rrbp[2:1710, 1:5]                                   
                                      rrbp <- as.matrix(rrbp)
                                      
                                      n_rows <- nrow(rrbp)
                                      n_cols <- ncol(rrbp)
                                      
                                      # Initialize vectors to store rolling averages
                                      rrbp2 <- numeric(n_rows - 1)
                                      rrbp5 <- numeric(n_rows - 4)
                                      rrbp10 <- numeric(n_rows - 9)
                                      
                                      # Calculate rolling averages
                                      for (i in 1:(n_rows - 1)) {
                                        rrbp2[i] <- mean(rrbp[i:(i+1),], na.rm = TRUE)
                                      }
                                      
                                      for (i in 1:(n_rows - 4)) {
                                        rrbp5[i] <- mean(rrbp[i:(i+4),], na.rm = TRUE)
                                      }
                                      
                                      for (i in 1:(n_rows - 9)) {
                                        rrbp10[i] <- mean(rrbp[i:(i+9),], na.rm = TRUE)
                                      }
                                      
                                      # Print the results
                                      print( n_rows <- nrow(rrbp)
                                      n_cols <- ncol(rrbp)
                                      
                                      # Initialize vectors to store rolling averages
                                      rrbp2 <- numeric(n_rows - 1)
                                      rrbp5 <- numeric(n_rows - 4)
                                      rrbp10 <- numeric(n_rows - 9)
                                      
                                      # Calculate rolling averages
                                      for (i in 1:(n_rows - 1)) {
                                        rrbp2[i] <- mean(rrbp[i:(i+1),], na.rm = TRUE)
                                      }
                                      
                                      for (i in 1:(n_rows - 4)) {
                                        rrbp5[i] <- mean(rrbp[i:(i+4),], na.rm = TRUE)
                                      }
                                      
                                      for (i in 1:(n_rows - 9)) {
                                        rrbp10[i] <- mean(rrbp[i:(i+9),], na.rm = TRUE)
                                      }
                                      
                                      print(rrbp2)
                                      print(rrbp5)
                                      print(rrbp10)
  #This code creates loops that calculate rolling averages for 2-day, 5-day, and 10-day periods by iterating through the rows of the rrbp matrix. It initializes vectors to store the calculated rolling averages and uses the mean function to calculate the average for each period. Make sure that the rrbp matrix only contains numeric values before running this code.
                                      
                                      
     # Method 2
     # rrbp_zoo <- zoo(rrbp)
     # 
     # # Calculate rolling averages for 2-day, 5-day, and 10-day periods
     # two_day_avg_returns <- rollapply(rrbp_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
     # five_day_avg_returns <- rollapply(rrbp_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
     # ten_day_avg_returns <- rollapply(rrbp_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
     # 
     # # Print the results
     # print(two_day_avg_returns)
     # print(five_day_avg_returns)
     # print(ten_day_avg_returns)     
                                      
                                      
                                      
 # Calculate rolling averages for 2-day, 5-day, and 10-day periods
  rrbp_zoo <- zoo(rrbp[,2:5])                                    
 
  rrbp2 <- rollapply(rrbp_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp2) #[1] 1709
  ncol(rrbp2) #[1] 5
  head(rrbp2)
  
  rrbp5 <- rollapply(rrbp_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp5) #[1] 1706
  ncol(rrbp5) #[1] 5
  
  rrbp10 <- rollapply(rrbp_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp10) #[1] 1701
  ncol(rrbp10) #[1] 5
#ten_day_avg_returns <- rowMeans(matrix(daily_returns, ncol = 5, byrow = TRUE, nrow = 10), ncol = 5)

  
n<- ncol(rrbp)                                      

# k=1  k=1 r(2,3) = a +b_1 r(1,2)    
T<-nrow(rrbp)
lhv<- rrbp[2:T,]
ones_v <- rep(1, times = T-1)
rhv1<- rrbp[1:T-1,]

# k=2  k=1 r(2,3) = a + a +b_1 r(1,3)                                  
T<-nrow(rrbp2) #[1] 1709
lhv<- rrbp2[2:T,]
ones_v <- rep(1, times = T-1)
rhv1<- rrbp2[1:T-1,]


# k=5  k=1 r(2,3) = a +b_1 r(1,6) 
# length(rrbp5) #[1] 1706
# rrbp5_df <- as.data.frame(rrbp5)
T<-nrow(rrbp5)
lhv<- rrbp5[2:T,]
ones_v <- rep(1, times = T-1)
rhv1<- rrbp5[1:T-1,]


# k=10   k=10 r(11,21) = a +b_1 r(1,11)   
# length(rrbp10) #[1] 1701
# rrbp10_df <- as.data.frame(rrbp10)
T<-nrow(rrbp10) 
lhv<- rrbp10[2:T,]
ones_v <- rep(1, times = T-1)
rhv1<- rrbp10[1:T-1,]


# Run olsgmm
rhv<- cbind(rhv1, ones_v) # Add a column of ones
nrow(lhv)
nrow(rhv)
nlag<-1
nw<-1

result <-olsgmmv2(lhv,rhv,nlag,nw)  #constant
#print(list_res)
print(result[[1]]) # bv
print(result[[2]]) # sebv
print(result[[4]]) # R2adj
print(result[[5]]) # v covariance
print(result[[6]]) # Ftest
bvtablek1<-xtable(result[[1]])
sebvtablek1<-xtable(result[[2]])
R2adjtablek1<-xtable(result[[4]])
vtablek1<-xtable(result[[5]])
Ftesttablek1<-xtable(result[[6]])
rrbpk1table <- cbind(bvtablek1, sebvtablek1)

bvtablek2<-xtable(result[[1]])
sebvtablek2<-xtable(result[[2]])
R2adjtablek2<-xtable(result[[4]])
vtablek2<-xtable(result[[5]])
Ftesttablek2<-xtable(result[[6]])``
rrbpk2table <- cbind(bvtablek2, sebvtablek2)

bvtablek5<-xtable(result[[1]])
sebvtablek5<-xtable(result[[2]])
R2adjtablek5<-xtable(result[[4]])
vtablek5<-xtable(result[[5]])
Ftesttablek5<-xtable(result[[6]])
rrbpk5table <- cbind(bvtablek5, sebvtablek5)

bvtablek10<-xtable(result[[1]])
sebvtablek10<-xtable(result[[2]])
R2adjtablek10<-xtable(result[[4]])
vtablek10<-xtable(result[[5]])
Ftesttablek10<-xtable(result[[6]])
rrbpk10table <- cbind(bvtablek10, sebvtablek10)
# Assuming result_list is a list of lists
# result_list <- list(
#   bv = list(...),         # Element 1 (bv)
#   sebf = list(...),       # Element 2 (sebf)
#   R2 = list(...),         # Element 3 (R2)
#   R2adj = list(...),      # Element 4 (R2adj)
#   v = list(...),          # Element 5 (v)
#   Ftest = list(...)       # Element 6 (Ftest)
#   # Convert each element to a LaTeX table
#   bv_table <- xtable(result_list$bv)
#   sebf_table <- xtable(result_list$sebf)
#   R2_table <- xtable(result_list$R2)
#   R2adj_table <- xtable(result_list$R2adj)
#   v_table <- xtable(result_list$v)
#   Ftest_table <- xtable(result_list$Ftest)
#   
  # Assuming result_list is a list of lists
  result_list <- list(
    bv = list(...),         # Element 1 (bv)
    sebf = list(...),       # Element 2 (sebf)
    R2 = list(...),         # Element 3 (R2)
    R2adj = list(...),      # Element 4 (R2adj)
    v = list(...),          # Element 5 (v)
    Ftest = list(...)       # Element 6 (Ftest)
    # Convert each element to a LaTeX table
    bv_table <- xtable(result_list$bv)
    sebf_table <- xtable(result_list$sebf)
    R2_table <- xtable(result_list$R2)
    R2adj_table <- xtable(result_list$R2adj)
    v_table <- xtable(result_list$v)
    Ftest_table <- xtable(result_list$Ftest)
    
    # Combine the LaTeX tables into a single LaTeX table
    combined_table <- cbind(bv_table, sebf_table, R2_table, R2adj_table, v_table, Ftest_table)
    
  
  # Combine the LaTeX tables into a single LaTeX table
  combined_table <- cbind(bv_table, sebf_table, R2_table, R2adj_table, v_table, Ftest_table)
  
#print(result$sec)
#print(result$R2adj)
#print(result$F)
#param<-[theta,sec,R2,R2adj,vcv,F]
  
# rrbp_zoo <- zoo(rrbp[,2:5])                                    
#   rrbp2 <- rollapply(rrbp_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
#   nrow(rrbp2) #[1] 1709
#   ncol(rrbp2) #[1] 5
#   head(rrbp2)
#   
#   rrbp5 <- rollapply(rrbp_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
#   nrow(rrbp5) #[1] 1706
#   ncol(rrbp5) #[1] 5
#   
#   rrbp10 <- rollapply(rrbp_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
#   nrow(rrbp10) #[1] 1701
#   ncol(rrbp10) #[1] 5
#ten_day_avg_returns <- rowMeans(matrix(daily_returns, ncol = 5, byrow = TRUE, nrow = 10), ncol = 5)
  
  
# epochs --------------------
# normalcy_zoo <- zoo(normalcy) 
  # adjust_zoo <- zoo(adjust)  
  # covid_zoo <- zoo(covid)  
  # zlb_zoo <- zoo(zlb)  
  # inflation_zoo <- zoo(inflation)  
  
n<-ncol(rrbp)
#NORMALCY
k=1  
bgn<-begn[k]
edn<-endn[k]
  # 
  normalcy <-rrbp[bgn:edn,2:n]
  normalcy_zoo <- zoo(normalcy)  
  
  normalcy2 <- rollapply(normalcy_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(normalcy2)
  lhv<- normalcy2[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- normalcy2[1:T-1,]
  
  normalcy5 <- rollapply(rrbp_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(normalcy5)
  lhv<- normalcy5[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- normalcy5[1:T-1,]
  
  normalcy10 <- rollapply(rrbp_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(normalcy10)
  lhv<- normalcy10[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- normalcy10[1:T-1,]
  
 # run GMM for normalcy2,  normalcy4,  normalcy10 
  rhv<- cbind(rhv1, ones_v) # Add a column of ones
  nrow(lhv)
  nrow(rhv)
  nlag<-1
  nw<-1
  
  result <-olsgmmv2(lhv,rhv,nlag,nw)  #constant
  #print(list_res)
  print(result[[1]]) # bv
  print(result[[2]]) # sebv
  print(result[[4]]) # R2adj
  print(result[[5]]) # v covariance
  print(result[[6]]) # Ftest
  
  bvtablenorm2<-xtable(result[[1]],caption ="Betas Normalcy period. 2 day rolling average")
  sebvtablenorm2<-xtable(result[[2]],caption ="Standard errors Normalcy period. 2 day rolling average")
  R2adjtablenorm2<-xtable(result[[4]],caption ="R2 adjusted Normalcy period. 2 day rolling average")
  vtablenorm2<-xtable(result[[5]],caption ="Covariance of betas Normalcy period. 2 day rolling average")
  Ftesttablenorm2<-xtable(result[[6]],caption ="Ftest Normalcy period. 2 day rolling average")
  tablenorm2 <- cbind(bvtablenorm2, sebvtablenorm2,caption ="Betas. standard errors Normalcy period. 2 day rolling average")
  
  
  bvtablek1<-xtable(result[[1]])
  sebvtablek1<-xtable(result[[2]])
  R2adjtablek1<-xtable(result[[4]])
  vtablek1<-xtable(result[[5]])
  Ftesttablek1<-xtable(result[[6]])
  rrbpk1table <- cbind(bvtablek1, sebvtablek1)
  
  #ADJUST
  k=2  
  bgn<-begn[k]
  edn<-endn[k]
  adjust <-rrbp[bgn:edn,,2:n]
  adjust_zoo <- zoo(adjust) 
  
  adjust2 <- rollapply(adjust_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(adjust2)
  lhv<- adjust2[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- adjust2[1:T-1,]
  
  adjust5 <-  rollapply(adjust_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(adjust5)
  lhv<- adjust5[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- adjust5[1:T-1,]
  
  adjust10 <-  rollapply(adjust_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(adjust10)
  lhv<- adjust10[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- adjust10[1:T-1,]
  
  #COVID
  k=3  
  bgn<-begn[k]
  edn<-endn[k]
  covid <-rrbp[bgn:end,2:n]
  
  covid_zoo <- zoo(covid) 
  covid2 <- rollapply(covid_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(covid2)
  lhv<- covid2[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- covid2[1:T-1,]
  
  covid5 <- rollapply(covid_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(covid5)
  lhv<- covid5[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- covid5[1:T-1,]
  
  covid10 <- rollapply(covid_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(covid10)
  lhv<- covid10[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- covid10[1:T-1,]
  
  rhv<- cbind(rhv1, ones_v) # Add a column of ones
  nrow(lhv)
  nrow(rhv)
  nlag<-1
  nw<-1
  
  result <-olsgmmv2(lhv,rhv,nlag,nw)  #constant
  #print(list_res)
  print(result[[1]]) # bv
  print(result[[2]]) # sebv
  print(result[[4]]) # R2adj
  print(result[[5]]) # v covariance
  print(result[[6]]) # Ftest
  bvtablek1<-xtable(result[[1]])
  sebvtablek1<-xtable(result[[2]])
  R2adjtablek1<-xtable(result[[4]])
  vtablek1<-xtable(result[[5]])
  Ftesttablek1<-xtable(result[[6]])
  rrbpk1table <- cbind(bvtablek1, sebvtablek1)
  
  #zlb 
  k=4 
  bgn<-begn[k]
  edn<-endn[k]
  zlb<-rrbp[bgn:end,,2:n]
  zlb_zoo <- zoo(zlb) 
  
  zlb2 <- rollapply(zlb_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(zlb2)
  lhv<- zlb2[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- zlb2[1:T-1,]
  
  zlb5 <- rollapply(zlb_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(zlb5)
  lhv<- zlb5[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- zlb5[1:T-1,]
  
  zlb10 <- rollapply(zlb_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(zlb10)
  lhv<- zlb10[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- zlb10[1:T-1,]
  
  rhv<- cbind(rhv1, ones_v) # Add a column of ones
  nrow(lhv)
  nrow(rhv)
  nlag<-1
  nw<-1
  
  result <-olsgmmv2(lhv,rhv,nlag,nw)  #constant
  #print(list_res)
  print(result[[1]]) # bv
  print(result[[2]]) # sebv
  print(result[[4]]) # R2adj
  print(result[[5]]) # v covariance
  print(result[[6]]) # Ftest
  bvtablek1<-xtable(result[[1]])
  sebvtablek1<-xtable(result[[2]])
  R2adjtablek1<-xtable(result[[4]])
  vtablek1<-xtable(result[[5]])
  Ftesttablek1<-xtable(result[[6]])
  rrbpk1table <- cbind(bvtablek1, sebvtablek1)
  
  #INFLATION
  k=5 
  bgn<-begn[k]
  edn<-endn[k]
  inflation<-rrbp[bgn:end,,2:n]
  inflation_zoo <- zoo(inflation)
  
  inflation2 <- rollapply( inflation_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(inflation2)
  lhv<- inflation2[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- inflation2[1:T-1,]
  
  nrow(inflation2) #[1] 196
  ncol(inflation2) #[1] 5
  lhv<- inflation2[2:196,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- inflation2[1:195,1:5]
  
  inflation5 <- rollapply( inflation_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(inflation5)
  lhv<- inflation5[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- inflation5[1:T-1,]
  
  inflation10 <- rollapply( inflation_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  T<-nrow(inflation10)
  lhv<- inflation10[2:T,]
  ones_v <- rep(1, times = T-1)
  rhv1<- inflation10[1:T-1,]
  
  rhv<- cbind(rhv1, ones_v) # Add a column of ones
  nrow(lhv)
  nrow(rhv)
  nlag<-1
  nw<-1
  
  # generalize for all epochs
  
  result <-olsgmmv2(lhv,rhv,nlag,nw)  #constant
  #print(list_res)
  print(result[[1]]) # bv
  print(result[[2]]) # sebv
  print(result[[4]]) # R2adj
  print(result[[5]]) # v covariance
  print(result[[6]]) # Ftest
  bvtablek1<-xtable(result[[1]])
  sebvtablek1<-xtable(result[[2]])
  R2adjtablek1<-xtable(result[[4]])
  vtablek1<-xtable(result[[5]])
  Ftesttablek1<-xtable(result[[6]])
  rrbpk1table <- cbind(bvtablek1, sebvtablek1)
  # 
  
  
  


# I ended edit here June 20, 2024)-----------------------------------
#Calculate the mean deviation daily rates
dailystat$rrbpm <- rrbp- mean_rrbp
rrbpts <- ts(rrbp$rrbpm)
# S Find the absolute differences between each data point and the mean
#rrbp$r<-rrbp[,1:5]
rated <- apply(rrbp, 2, function(rrbp) abs(rrbp- mean_y))   # natrix array
dailystat$mean_devrated <- colMeans(rated)
print(mean_deviation)
#EFFR     OBFR     TGCR     BGCR     SOFR  
#84.22324 85.56520 85.06471 84.90744 84.57160 


# -----------------------Filter outliers, not working
outlier_threshold<-3
rrbp_filtered <- rrbp[abs(rrbp - mean_y) <= outlier_threshold * sd_y, ]

rterm<-abs(rrbp - mean_y)
outlier<-outlier_threshold * sd_y
rrbp_filtered <- rrbp[rterm <= outlier_threshold * sd_y, ]
#df_filtered <- df[abs(df$y - mean_y) <= outlier_threshold * sd_y, ]

ggplot(rrbp_filtered , aes(x = sdatett)) +
  geom_point(aes(y = rrbp_filtered [,1], color = "EFFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp_filtered [,2], color = "OBFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp_filtered [,3], color = "TGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp_filtered [,4], color = "BGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp_filtered [,5], color = "SOFR"), shape = 16, size = 1) + 
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) + 
  #scale_x_date(labels = date_format("%Y-%m-%d")) +
  #scale_x_date(labels = date_format("%Y-%m-%d")) +
  theme_minimal()

# --------------------------------WEEKLY DATA
weekly <- read.csv('C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Data/Final data files/weeklyrates072323.csv',header=TRUE, sep=",",dec=".",fileEncoding = "UTF-8")
colnames(weekly)
class(weekly)
str(weekly)
weekly[is.na(weekly)] <- 0
# weekly <- ifelse(is.na(weekly), 0, weekly) converts df to list
#weekly %>% replace(is.na(.),0)
# Assuming 'rrbpw' is your data frame and 'your_variable' is the variable with NA values
#rrbpw$your_variable <- ifelse(is.na(rrbpw$your_variable), 0, rrbpw$your_variable)

str(weekly) # 357 obs. of  44 variables, 7 mysterious NA columens with data 
# no RRPONTSYAWARD on file, but doesn't capture ONRRPust, ONRRPmbs
#weekly[1] "data.frame"
#rm(weekly)

#R Data Import/Export manual.
# Check that the data were read correctly, and inspect the table:
nrow(weekly) # [1] 1710
ncol(weekly) # [1] 37
summary(weekly)
length(weekly) #   1244          47
class(weekly$Time)

rrbpw<-  select(weekly,EFFR,OBFR,TGCR,BGCR,SOFR)
# Assuming 'rrbpw' is your data frame and 'your_variable' is the variable with NA values
rrbpw <- ifelse(is.na(rrbpw), 0, rrbpw)
rrbpw %>% replace(is.na(.),0)

rrbpw %>% replace(is.na(.),0)
rrbpw<-rrbpw*100;
volw<-  select(weekly,volEFFR,volOBFR,volTGCR,volBGCR,volSOFR)
# Dates
wdate<-as.Date(weekly$Time)\sdate<-as.Date("Time","%m/%d/%Y") 


mean_yw <- colMeans(rrbpw)
#EFFR     OBFR     TGCR     BGCR     SOFR 
#108.6403 105.2940       NA       NA       NA 
# EFFR        OBFR        TGCR        BGCR        SOFR rrbpwm.EFFR rrbpwm.OBFR rrbpwm.TGCR rrbpwm.BGCR 
# 108.6403    105.2940          NA          NA          NA          NA          NA          NA          NA 
# rrbpwm.SOFR 
# NA 
rrbpw$EFFR  #OK correct values
rrbpw$OBFR  #OK correct values
rrbpw$SOFR  # initial NA rows wrong values
rrbpw$TGFR  # all NA
rrbpw$BGFR   # Ok Initial and lat row NA
rrbpw$rrbpwm<-rrbpw-colMeans(rrbpw)
rrbpwts <- ts(rrbpw$rrbpwm)

rrbpw$res<-res
weeklyrates<-ggplot(rrbpw, aes(x = sdatett)) +
  geom_point(aes(y = rrbpw[,1], color = "EFFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbpw[,2], color = "OBFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbpw[,3], color = "TGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbpw[,4], color = "BGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbpw[,5], color = "SOFR"), shape = 16, size = 1) + 
  geom_point(aes(y = res[,1], color = "Reserves"), shape = 16, size = 1) + 
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red","Reserves"="black")) + 
  theme_minimal()

boxplot<-ggplot(rrbp,aes(sdate,rrbp))
plot +
  geom_boxplot(outlier.col="red")+ stat_summary()
# qqplot
plot(sort(rrbp[,1]),sort(rrbp[,5]))
abline(0,1)
qq(plot)


# ------------------------ Daily epoch rates

# # Loop through a numeric range
# for (k in 1:5) {
#   norm<-rrbp[begn[k]{endn[].]
#   cat("Iteration:", i, "\n")
# }

k<-1
norm<-rrbp[begn[k]:endn[k],]
K<-2
adjust<-rrbp[begn[k]:endn[k],]
K<-3
covid<-rrbp[begn[k]:endn[k],]
K<-4
zlb<-rrbp[begn[k]:endn[k],]
K<-5
inflation<-rrbp[begn[k]:endn[k],]


norm <-rrbp %>% slice(1:856)
adjust <-rrbp %>% slice(857:920)
covid <-rrbp %>% slice(921:1029)
zlb <-rrbp %>% slice(1030:1513)
inflation <-rrbp %>% slice(1514:1710)

# ---------- STATS sample rates
mean_rrbp <- colMeans(rrbp)
median_rrbp <- colMedians(rrbp)
var_rrbp <- colVars(rrbp)
sd_rrbp<-sqrt(var_rrbp)
kurtosis_rrbp <- colkurtosis(rrbp, pvalue = TRUE)
skew_rrbp<-colskewness(rrbp, pvalue = TRUE)
cv_rrbp<-sqrt(var_rrbp)/mean_rrbp
stats_rrbp<-data.frame(mean_rrbp,median_rrbp,sd_rrbp, kurtosis_rrbp,skew_rrbp,cv_rrbp)
moments_rrbp<-xtable(stats_rrbp)

# ---------- STATS epochs
mean_norm <- colMeans(norm)
median_norm <- colMedians(norm)
var_norm <- colVars(norm)
sd_norm<-sqrt(var_norm)
kurtosis_norm <- colkurtosis(norm, pvalue = TRUE)
skew_norm<-colskewness(norm, pvalue = TRUE)
cv_norm<-sqrt(var_norm)/mean_norm
stats_norm<-data.frame(mean_norm,median_norm, sd_norm,kurtosis_norm,skew_norm,cv_norm)
#stats_norm<-data.frame(mean_norm,median_norm,var_norm, sd_norm,kurtosis_norm,skew_norm,cv_norm)
moments_norm<-xtable(stats_norm)

str(stats_norm)
# 'data.frame':	5 obs. of  8 variables:
#   $ mean_norm  : num  24.8 20.8 21 21.9 24.3
# $ median_norm: num  9 9 8 7 8
# $ var_norm   : num  636 453 455 529 616
# $ kurtosis   : num  1 1 1 1 1
# $ p.value    : num  2.1e-09 2.1e-09 2.1e-09 2.1e-09 2.1e-09
# $ skewness   : num  -13.1 -13.1 -13.1 -13.1 -13.1
# $ p.value.1  : num  0 0 0 0 0
# $ cv_norm    : num  1.02 1.02 1.02 1.05 1.02


mean_adjust <- colMeans(adjust)
median_adjust <- colMedians(adjust)
var_adjust <- colVars(adjust)
sd_adjust<-sqrt(var_adjust)
kurtosis_adjust <- colkurtosis(adjust, pvalue = TRUE)
skew_adjust<-colskewness(adjust, pvalue = TRUE)
cv_adjust<-sqrt(var_norm)/mean_adjust
stats_adjust<-data.frame(mean_adjust,median_adjust,sd_adjust, kurtosis_adjust,skew_adjust,cv_adjust)
#stats_adjust<-data.frame(mean_adjust,median_adjust,var_adjust,sd_adjust, kurtosis_adjust,skew_adjust,cv_adjust)
moments_adjust<-xtable(stats_adjust)
str(stats_adjust)
    
mean_covid <- colMeans(covid)
median_covid <- colMedians(covid)
var_covid <- colVars(covid)
sd_covid<-sqrt(var_covid)
kurtosis_covid <- colkurtosis(covid, pvalue = TRUE)
skew_covid<-colskewness(covid, pvalue = TRUE) 
cv_covid<-sqrt(var_covid)/mean_covid
stats_covid<-data.frame(mean_covid,median_covid,sd_covid, kurtosis_covid,skew_covid,cv_covid)
#stats_covid<-data.frame(mean_covid,median_covid,var_covid,sd_covid, kurtosis_covid,skew_covid,cv_covid)
moments_covid<-xtable(stats_covid)
    
str(stats_covid)
        
mean_zlb <- colMeans(zlb)
median_zlb <- colMedians(zlb)
var_zlb <- colVars(zlb)
sd_zlb<-sqrt(var_zlb)
kurtosis_zlb <- colkurtosis(zlb, pvalue = TRUE)
skew_zlb<-colskewness(zlb, pvalue = TRUE)
cv_zlb<-sqrt(var_zlb)/mean_zlb
stats_zlb<-data.frame(mean_zlb,median_zlb, sd_zlb,kurtosis_zlb,skew_zlb,cv_zlb)
#stats_zlb<-data.frame(mean_zlb,median_zlb,var_zlb, sd_zlb,kurtosis_zlb,skew_zlb,cv_zlb)
moments_zlb<-xtable(stats_zlb)
        
str(stats_zlb)
            
mean_inflation <- colMeans(inflation)
median_inflation <- colMedians(inflation)
var_inflation <- colVars(inflation)
sd_inflation<-sqrt(var_inflation)
kurtosis_inflation <- colkurtosis(inflation, pvalue = TRUE)
skew_inflation<-colskewness(inflation, pvalue = TRUE)
cv_inflation<-sqrt(var_inflation)/mean_inflation
stats_inflation<-data.frame(mean_inflation,median_inflation, sd_inflation,kurtosis_inflation,skew_inflation,cv_inflation)
#stats_inflation<-data.frame(mean_inflation,median_inflation,var_inflation, sd_inflation,kurtosis_inflation,skew_inflation,cv_inflation)
moments_inflationt<-xtable(stats_inflation)            
str(stats_inflation)



# ------------------- Notes
# Write LaTeX tables to  .tex filea
file_path <- "C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Tables/rrbptable.tex"
cat("\\documentclass{article}\n", 
    "\\begin{document}\n", 
     print(rrbptable), 
    "\\end{document}\n", 
    file = file_path)

# Combine LaTeX representations into a single LaTeX table
combined_rates <- paste(rrbptable, normtable, adjusttable, covidtable,zlbtable,inflationtable,sep = "\n")
# Write the combined LaTeX table to a .tex file
file_path <- "C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Tables/combined_rates.tex"
cat("\\documentclass{article}\n", 
     "\\begin{document}\n", 
     combined_rates, 
     "\\end{document}\n", 
     file = file_path)


# --------------- epoch plots
# normalcy <-rrbp %>% slice(1:856)
# adjust <-rrbp %>% slice(857:920)
# covid <-rrbp %>% slice(921:1029)
# zlb <-rrbp %>% slice(1030:1513)
# inflation <-rrbp %>% slice(1514:1710)
norm_sdate <- sdate[1:856]
adj_sdate <- sdate[857:920]
covid_sdate <- sdate[921:1029]
zlb_sdate <- sdate[1030:1513]
inflation_sdate <- sdate[1514:1710]


# Assuming normalcy is a matrix and sdate is a vector
norm_sdate <- sdate[1:856]
ggnorm <- ggplot(normalcy, aes(x = norm_sdate)) +
  geom_point(aes(y = normalcy[, 1], color = "EFFR"), shape = 16, size = 1, key_glyph = draw_key_point) +
  geom_point(aes(y = normalcy[, 2], color = "OBFR"), shape = 16, size = 1, key_glyph = draw_key_point) +
  geom_point(aes(y = normalcy[, 3], color = "TGCR"), shape = 16, size = 1, key_glyph = draw_key_point) +
  geom_point(aes(y = normalcy[, 4], color = "BGCR"), shape = 16, size = 1, key_glyph = draw_key_point) +
  geom_point(aes(y = normalcy[, 5], color = "SOFR"), shape = 16, size = 1, key_glyph = draw_key_point) +
  labs(x = "Date", y = "basis points (bp)", color = "Lines") +
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) +
  theme_minimal()
print(ggnorm)

ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggnorm.pdf")
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggnorm.png")

adj_sdate <- sdate[857:920]
ggadj<-ggplot(adjust, aes(x = adj_sdate)) +
  geom_point(aes(y = adjust[,1], color = "EFFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = adjust[,2], color = "OBFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = adjust[,3], color = "TGCR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = adjust[,4], color = "BGCR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = adjust[,5], color = "SOFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) +
  theme_minimal()
print(ggadj)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggadj.pdf")
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggadj.png")


covid_sdate <- sdate[921:1029]
ggcovd<-ggplot(covid, aes(x = covid_sdate)) +
  geom_point(aes(y = covid[,1], color = "EFFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = covid[,2], color = "OBFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = covid[,3], color = "TGCR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = covid[,4], color = "BGCR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = covid[,5], color = "SOFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) +
  theme_minimal()
print(ggcovid)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggcovid.pdf")
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggcovid.png")


zlb_sdate <- sdate[1030:1513]
ggzlb<-ggplot(zlb, aes(x = zlb_sdate)) +
  geom_point(aes(y = zlb[,1], color = "EFFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = zlb[,2], color = "OBFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = zlb[,3], color = "TGCR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y = zlb[,4], color = "BGCR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  geom_point(aes(y =zlb[,5], color = "SOFR"), shape = 16, size = 1, key_glyph = draw_key_point) + 
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) +
  theme_minimal()
print(ggzlb)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggzlb.pdf")
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggzlb.png")


inflation_sdate <- sdate[1514:1710]
ggpi<-ggplot(inflation, aes(x = inflation_sdate)) +
  geom_point(aes(y = inflation[,1], color = "EFFR"), shape = 16, size = 1) + 
  geom_point(aes(y = inflation[,2], color = "OBFR"), shape = 16, size = 1) + 
  geom_point(aes(y = inflation[,3], color = "TGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = inflation[,4], color = "BGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = inflation[,5], color = "SOFR"), shape = 16, size = 1) + 
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) +
  theme_minimal()
print(ggpi)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggpi.pdf")
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggpi.png")

  
# line 91
grid_arrangement <- grid.arrange(dailyrates,ggnorm,ggadj, ggzlb, ncol = 5)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/storyOnrates.png", grid_arrangement, width = 12, height = 8, dpi = 300)

ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/dailyrates.png")
grid_arrangement <- grid.arrange(ggnorm,ggadj, ggzlb, ncol = 4)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/storyOnrates.png", grid_arrangement, width = 12, height = 8, dpi = 300)

# ------------- ridgeline and density plots
#https://cran.r-project.org/web/packages/ggridges/vignettes/introduction.html
# 1. Ridge ggplot(d, aes(x, y, height = height, group = y)) + 
#   geom_density_ridges(stat = "identity", scale = 1)
# data <- data.frame(x = 1:5, y = rep(1, 5), height = c(0, 1, 3, 4, 2))
# ggplot(data, aes(x, y, height = height)) + geom_ridgeline()

# 2. Density plots
# The geom geom_density_ridges calculates density estimates from the provided data and then plots those, using the ridgeline visualization. The height aesthetic does not need to be specified in this case.
# 
# ggplot(iris, aes(x = Sepal.Length, y = Species)) + geom_density_ridges()

# Ridgeline, density plots rrbp
# 1. Ridge 
# Load the dplyr package if not already loaded
library(dplyr)

# Assuming you have already created the data_rrbp data frame with columns EFFR, OBFR, TGCR, BGCR, SOFR, and sdate.
#2. Density plot
2. Density
#ggplot(iris, aes(x = Sepal.Length, y = Species)) + geom_density_ridges()

# Assuming y is formed by concatenating columns from rrbp
# y = c(rrbp[,1], rrbp[,2], rrbp[,3], rrbp[,4], rrbp[,5])

data_rrbp <- data_rrbp %>%
  mutate(
    rrbp = case_when(
      EFFR == 10 ~ "EFFR",
      EFFR == 5  ~ "OBFR",
      EFFR == 8  ~ "SOFR",
      TRUE       ~ NA_character_  # Default case for unmatched values
    )
  ) %>%
  mutate(
    rrbp = ifelse(TGCR == 79, "TGCR", rrbp),
    rrbp = ifelse(BGCR == 80, "BGCR", rrbp)
  ) %>%
  mutate(rrbp = factor(rrbp, levels = rev(c("EFFR", "OBFR", "TGCR", "BGCR", "SOFR"))))

# Check the structure of data_rrbp
str(data_rrbp)

# Create the ggplot visualization
rates_density<-ggplot(data_rrbp, aes(x = sdate, y = rrbp)) + 
  gdensity_ridges()
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures2/rates_density.png", grid_arrangement, width = 12, height = 8, dpi = 300)


# 9/05 9:30 pm
height = c(max(rrbp[, 1]), max(rrbp[, 2]), max(rrbp[, 3]), max(rrbp[, 4]), max(rrbp[, 5]))
data_rrbp<-data.frame(sdate,"EFFR", "OBFR","TGCR", "BGCR", "SOFR") 
rates_ridge<-ggplot(data_rrbp, aes(x = sdate, y = rrbp),height) 
+ geom_ridgeline()
print(rates_ridge)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures2/rates_ridge.png", grid_arrangement, width = 12, height = 8, dpi = 300)

print(colnames(rrbp))



#Create a new data frame with the desired columns (replace with correct names)
data_rrbp <- rrbp[, c("EFFR", "OBFR","TGCR", "BGCR", "SOFR")]

# Reshape the data from wide to long format
data_rrbp_long <- gather(data_rrbp, variable, value)

# Calculate the maximum value for each variable
class(data_rrbp_long$sdate) #[1] "NULL"


data_rrbp <- rrbp[, c("EFFR", "OBFR","TGCR", "BGCR", "SOFR")]
data_rrbp_long <- gather(data_rrbp, variable, value)

max_values <- data_rrbp_long %>%
  +     group_by(variable) %>%
  +     summarize(max_value = max(value, na.rm = TRUE))

rates_ridge <- ggplot(data_rrbp_long, aes(x = sdate, y = value, group = variable, color = variable)) + 
  geom_ridgeline() +
  scale_y_continuous(limits = c(0, max(max_values$max_value))) +
  labs(y = "Value")

 print(rates_ridge)

 

 sdate <- rrbp$sdate
 # Create an empty data frame for the long-format data
 data_rrbp_long <- data.frame()
 
 
 
 # Create a new data frame with the desired columns (replace with correct names)
 library(ggplot2)
 library(dplyr)
 library(tidyr)
 data_rrbp <- rrbp[, c("EFFR", "OBFR","TGCR", "BGCR", "SOFR")]
 # Add the sdate column back to data_rrbp
 data_rrbp$sdate <- rrbp$sdate
 
 # Reshape the data from wide to long format using pivot_longer
 data_rrbp_long <- data_rrbp %>%
   pivot_longer(cols = -sdate, names_to = "variable", values_to = "value")
 
 # Calculate the maximum value for each variable
max_values <- data_rrbp_long %>%
  +     group_by(variable) %>%
  +     summarize(max_value = max(value, na.rm = TRUE))

# Set a default maximum value when there are no non-missing values
default_max <- 1  # You can adjust this value as needed
 
# Create the ridgeline plot
library(ggplot2)
library(ggridges)

rates_ridge <- ggplot(data_rrbp_long, aes(x = sdate, y = value, group = variable, color = variable)) + 
  geom_density_ridges(scale = 0.02) +
  scale_y_continuous(limits = c(0, max(data_rrbp_long$value, na.rm = TRUE))) +
  labs(y = "Value", fill = "") +
  theme(legend.position = "top")

print(rates_ridge)


# MY wide form plot works
dailyrates<-ggplot(rrbp, aes(x = sdate)) +
geom_point(aes(y = rrbp[,1], color = "EFFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,2], color = "OBFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,3], color = "TGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,4], color = "BGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,5], color = "SOFR"), shape = 16, size = 1) + 
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) + 

  rates_ridge<-ggplot(rrbp, aes(x = sdate)) +
  geom_point(aes(y = rrbp[,1], color = "EFFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,2], color = "OBFR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,3], color = "TGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,4], color = "BGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = rrbp[,5], color = "SOFR"), shape = 16, size = 1) + 
  
  rates_ridge <- ggplot(rrbp_long, aes(x = sdate,
  y = rrbp[,1], color = "EFFR"), shape = 16, size = 1) + 
  y = rrbp[,2], color = "OBFR"), shape = 16, size = 1) + 
  y = rrbp[,3], color = "TGCR"), shape = 16, size = 1) + 
  y = rrbp[,4], color = "BGCR"), shape = 16, size = 1) + 
  y = rrbp[,5], color = "SOFR"), shape = 16, size = 1) + 
 
  rates_ridge <- ggplot(rrbp_long, aes(x = sdate, y = value, group = variable, color = variable)) + 
  geom_density_ridges(scale = 0.02) +
  scale_y_continuous(limits = c(0, max(data_rrbp_long$value, na.rm = TRUE))) +
  labs(y = "Value", fill = "") +
  theme(legend.position = "top")

print(rates_ridge)


library(tidyverse); library(ggridges)
n = 50000
df2 <- df %>% 
  uncount(n) %>%
  mutate(value = rnorm(n(), caseMean, caseSD))
ggplot(df2, aes(x = value, y = case_number)) + geom_density_ridges()


# Assuming your original data frame is named 'rrbp'
rates_ridge <- ggplot(data = rrbp, aes(x = sdate)) +
  geom_density_ridges(aes(y = EFFR, fill = "EFFR"), scale = 0.02) +
  geom_density_ridges(aes(y = OBFR, fill = "OBFR"), scale = 0.02) +
  geom_density_ridges(aes(y = TGCR, fill = "TGCR"), scale = 0.02) +
  geom_density_ridges(aes(y = BGCR, fill = "BGCR"), scale = 0.02) +
  geom_density_ridges(aes(y = SOFR, fill = "SOFR"), scale = 0.02) +
  scale_y_continuous(limits = c(0, max(rrbp$max_value, na.rm = TRUE, default_max))) +
  labs(y = "Value", fill = "") +
  theme(legend.position = "top")

print(rates_ridge)

# This can happen when ggplot fails to infer the correct grouping structure in the data.
# ℹ Did you forget to specify a `group` aesthetic or to convert a numerical variable into a factor? 
#   2: The following aesthetics were dropped during statistical transformation: y
# ℹ This can happen when ggplot fails to infer the correct grouping structure in the data.
# ℹ Did you forget to specify a `group` aesthetic or to convert a numerical variable into a factor? 
#   3: The following aesthetics were dropped during statistical transformation: y
# ℹ This can happen when ggplot fails to infer the correct grouping structure in the data.
# ℹ Did you forget to specify a `group` aesthetic or to convert a numerical variable into a factor? 
#   4: The following aesthetics were dropped during statistical transformation: y
# ℹ This can happen when ggplot fails to infer the correct grouping structure in the data.
# ℹ Did you forget to specify a `group` aesthetic or to convert a numerical variable into a factor? 
#   5: The following aesthetics were dropped during statistical transformation: y
# ℹ This can happen when ggplot fails to infer the correct grouping structure in the data.
# ℹ Did you forget to specify a `group` aesthetic or to convert a numerical variable into a factor? 
#   > 

# Error in `geom_density_ridges()`:
#   ! Problem while computing stat.
# ℹ Error occurred in the 1st layer.
# Caused by error in `data.frame()`:
#   ! arguments imply differing number of rows: 0, 1710
# Run `rlang::last_trace()` to see where the error occurred.

#FINAL
rates_ridge<- ggplot() +
  +     geom_density(data = rrbp, aes(x = EFFR, y = ..scaled.., fill = "EFFR"), alpha = 0.5) +
  +     geom_density(data = rrbp, aes(x = OBFR, y = ..scaled.., fill = "OBFR"), alpha = 0.5) +
  +     geom_density(data = rrbp, aes(x = TGCR, y = ..scaled.., fill = "TGCR"), alpha = 0.5) +
  +     geom_density(data = rrbp, aes(x = BGCR, y = ..scaled.., fill = "BGCR"), alpha = 0.5) +
  +     geom_density(data = rrbp, aes(x = SOFR, y = ..scaled.., fill = "SOFR"), alpha = 0.5) +
  +     scale_x_continuous(limits = c(0, max(rrbp$EFFR, rrbp$OBFR, rrbp$TGCR, rrbp$BGCR, rrbp$SOFR))) +
  +     labs(x = "Basis Points (bp)", fill = "Lines") +
  +     scale_fill_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) +
  +     theme_minimal()
print(rates_ridge)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures2/rates_ridge.png", grid_arrangement, width = 12, height = 8, dpi = 300)


rates_ridge2 <- ggplot(rrbp, aes(x = sdate)) +
  geom_density(aes(y = EFFR, fill = "EFFR"), alpha = 0.5) +
  geom_density(aes(y = OBFR, fill = "OBFR"), alpha = 0.5) +
  geom_density(aes(y = TGCR, fill = "TGCR"), alpha = 0.5) +
  geom_density(aes(y = BGCR, fill = "BGCR"), alpha = 0.5) +
  geom_density(aes(y = SOFR, fill = "SOFR"), alpha = 0.5) +
  labs(x = "Date", y = "Basis Points (bp)", fill = "Lines") +
  scale_fill_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) +
  theme_minimal()
# height 433 432 525 525 525 
# rrbp levels SOFR BGCR TGCR OBFR EFFR

rates_ridge3 <- ggplot(rrbp, aes(x = sdate, y = EFFR)) + 
  geom_density_ridges(aes(y = OBFR), scale = 0.02, rel_min_height = 0.01) +
  geom_density_ridges(aes(y = TGCR), scale = 0.02, rel_min_height = 0.01) +
  geom_density_ridges(aes(y = BGCR), scale = 0.02, rel_min_height = 0.01) +
  geom_density_ridges(aes(y = SOFR), scale = 0.02, rel_min_height = 0.01) +
  scale_y_continuous(limits = c(0, max(rrbp$EFFR, rrbp$OBFR, rrbp$TGCR, rrbp$BGCR, rrbp$SOFR)), expand = c(0.01, 0)) +
  labs(x = "Date", y = "Value", color = "") +
  theme_minimal() +
  theme(legend.position = "top")

print(rates_ridge3)


#TRY DENSITY PLOT STACKOVERFLOW
#https://stackoverflow.com/questions/61822048/ridgline-plot-of-several-groups-in-r
# library(tidyr)
# library(dplyr)
# library(ggridges)
# set.seed(1234)
# data<-data.frame(age= rnorm(100, 50, 2), symptom_1 = rbinom(100, 1, 0.5), symptom_2 = rbinom(100, 1, 0.5), symptom_3 = rbinom(100, 1, 0.5), symptom_4 = rbinom(100, 1, 0.5), death= rbinom(100, 1, 0.75))
# Step 1: Melt or Gather the data
# There are a few ways to approach this, but the format of your original dataframe has the same information separated across many columns. It's generally best practice to follow Tidy Data Principles. Our aim with the code below is to combine the information in data$symptom_1 through data$symptom_4, to be the label column, and then just keep data$age, data$Symptom (our new column), and data$death:
# 
# df <- data %>% gather(key='Symptom', value='Value',-death,-age)
# df <- df %>% dplyr::filter(Value==1) %>% select(age, Symptom, death)
# Step 2: Plot the Data
# Now that we have the data in the format needed, we'll plot the data. This is pretty simple. First, let's create the basic overlapping density plot via geom_density and a bit of theme element adjustments to make it look a bit better:
# 
# ggplot(df, aes(x=age)) + theme_minimal() +
#   geom_density(aes(fill=Symptom), alpha=0.3) +
#   xlim(min(df$age)-2,max(df$age)+2)


library(ggplot2)

# Create the data frame (replace rrbp1, rrbp2, etc., with your actual column names)
data_rrbp <- data.frame(sdate,rrbp , group)
EFFR, OBFR, TGCR, BGCR, SOFR
# Create the ggplot visualization with a specific rrbp column (e.g., rrbp1)
rates_ridge <- ggplot(data_rrbp, aes(x = sdate, y = rrbp1, group = group)) + 
  geom_ridgeline()

# Print the plot
print(rates_ridge)

# 2> Density
#2. density
data<-data.frame(age= rnorm(100, 50, 2), symptom_1 = rbinom(100, 1, 0.5), symptom_2 = rbinom(100, 1, 0.5), symptom_3 = rbinom(100, 1, 0.5), symptom_4 = rbinom(100, 1, 0.5), death= rbinom(100, 1, 0.75))
# Step 1: Melt or Gather the data
# There are a few ways to approach this, but the format of your original dataframe has the same information separated across many columns. It's generally best practice to follow Tidy Data Principles. Our aim with the code below is to combine the information in data$symptom_1 through data$symptom_4, to be the label column, and then just keep data$age, data$Symptom (our new column), and data$death:
# 
# df <- data %>% gather(key='Symptom', value='Value',-death,-age)
# df <- df %>% dplyr::filter(Value==1) %>% select(age, Symptom, death)
# Step 2: Plot the Data
# Now that we have the data in the format needed, we'll plot the data. This is pretty simple. First, let's create the basic overlapping density plot via geom_density and a bit of theme element adjustments to make it look a bit better:
# 
# ggplot(df, aes(x=age)) + theme_minimal() +
#   geom_density(aes(fill=Symptom), alpha=0.3) +
#   xlim(min(df$age)-2,max(df$age)+2)

norm_date <- as.character(norm_sdate)
data_norm<-data.frame(norm_date, rate_1 = normalcy[,1],rate_2 = normalcy[,2],rate_3 = normalcy[,3], rate_3 = normalcy[,4],rate_4 = normalcy[,5])
data_norm <- data_norm %>% gather(key='rate') #, value='Value',norm_date)
# Error in `gather()`:
#   ! Can't subset columns that don't exist.
# ✖ Columns `2016-03-07`, `2016-03-08`, `2016-03-09`, `2016-03-10`, `2016-03-11`, etc. don't exist.
# Run `rlang::last_trace()` to see where the error occurred.
# df_norm <- df_norm %>% dplyr::filter(Value==1) %>% select(norm_date, rate)
density_norm<-ggplot(data_norm, aes(x=norm_date)) + theme_minimal() +
     geom_density(aes(fill=rate), alpha=0.3) 
print(density_norm)
# vs
y_matrix <- matrix(y, nrow = num_rows, ncol = num_cols, byrow = TRUE)
#data_norm<-data.frame(norm_sdate, y=c(normalcy[,1],normalcy[,2],normalcy[,3],normalcy[,4],normalcy[,5]), c(max(normalcy[,1]), max(normalcy[,2]), max(normalcy[,3]), max(normalcy[,4]), max(normalcy[,5]))
data_norm<-data.frame(norm_sdate, y_matrix, height = c(max(normalcy[,1]), max(normalcy[,2]), max(normalcy[,3]), max(normalcy[,4]), max(normalcy[,5])))


# Ridgeline, density plots adjust
# 1. Ridge 
num_rows <- nrow(adjust)
num_cols <- 5
# Reshape y into a matrix with 1710 rows and 5 columns
y_matrix <- matrix(y, nrow = num_rows, ncol = num_cols, byrow = TRUE)
data_adjust<-data.frame(adj_sdate, y=c(adjust[,1],adjust[,2],adjust[,3],adjust[,4],adjust[,5]), height = c(0, 1, 3, 4, 2))
ridge_adj<-ggplot(data_adjust, aes(adj_sdate, y, height = height)) + geom_ridgeline()
print(ridge_adj)


# Ridgeline, density plots covid
# 1. Covid
num_rows <- nrow(covid)
num_cols <- 5
# Reshape y into a matrix with 1710 rows and 5 columns
y_matrix <- matrix(y, nrow = num_rows, ncol = num_cols, byrow = TRUE)
data_covid<-data.frame(covid_sdate, y=c(covid[,1],covid[,2],covid[,3],covid[,4],covid[,5]), height = c(0, 1, 3, 4, 2))
ridge_covid<-ggplot(data_covid, aes(covid_sdate, y, height = height)) + geom_ridgeline()
print(ridge_covid)

# Ridgeline, density plots zlb
# 1. Ridge 
num_rows <- nrow(zlb)
num_cols <- 5
# Reshape y into a matrix with 1710 rows and 5 columns
y_matrix <- matrix(y, nrow = num_rows, ncol = num_cols, byrow = TRUE)
data_zlb<-data.frame(zlb_sdate, y=c(zlb[,1],zlb[,2],zlb[,3],zlb[,4],zlb[,5]), height = c(0, 1, 3, 4, 2))
ridge_zlb<-ggplot(data_zlb, aes(zlb_sdate, y, height = height)) + geom_ridgeline()
print(ridge_zlb)

# Ridgeline, density plots inflation
# 1. Ridge 
num_rows <- nrow(inflation)
num_cols <- 5
# Reshape y into a matrix with 1710 rows and 5 columns
y_matrix <- matrix(y, nrow = num_rows, ncol = num_cols, byrow = TRUE)
data_inflation<-data.frame(inflation_sdate, y=c(inflation[,1],inflation[,2],inflation[,3],inflation[,4],inflation[,5]), height = c(0, 1, 3, 4, 2))
ridge_inflation<-ggplot(data_inflation, aes(inflation_sdate, y, height = height)) + geom_ridgeline()
print(ridge_inflation)

# chatgptnote on density errors -------------------
# Assuming you have y_matrix and sdate as described earlier
# Also, assuming rrbp contains sdate

# Reshape y_matrix and sdate into a data frame
data_rrbp2 <- data.frame(sdate = rep(sdate, ncol(y_matrix)),
                   value = as.vector(y_matrix))

# Create a density ridgeline plot
ggplot(data_rrbp2, aes(x = sdate, y = value, group = sdate)) +
  geom_density_ridges(scale = 3) +
  theme_ridges()  # Optional: Apply a theme to the ridgeline plot

# third try
data_rrbp2 <- data.frame(
  sdate = rep(sdate, each = ncol(y_matrix)),
  value = as.vector(y_matrix)
)
ggplot(data_rrbp2, aes(x = value, y = sdate, group = sdate)) +
  +     geom_density_ridges(scale = 3) +
  +     theme_ridges() 
#Picking joint bandwidth of 11.7

# Create a density ridgeline plot
 ggplot(data_rrbp2, aes(x = value, y = sdate, group = sdate)) +
  +     geom_density_ridges(scale = 3) +
  +     theme_ridges() 
#Picking joint bandwidth of 11.7

 
 # 4th try
 # print(ggplot(data_rrbp2, aes(x = value, y = sdate, group = sdate)) +
 #         Warning message:
 #         In diff.default(xscale) : reached elapsed time limit
 #       +           geom_density_ridges(scale = 3) +
 #         +           theme_ridges())
 # Picking joint bandwidth of 11.7
 


data_rrbp2 <- data.frame(sdate = rep(sdate, ncol(y_matrix)),
                         +                          value = as.vector(y_matrix))
# > ggplot(data_rrbp2, aes(x = sdate, y = value, group = sdate)) +
#   +     geom_density_ridges(scale = 3) +
#   +     theme_ridges() 
# Picking joint bandwidth of 11800
# Error in `geom_density_ridges()`:
#   ! Problem while setting up geom.
# ℹ Error occurred in the 1st layer.
# Caused by error in `compute_geom_1()`:
#   ! `geom_density_ridges()` requires the following missing aesthetics: y
# Run `rlang::last_trace()` to see where the error occurred.
# Warning message:
#   The following aesthetics were dropped during statistical transformation: y
# ℹ This can happen when ggplot fails to infer the correct grouping structure in the data.
# ℹ Did you forget to specify a `group` aesthetic or to convert a numerical variable into a factor? 
#   > 

#ggplot(rrbp, aes(sdate, y=c(rrbp[,1],rrbp[,2],rrbp[,3],rrbp[,4],rrbp[,5]))) + geom_density_ridges()


# Caused by error in `check_aesthetics()`:
#   ! Aesthetics must be either length 1 or the same as the data (1710)
# ✖ Fix the following mappings: `y`
# Run `rlang::last_trace()` to see where the error occurred.
# > length(y)
# [1] 8550 1710*5
# > length(sdate)
# [1] 1710
 

# # Save the plot as a PDF file
# pdf("my_plot.pdf")
# # ... your plot code here ...
# dev.off()  # This closes the PDF device
# 
# # Save the plot as a PNG file
# png("my_plot.png", width = 800, height = 600)
# # ... your plot code here ...
# dev.off()  # This closes the PNG device


@ ---------------------------------------
percentile <-ggplot(metricE, aes(x = sdate)) +
geom_line(aes(y = normalcy, color = "EFFR", linetype ="solid", linewidth = 1.5, alpha = 1.25) + 
              #geom_area(aes(ymin = metricE[,4]*100, ymax= metricE[,5]*100)
              #          ,fill = "Area between 25th and 75th percentile"), alpha = 0.5) +
              geom_line(aes(y = metricE[,4]*100, color = "25 pct", linetype = "dashed", linewidth = 1, alpha = 0.8) + 
                          geom_line(aes(y = metricE[,5]*100, color = "75 pct", linetype ="dashed", linewidth = 1, alpha = 0.8) + 
                                      #geom_line(aes(y = metricE[,4]*100), color = "green") +
                                      #geom_line(aes(y = metricE[,5]*100), color = "blue") +
                                      geom_ribbon(aes(x = sdate,
                                                      ymin = metricE[,4]*100,
                                                      ymax = metricE[,5]*100),
                                                  fill ="grey80")+
                                      labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
                                      #ylim= c(0,450)+
                                      scale_color_manual(values = c("EFFR" = "blue))
  #scale_color_manual(values = c("EFFR" = "blue, "25 pct" = "grey", "75 pct" = "grey" )) + 
                                      #scale_color_manual(values = c("EFFR" = "black","Lower target" = "green","Upper target" = "blue", "25 pct" = "grey", "75 pct" = "grey" )) + 
                                      theme_minimal()# 


# ---------------------------------------------------------
  olsgmmv2 <- function(
    lhv,
    rhv,
    lags,
    weight){
    
    # --------------------------------------------------------------------------------     
    ## % function olsgmm does ols regressions with gmm corrected standard errors
    ## % Inputs:
    ## %  lhv T x N vector, left hand variable data 
    ## %  rhv T x K matrix,N< right hand variable data
    ## %  If N > 1, this runs N regressions of the left hand columns on all the (same) right hand variables. 
    ## %  lags number of lags to include in GMM corrected standard errors
    ## %  weight: 1 for newey-west weighting 
    ## %          0 for even weighting
    ## %         -1 skips standard error computations. This speeds the program up a lot; used inside monte carlos where only estimates are needed
    ## %  NOTE: you must make one column of rhv a vector of ones if you want a constant. 
    ## %        should the covariance matrix estimate take out sample means?
    ## % Output:
    ## %  b: regression coefficients K x 1 vector of coefficients
    ## %  seb: K x N matrix standard errors of parameters. 
    ## %      (Note this will be negative if variance comes out negative) 
    ## %  v: variance covariance matrix of estimated parameters. If there are many y variables, the vcv are stacked vertically
    ## %  R2v:    unadjusted
    ## %  R2vadj: adjusted R2
    ## %  F: [Chi squared statistic    degrees of freedom    pvalue] for all coeffs jointly zero. 
    ## %   Note: program checks whether first is a constant and ignores that one for test
    # --------------------------------------------------------------------------------
    
    
    # ----- required packages
    library('matlab');
    
    lhv <- as.matrix(lhv)
    rhv <- as.matrix(rhv) 
    #print(lhv)
    print(nrow(lhv))
    print(nrow(rhv))
    print('Is error here 1')
    # ----- check we can do the analysis
    if (nrow(lhv) != nrow(rhv)){
      print(nrow(lhv))
      print(nrow(rhv))
      stop("# olsgmm: left and right sides must have same number of rows. Current rows are:\n",
           "  # ----- lhv .... ", nrow(lhv), "; rhv .... ", nrow(rhv), "\n")
    }
    
    # --------------------------------------------------------------------------------
    # ----- initialize
    res   = NULL
    #Ftest = matrix(NA, N, 3)
    
    lags = lags[1];
    ## weight=1 ;
    
    Tobs    = dim(rhv)[1];   # number or rows
    N       = dim(lhv)[2];   # number or columns
    K       = dim(rhv)[2];
    print(Tobs)
    print(N)
    print(K)
    #
    
    print(mean(lhv))
    print(ones(Tobs, 1))
    
    Ftest = matrix(NA, N, 3)
    print(Ftest)
    sebv    = matrix(0,K,N)
    Exxprim = solve( t(rhv) %*% rhv / Tobs);
    bv      = solve( t(rhv) %*% rhv ) %*% t(rhv) %*% lhv;
    
    # --------------------------------------------------------------------------------
    ## skip ses if you don't want them.  returns something so won't get error message
    if (weight == -1){  
      sebv    = NA;
      R2v     = NA;
      R2vadj  = NA;
      v       = NA;
      Ftest   = NA;
    }
    
    # --------------------------------------------------------------------------------
    ## now compute newey-west errors
    else {
      
      errv   = lhv - rhv %*% bv; 
      # dim(errv) [1] 1709    5
      # dim(bv)  [1] 6 5
      print(errv)
      #s2     = mean(errv^2) # dim(s2) NULL   s2 [1] 74.80025
      
      s2 =colMeans(errv^2,dim(errv))
      #EFFR      OBFR      TGCR      BGCR      SOFR 
      #33.14544  49.96864 104.78123 105.42146  80.68448 
      print(s2)
      
      #colMeans(lhv,dim(lhv))
      #EFFR     OBFR     TGCR     BGCR     SOFR 
      #108.3745 104.8578 104.4833 105.6173 108.1761 
      vary   = lhv - ones(Tobs,1) %*% colMeans(lhv,dim(lhv)); # mean(lhv) [1] 106.3018
      print(vary)
      
      # The code snippet you provided is written in R programming language. Let me break down the code for you:
      # lhv: This is a variable or a matrix that contains data. It represents the Left Hand Variable.
      # ones(Tobs, 1): This creates a column vector of ones with Tobs rows and 1 column. In R, ones() is not a built-in function, so this code is likely using a custom function or the user has defined the ones() function elsewhere in the code.
      # mean(lhv): This calculates the mean of the lhv matrix, which represents the mean of the Left Hand Variable.
      # %*%: This is the matrix multiplication operator in R.
      # Putting it all together, the code computes the variable vary, which represents the difference between the lhv matrix and the mean of the lhv matrix, where the mean is subtracted from each row of the lhv matrix. The result is a new matrix with the same dimensions as the original lhv matrix.
      # vary   = mean(vary^2);
      
      R2v    = t(1-s2/vary); # dim(R2v)  [1]    5 1709
      R2vadj = t( 1 - (s2/vary) * (Tobs-1)/(Tobs-K) );
      print(R2vadj)
      #mean(lhv)
      
      indx = 1;
      
      # Compute GMM standard errors
      while(indx <= N){
        # debug
        ## indx = 1
        
        err   = as.matrix(errv[,indx]);
        inner = t(rhv * (err %*% matrix(1,1,K) ) ) %*% (rhv * (err %*% matrix(1,1,K)) ) / Tobs;
        jindx = 1;
        
        for(jindx in seq(1, lags)){
          
          startindx = 1 + jindx; endindx = Tobs - jindx;
          inneradd  = t(rhv[1:endindx,] * err[1:endindx] %*% matrix(1,1,K)) %*% (rhv[startindx:Tobs,] * err[startindx:Tobs] %*% matrix(1,1,K)) / Tobs;
          inner     = inner + (1-weight*jindx/(lags+1)) * (inneradd + t(inneradd) );
          
        }
        
        varb = 1/Tobs * Exxprim %*% inner %*% Exxprim;
        
        # F test for all coeffs (except constant) zero -- actually chi2 test
        if (identical(as.matrix(rhv[,1]), ones(dim(rhv)[1],1))){
          chi2val         = t( bv[2:nrow(bv), indx] ) %*% solve( varb[2:nrow(bv),2:nrow(bv)]) %*% bv[2:nrow(bv), indx];
          dof             = nrow(as.matrix(bv[2:nrow(bv), 1])) 
          ## pval            = 1-cdf('chi2',chi2val, dof);
          pval            = 1 - pchisq(chi2val, dof)
          Ftest[indx,1:3] = c(chi2val, dof, pval);
        } else {
          chi2val = t(bv[,indx]) %*% solve(varb) %*% bv[,indx];
          dof     = nrow(as.matrix(bv[, 1]))
          pval            = 1 - pchisq(chi2val, dof)            
          Ftest[indx,1:3] = c(chi2val, dof, pval);            
        }
        print(Ftest)
        # -----------------------------------------------------------------------------
        if (indx == 1) {
          v = varb;
        } else {
          v = cbind(v,varb);
        }
        
        seb = diag(varb);
        seb = sign(seb) * sqrt(abs(seb));
        sebv[,indx] = seb;
        indx=indx+1;
        
      }
      
      # get results
      res$bv = bv
      res$sebv = sebv
      
      list_res <- list(bv, sebv, R2v, R2vadj, v, Ftest)
      
    } # end of else clause
    
    list_res <- list(bv, sebv, R2v, R2vadj, v, Ftest)
    print(list_res)
    return(list_res)
  }
 
#
# see Fama French  
# expected return shocks (the discount-rate effect) can combine to produce
# mean-reverting comp6nents of stock prices. Fama and French (1987a) show
# that mean-reverting price components tend to induce negative autocorrelation
# in long-horizon returns. Thus, the negative autocorrelation of long-horizon
# returns in the earlier work is consistent with the positive autocorrelation of
# expected returns documented here.
# But a mean-reve~ing, posit~ePy autoco~e!ated expected return does not
# necessarily imply negative autocorrelated returns or a mean-reverting component
# of prices. If shocks to expected returns and expected dividends are
# positively correlated, the opposite response o~' prices to expected return shocks
# can disappear. In this case, the positive autocorrelation of expected returns
# will imply positively autocorrelated returns~ and time-varying expected returns
# will not generate mean-reverting price components. Moreover, changes through
# 24 E.F. Fama and K.R. French, Dioidend yields and expected stock returns
# time in the autocorrelation of expected returns, or in the relation between
# shocks to expected returns and expected dividends, can change the time-series
# properties of returns and obscure tests of fo~ ~ ~o~ :3~we~ based on autocorrelation.

# http://www.sthda.com/english/wiki/f-test-compare-two-variances-in-r
# Compute F-test in R
# R function
# The R function var.test() can be used to compare two variances as follow:
#   
#   # Method 1
#   var.test(values ~ groups, data, 
#            alternative = "two.sided")
# # or Method 2
# var.test(x, y, alternative = "two.sided")
# 
# x,y: numeric vectors
# alternative: the alternative hypothesis. Allowed value is one of “two.sided” (default), “greater” or “less”.


#
# Poterba Summers Variance ratio test
# This statistic converges to unity if
# returns are uncorrelated through time. If some of the price variation is due to
# transitory factors, however, autocorrelations at some lags will be negative and
# the variance ratio will fall below one.
# $VR(k)=var(R^k_t)/k / var(R^{12}_t)/12
# VR(k) = k l2 ,
# k-1
# $R^k_t = \sum_(i=0)^(k-1)R_{t-i}$
# #
# see Cochrane
# Cochrane's (1988) result that the ratio of the k-month
# return variance to k times the one-month return variance is approximately
# equal to a linear combination of sample autocorrelations, (1) can be written
# $VR(k) = 1+ 2*\sum_(i=1)^(k-1)((k-i)/k)\rho_i
#-2*\sum_(i=1)^(k-1)((12-i)/12)\rho_i$
#
# R example
# Farmed.Trout <- data.frame(cbind(Trout.250, Trout.300))  # combine as data frame
# str(Farmed.Trout)
# summary(Farmed.Trout)
# with(Farmed.Trout,boxplot(Trout.250,Trout.300, 
#                           col= "lightgray",   
#                           main= "Overnight rayes",
#                           xlab= "", 
#                           ylab= "basis points (bp)", 
#                           ylim= c(0,450), 
#                           names= c("250 per pen","300 per pen"), # group names
#                           las= 1,  
#                           boxwex =0.6))
#  boxplot
# rates<- data.matrix(rrbp)
# summary(rates)
# class(rates)
# with(rrbp,boxplot(rrbp, 
#                           col= "lightgray",   
#                           main= "Overnight rates",
#                           xlab= "", 
#                           ylab= "basis points (bp)", 
#                           ylim= c(0,450), 
#                           #abline(h=quantile(rrbp,c(0.25,0.75)),col="blue"),
#                           names= c("EFFR","OBFR","TGCR","BGCR","SOFR"), # group names
#                           las= 1,  
#                           boxwex =0.6))
# 



# ------------------- VR TESTS  DO MORE )
# data(exrates)
# y <- exrates$ca
# nob <- length(y)
# r <- log(y[2:nob])-log(y[1:(nob-1)])
# Auto.VR(r)
# CORRECTION
#Apologies for the confusion in my previous response. I misunderstood your question. 
#If you are looking for alternatives to the var.test() function in R for conducting a variance test between two groups, the most commonly used alternative is the Welch's t-test (also known as the unequal variances t-test). This test allows for unequal variances between the groups and does not assume equal variances like the var.test() function doesHere's how to perform Welch's t-test in R:
# Assuming 'group1' and 'group2' are vectors containing your data for each group
#result <- t.test(group1, group2)
#print(result)

dailystat$rrbpm <- rrbp- mean_y
ratesm<-colMeans(rrbpm)
#EFFR     OBFR     TGCR     BGCR     SOFR 
#108.3327 104.8129 104.4386 105.5754 108.1339 
#[1] "matrix" "array" 
#nob <- length(ratesm)
Auto.VR(rates)n# or ratesm?
# $stat
# [1] 1346.024
# $sum
# [1] 632.9136

# rateswm<-rrbpw-colMeans(rrbpw)
# colMeans(ratesw)
# #EFFR     OBFR     TGCR     BGCR     SOFR 
# #108.3327 104.8129 104.4386 105.5754 108.1339 
# #[1] "matrix" "array" 
# nob <- length(rateswm)
# Auto.VR(rateswm)
# 
# 
# Auto.Q(ratesm[,1],1)
# #stat Automatic variance ratio test statistic
# #sum 1+ weighted sum of autocorrelation up to the optimal order
# 
# Auto.Q(rates,1)
# Auto.Q(rates,1)
#$Stat
#[1] 2994.634
#$Pvalue
#[1] 0

# Chatgpt
# Install and load the required package
# install.packages("tseries")
# library(tseries)
# Let's assume you have two datasets, one with daily data and another with weekly aggregated data. For this example, I'll generate some random data for illustration purposes.
# 
# R
# Copy code
# # Generate some random daily data (replace this with your actual daily data)
# set.seed(42)
# daily_data <- rnorm(365, mean = 10, sd = 2)
# 
# # Aggregate the daily data to weekly data
# weekly_data <- aggregate(daily_data, FUN = sum, by = as.integer(gl(length(daily_data), k = 7, length = length(daily_data))))
# 
# # Convert the weekly_data to a time series object
# weekly_ts <- ts(weekly_data$x, start = c(2022, 1), frequency = 52)
# Now that we have our daily and weekly data, let's perform the variance ratio test:
# The var.test function from the tseries package is used to perform the variance ratio test. We set lags.max = 1 to consider the first lag in the test, and alternative = "greater" indicates a one-sided test to check if the variance of the weekly data is greater than that of the daily data.
# 
# The test results will provide the p-value and the test statistic. If the p-value is smaller than a chosen significance level (e.g., 0.05), you can reject the null hypothesis, indicating that there is a significant increase in variance when aggregating the data from daily to weekly. Otherwise, you fail to reject the null hypothesis, suggesting that there is no significant increase in variance.
# R
# Copy code
# # Perform the variance ratio test for daily data
# daily_var_ratio <- var.test(daily_data, lags.max = 1, alternative = "greater")
# print(daily_var_ratio)

# Perform the variance ratio test for weekly data
#weekly_var_ratio <- var.test(weekly_ts, lags.max = 1, alternative = "greater")
#print(weekly_var_ratio)

# # Perform the variance ratio test for daily data

rrbpts <- ts(rrbp$rrbpm)
rrbpwts <- ts(rrbpw$rrbpwm)
daily_Var_ratio <- var.test(x=rrbp[,1:5], y=rrbpw[,1:5], ratio=1, alternative = "two.sided") #default
# alternative: a character string specifying the alternative hypothesis, must be one of "two.sided" (default), "greater" or "less". You can specify just the initial letter.
print(daily_var_ratio)

# Perform the variance ratio test for weekly data WRONG???
# weekly_var_ratio <- var.test(rrbpwts, lags.max = 1, alternative = "greater")
# print(weekly_var_ratio)

# variance ratios for EFFR, sample vs subset
# normalcy
column_rrbp <- rrbp$EFFR
column_norm <- normalcy$EFFR
VarratioEFFRnorm <- var.test(x = column_rrbp, y = column_norm, ratio = 1, alternative = "two.sided")
print(VarratioEFFRnorm)
testnorm <- data.frame(
  Group1_Variance = VarratioEFFRnorm$estimate[1],
  Group2_Variance = VarratioEFFRnorm$estimate[2],
  F_statistic = VarratioEFFRnorm$statistic,
  p_value = VarratioEFFRnorm$p.value
)
# Print the data frame
print(testnorm)

varnorm<-var(normalcy$EFFR)

#ERROR
varnorm<-var(normalcy$EFFR)
> varnorm
[1] 5543.292
> var(column_norm) # 856 observations
[1] 5543.292
> VarratioEFFRnorm$estimate[2]
<NA> 
  NA 
> Group1_Variance = VarratioEFFRnorm$estimate[1],
Error: unexpected ',' in "Group1_Variance = VarratioEFFRnorm$estimate[1],"
> 
  > Group1_Variance = VarratioEFFRnorm$estimate[1]
> Group1_Variance
ratio of variances 
1.738107 
> Group2_Variance = VarratioEFFRnorm$estimate[2]
> Group2_Variance
<NA> 
  NA  1.738107/5542.292
[1] 0.000313608


# adjust
column_rrbp <- rrbp$EFFR
column_y <- adjust$EFFR  #var(column_y [1] 269.6565 # 64 observations
VarratioEFFRadj <- var.test(x = column_rrbp, y = column_y, ratio = 1, alternative = "two.sided")
print(VarratioEFFRadjust)
testcovid <- data.frame(
  Group1_Variance = VarratioEFFRadjust$estimate[1],
  Group2_Variance = VarratioEFFRadjust$estimate[2],
  F_statistic = VarratioEFFRadjust$statistic,
  p_value = VarratioEFFRadjust$p.value
)
# Print the data frame
print(testadjust)


# covid
column_rrbp <- rrbp$EFFR
column_y <- covid$EFFR  # var [1] 3152.296 # 109 observations
VarratioEFFRcovid <- var.test(x = column_rrbp, y = column_y, ratio = 1, alternative = "two.sided")
print(VarratioEFFRcovid)
testcovid <- data.frame(
  Group1_Variance = VarratioEFFRcovid$estimate[1],
  Group2_Variance = VarratioEFFRcovid$estimate[2],
  F_statistic = VarratioEFFRcovid$statistic,
  p_value = VarratioEFFRcovid$p.value
)
# Print the data frame
print(testzlb)


# zlb
column_rrbp <- rrbp$EFFR
column_y <- zlb$EFFR # var 6.849695 # 484 observations
VarratioEFFRzlb <- var.test(x = column_rrbp, y = column_y, ratio = 1, alternative = "two.sided")
print(VarratioEFFRzlb)

# Extract relevant information
testzlb <- data.frame(
  Group1_Variance = VarratioEFFRzlb$estimate[1],
  Group2_Variance = VarratioEFFRzlb$estimate[2],
  F_statistic = VarratioEFFRzlb$statistic,
  p_value = VarratioEFFRzlb$p.value
)
# Print the data frame
print(testzlb)

# pi
column_rrbp <- rrbp$EFFR
column_y <- inflation$EFFR # var 16651.18 # 197 observations
VarratioEFFRpi <- var.test(x = column_rrbp, y = column_y, ratio = 1, alternative = "two.sided")
print(VarratioEFFRpi)

# Extract relevant information
testpi <- data.frame(
  Group1_Variance = VarratioEFFRpi$estimate[1],
  Group2_Variance = VarratioEFFRpi$estimate[2],
  F_statistic = VarratioEFFRpi$statistic,
  p_value = VarratioEFFRpi$p.value
)

# compare different sample sizes
column_rrbp <- rrbp$EFFR
column_k2 <- rrbp2[,1]
#column_y <- inflation$EFFR # var 16651.18 # 197 observations
Varratiok2 <- var.test(x = column_rrbp, y = column_y, ratio = 1, alternative = "two.sided")
print(Varratiok2)

# Extract relevant information
testk2 <- data.frame(
  Group1_Variance = Varratiok2$estimate[1],
  Group2_Variance = Varratiok2$estimate[2],
  F_statistic = Varratiok2$statistic,
  p_value = Varratiok2$p.value
)

# Print the data frame
print(testpi)

# # Extract relevant information
# test_result <- data.frame(
#   Group1_Variance = result$estimate[1],
#   Group2_Variance = result$estimate[2],
#   F_statistic = result$statistic,
#   p_value = result$p.value
# )
# 
# # Print the data frame
# print(test_result)


# ---------------------------------- var.test
# var.test(x, ...)
# 
# ## Default S3 method:
# var.test(x, y, ratio = 1,
#          alternative = c("two.sided", "less", "greater"),
#          conf.level = 0.95, ...)
# 
# ## S3 method for class 'formula'
# var.test(formula, data, subset, na.action, ...)

# var test 
# 1 for each epoch and whole sample
# 2 changes over k days vc changes over k-1 days

# ------------------------------ DISPERSION
# see also mean deviation

# EFFR, targets, quintiles
metricE<-data.frame(rrbp[,1],TargetDe,TargetUe,PercentileE25,PercentileE75)
str(metricE)
#metricE$EFFR<-metricE$EFFR*100;
# metricE$TargetUe<-metricE$TargetUe*100;
# metricE$TargetDe<-metricE$TargetDe*100;
# metricE$PercentileE25<-metricE$PercentileE25*100;
# metricE$PercentileE75<-metricE$PercentileE75*100;

# dailyrates_md<-ggplot(rrbp, aes(x = sdate)) +
#   geom_point(aes(y = rrbp[,1], color = "EFFR"), shape = 16, size = 1) + 
#   geom_point(aes(y = rrbp[,2], color = "OBFR"), shape = 16, size = 1) + 
#   geom_point(aes(y = rrbp[,3], color = "TGCR"), shape = 16, size = 1) + 
#   geom_point(aes(y = rrbp[,4], color = "BGCR"), shape = 16, size = 1) + 
#   geom_point(aes(y = rrbp[,5], color = "SOFR"), shape = 16, size = 1) + 
#   labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
#   scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) + 
#   theme_minimal()
# print(dailyrates_md)
#geom_ribbon(aes(ymin =PercentileE25, ymax = PercentileE75), fill = "grey70") +


quantileE<-ggplot(metricE, aes(x = sdate)) +
  geom_ribbon(aes(ymin =metricE[,4], ymax = metricE[,5]), fill = "grey70") +
                    geom_line(aes(y = EFFR, color = "EFFR"), linetype ="solid", size = 1, alpha = 1.25) + 
                                labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
                                scale_color_manual(values = c("EFFR" = "blue"))+
                                theme_minimal()
                                print(quantileE)
                                
                                targetE <-ggplot(metricE, aes(x = sdate)) +
  geom_ribbon(aes(ymin =metricE[,2], ymax = metricE[,3]), fill = "grey70") +
                    geom_line(aes(y = EFFR, color = "EFFR"), linetype ="solid", size = 1, alpha = 1.25) + 
                                labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
                                scale_color_manual(values = c("EFFR" = "blue") )+
  theme_minimal()
  print(targetE)
                                

targetE <-ggplot(metricE, aes(x = sdate, y=metricE)) +
  geom_ribbon(aes(ymin =metricE[,2], ymax = metricE[,2]), fill = grey70) +
                    geom_line(aes(y = metricE[,1], color = "EFFR"), linetype ="solid", size = 1.5, alpha = 1.25) + 
                                labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
                                scale_color_manual(values = c("EFFR" = "blue))+
                               theme_minimal()
 
# https://rpruim.github.io/s341/S19/from-class/MathinRmd.html
# Duffie Krishnamurthy dispersion index 
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




T <-nrow(rrbp)
# Initialize vtot(t) and mrate(t) to zero
# Assuming 'dk' is your data frame or matrix
# Specify the number of columns to sum (e.g., the first 5 columns)
rcol <- 5

# Initialize vectors to store results
vtot <- numeric(1710)
mrate <- numeric(1710)
meanr <- numeric(1710)
dkindex <- numeric(1710)

# Loop over rows
for (t in 1:1710) {
  # Initialize variables for this row
  vtot[t] <- 0
  mrate[t] <- 0
  
  # Loop over the first 'rcol' columns
  for (i in 1:rcol) {
    # Calculate vtot(t) and mrate(t)
    vtot[t] <- vtot[t] + dk[t, i]
    mrate[t] <- mrate[t] + dk[t, i] * rrbp[t, i]
  }
  
  # Calculate meanr(t)
  meanr[t] <- mrate[t] / vtot[t]
  
  # Calculate dk(t)
  for (i in 1:rcol) {
    dk[t, i] <- (1 / vtot[t]) * dk[t, i] * abs(rrbp[t, i] - meanr[t])
  }
  
  # Calculate dkindex(t)
  dkindex[t] <- sum(dk[t, 1:rcol])
}



# Convert the "sdate" column to a Date format
dk_data$sdate <- as.Date(dk_data$sdate, format = "%m/%d/%Y")

dk_data <- cbind(sdate, dk, dkindex,TargetDe, TargetUe)
# Convert the numeric matrix 'dk_data' to a data frame
dk_data <- data.frame(dk_data)
# Assign names to the columns of 'dk' within 'dk_data'
colnames(dk_data)[2:6] <- c("EFFR", "OBFR", "TGCR", "BGCR", "SOFR")
# Set column names for 'dk_data'
colnames(dk_data) <- c("sdate", "EFFR", "OBFR", "TGCR", "BGCR", "SOFR", "dkindex", "TargetDe", "TargetUe")



file_path<-"C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Data/indices.csv"

write.csv(dk_data, file = file_path, row.names = FALSE)

dk_data$sdate <- as.Date(dk_data$sdate, format = "%y/%m/%d)
ggdkindex<-ggplot(dk_data, aes(x = sdate)) +
  geom_point(aes(y = dk_data[,7], color = "Duffie Krishnamurthy index"), shape = 16, size = 1) + 
  geom_point(aes(y = TargetDe, color = "Lower target FFR"), shape = 16, size = 1) + 
  geom_point(aes(y = TargetUe, color = "Upper target FFR"), shape = 16, size = 1) +
 # geom_point(aes(y = rrbp[,3], color = "TGCR"), shape = 16, size = 1) + 
 # geom_point(aes(y = rrbp[,4], color = "BGCR"), shape = 16, size = 1) + 
 # geom_point(aes(y = rrbp[,5], color = "SOFR"), shape = 16, size = 1) + 
  labs(x = "X-axis", y = "Y-axis", color = "Lines") +
  scale_color_manual(values = c("Duffie Krishnamurthy index" = "black", "Lower target FFR" = "blue", "Upper target FFR" )) + 
  #scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) + 
  theme_minimal()
print(ggdkindex)


# Create the ggplot object
ggdkindex <- ggplot(dk_data, aes(x = sdate)) +
  geom_point(aes(y = dk_data[, 7], color = "Duffie Krishnamurthy index"), shape = 16, size = 1) + 
  geom_point(aes(y = TargetDe, color = "Lower target FFR"), shape = 16, size = 1) + 
  geom_point(aes(y = TargetUe, color = "Upper target FFR"), shape = 16, size = 1) +
  labs(x = "X-axis", y = "Y-axis", color = "Lines") +
  scale_color_manual(values = c("Duffie Krishnamurthy index" = "black", "Lower target FFR" = "blue", "Upper target FFR" )) + 
  scale_x_date(date_labels = "%m/%d/%Y", date_breaks = "1 month") +
  theme_minimal()

print(ggdkindex)

#https://r4ds.had.co.nz/data-visualisation.html
#https://r4ds.had.co.nz/graphics-for-communication.html


# ALonso dispersion index from target rates
# Targets quintile plots in stirregv

#The daily value of $D_t$ is the deviations between the value weighted daily 
#fed funds rate and the FOMC target, for 2017-2022.
#FF > upper target TU
Equation 1:
  $D_t = \overline{\rho}_t - \rho_{max,t}$ if $\rho_{max,t} < \overline{\rho}_t$ 
  Equation 2:
  $D_t = \overline{\rho}_t - \rho_{min,t}$ if $\overline{\rho}_t < \rho_{min,t}$ 
  
  #FF < lower target 
  Equation 3:
  D_t = \overline{\rho}_t - \rho_{min,t}$ if $\overline{\rho}_t <\rho_{min,t}$
  Equation 4:
  $D_t=0$ if $\rho_{min,t}<\overline{\rho}_t <\rho_{max,t} $
  
  # Create a data frame with the equations
  equations_df <- data.frame(Equation = c(equation1, equation2,equation3, equation4))

# Display the table
kable(equations_df, format = "latex", escape = FALSE, booktab
      
      cat("Equation 1:\n")
      cat(eq1, "\n")
      
      cat("Equation 2:\n")
      cat(eq2, "\n")
      
      cat("Equation 3:\n")
      cat(eq3, "\n")
      
      cat("Equation 4:\n")
      cat(eq4, "\n")
      
      
      # Alternative
      # Define the variables
      D_t <- 0
      rho_bar_t <- 0
      rho_max_t <- 0
      rho_min_t <- 0
      
      # Calculate D_t based on conditions
      if (rho_max_t < rho_bar_t) {
        D_t <- rho_bar_t - rho_max_t
      } else if (rho_bar_t < rho_min_t) {
        D_t <- rho_bar_t - rho_min_t
      }
      
      # Print the result
      print(D_t)
      
      #Note that you need to replace the 0 placeholders with actual numerical values for rho_bar_t, rho_max_t, and rho_min_t in your specific problem.
      
      T <- nrow(rrbp)  #rrbp(begn(k):endn(k),:),1)
      spread <- data.frame(spread, dgara = 0)
      dgaraa<-  select(spread,dgara)
      nrow(dgaraa) #[1] 1710
      
      
      # Loop from t = 524 to the size of dgara
      # Start the for loop at position 520
      # Loop body - do something with my_vector[i]# Start the for loop at position 5
      # for (i in 5:length(my_vector)) {
      #   # Loop body - do something with my_vector[i]
      #   print(my_vector[i])
      # }
      
      for (i in 520:T) 
      {
        print(targetbp[i,])
        print(rrbp[i,])
      }
      
      > nrow(dgaraa)
      begn<-  520
      for (t in 520:nrow(dgaraa)) {
        if (rrbp[t, 1] > targetbp[t, 2]) {
          dgaraa[t,1] <- rrbp[t, 1] - targetbp[t, 2] } # greater than TU
        else if (rrbp[t, 1] < targetbp[t, 1]) {
          dgaraa[t,1] <- rrbp[t, 1] - targetbp[t, 1] }  # less than TD
      }
      
      # ------------------- OLD MATLAB
      # dgara = zeros(T,1);
      # % targets start at line 525 3/29/2018 0:00	1.68	102	1.75	1.5
      # % t= 524
      # targetbp = target*100;
      # for t =524:size(dgara,1)
      # if rrbp(t,1)>targetbp(t,1) % greater than TU
      # dgara(t) = rrbp(t,1)-targetbp(t,1);
      # elseif rrbp(t,1)<targetbp(t,2) % less than TD
      # dgara(t) = rrbp(t,1)-targetbp(t,2)*100;
      # end
      # end
      # % Test
      # chk = [dgara(620:850) rrbp(620:850,1) targetbp(620:850,1) targetbp(620:850,2)];
      
      # Test
      chk <- cbind(dgara[620:850], rrbp[620:850, 1], targetbp[620:850, 1], targetbp[620:850, 2])
      
      

# ------------------GARCH Models:
# Alternatively, you can model the time series using GARCH (Generalized Autoregressive Conditional Heteroskedasticity) models to explicitly capture changes in volatility over time. The "rugarch" package in R provides functions for fitting GARCH models.
# R
# Copy code
# # Assuming 'returns' is a vector containing the returns of the time series
# library(rugarch)
# garch_model <- ugarchspec(variance.model = list(model = "sGARCH"))
# garch_fit <- ugarchfit(garch_model, data = returns)

# Prepare your time series data. Assuming you have a vector named returns containing the returns of your time series:
#   
#   Specify the EGARCH model:
#   
#   R
# Copy code
# egarch_spec <- ugarchspec(variance.model = list(model = "eGARCH"), mean.model = list(armaOrder = c(0, 0)))
# In this example, we are specifying a pure EGARCH model without an ARMA mean component. You can adjust the armaOrder argument to include an ARMA mean component if needed.
# 
# Fit the EGARCH model to the data:
#   R
# Copy code
# egarch_fit <- ugarchfit(spec = egarch_spec, data = returns)
# Examine the model summary and output:
#   R
# Copy code
# show(egarch_fit)
# The model summary will display the estimated parameters, standard errors, log-likelihood, and other relevant information about the EGARCH model fit to your data.
# 
# Analyze the model residuals and check for goodness-of-fit:
#   R
# Copy code
# # Extract the residuals from the model fit
# residuals <- residuals(egarch_fit)
# 
# # Plot the residuals to check for patterns and autocorrelation
# plot(residuals)
# 
# # Conduct Ljung-Box test to assess residual autocorrelation
# Box.test(residuals, lag = 20, type = "Ljung-Box")
# The Box.test function tests the null hypothesis that the residuals are independently distributed.
# 
# Remember that fitting and interpreting time series models, including EGARCH models, require careful consideration of the underlying data and potential model assumptions. It's essential to validate the model and assess its adequacy for your specific use case.

egarch_spec <- ugarchspec(variance.model = list(model = "eGARCH"), mean.model = list(armaOrder = c(0, 0)))
egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbpts)
egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbpts)
residuals <- residuals(egarch_fit)
plot(residuals)
Box.test(residuals, lag = 20, type = "Ljung-Box")



# Create a data frame with the equations
dispersion <- data.frame(disp = c(rrbp[,1],spread$PercentileE25*100, spread$PercentileE75*100, spread$TargetUE*100,spread$TargetDE*100,dk, dgaraa))
# quantileeffr=select(spread,Percentile1,Percentile25,Percentile75,Percentile99)
# plot dispersion indices
#metricE<-select(spread,EFFR,TargetDe,TargetUe,PercentileE25,PercentileE75,spread$dk)
#metricE$TargetDe<-metricE$TargetDe*100


# ylim= c(0,450)
#geom_area(aes(y = y1, fill = "Area between y1 and y2"), alpha = 0.5) +
#geom_line(aes(y = y1), color = "blue") +
#geom_line(aes(y = y2), color = "red") +

geom_area(aes(y = metricE[,4]*100, fill = "Area between 25th and 75th percentile"), alpha = 0.5) +
geom_line(aes(y = metricE[,4]*100), color = "blue") +
geom_line(aes(y = metricE[,5]*100), color = "red") +

# stack overflow
# ymin = pmin(data$adjusted[data$symbol == "AAPL"], data$adjusted[data$symbol == "MSFT"]),
# max = pmax(data$adjusted[data$symbol == "AAPL"], data$adjusted[data$symbol == "MSFT"]),
#   # Then, we'll save a variable for which observations to keep
#   keep = data$adjusted[data$symbol == "AAPL"] > data$adjusted[data$symbol == "MSFT"]
ymin<-pmin(metricE[,4]*100="25 pct")
ymax<-pmax(metricE[,5]*100="75 pct")


ggplot(metricE, aes(x = sdate)) +
  geom_line(aes(y = metricE[,1], color = "EFFR", linetype ="solid", linewidth = 1.5, alpha = 1.25) + 
  geom_area(aes(y = metricE[,2]*100, "Area between upper and lower target rate"), alpha = 0.5) +
  geom_line(aes(y = metricE[,2]*100), color = "grey") +
  geom_line(aes(y = metricE[,3]*100), color = "grey") +
  #geom_line(aes(y = metricE[,2], color = "TargetDe",linetype ="dotted" , linewidth = 1) + 
  #geom_line(aes(y = metricE[,3], color = "TargetUe",linetype = "dotted", linewidth = 1) +
  labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
  #ylim= c(0,450)+
  scale_color_manual(values = c("EFFR" = "black","Lower target" = "green","Upper target" = "blue" )) + 
  theme_minimal()
 
  #scale_x_date(labels = date_format("%Y-%m-%d")) +
  #scale_x_date(labels = date_format("%Y-%m-%d")) +

#linetype = 
#geom_point(aes(y = dispersion[,4], color = "Duffie,Krishnamurthy"), shape = 16, size = 1) + 
#geom_point(aes(y = dispersion[,5], color = "Alonso et al"), shape = 16, size = 1) + 
#scale_color_manual(values = c("EFFR" = "black", "25 pct" = "grey", "75 pct" = "grey", "Duffie,Krishnamurthy" = "blue", "Alonso et al" = "green")) + 



% EFFR
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(rrbp(begn(k):endn(k),1)):25:max(rrbp(begn(k):endn(k),1))];
%a1 = subplot( 1, 2, 1 );
yyaxis left
hE = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),1)) %,'LineStyle', 'none');
hold on
ylim ([0 450])
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100);
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100);
hold on
hYLabel=ylabel('basis points');
yyaxis right
hG = plot(sdate(begn(k):endn(k)),dgara(:,1)) %,'LineStyle', 'none');
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h1=[hE hG hL hU];
hLegend = legend(h1,'EFFR','Index','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
# --------------------------------------------------------------------------
# use filter or slice to define eopchs
#
# plot  year ny=1
#2017  213   463  {'1/3/2017'} - '12/29/2017'}
#2018  464   712  {'1/2/2018'} - {'12/31/2018'} 
#2019  713   963  {'1/2/2019'} - {'12/31/2019'}    
#2020  964  1214  {'1/2/2020'} - {'12/31/2020'}    
#2021 1215  1465  {'1/4/2021'} - {'12/31/2021'}  
#2022 1466  1714  {'1/3/2022'} - {'12/29/2022'} 

# ------------ Notes
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
#}
#
# A version of this package for your version of R might be available elsewhere,
#see the ideas at  <rugarch>
#https://cran.r-project.org/doc/manuals/r-patched/R-admin.html#Installing-packages
#Warning in install.packages :
#unable to access index for repository https://cran.rstudio.com/bin/windows/contrib/4.3:
#  cannot open URL 'https://cran.rstudio.com/bin/windows/contrib/4.3/PACKAGES'
#
# install.packages("ggplot2")
# install.packages("cowplot")
# As you can see, the ggplot2 code is a bit more complicated:
#  library(ggplot2)
# p <- ggplot(stations,
#            aes(x = longitude,
#                y = latitude,
#                color = city)) +
#  geom_point()
# print(p)
# ggsave("stations.png",p,dpi = 200)
# ggsa


#https://www.statology.org/variance-ratio-test-in-r/
#https://saestatsteaching.tech/section-varianceratio