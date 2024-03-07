# Loading
#library("dplyr")
library(tidyverse)
library(dslabs)
library(lubridate)
library(rugarch)
library(xts)
library(rmgarch)
#library(mgarch)
library(fGarch)
library(xtable)

# --------------- READ DATA ------------------
spreads=  read.csv("C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedReferenceRates_1142024v2.csv",header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE)
# Assuming 'variable_to_delete' is the name of the variable to be deleted
spread <- subset(spreads, select = -c(SOFR.1,EFFR.1))
# Convert to numeric and replace non-numeric values with NA
spread$IORR <- as.numeric(as.character(spread_no_na$IORR))
spread$IORR[is.na(spread_no_na$IORR) | spread_no_na$IORR == "#N/A"] <- NA
spread$RRPONTSYAWARD <- as.numeric(as.character(spread$RRPONTSYAWARD))
spread$RRPONTSYAWARD [is.na(spread$RRPONTSYAWARD) | spread$RRPONTSYAWARD  == "#N/A"] <- NA
print(colnames(spread))
str(spread)
#sdate <- as.Date(date_vector, format = "%m/%d/%Y")
sdate<-as.Date(spread$Date,format="%m/%d/%Y")

# Find the row number for the beginning and end dates of the sample: where  "3/4/2016" occurs and 12/29/2022 for the first time
# Check which index corresponds to the specified dates
begs <- which(sdate == as.Date("2016-03-04")) 
ends <- which(sdate == as.Date("2023-12-14")) 
print(begs) #[1] 4
print(ends) #[1] 1960
spread=spread[begs:ends,]
sdate=sdate[begs:ends]
str(spread)

spread_no_na <- spread
spread_no_na <- mutate(spread_no_na, sdate = as.Date(Date, format = "%m/%d/%Y"))
spread_no_na[is.na(spread_no_na)] <- 0
columns_to_exclude <- c("Date","sdate", "VolumeEFFR","VolumeOBFR","VolumeTGCR", "VolumeBGCR","VolumeSOFR")  # Add other column names to exclude
# Check spread before mutating to see if variables are in basis points
spread_no_na <- spread_no_na %>%
  #mutate(across(-all_of(columns_to_exclude), ~ . *0.01))
  mutate(across(.cols = -columns_to_exclude, ~ . * 100))
str(spread_no_na)

# Create a new environment
my_envrates <- new.env()
# Store your data frame in the environment
my_envrates$spread_no_na <-spread_no_na

                  

# FIND THIS FILE
#mshocks=read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv8.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE,skip=4));
#class(spread)
#mshocks %>% replace(is.na(.),0)
#str(mshocks)

# Daily data frames overnight rates and volumes -rrbp and vold------------------------
# rrbp daily volume weighted median overnight reference rates
rrbp <-  spread_no_na[, c("sdate","EFFR","OBFR","TGCR","BGCR","SOFR")]
head(rrbp)
str(rrbp)

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
iorsofr<-spread_no_na$IORR-spread_no_na$SOFR;
rrppsofr<-spread_no_na$RRPONTSYAWARD-spread_no_na$SOFR;

# target<- select(spread,TargetDe,TargetUe);
vdsum <- colSums(vold[, sapply(vold, is.numeric)], na.rm = TRUE)
# VolumeEFFR VolumeOBFR VolumeTGCR VolumeBGCR VolumeSOFR 
# 154338     415674     579310     607225    1471252        



# Quantiles -------------------------------------------
# Define a color palette  FOLLOW EXAMPLE FOR RRBP
# my_color_palette <- c("EFFR" = "darkblue", "OBFR" = "darkgreen", "TGCR" = "darkred", "BGCR" = "darkcyan", "SOFR" = "darkorange")

quantilesE <- spread_no_na[, c("Date", "EFFR", "VolumeEFFR", "TargetUe_EFFR", "TargetDe_EFFR", "Percentile01_EFFR", "Percentile25_EFFR", "Percentile75_EFFR", "Percentile99_EFFR")]
quantilesO <- spread_no_na[, c("Date", "OBFR", "VolumeOBFR", "Percentile01_OBFR", "Percentile25_OBFR", "Percentile75_OBFR", "Percentile99_OBFR")]
quantilesT <- spread_no_na[, c("sdate","TGCR","VolumeTGCR","Percentile01_TGCR","Percentile25_TGCR","Percentile75_TGCR","Percentile99_TGCR")]
quantilesB <- spread_no_na[, c("sdate","BGCR","VolumeBGCR","Percentile01_BGCR","Percentile25_BGCR","Percentile75_BGCR","Percentile99_BGCR")]
quantilesS <- spread_no_na[, c("sdate","SOFR","VolumeSOFR","Percentile01_SOFR","Percentile25_SOFR", "Percentile75_SOFR", "Percentile99_SOFR")]


# plot daily sample rates
#
# plot daily sample volumes
#
# plot daily epoch rates
#begn = [4 860 924  1033 1517 4];
#endn = [859 923 1032 1516 1714 1714];
#1. normalcy   3/4/2016		7/31/2019      4  859
#2. mid cycle adjustment 8/1/2019 - 10/31/2019 737660 
#860 - 923
#3. covid 11/1/2019	    3/16/2020   924  1032
#4. zlb         3/17/2020- 3/16/2022     1032-1516
#4. Taming inflation 03/17/2022 - 12/29/2022 1517-1714
#NO! inflation   5/5/2022		12/29/2022 1517  1714
# Redo -3 for each position for nrow=1710
normalcy <-rrbp %>% slice(4:859)
adjust <-rrbp %>% slice(860:923)
covid <-rrbp %>% slice(924:1032)
zlb <-rrbp %>% slice(1032:1516)
inflation <-rrbp %>% slice(1517:1714)


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
  # 
  # While GARCH, FIGARCH and stochastic volatility models propose statistical
  # constructions which mimick volatility clustering in financial time series, they
  # do not provide any economic explanation for it.
  # 
  # Duffie Among our other explanatory variables are measures of the volatility of the federal funds rate and of the 
  # strength of the relationship between pairs of counterparties. In
  # to capture the volatility of the federal funds rate, we start with 
  # a dollar-weighted average during a given minute t of the interest rates of all loans made in that minute. 
  # We then measure the time-series sample standard deviation of these minute-by-minute average rates 
  # over the previous 30 minutes, denoted or(t). 
  # The median federal funds rate volatility is about 3 basis points, but ranges from under 1 basis point to 87 basis points, with a sample standard deviation of 4 basis points. Our measure of sender-receiver relationship strength for a particular pair (i,j) of counterparties, denoted Sij, is the dollar volume of transactions sent by i to j over the previous month divided by the dollar volume of all trans- actions sent by i to the top 100 institutions. The receiver-sender relationship strength Rij is the dollar volume of transactions received by i from j over the previous month divided by the dollar volume of all transactions received by i from
  # 
  # The formal definition of the primary metric I study, market volatility, is the standard deviation of 1
  # minute returns: s
  # ⌃Ni
  # =sqrt(sum 1 through n(ri -rbar)^2/(n-1))
  


measure1 = zeros(endn(k),5);
measure2 = zeros(endn(k),5);
measure3 = zeros(endn(k),5);
measure4 = zeros(endn(k),5);

# my_vector <- rep(0, 5)

# Define the dimensions of the matrices
# k <- 10  # Replace with the desired value for 'k'
# n <- 5   # Replace with the desired value for 'n'
# 
# # Create the matrices filled with zeros
# measure1 <- matrix(0, nrow = k, ncol = n)
# measure2 <- matrix(0, nrow = k, ncol = n)
# measure3 <- matrix(0, nrow = k, ncol = n)
# measure4 <- matrix(0, nrow = k, ncol = n)


# x <- 10
# if (x > 15) {
#   print("x is greater than 15")
# } else if (x > 5) {
#   print("x is greater than 5 but not greater than 15")
# } else {
#   print("x is not greater than 5")
# }


if(rates == 1)
{ #measure1(begn(k)+1:endn(k),:) = abs(rrbp(begn(k)+1:endn(k),:)-rrbp(begn(k):endn(k)-1,:));
#measure2(begn(k)+1:endn(k),:) = abs(rrbp(begn(k)+1:endn(k),:)-rrbp(begn(k)+1:endn(k)-1,3));
measure1 <- log(rrbp(begn(k)+1:endn(k),))-log(rrbp(begn(k):endn(k)-1,));
measure2 <-  std(measure1)  #(:,1:5))
measure3  <-  movstd(measure1,244)}
elseif (rates ==0) {
measure1(begn(k)+1:endn(k),)  <-  abs(vold(begn(k)+1:endn(k),)-rrbp(begn(k):endn(k)-1,));
measure2(begn(k)+1:endn(k),)  <-  abs(vold(begn(k)+1:endn(k),)-rrbp(begn(k)+1:endn(k)-1,3));
measure3(begn(k)+1:endn(k),)  <-  log(vodl(begn(k)+1:endn(k),))-log(rrbp(begn(k):endn(k)-1,))}


# What is this?
volrates1(begn(k)+1:endn(k),)  <-  measure3(begn(k)+1:endn(k),); # log pct change
volrates2(begn(k)+1:endn(k),2)  <-  movstd(measure(,2),252);
volrates3(begn(k)+1:endn(k),)  movstd(measure3(begn(k)+1:endn(k),),252);

# ---------------------- EGARCH model



# 1) ------------------- univariate garch
simpleegarch_spec <- ugarchspec(variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
                       mean.model = list(armaOrder = c(0, 0)),
                       distribution.model = "norm")


# Define the EGARCH model specification
# egarch_spec <- ugarchspec(
#   variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
#   mean.model = list(armaOrder = c(0, 0)),
#   distribution.model = "std"
# )

## Fit the EGARCH model to your financial data
#egarch_fit <- ugarchfit(spec = egarch_spec, data = your_returns_data)

simple_fit<-ugarchfit(spec=simpleegarch_spec,data=rrbp,solver="hybrid")
# View model summary
summary(simple_fit)


forecast<-ugarchforecast(simple_fit,data=rrbp,n.ahead=22)
egarch30d<-mean(forecast@forecast$sigmaFor)*sqrt(252)
# see stockoverflow
# y ~ x + I(x^2)

# 2) ------------------- Multivariate garch - simple
# Create a multivariate specification for five assets
  multireturn_spec <- rmgarchspec(
    variance.model = list(model = c("eGARCH", "eGARCH"), garchOrder = c(1, 1)),
    distribution.model = "mvnorm"
  )

# Combine the returns data into a multivariate time series
#multivariate_returns <- merge(asset1_returns, asset2_returns)
#multivariate_returns <- merge(rrbp[,1],rrbp[,2],rrbp[,3],rrbp[,4],rrbp[,5])
# Assuming rrbp is a data frame with multiple columns
# For example, columns 1 to 5 are the returns of different assets

# Extract the relevant columns
effr <- rrbp[, 1]
obfr <- rrbp[, 2]
tgcr <- rrbp[, 3]
bgcr <- rrbp[, 4]
sofr <- rrbp[, 5]

# Combine the returns into a multivariate data frame
multivariate_returns <- data.frame(
  effr,
  obfr,
  tgcr,
  bgcr,
  sofr
)

# Create an xts object with the time index
multivariate_returns_xts <- xts(multivariate_returns, order.by = sdate)


# Create a multivariate DCC-GARCH model specification
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

conditional_correlation <- rcor(multifit)
parameter_estimates <- coef(multifit)
log_likelihood <- logLik(multifit)
str(multifit)

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

penalty<-1- rrbp[,k[1]]/discount;

multivariate_returns3 <- data.frame(
  effr,
  obfr,
  tgcr,
  bgcr,
  sofr,
  penalty,
  dkindex,
  iorsofr,
  rrppsofr,
  
)


# Create an xts object with the time index
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
  $ -\omega h_t -\psi \nu_t -(1+\gamma N_t)$. Add day if maintenance period effects
equation1_result <- -omega * h_t - psi * nu_t - (1 + gamma * N_t)

                                                                                            
#The resulting variance for the FFR is
#4
equation2_result <- log(sigma2_t - omega * h_t - psi * nu_t - (1 + gamma * N_t)) == 
  sigma2_t_minus_1 - omega * h_t_minus_1 - psi * nu_t_minus_1 - 
  (1 + gamma * N_t_minus_1) + alpha * abs(nu_t_minus_1) + Theta * nu_t_minus_1

    $$log(\sigma^2_t -\omega h_t -\psi \nu_t -(1+\gamma N_t)=\sigma^2_{t=1}  -\omega h_{t-1} -\psi \nu_{t-1}  -(1+\gamma N_{t-1} )+\alpha \abs(\nu_{t-1} ) + \Theta \nu_{t-1} 
                                                                                                  
#Assume t distributions for innovations $\nu$
# Obtain maximum likelihood of the parameters, including the degrees of freedom of the t distribution,  by numerical optimization

# -------------------- SIMPLE MODELS
xx1=[rrbp(begn(k)+1:endn(k),:)];
xx2=[rrbp(begn(k)+1:endn(k),:) SOFR_IOR(begn(k)+1:endn(k)) EFFR_IOR(begn(k)+1:begn(k)) ONRRP_IOR(begn(k)+1:begn(k))]
xx3=[rrbp(begn(k)+1:endn(k),:) IOR(begn(k)+1:endn(k)) ONRRP(begn(k)-1:endn(k))]
%be=rrbp(begn(k):endn(k)-1,1)/rrbp(begn(k)+1:endn(k),1)
%
% Rates
[theta1,sec1,R2,R2adj,vcv,F1] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx1,nlag,nw);  % constant
%param1 = [theta1 sec1,R2,R2adj,F1]
vcv1

[theta2,sec2,R2,R2adj,vcv,F2] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx2,nlag,nw);  % constant
%param2 = [theta2 sec2,R2,R2adj,F2]
vcv

[theta3,sec3,R2,R2adj,vcv,F3] = olsgmm(rrbp(begn(k):endn(k)-1,:), xx2,nlag,nw)
%param3 = [theta3 sec3 R2,R2adj,vcv,F3]

# ------------ Bertolini EFARCH
The resulting variance for the FFR is

r <-rrbp
mu <-mean(r)
rstar <- targetbp
aigma2 <- square(r-mu)
$$log(\sigma^2_t -\omega h_t -\psi \nu_t -(1+\gamma N_t)=\sigma^2_{t=1}  -\omega h_{t-1} -\psi \nu_{t-1}  -(1+\gamma N_{t-1} )+\alpha \abs(\nu_{t-1} ) + \Theta \nu_{t-1} 
      
      
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
# 
# # Conduct Ljung-Box test to assess residual autocorrelation
# Box.test(residuals, lag = 20, type = "Ljung-Box")
# The Box.test function tests the null hypothesis that the residuals are independently distributed.
# 
# Remember that fitting and interpreting time series models, including EGARCH models, require careful consideration of the underlying data and potential model assumptions. It's essential to validate the model and assess its adequacy for your specific use case.

# egarch_spec <- ugarchspec(variance.model = list(model = "eGARCH"), mean.model = list(armaOrder = c(0, 0)))
# egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbpts)
# egarch_fit <- ugarchfit(spec = egarch_spec, data = rrbpts)
# residuals <- residuals(egarch_fit)
# plot(residuals)
# Box.test(residuals, lag = 20, type = "Ljung-Box")

      
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
#}


