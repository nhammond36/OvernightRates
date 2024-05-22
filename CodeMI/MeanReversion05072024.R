# Loading
          
library("plyr")
library(tidyverse)
library(ggplot2)
library(knitr)
library(xtable)
library(dslabs)
#library('matlab')
#library(lubridate)
library(kableExtra)
library(quarto)
library(zoo)
library(gridExtra)
#library(e1071)
#library(ggridges)
#library(viridis)
#library(Rfast)
#library(car)
#library(MASS)
library(fitdistrplus)
library(reshape2)
library(patchwork)
library(ggpubr)
library(cowplot)
library(caTools)
library(httpuv)
# ------------------- Set up git -----------------------------
# https://hansenjohnson.org/post/sync-github-repository-with-existing-r-project/
#X/ONrates11182023.rmd"

# Check existing permissions
existing_permissions <- file.access(file_path)

# Grant read permissions
# Rmd file
file_path <- "C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11182023.rmd"

# Replace spaces with escaped spaces
file_path_quoted <- shQuote(file_path)

# Grant read permissions using icacls
command <- paste("icacls", file_path_quoted, "/grant", shQuote("Everyone:(R)"), collapse = " ")
system(command, intern = TRUE)

# code 
file_path <- "C:/Users/Owner/Documents/Research/MonetaryPolicy/Code/CodeMI/MeanReversion11112023nogmmgit.r"
# Grant read permissions using icaclsCode
command <- paste("icacls", file_path_quoted, "/grant", shQuote("Everyone:(R)"), collapse = " ")
system(command, intern = TRUE)

# Commit the changes
#git commit -m "Add MeanReversion11112023nogmmgit.r"

# Push changes to remote repository
# git push origin master
# git remote get-url origin
# git branch
# --------------------------------------------

# Initialize a Git repository ---------------------
system("git init")

# Add a specific file to Git in terminal
file_path <- "C:/Users/Owner/Documents/Research/MonetaryPolicy/Code/CodeMI/MeanReversion11112023nogmmgit.r"
#git add path/to/your/file.R
#git add "C:/Users/Owner/Documents/Research/MonetaryPolicy/Code/CodeMI/MeanReversion11112023nogmmgit.r"
#git add C:/Users/Owner/Documents/MonetaryPolicy/MPResults/LaTeX/ONrates11182023.rmd

# reset git  git config --global user. email "you@example.comgmail
# Create external environment for dataframes used in tables, plots for RMD files

# Send dataframe data to rmarkdown--------------------------------
# Create a new environment
my_envmp <- new.env()

# Store your data frame in the environment
my_envmp$spread_no_na <-spread_no_na

# Save the environment to an RDS file
#saveRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/my_environmentmp.RDS")
saveRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envmp.RDS")

# Render the R Markdown document
#rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11292023b.Rmd",envir= my_envmp)
rmarkdown::render("C:/Users/Owner/Documents/Research/OvernightRates/ONrates03072024v3.Rmd",envir= my_envmp)

# my_env$bondcoupon <- bondcoupon
my_data<- my_envmp$spread_no_na
str(my_data)

# rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11292023.Rmd", clean = TRUE)



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
filepath<-"C:/Users/Owner/Documents/Research//MonetaryPolicy/Data/Final data file
spread <- read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedReferenceRates_1142023v2.csv', header = TRUE, sep = ",", dec = ".", stringsAsFactors = FALSE)
colnames(spread) <- names(spread)
print(colnames)
sdate<-as.Date(spread$Date,"%m/%d/%Y")

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

# Environments ---------------------------------------
my_env <- new.env()
my_envmp$spread_no_na <-spread_no_na
saveRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_environmentmp.RDS")
#  rmarkdown::render("C:/Users/Owner/Documents/Research/OvernightRates/ONrates03142024draft.Rmd",envir= my_envmp)

my_envepisodes <- new.env()

# -------------------------------
# 'data.frame':	1957 obs. of  36 variables:
#  $ Date             : chr  "3/4/2016" "3/7/2016" "3/8/2016" "3/9/2016" ...
#  $ EFFR             : num  36 36 36 36 36 36 36 37 37 37 ...
#  $ OBFR             : num  37 37 37 37 37 37 37 37 37 37 ...
#  $ TGCR             : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ BGCR             : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ SOFR             : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile01_EFFR: num  34 34 32 34 35 35 35 35 35 36 ...
#  $ Percentile01_OBFR: num  25 15 25 25 25 25 25 29 28 15 ...
#  $ Percentile01_TGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile01_BGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile01_SOFR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile25_EFFR: num  36 36 36 36 36 36 36 36 36 36 ...
#  $ Percentile25_OBFR: num  36 36 36 36 36 36 36 36 36 36 ...
#  $ Percentile25_TGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile25_BGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile25_SOFR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile75_EFFR: num  37 37 37 37 37 37 37 37 37 37 ...
#  $ Percentile75_OBFR: num  37 37 37 37 37 37 37 37 37 37 ...
#  $ Percentile75_TGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile75_BGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile75_SOFR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile99_EFFR: num  52 50 50 52 75 50 50 50 50 50 ...
#  $ Percentile99_OBFR: num  43 43 42 43 43 43 43 42 42 42 ...
#  $ Percentile99_TGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile99_BGCR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Percentile99_SOFR: num  0 0 0 0 0 0 0 0 0 0 ...
#  $ TargetDe_EFFR    : num  25 25 25 25 25 25 25 25 25 25 ...
#  $ TargetDe_SOFR    : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ TargetUe_EFFR    : num  50 50 50 50 50 50 50 50 50 50 ...
#  $ TargetUe_SOFR    : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Volume_EFFR      : int  75 72 72 75 72 68 67 67 63 63 ...
#  $ Volume_OBFR      : int  325 320 327 322 331 314 304 302 299 306 ...
#  $ Volume_TGCR      : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Volume_BGCR      : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Volume_SOFR      : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ sdate            : Date, format: "2016-03-04" "2016-03-07" "2016-03-08" "2016-03-09" ...

# The effective federal funds rate (EFFR) is calculated as a volume-weighted median of overnight federal funds transactions reported in the FR 2420 Report of Selected Money Market Rates. 
# The New York Fed publishes the EFFR for the prior business day on the New York Fed’s website at approximately 9:00 a.m.
# For more information on the EFFR’s publication schedule and methodology, see Additional Information about Reference Rates Administered by the New York Fed
# ($Billions)	TARGET RATE/RANGE
# (%)
#
# Revised
# 1 Rate was calculated with reduced volume
# 2 EFFR, OBFR: Rate was calculated using brokered data
# TGCR, BGCR, SOFR: Rate was calculated using survey data
# 3 Because of insufficient current data, the published rate is a republication of the prior day's rate
# https://www.newyorkfed.org/markets/reference-rates/additional-information-about-reference-rates

# If the New York Federal Reserve only publishes medians and percentiles, you can still estimate the standard deviation, skewness, and kurtosis using statistical methods and assumptions based on these summary statistics. Here's how you can proceed:
# see 9/30/2023 version of meanreersion code


# Daily data frames overnight rates and volumes -rrbp and vold------------------------
# rrbp daily volume weighted median overnight reference rates
rrbp <-  spread_no_na[, c("sdate","EFFR","OBFR","TGCR","BGCR","SOFR")]
head(rrbp)
rrbp <- subset(rrbp, select = -OBFR)
rrbp$sdate<-sdate
str(rrbp)
rrbp[1650:1711,]

secured <-  spread_no_na[, c("sdate","TGCR","BGCR","SOFR")]
str(secured)

# 'data.frame':	1711 obs. of  6 variables:
#   $ sdate: Date, format: "2016-03-04" "2016-03-07" "2016-03-08" "2016-03-09" ...
# $ EFFR : num  37 37 37 37 37 37 37 37 37 37 ...
# $ OBFR : num  29 29 29 29 29 29 29 29 29 29 ...
# $ TGCR : num  28 28 28 28 28 28 28 28 28 28 ...
# $ BGCR : num  34 34 34 34 34 34 34 34 34 34 ...
# $ SOFR : num  37 37 37 37 37 37 37 37 37 37 ...

# vold daily volumes 
vold <- spread_no_na[, c("sdate","VolumeEFFR", "VolumeOBFR", "VolumeTGCR", "VolumeBGCR", "VolumeSOFR" )]
head(vold)
vold$sdate <- as.Date(rrbp$sdate)
vold <- subset(vold, select = -VolumeOBFR)
str(vold)

# DAILY DATA Plots and sample stats for sample  ------------------------------------------
k=6 
bgn<-1 #begn[k]
edn<-nrow(rrbp) #endn[k]
print(bgn)
print(edn)
sdatesample<-sdate[bgn:edn]
str(rrbp)

meltrrbp <- melt(rrbp,id="sdate")
maxr<-max(rrbp[,2:ncol(rrbp)])
 ratests_sample <- ggplot(meltrrbp,aes(x=sdate,y=value,colour=variable,group=variable)) + 
   geom_point(size = 1) +
   labs(x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
   scale_y_continuous(breaks = seq(0,maxr, by = 50), limits = c(0,maxr)) + 
   theme_minimal() +                  
  guides(shape = guide_legend(title = "Rate"))
   print(ratests_sample)
   my_envepisodes$ratests_sample<-ratests_sample
 ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/dailyrates.pdf")
 ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/dailyrates.png")
 
 meltsecured <- melt(secured,id="sdate")
 securedrates <- ggplot(meltsecured,aes(x=sdate,y=value,colour=variable,group=variable)) + 
   geom_point(size = 1) +
   labs(x="Date",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
   scale_y_continuous(breaks = seq(0, 500, by = 50), limits = c(0, 500)) + 
   theme_minimal() +
  guides(shape = guide_legend(title = "Rate"))
 print(securedrates)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/securedratesdot2.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/securedratesdot2.png")

grid_sample <- grid.arrange(rates, securedrates,ncol = 1)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/sample2.png", grid_allrates, width = 12, height = 8, dpi = 300)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/sample2.png", width = 12, height = 8, dpi = 300)
grid_sample <- grid.arrange(quantileseffr, quantilessofr,ncol = 1)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/sample.png", grid_allquantiles, width = 12, height = 8, dpi = 300)
 
# Quantiles -------------------------------------------
# my_color_palette <- c("EFFR" = "darkblue", "TGCR" = "darkred", "BGCR" = "darkcyan", "SOFR" = "darkorange")

quantilesE<-spread_no_na[, c("sdate","EFFR","VolumeEFFR","TargetUe","TargetDe","Percentile01_EFFR","Percentile25_EFFR","Percentile75_EFFR","Percentile99_EFFR")]
quantilesO<-spread_no_na[, c("sdate","OBFR","VolumeOBFR","Percentile01_OBFR","Percentile25_OBFR","Percentile75_OBFR","Percentile99_OBFR")]
quantilesT<-spread_no_na[, c("sdate","TGCR","VolumeTGCR","Percentile01_TGCR","Percentile25_TGCR","Percentile75_TGCR","Percentile99_TGCR")]
quantilesB<-spread_no_na[, c("sdate","BGCR","VolumeBGCR","Percentile01_BGCR","Percentile25_BGCR","Percentile75_BGCR","Percentile99_BGCR")]
quantilesS<-spread_no_na[, c("sdate","SOFR","VolumeSOFR","Percentile01_SOFR","Percentile25_SOFR","Percentile75_SOFR","Percentile99_SOFR")]

my_envepisodes$quantilesE<-quantilesE
#str(my_envepisodes$quantilesO<-quantilesO
my_envepisodes$quantilesT<-quantilesT
my_envepisodes$quantilesB<-quantilesB
my_envepisodes$quantilesS<-quantilesS
# str(quantilesE)
# str(quantilesO)
# str(quantilesT)
# str(quantilesB)
# str(quantilesS)

print(colnames(spread_no_na))
#  [1] "Date"              "EFFR"              "OBFR"              "TGCR"              "BGCR"             
#  [6] "SOFR"              "Percentile01_EFFR" "Percentile01_OBFR" "Percentile01_TGCR" "Percentile01_BGCR"
# [11] "Percentile01_SOFR" "Percentile25_EFFR" "Percentile25_OBFR" "Percentile25_TGCR" "Percentile25_BGCR"
# [16] "Percentile25_SOFR" "Percentile75_EFFR" "Percentile75_OBFR" "Percentile75_TGCR" "Percentile75_BGCR"
# [21] "Percentile75_SOFR" "Percentile99_EFFR" "Percentile99_OBFR" "Percentile99_TGCR" "Percentile99_BGCR"
# [26] "Percentile99_SOFR" "TargetDe_EFFR"     "TargetDe_SOFR"     "TargetUe_EFFR"     "TargetUe_SOFR"    
# [31] "Volume_EFFR"       "Volume_OBFR"       "Volume_TGCR"       "Volume_BGCR"       "Volume_SOFR"      
# [36] "sdate"


#```{r, sample data description, echo=FALSE}
Estats <- colMeans(quantilesE[,2:ncol(quantilesE)], na.rm = TRUE)
#Ostats <- colMeans(quantiles[,2:ncol(quantilesO], na.rm = TRUE)
Tstats <- colMeans(quantilesT[,2:ncol(quantilesT)], na.rm = TRUE)
Bstats <- colMeans(quantilesB[,2:ncol(quantilesB)], na.rm = TRUE)
Sstats <- colMeans(quantilesS[,2:ncol(quantilesS)], na.rm = TRUE)
#volumessample<-colMeans(vold[,2:ncol(vold)])
#```


# Quantile plot sample ------------------
# LEGEND NOT COMPLETE
 melteffr <- melt(quantilesE,id="sdate")
 maxr<-max(quantilesE[,2:ncol(quantilesE)])
 quantileseffr <- ggplot(melteffr,aes(x=sdate,y=value,colour=variable,group=variable)) + 
   geom_point(shape = 16, size = 1) +
   labs(x="",  y = "Basis Points (bp),volume $billions", color = "Rate", shape = "Rate") +  
   scale_y_continuous(breaks = seq(0,maxr, by = 50), limits = c(0, maxr)) + 
   theme_minimal() + guides(shape = guide_legend(title = "Rate"))
 print(quantileseffr)
 ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/quantileseffrline.pdf")
 ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/quantileseffrline.png")
 #labs(tag = "Figure 3: EFFR, FOMC target rates", y = "Basis Points (bp)", color = "Rate", linetype = "Rate") +  


# VOLUMES Plots and sample stats ---------------------------------------
# CHECK MISSING DATA
y_breaks =25 
str(vold)
maxr<-max(vold[,2:ncol(vold)]) #1850
dailyvolumes <- ggplot(vold, aes(x = sdate)) +
  geom_point(aes(y = VolumeEFFR, color = "EFFR"), shape = 16, size = 1) + 
  geom_point(aes(y = VolumeTGCR, color = "TGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = VolumeBGCR, color = "BGCR"), shape = 16, size = 1) + 
  geom_point(aes(y = VolumeSOFR, color = "SOFR"), shape = 16, size = 1) + 
  labs(x = "", y = "volume (billions)", color = "Legend Title", linetype = "Legend Title") + 
  scale_color_manual(values = c("EFFR" = "black", "TGCR" = "green", "BGCR" = "blue", "SOFR" = "red"), name = "Legend Title") + 
  scale_linetype_manual(values = c("EFFR" = "solid",  "TGCR" = "dotted", "BGCR" = "dotdash", "SOFR" = "longdash"), name = "Legend Title") +  
   scale_y_continuous(breaks = seq(0,maxr, by = 100), limits = c(0, maxr)) +
   #scale_y_continuous(breaks = y_breaks, limits = y_limits) + 
  theme_minimal()
print(dailyvolumes)  
my_envepisodes$dailyvolumes<-dailyvolumes
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/dailyvolumesline.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/dailyvolumesline.png")

# ------------------------ Sample stats
# 1. average rates and volumes
# 2. IQR
# 3. all quantiles
# 3. Distance from target ?? or average:  below target, above target

# Note: colMeans of rates are average median values -----------------------------
# Rates, volumes, targets, quantiles
avemedianrates<-colMeans(rrbp)
# EFFR     OBFR     TGCR     BGCR     SOFR 
# 108.2911 104.7686 104.3939 105.5336 108.0923 

avevolumeses<-colMeans(vold)

# Sample characterisics quantiles and more --------------------------------------------------
k=6 # sample period maybe convert to begn later etc

bgn<-1
edn<-nrow(rrbp)
print(bgn)
print(edn)
sample<-rrbp[bgn:edn,]  # All
sdate<-spread_no_na$sdate
#sdatesample<-sdate[bgn:edn]
qsampleE=quantilesE[bgn:edn,] # rate specific metrics 
qsampleT=quantilesT[bgn:edn,]
qsampleB=quantilesB[bgn:edn,]
qsampleS=quantilesS[bgn:edn,]
str(sample)

# Store your data frame in the environment
my_envepisodes$sdate <- sdate
my_envepisodes$sampleE <-qsampleE
my_envepisodes$sampleT <-qsampleT
my_envepisodes$sampleB <-qsampleB
my_envepisodes$sampleS <-qsampleS

Estats <- colMeans(qsampleE[bgn:edn,2:ncol(qsampleE)], na.rm = TRUE)
#Ostats <- colMeans(qsampleO[bgn:edn,,2:ncol(qsampleO)], na.rm = TRUE)
Tstats <- colMeans(qsampleT[bgn:edn,2:ncol(qsampleT)], na.rm = TRUE)
Bstats <- colMeans(qsampleB[bgn:edn,2:ncol(qsampleB)], na.rm = TRUE)
Sstatssample <- colMeans(qsampleS[bgn:edn,2:ncol(qsampleS)], na.rm = TRUE)

# Add NA for targets 
Tstats2<-c(Tstats[1],Tstats[2], TargetUe=NA, TargetDe=NA,Tstats[3],Tstats[4],Tstats[5],Tstats[6])
Bstats2<-c(Bstats[1],Bstats[2], TargetUe=NA, TargetDe=NA,Bstats[3],Bstats[4],Bstats[5],Bstats[6])
Sstats2<-c(Sstats[1],Sstats[2], TargetUe=NA, TargetDe=NA,Sstats[3],Sstats[4],Sstats[5],Sstats[6])

Estats_mat <- matrix(Estats, nrow = 8, ncol = 1)
Tstats_mat <- matrix(Tstats2, nrow = 8, ncol = 1)
Bstats_mat <- matrix(Bstats2, nrow = 8, ncol = 1)
Sstats_mat <- matrix(Sstats2, nrow = 8, ncol = 1)

# Combine the matrices into one matrix
stats_sample <- cbind(Estats_mat, Tstats_mat, Bstats_mat, Sstats_mat)

# Print the combined matrix
print(stats)
rownames(stats_sample) <- c("Rate", "Volume", "Upper target", "Lower target", 
                     "Percentile_01", "Percentile_25", "Percentile_75", "Percentile_99")
colnames(stats_sample) <- c("EFFR", "TGCR", "BGCR",  "SOFR")
print(stats_sample)

# Sample data metrics --------------------------------------------------------
categories = c('EFFR', 'TGCR', 'BGCR', 'SOFR')
median_values = c(Estats[1], Tstats[1], Bstats[1], Sstats[1])
iqr_values = c(Estats[7] - Estats[6], Tstats[5] - Tstats[4], Bstats[5] - Bstats[4], Sstats[5] - Sstats[4]) 
range_values = c(Estats[8] - Estats[5],  Tstats[6] - Tstats[3], Bstats[6] - Bstats[3], Sstats[6] - Sstats[3])
volume=c(Estats[2],Tstats[2],Bstats[2],Sstats[2])
ratesamplestats <- data.frame(Category = categories, Median = median_values, IQR = iqr_values, RANGE=range_values, VOLUME=volume)
print( xtable(ratesamplestats), include.rownames = FALSE )


# DAILY DATA Plots and stats for policy episodes  -------------------------------------------
# ------------------------ Daily episode rates and stats
#1. normalcy   3/4/2016		7/31/2019      4  859
#2. mid cycle adjustment 8/1/2019 - 10/31/2019 737660 
#860 - 923
#3. covid 11/1/2019	    3/16/2020   924  1032
#4. zlb         3/17/2020- 3/16/2022     1032-1516
#5. Taming inflation 03/17/2022 - 12/29/2022 1517-1714
#NO! inflation   5/5/2022		12/14/2023 1517  1714
# Redo -3 for each position for nrow=1957

# 1. normalcy              3/4/2016-7/31/2019    
# 2. mid cycle adjustment  8/1/2019-10/31/2019
# 3. covid                11/1/2019-3/16/2020   
# 4. zero lower bound      3/17/2020-3/16/2022
# 5. Taming inflation      3/17/2022-12/14/2023


begn<-c(1,859,923,1014,1519,1)
endn<-c(858,922,1013,1518,1957,1957)
# ------------------------ episode stats
# 1. average rates and volumes
# 2. IQR
# 3. all quantiles
# 3. Distance from target ?? or average:  below target, above target

# Note: colMeans of rates are average median values -----------------------------
avevolumeses<-colMeans(vold)

# Select only numeric columns
# Estats <- colMeans(quantilesE) # Error in colMeans(quantilesE)  : 'x' must be numeri

# do for episodes for EFFR only
# Estatsnorm
# Estatsadj
# Estatscovid
# Estatszlb
# Estatsinflation


# ------------------------ Sample plots, descriptions, stats LATER: ADD TO VOLATILITY PLOTS
k=6
bgn<-begn[k]
edn<-endn[k]-1
df <- as.data.frame(sample_measure1)
df$OBFR <- NULL
df$sdate <- sdate[bgn:edn]


# --------------------------- OUT of sequence volatility plot for sample
# Reshape the data to long format
df_long <- gather(df, key = "Variable", value = "Value", -sdate)
start_dates <-sdate[begn[k]]
end_dates <-sdate[endn[k]]
start_dates_strings <- as.character(start_dates)
end_dates_strings <- as.character(end_dates)
#title <- paste("Log percent change in rates during full sample", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])
figure_number <- 10
title <- paste("Figure", figure_number, ": Log percent change in rates during normalcy period", start_dates_strings[1], "to", end_dates_strings[length(end_dates_strings)])
ggplot(df_long, aes(x = sdate, y = Value, color = Variable)) +
  geom_point() +
  labs(title = title,
        x = "",
       y = "Percent",
       color = "Variable") +
  theme(plot.title = element_text(hjust = 0.5))
  
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_sample.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_sample.png")
# --------------------------- OUT of sequence vol plot


# --------------- epoch plots
#1. normalcy   3/4/2016		7/31/2019      4  859
k=1 # normalcy period
bgn<-begn[k]
edn<-endn[k]
print(bgn)
print(edn)
norm<-rrbp[bgn:edn,]  # All
sdatenorm<-sdate[bgn:edn]

qnormE=quantilesE[bgn:edn,] # rate specific metrics 
qnormT=quantilesT[bgn:edn,]
qnormB=quantilesB[bgn:edn,]
qnormS=quantilesS[bgn:edn,]
str(norm)

# Store your data frame in the environment
my_envepisodes$sdatenorm <-sdatenorm
my_envepisodes$normE <-qnormE
my_envepisodes$normT <-qnormT
my_envepisodes$normB <-qnormB
my_envepisodes$normS <-qnormS

Estatsnorm <- colMeans(qnormE[,2:ncol(qnormE)], na.rm = TRUE)
#Ostatsnorm <- colMeans(qnormO[,2:ncol(qnormO)], na.rm = TRUE)
Tstatsnorm <- colMeans(qnormT[,2:ncol(qnormT)], na.rm = TRUE)
Bstatsnorm <- colMeans(qnormB[,2:ncol(qnormB)], na.rm = TRUE)
Sstatsnorm <- colMeans(qnormS[,2:ncol(qnormS)], na.rm = TRUE)

# Add NA for targets 
Tstatsnorm2<-c(Tstatsnorm[1],Tstatsnorm[2], TargetUe=NA, TargetDe=NA,Tstatsnorm[3],Tstatsnorm[4],Tstatsnorm[5],Tstatsnorm[6])
Bstatsnorm2<-c(Bstatsnorm[1],Bstatsnorm[2], TargetUe=NA, TargetDe=NA,Bstatsnorm[3],Bstatsnorm[4],Bstatsnorm[5],Bstatsnorm[6])
Sstatsnorm2<-c(Sstatsnorm[1],Sstatsnorm[2], TargetUe=NA, TargetDe=NA,Sstatsnorm[3],Sstatsnorm[4],Sstatsnorm[5],Sstatsnorm[6])

# episode characteristics NEW---------------------------------
Estatsnorm_mat <- matrix(Estatsnorm, nrow = 8, ncol = 1)
Tstatsnorm_mat <- matrix(Tstatsnorm2, nrow = 8, ncol = 1)
Bstatsnorm_mat <- matrix(Bstatsnorm2, nrow = 8, ncol = 1)
Sstatsnorm_mat <- matrix(Sstatsnorm2, nrow = 8, ncol = 1)

# Combine the matrices into one matrix
charnorm <- cbind(Estatsnorm_mat, Tstatsnorm_mat, Bstatsnorm_mat, Sstatsnorm_mat)
print(charnorm)
# Set row names
rownames(charnorm) <- c("Rate", "Volume", "Upper target", "Lower target", 
                     "Percentile_01", "Percentile_25", "Percentile_75", "Percentile_99")

colnames(charnorm) <- c("EFFR", "TGCR", "BGCR",  "SOFR")
print(charnorm)
print(xtable(charnorm),include.rownames = FALSE)
my_envepisodes$charnorm <-charnorm

# episode stats --------------------------------------------------------
# Assuming categories is defined somewhere in your code
categories <- c("EFFR", "TGCR", "BGCR", "SOFR")
# Assuming Estatsnorm, Tstatsnorm, Bstatsnorm, and Sstatsnorm are correctly calculated
median_values <- c(Estatsnorm[1], Tstatsnorm[1], Bstatsnorm[1], Sstatsnorm[1])
iqr_values <- c(Estatsnorm[7] - Estatsnorm[6], Tstatsnorm[5] - Tstatsnorm[4], Bstatsnorm[5] - Bstatsnorm[4], Sstatsnorm[5] - Sstatsnorm[4])
range_values <- c(Estatsnorm[8] - Estatsnorm[5], Tstatsnorm[6] - Tstatsnorm[3], Bstatsnorm[6] - Bstatsnorm[3], Sstatsnorm[6] - Sstatsnorm[3])
volume_values = c(Estatsnorm[2], Tstatsnorm[2], Bstatsnorm[2], Sstatsnorm[2])
# Create the data frame
normstats <- data.frame(Category = categories, Median = median_values, IQR = iqr_values, RANGE = range_values, VOLUME = volume_values)

# Print the table using xtable
print(xtable(normstats), include.rownames = FALSE)
my_envepisodes$normstats <-normstats

# Plots  rates
sdate<-sdatenorm
maxr-max(norm[,2:ncol(norm)]) #224
maxr=250
minr=0 #min(norm[,2:ncol(norm)]) #0
meltrates_norm <- melt(norm,id="sdate")
ratests_norm <- ggplot(meltrates_norm,aes(x=sdate,y=value,colour=variable,group=variable)) + 
  geom_point(shape = 16, size = 1) +
  labs(caption= "Normalcy  3/4/2016-7/31/2019",x="", y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
  scale_y_continuous(breaks = seq(minr, maxr, by = 25), limits = c(minr, maxr)) + 
  theme_minimal()+ guides(shape = guide_legend(title = "Rate"))
print(ratests_norm)
my_envepisodes$ratests_norm<-ratests_norm
#Removed 32 rows containing missing values (`geom_point()`)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/ratests_norm.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/ratests_norm.png")


# adjustment period --------------------------------------
k=2  
bgn<-begn[k]
edn<-endn[k]
print(bgn)
print(edn)
adjust<-rrbp[bgn:edn,]  # rates plot
#sdate<-spread_no_na$sdate  I had to do this
sdateadj<-sdate[bgn:edn]

qadjE=quantilesE[bgn:edn,]
qadjT=quantilesT[bgn:edn,]
qadjB=quantilesB[bgn:edn,]
qadjS=quantilesS[bgn:edn,]
adjust<-rrbp[bgn:edn,]  # All 

# Store your data frame in the environment
my_envepisodes$sdateadj <-sdateadj
my_envepisodes$adjE <-qadjE
my_envepisodes$adjT <-qadjT
my_envepisodes$adjB <-qadjB
my_envepisodes$adjS <-qadjS

# stats_adjust<-colMeans(quantilesE[bgn_edn,]     #adjust
Estatsadj <- colMeans(qadjE[,2:ncol(qadjE)], na.rm = TRUE)
#Ostatsadj <- colMeans(qadjO[,2:ncol(qadjO)], na.rm = TRUE)
Tstatsadj <- colMeans(qadjT[,2:ncol(qadjT)], na.rm = TRUE)
Bstatsadj <- colMeans(qadjB[,2:ncol(qadjB)], na.rm = TRUE)
Sstatsadj <- colMeans(qadjS[,2:ncol(qadjS)], na.rm = TRUE)

# Add NA for targets 
Tstatsadj2<-c(Tstatsadj[1],Tstatsadj[2], TargetUe=NA, TargetDe=NA,Tstatsadj[3],Tstatsadj[4],Tstatsadj[5],Tstatsadj[6])
Bstatsadj2<-c(Bstatsadj[1],Bstatsadj[2], TargetUe=NA, TargetDe=NA,Bstatsadj[3],Bstatsadj[4],Bstatsadj[5],Bstatsadj[6])
Sstatsadj2<-c(Sstatsadj[1],Sstatsadj[2], TargetUe=NA, TargetDe=NA,Sstatsadj[3],Sstatsadj[4],Sstatsadj[5],Sstatsadj[6])

# episode characteristics NEW---------------------------------
Estatsadj_mat <- matrix(Estatsadj, nrow = 8, ncol = 1)
Tstatsadj_mat <- matrix(Tstatsadj2, nrow = 8, ncol = 1)
Bstatsadj_mat <- matrix(Bstatsadj2, nrow = 8, ncol = 1)
Sstatsadj_mat <- matrix(Sstatsadj2, nrow = 8, ncol = 1)

# Combine the matrices into one matrix
charadj <- cbind(Estatsadj_mat, Tstatsadj_mat, Bstatsadj_mat, Sstatsadj_mat)
print(charadj)
# Set row names
rownames(charadj) <- c("Rate", "Volume", "Upper target", "Lower target", 
                     "Percentile_01", "Percentile_25", "Percentile_75", "Percentile_99")

colnames(charadj) <- c("EFFR", "TGCR", "BGCR",  "SOFR")
print(charadj)
print(xtable(charadj),include.rownames = FALSE)

median_values = c(Estatsadj[1], Tstatsadj[1], Bstatsadj[1], Sstatsadj[1])
iqr_values = c(Estatsadj[7] - Estatsadj[6],  Tstatsadj[5] - Tstatsadj[4], Bstatsadj[5] - Bstatsadj[4], Sstatsadj[5] - Sstatsadj[4])
range_values = c(Estatsadj[8] - Estatsadj[5], Tstatsadj[6] - Tstatsadj[3], Bstatsadj[6] - Bstatsadj[3], Sstatsadj[6] - Sstatsadj[3])
volume_values = c(Estatsadj[2], Tstatsadj[2], Bstatsadj[2], Sstatsadj[2])
adjstats <- data.frame(Category = categories, Median = median_values, IQR = iqr_values, RANGE=range_values, VOLUME = volume_values)
print(xtable(adjstats),include.rownames = FALSE)

# Plots  rates
sdate<-sdateadj
maxr=max(adjust[,2:ncol(adjust)]) # drop outlier 525
maxr=260
minr=min(adjust[,2:ncol(adjust)])
meltratests_adjust <- melt(adjust,id="sdate")
ratests_adjust <- ggplot(meltrates_adjust,aes(x=sdate,y=value,colour=variable,group=variable)) + 
  geom_point(shape=16,size=1) +
  labs(caption= "Adjustment 8/1/2019-10/31/2019",x="", y = "Basis Points (bp)", color = "Rate", linetype = "Rate") +  
  scale_y_continuous(breaks = seq(minr, maxr, by = 25), limits = c(minr, maxr)) + 
  theme_minimal() + guides(shape = guide_legend(title = "Rate"))
print(ratests_adjust)
my_envepisodes$ratests_adjust<-ratests_adjust
#Removed 3 rows containing missing values (`geom_point()`). 

ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_adjust.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_adjust.png")

my_envepisodes$charadj <-charadj
my_envepisodes$adjstats <-adjstats

# Covid period --------------------------------------
k=3  
bgn<-begn[k]
edn<-endn[k]
print(bgn)
print(edn)
covid<-rrbp[bgn:edn,]
sdatecovid<-sdate[bgn:edn]

qcovidE=quantilesE[bgn:edn,]
qcovidT=quantilesT[bgn:edn,]
qcovidB=quantilesB[bgn:edn,]
qcovidS=quantilesS[bgn:edn,]

# Store your data frame in the environment
my_envepisodes$sdatecovid <-sdatecovid
my_envepisodes$covidE <-qcovidE
my_envepisodes$covidT <-qcovidT
my_envepisodes$covidB <-qcovidB
my_envepisodes$covidS <-qcovidS

# stats_covidust<-colMeans(quantilesE[bgn_edn,]     #covidust
Estatscovid <- colMeans(qcovidE[,2:ncol(qcovidE)], na.rm = TRUE)
#Ostatscovid <- colMeans(qcovidO[,2:ncol(qcovidO)], na.rm = TRUE)
Tstatscovid <- colMeans(qcovidT[,2:ncol(qcovidT)], na.rm = TRUE)
Bstatscovid <- colMeans(qcovidB[,2:ncol(qcovidB)], na.rm = TRUE)
Sstatscovid <- colMeans(qcovidS[,2:ncol(qcovidS)], na.rm = TRUE)

# Add NA for targets 
Tstatscovid2<-c(Tstatscovid[1],Tstatscovid[2], TargetUe=NA, TargetDe=NA,Tstatscovid[3],Tstatscovid[4],Tstatscovid[5],Tstatscovid[6])
Bstatscovid2<-c(Bstatscovid[1],Bstatscovid[2], TargetUe=NA, TargetDe=NA,Bstatscovid[3],Bstatscovid[4],Bstatscovid[5],Bstatscovid[6])
Sstatscovid2<-c(Sstatscovid[1],Sstatscovid[2], TargetUe=NA, TargetDe=NA,Sstatscovid[3],Sstatscovid[4],Sstatscovid[5],Sstatscovid[6])

# episode characteristics NEW---------------------------------
Estatscovid_mat <- matrix(Estatscovid, nrow = 8, ncol = 1)
Tstatscovid_mat <- matrix(Tstatscovid2, nrow = 8, ncol = 1)
Bstatscovid_mat <- matrix(Bstatscovid2, nrow = 8, ncol = 1)
Sstatscovid_mat <- matrix(Sstatscovid2, nrow = 8, ncol = 1)

# Combine the matrices into one matrix
charcovid <- cbind(Estatscovid_mat, Tstatscovid_mat, Bstatscovid_mat, Sstatscovid_mat)
print(charcovid)
# Set row names
rownames(charcovid) <- c("Rate", "Volume", "Upper target", "Lower target", 
                     "Percentile_01", "Percentile_25", "Percentile_75", "Percentile_99")

colnames(charcovid) <- c("EFFR", "TGCR", "BGCR",  "SOFR")
print(charcovid)
print(xtable(charcovid),include.rownames = FALSE)

median_values = c(Estatscovid[1], Tstatscovid[1], Bstatscovid[1], Sstatscovid[1])
iqr_values = c(Estatscovid[7] - Estatscovid[6], Tstatscovid[5] - Tstatscovid[4], Bstatscovid[5] - Bstatscovid[4], Sstatscovid[5] - Sstatscovid[4])
range_values = c(Estatscovid[8] - Estatscovid[5], Tstatscovid[6] - Tstatscovid[3], Bstatscovid[6] - Bstatscovid[3], Sstatscovid[6] - Sstatscovid[3])
volume_values = c(Estatscovid[2], Tstatscovid[2], Bstatscovid[2], Sstatscovid[2])
covidstats <- data.frame(Category = categories, Median = median_values, IQR = iqr_values, RANGE=range_values, VOLUME = volume_values)
print(xtable(covidstats), include.rownames = FALSE)

my_envepisodes$charcovid <-charcovid
my_envepisodes$covidstats <-covidstats


#caption= "Covid 11/1/2019-3/16/2020"
#Removed 295 rows containing missing values (`geom_point()`). ???
sdate<-sdatecovid
maxr=max(covid[,2:ncol(covid)]) # drop outlier 165
maxr=maxr+5
minr=min(covid[,2:ncol(covid)]) #23
minr=minr-3
meltrates_covid <- melt(covid,id="sdate")
ratests_covid <- ggplot(meltrates_covid,aes(x=sdate,y=value,colour=variable,group=variable)) + 
  geom_point(shape=16,size=1) +
  labs(caption= "Covid 11/1/2019-3/16/2020",x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
  scale_y_continuous(breaks = seq(minr, maxr, by = 25), limits = c(minr, maxr)) + 
  theme_minimal() + guides(shape = guide_legend(title = "Rate"))
print(ratests_covid)
my_envepisodes$ratests_covid<-ratests_covid
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_covid.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_covid.png")

# zero lower bound period --------------------------------------
k=4  
bgn<-begn[k]
edn<-endn[k]
print(bgn)
print(edn)
zlb<-rrbp[bgn:edn,]
sdatezlb<-sdate[bgn:edn]

qzlbE=quantilesE[bgn:edn,]
qzlbT=quantilesT[bgn:edn,]
qzlbB=quantilesB[bgn:edn,]
qzlbS=quantilesS[bgn:edn,]

# Store your data frame in the environment
my_envepisodes$sdatezlb <-sdatezlb
my_envepisodes$zlbE <-qzlbE
my_envepisodes$zlbT <-qzlbT
my_envepisodes$zlbB <-qzlbB
my_envepisodes$zlbS <-qzlbS

# stats_zlbust<-colMeans(quantilesE[bgn_edn,]     #zlbust
Estatszlb <- colMeans(qzlbE[,2:ncol(qzlbE)], na.rm = TRUE)
#Ostatszlb <- colMeans(qzlbO[,2:ncol(qzlbO)], na.rm = TRUE)
Tstatszlb <- colMeans(qzlbT[,2:ncol(qzlbT)], na.rm = TRUE)
Bstatszlb <- colMeans(qzlbB[,2:ncol(qzlbB)], na.rm = TRUE)
Sstatszlb <- colMeans(qzlbS[,2:ncol(qzlbS)], na.rm = TRUE)

# Add NA for targets 
Tstatszlb2<-c(Tstatszlb[1],Tstatszlb[2], TargetUe=NA, TargetDe=NA,Tstatszlb[3],Tstatszlb[4],Tstatszlb[5],Tstatszlb[6])
Bstatszlb2<-c(Bstatszlb[1],Bstatszlb[2], TargetUe=NA, TargetDe=NA,Bstatszlb[3],Bstatszlb[4],Bstatszlb[5],Bstatszlb[6])
Sstatszlb2<-c(Sstatszlb[1],Sstatszlb[2], TargetUe=NA, TargetDe=NA,Sstatszlb[3],Sstatszlb[4],Sstatszlb[5],Sstatszlb[6])


# episode characteristics NEW---------------------------------
Estatszlb_mat <- matrix(Estatszlb, nrow = 8, ncol = 1)
Tstatszlb_mat <- matrix(Tstatszlb2, nrow = 8, ncol = 1)
Bstatszlb_mat <- matrix(Bstatszlb2, nrow = 8, ncol = 1)
Sstatszlb_mat <- matrix(Sstatszlb2, nrow = 8, ncol = 1)

# Combine the matrices into one matrix
charzlb <- cbind(Estatszlb_mat, Tstatszlb_mat, Bstatszlb_mat, Sstatszlb_mat)
print(charzlb)
rownames(charzlb) <- c("Rate", "Volume", "Upper target", "Lower target", 
                     "Percentile_01", "Percentile_25", "Percentile_75", "Percentile_99")

colnames(charzlb) <- c("EFFR", "TGCR", "BGCR",  "SOFR")
print(charzlb)
print(xtable(charzlb),include.rownames = FALSE)

median_values = c(Estatszlb[1], Tstatszlb[1], Bstatszlb[1], Sstatszlb[1])
iqr_values = c(Estatszlb[7] - Estatszlb[6], Tstatszlb[5] - Tstatszlb[4], Bstatszlb[5] - Bstatszlb[4], Sstatszlb[5] - Sstatszlb[4])
range_values = c(Estatszlb[8] - Estatszlb[5], Tstatszlb[6] - Tstatszlb[3], Bstatszlb[6] - Bstatszlb[3], Sstatszlb[6] - Sstatszlb[3])
volume_values = c(Estatszlb[2], Tstatszlb[2], Bstatszlb[2], Sstatszlb[2])
zlbstats <- data.frame(Category = categories, Median = median_values, IQR = iqr_values, RANGE=range_values, VOLUME = volume_values)
print(xtable(zlbstats),include.rownames = FALSE)

my_envepisodes$charzlb <-charzlb
my_envepisodes$zlbstats <-zlbstats

# Plot rates
#```{r ,  EFFR and percentiles, echo=FALSE, fig.cap="Overnight rates EFFR percentiles Zero lower bound"}   
print(effrrates_zlb)
#````

sdate<-sdatezlb
maxr=max(zlb[,2:ncol(zlb)]) # drop outlier 54
maxr=maxr+6
minr=min(zlb[,2:ncol(zlb)]) #0

meltrates_zlb <- melt(zlb,id="sdate")
ratests_zlb <- ggplot(meltrates_zlb,aes(x=sdate,y=value,colour=variable,group=variable)) + 
  geom_point(shape=16,size=1) +
  labs(caption= "Zero lower bound 3/17/2020-3/16/2022",x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
  scale_y_continuous(breaks = seq(0,maxr, by = 20), limits = c(0,maxr)) + 
  theme_minimal() + guides(shape = guide_legend(title = "Rate"))
print(ratests_zlb)
my_envepisodes$ratests_zlb <-ratests_zlb
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_zlb.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_zlb.png")

# inflation period --------------------------------------
k=5 
bgn<-begn[k]
edn<-endn[k]
print(bgn)
print(edn)
inflation<-rrbp[bgn:edn,]
sdateinflation<-sdate[bgn:edn]

qinflationE=quantilesE[bgn:edn,]
qinflationT=quantilesT[bgn:edn,]
qinflationB=quantilesB[bgn:edn,]
qinflationS=quantilesS[bgn:edn,]


# Store your data frame in the environment
my_envepisodes$sdateinflation <-sdateinflation
my_envepisodes$inflationE <-qinflationE
my_envepisodes$inflationT <-qinflationT
my_envepisodes$inflationB <-qinflationB
my_envepisodes$inflationS <-qinflationS

# stats_inflationust<-colMeans(quantilesE[bgn_edn,]     #inflationust
Estatsinflation <- colMeans(qinflationE[,2:ncol(qinflationE)], na.rm = TRUE)
#Ostatsinflation <- colMeans(qinflationO[,2:ncol(qinflationO)], na.rm = TRUE)
Tstatsinflation <- colMeans(qinflationT[,2:ncol(qinflationT)], na.rm = TRUE)
Bstatsinflation <- colMeans(qinflationB[,2:ncol(qinflationB)], na.rm = TRUE)
Sstatsinflation <- colMeans(qinflationS[,2:ncol(qinflationS)], na.rm = TRUE)

# Add NA for targets 
Tstatsinflation2<-c(Tstatsinflation[1],Tstatsinflation[2], TargetUe=NA, TargetDe=NA,Tstatsinflation[3],Tstatsinflation[4],Tstatsinflation[5],Tstatsinflation[6])
Bstatsinflation2<-c(Bstatsinflation[1],Bstatsinflation[2], TargetUe=NA, TargetDe=NA,Bstatsinflation[3],Bstatsinflation[4],Bstatsinflation[5],Bstatsinflation[6])
Sstatsinflation2<-c(Sstatsinflation[1],Sstatsinflation[2], TargetUe=NA, TargetDe=NA,Sstatsinflation[3],Sstatsinflation[4],Sstatsinflation[5],Sstatsinflation[6])


# episode characteristics NEW---------------------------------
Estatsinflation_mat <- matrix(Estatsinflation, nrow = 8, ncol = 1)
Tstatsinflation_mat <- matrix(Tstatsinflation2, nrow = 8, ncol = 1)
Bstatsinflation_mat <- matrix(Bstatsinflation2, nrow = 8, ncol = 1)
Sstatsinflation_mat <- matrix(Sstatsinflation2, nrow = 8, ncol = 1)

# Combine the matrices into one matrix
charinflation <- cbind(Estatsinflation_mat, Tstatsinflation_mat, Bstatsinflation_mat, Sstatsinflation_mat)
print(charinflation)
rownames(charinflation) <- c("Rate", "Volume", "Upper target", "Lower target", 
                     "Percentile_01", "Percentile_25", "Percentile_75", "Percentile_99")

colnames(charinflation) <- c("EFFR", "TGCR", "BGCR",  "SOFR")
print(charinflation)
print(xtable(charinflation),include.rownames = FALSE)

median_values = c(Estatsinflation[1], Tstatsinflation[1], Bstatsinflation[1], Sstatsinflation[1])
iqr_values = c(Estatsinflation[7] - Estatsinflation[6], Tstatsinflation[5] - Tstatsinflation[4], Bstatsinflation[5] - Bstatsinflation[4], Sstatsinflation[5] - Sstatsinflation[4])
range_values = c(Estatsinflation[8] - Estatsinflation[5], Tstatsinflation[6] - Tstatsinflation[3], Bstatsinflation[6] - Bstatsinflation[3], Sstatsinflation[6] - Sstatsinflation[3])
volume_values = c(Estatsinflation[2], Tstatsinflation[2], Bstatsinflation[2], Sstatsinflation[2])
inflationstats <- data.frame(Category = categories, Median = median_values, IQR = iqr_values, RANGE=range_values, VOLUME = volume_values)
print(xtable(inflationstats),include.rownames = FALSE)

my_envepisodes$charinflation <-charinflation
my_envepisodes$inflationstats <-inflationstats

# Plot rates
sdate<-sdateinflation
maxr=max(inflation[,2:ncol(inflation)]) # 539
minr=min(inflation[,2:ncol(inflation)]) #0

meltrates_inflation <- melt(inflation,id="sdate")
ratests_inflation <- ggplot(meltrates_inflation,aes(x=sdate,y=value,colour=variable,group=variable)) + 
  geom_point(shape=16,size=1) +
  labs(caption = "Inflation 03/17/2022-12/14/2023", x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
  scale_y_continuous(breaks = seq(0, maxr, by = 50), limits = c(0, maxr)) + 
  theme_minimal() + guides(shape = guide_legend(title = "Rate"))
print(ratests_inflation)
my_envepisodes$ratests_inflation<-ratests_inflation
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_inflation.pdf")
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/rates_inflation.png")

# 1. normalcy   3/4/2016		7/31/2019      1  858 
# 2. mid cycle adjustment 8/1/2019 - 10/31/2019 737660  859 - 922
# 3. covid 11/1/2019	    3/16/2020   923  1013
# 4. zlb         3/17/2020- 3/16/2022     1014-1518
# 4. Taming inflation 03/17/2022 - 12/14/2023 1519-1957

# Combine episode time series plots
rates_norm + rates_adjust + rates_covid + rates_zlb + rates_inflation
plot_layout(ncol = 2) +
plot_annotation( title = 'Overnight rates over different policy regimes', caption = '2016-2023', theme = theme(plot.title = element_text(size = 16)) )

#Another way combined_plot <- plot1 + plot2 + plot3

# Combine episode percent change plots
pratests<-(ratests_norm | ratests_adjust) / (ratests_covid |ratests_zlb) / ratests_inflation
print(pratests)
# The best plots, still not great
my_envepisodes$pratests<-pratests
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.pdf", pratests)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.png", pratests)

pratests2 <- wrap_plots(ratests_norm, ratests_adjust,ratests_covid,ratests_zlb, ratests_inflation, ncol = 1)
print(pratests2)

pratests3 <- grid.arrange(ratests_norm, ratests_adjust,ratests_covid,ratests_zlb, ratests_inflation, ncol = 1)
print(pratests3)

library(grid)
plot_width <- 6  # Width of each plot
plot_height <- 4  # Height of each plot

# Arrange plots using grid.arrange
pratests4 <-grid.arrange(
  arrangeGrob(ratests_norm, ratests_adjust,ratests_covid,ratests_zlb, ratests_inflation, ncol = 1),
  widths = rep(plot_width, 1),
  heights = rep(plot_height, 3),
  #top = textGrob("Combined Plots", gp = gpar(fontsize = 14)),
  #bottom = grid.text("X-Axis Label", x = unit(0.5, "npc"), y = unit(-0.5, "line"), 
  #                   just = "center", gp = gpar(fontsize = 12)),
  left = grid.text("Y-Axis Label", x = unit(-0.5, "line"), y = unit(0.5, "npc"), 
                   just = "center", gp = gpar(fontsize = 12), rot = 90),
  right = grid.text("Right Label", rot = -90, gp = gpar(fontsize = 12)),
  padding = unit(0.5, "line")
)
print(pratests4)

# Quintile plots--------------------------------
# Sample
# OLD
melteffr <- melt(quantilesE,id="sdate")
maxr<-max(quantilesE[,2:ncol(quantilesE)])
quantileseffr <- ggplot(melteffr,aes(x=sdate,y=value,colour=variable,group=variable)) + 
  geom_point(shape = 16, size = 1) +
  labs(x="",  y = "Basis Points (bp),volume $billions", color = "Rate", shape = "Rate") +  
  scale_y_continuous(breaks = seq(0,maxr, by = 50), limits = c(0, maxr)) + 
  theme_minimal() + guides(shape = guide_legend(title = "Rate"))
print(quantileseffr)



#{r,EFFR during normalcy period 3/4/2016-7/31/2019, echo=FALSE}
ratecol=2
vol=3
targetup = 3
targetdown = 4
p1=6
p25=7
p75=8
p99=9
normE<-
maxr<-max(quantilesE[,ncol(quantilesE)])
minr<-min(quantilesE[,ncol(quantilesE)]
          
          #(see Figure \@ref(fig:EFFR during normalcy period 3/4/2016-7/31/2019)
          #{r, fig.caption= "EFFR during normalcy period 3/4/2016-7/31/2019", rates_norm,fig.num=TRUE, echo=FALSE, results='asis'}
          library(ggplot2)
          sample<-quantilesE
          sdate <- quantilesE[, 1]
          data_without_sdate <- quantilesE[, -1]
          #maxr<-max(normE[,ncol(quantilesE)]) 
          #minr<-min(normE[,ncol(quantilesE)])
          
          meltrates_sample <- melt(data.frame(sdate, data_without_sdate), id.vars = "sdate")
          rates_sample <<- ggplot(meltrates_sample, aes(x = sdate, y = value, colour = variable, group = variable)) + 
            geom_line() +
            labs( caption = "Sample 3/4/2016-12/14/2023", x = "", y = "rates basis points (bp) volume (billion dollars)", color = "Rate") +  
            scale_y_continuous(breaks = seq(0, maxr, by = 25), limits = c(0,maxr)) + 
            theme_minimal()
          #my_envepisodes$rates_sample<-rates_sample
          print(rates_sample)
          ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/samplequantiles.pdf",rates_sample)
          ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/samplequantiles.png",rates_sample)
          



# NORMALCY -------------------------------------------
#{r,EFFR during normalcy period 3/4/2016-7/31/2019, echo=FALSE}
ratecol=2
vol=3
targetup = 3
targetdown = 4
p1=6
p25=7
p75=8
p99=9
normE<-my_envepisodes$norm
maxr<-max(normE[,ncol(normE)])
minr<-min(normE[,ncol(normE)]

#(see Figure \@ref(fig:EFFR during normalcy period 3/4/2016-7/31/2019)
#{r, fig.caption= "EFFR during normalcy period 3/4/2016-7/31/2019", rates_norm,fig.num=TRUE, echo=FALSE, results='asis'}
 library(ggplot2)
 normE<-my_envepisodes$norm
 sdate <- normE[, 1]
 data_without_sdate <- normE[, -1]
 maxr<-max(normE[,ncol(normE)]) 
 minr<-min(normE[,ncol(normE)])
 
 meltrates_norm <- melt(data.frame(sdate, data_without_sdate), id.vars = "sdate")
 rates_norm <<- ggplot(meltrates_norm, aes(x = sdate, y = value, colour = variable, group = variable)) + 
   geom_line() +
   labs( caption = "Normalcy 3/4/2016-7/31/2019", x = "", y = "rates basis points (bp) volume (billion dollars)", color = "Rate") +  
   scale_y_continuous(breaks = seq(0, maxr, by = 25), limits = c(0,maxr)) + 
   theme_minimal()
 #my_envepisodes$rates_norm<-rates_norm
 print(rates_norm)
 
 ##see Figure \@ref(fig:Reference rates during normalcy period 3/4/2016-7/31/2019)
 #```{r,Reference rates during normalcy period 3/4/2016-7/31/2019, echo=FALSE}
 library(gridExtra)
 library(grid)
 norm_plots <- grid.arrange(ratests_norm, rates_norm, ncol=1)
 grid.text("Normalcy period 3/4/2016-7/31/2019", x = 0.5, y = -0.1, just = "center")
 print(norm_plots)

 # IQR as ribbon plot-------------------------------
 
 
 rates=2
 vol=3
 targetup = 4
 targetdown = 5
 p1=6
 p25=7
 p75=8
 p99=9
 library(ggplot2)
 normE<-my_envepisodes$norm
 sdate <- normE[, 1]
 data_without_sdate <- normE[, -1]
 maxr<-max(normE[,ncol(normE)]) 
 minr<-min(normE[,ncol(normE)])
 
 meltrates_norm <- melt(data.frame(sdate, data_without_sdate), id.vars = "sdate")
 rates_norm <<- ggplot(meltrates_norm, aes(x = sdate, y = value, colour = variable, group = variable)) + 
   geom_line() +
   labs( caption = "Normalcy 3/4/2016-7/31/2019", x = "", y = "rates basis points (bp) volume (billion dollars)", color = "Rate") +  
   scale_y_continuous(breaks = seq(0, maxr, by = 25), limits = c(0,maxr)) + 
   theme_minimal()
 #my_envepisodes$rates_norm<-rates_norm
 print(rates_norm)
 
 # ADJUST -------------------------------------------
 #{r, EFFR during adjustment period 8/1/2019-10/31/2019, echo=FALSE,results='asis'}
 rates=2
 vol=3
 targetup = 4
 targetdown = 5
 p1=6
 p25=7
 p75=8
 p99=9
 adjust<-rrbp[bgn:edn,]
 max(adjust[,2:ncol(adjust)]) 
 min(adjust[,2:ncol(adjust)])
 qadjE<-my_envepisodes$adjust
 maxr<-max(qadjE[,rates]) 
 minr<-min(qadjE[,rates])
 
 #(see Figure \@ref(fig:EFFR during adjustment period 8/1/2019-10/31/2019)
 #{r, fig.caption= "EFFR during adjustment period 8/1/2019-10/31/2019", rates_adjust,eval=TRUE, echo=FALSE, results='asis'}
  library(ggplot2)                        
  library(reshape2)
  qadjE<-my_envepisodes$adjust # Using the same data as the first plot
  sdate <- as.Date(qadjE[, 1])
  data_without_sdate<- qadjE[, -1]
  rates=2
  adjust<-rrbp[bgn:edn,]
  maxr<-max(adjust[,2:ncol(adjust)]) 
  minr<-min(adjust[,2:ncol(adjust)])
  #maxr<-max(qadjE[,2]) 
  #minr<-min(qadjE[,2]) 
  
  meltrates_adjust <- melt(data.frame(sdate, data_without_sdate), id.vars = "sdate")
  meltrates_adjust$variable <- as.factor(meltrates_adjust$variable)
  meltrates_adjust$value <- as.numeric(meltrates_adjust$value)
  rates_adjust <<- ggplot(meltrates_adjust, aes(x = sdate, y=value, colour=variable, group=variable)) +
    geom_line() +
    labs(caption= "Adjustment  8/1/2019-10/31/2019",x = "", y = "rates basis points (bp) volume (billion dollars)", color = "Rate") +  
    scale_y_continuous(breaks = seq(minr, maxr, by = 25), limits = c(minr, maxr)) + 
    scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 month") +  #Specify date format and breaks
    theme_minimal()
  #print(rates_adjust)
  #my_envepisodes$rates_adjust<-rates_adjust
  
  #see Figure \@ref(fig:Reference rates during adjustment period 8/1/2019-10/31/2019)
  #```{r,Reference rates during adjustment period 8/1/2019-10/31/2019, echo=FALSE}
  library(gridExtra)
  library(grid)
  adjust_plots <- grid.arrange(ratests_adjust, rates_adjust, ncol=1)
  grid.text("Adjustment period 8/1/2019-10/31/2019", x = 0.5, y = -0.1, just = "center")
  print(adjust_plots)

  
# COVID -------------------------------------------
  #{r, EFFR during covid period 11/1/2019-3/16/2020, echo=FALSE}
  rates=2
  vol=3
  targetup = 3
  targetdown = 4
  p1=6
  p1=7
  p1=8
  p1=9
  qcovidE<-my_envepisodes$covid
  maxr<-max(covid[,2:ncol(covid)]) 
  minr<-min(covid[,2:ncol(covid)])  

  #(see Figure \@ref(fig:EFFR during covid period 11/1/2019-3/16/2020)
  #{r, fig.caption= "EFFR during covid period 11/1/2019-3/16/2020",rates_covid,echo=FALSE,results='asis'}
   library(ggplot2)
   rates=2
   qcovidE<-my_envepisodes$covid # Using the same data as the first plot
   data_without_sdate<- qcovidE[, -1]
   sdate <- as.Date(qcovidE[, 1])
   maxr<-max(qcovidE[,2:ncol(qcovidE)]) 
   minr<-min(qcovidE[,2:ncol(qcovidE)])  
   
   meltrates_covid <- melt(data.frame(sdate, data_without_sdate), id.vars = "sdate")
   meltrates_covid$variable <- as.factor(meltrates_covid$variable)
   meltrates_covid$value <- as.numeric(meltrates_covid$value)
   rates_covid <- ggplot(meltrates_covid, aes(x = sdate, y = value, colour = variable, group = variable)) +
     geom_line() +
     labs(caption="Covid 11/1/2019-3/16/2020",x = "", y = "rates basis points (bp) volume (billion dollars)", color = "Rate") +  
     scale_y_continuous(breaks = seq(0, maxr, by = 25), limits = c(0, maxr)) + 
     scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 month") +  
     theme_minimal()
   #print(rates_covid)
   #my_envepisodes$rates_covid<-rates_covid
   
   #see Figure \@ref(fig:Reference rates during covid period 11/1/2019-3/16/2020)
   #{r,Reference rates during Covid period 11/1/2019-3/16/2020, echo=FALSE}
   library(gridExtra)
   library(grid)
   covid_plots <- grid.arrange(ratests_covid, rates_covid, ncol=1)
   grid.text("Covid period 11/1/2019-3/16/2020", x = 0.5, y = -0.1, just = "center")
   print(covid_plots)

# ZLB -------------------------------------------  
   #{r, EFFR during zero lower bound (zlb) period 3/17/2020-3/16/2022, echo=FALSE}
   rates=2
   vol=3
   targetup = 3
   targetdown = 4
   p1=6
   p25=7
   p75=8
   p99=9
   zlbE<-my_envepisodes$zlb
   maxr<-max(zlbE[,rates]) #25
   minr<-min(zlbE[,rates]) # 4
   
  
   #see Figure \@ref(fig:EFFR during zero lower bound (Zlb) period 3/17/2020-3/16/2022)
   #{r, fig.caption= "EFFR during zero lower bound (zlb) period 3/17/2020-3/16/2022",rates_zlb,echo=FALSE}
   library(ggplot2)
   qzlbE<-my_envepisodes$zlb
   sdate <- qzlbE[, 1]
   rates=2
   data_without_sdate <- qzlbE[, -1]
   maxr<-max(zlbE[,rates]) 
   minr<-0 
   
   meltrates_zlb<- melt(data.frame(sdate, data_without_sdate), id.vars = "sdate")
   rates_zlb <- ggplot(meltrates_zlb,aes(x=sdate,y=value,colour=variable,group=variable)) + 
     geom_line() +
     labs(caption="Zero lower bound 3/17/2020-3/16/2022",x="", y = "rates basis points (bp) volume (billion dollars)", color="Rate") +  
     scale_y_continuous(breaks = seq(0,maxr, by = 5), limits = c(0,maxr)) + 
     scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 month") + 
     theme_minimal()
   #print(rates_zlb)
   #my_envepisodes$rates_zlb<-rates_zlb
   
   see Figure \@ref(fig:Reference rates during zero lower bound (zlb) period 3/17/2020-3/16/202)
   #{r,Reference rates during zero lower bound (zlb) period 3/17/2020-3/16/2022, echo=FALSE}
   library(gridExtra)
   library(grid)
   zlb_plots <- grid.arrange(ratests_zlb, rates_zlb, ncol=1)
   grid.text("Zero lower bound (zlb) period 3/17/2020-3/16/2022", x = 0.5, y = -0.1, just = "center")
   print(zlb_plots)
     
   
# INFLATION -------------------------------------------   
   #{r, EFFR during inflation period 03/17/2022-12/14/2023, echo=FALSE}
   rates=2
   vol=3
   targetup = 4
   targetdown = 5
   p1=6
   p25=7
   p75=8
   p99=9
   qinflationE<-my_envepisodes$inflationE
   maxr<-max(qinflationE[,rates]) 
   min(qinflationE[,rates])
  
   #(see Figure \@ref(fig:EFFR during inflation period 3/17/2022-12/14/2023)
   #{r, fig.caption="EFFR during inflation period 3/17/2022-12/14/2023",rates_inflation,echo=FALSE}
    library(ggplot2)
    library(reshape2)
    qinflationE<-my_envepisodes$inflation
    sdate <- qinflationE[, 1]
    rates=2
    data_without_sdate <- qinflationE[, -1]
    maxr<-max(qinflationE[,rates]) 
    minr<-min(qinflationE[,rates])
    
    meltrates_inflation <- melt(data.frame(sdate, data_without_sdate), id.vars = "sdate")
    rates_inflation <<- ggplot(meltrates_inflation,aes(x=sdate,y=value,colour=variable,group=variable)) + 
      geom_line() +
      labs(caption="Inflation 03/17/2022-12/14/2023",x="", y = "rates basis points (bp) volume (billion dollars)", color="Rate") +  
      scale_y_continuous(breaks = seq(0,maxr, by = 50), limits = c(0,maxr)) + 
      theme_minimal()
    #print(rates_inflation)
    #my_envepisodes$rates_inflation<-rates_inflation
    
    #(see Figure \@ref(fig:Reference rates during Taming inflation 03/17/2022-12/14/2023)
    #{r,Reference rates during Taming inflation 03/17/2022-12/14/2023, echo=FALSE}
     library(gridExtra)
     library(grid)
     inflation_plots <- grid.arrange(ratests_inflation, rates_inflation, ncol=1)
     grid.text("Taming inflation 03/17/2022-12/14/2023", x = 0.5, y = -0.1, just = "center")
     print(inflation_plots)
     
     #{r Combine episode dataframes, include=FALSE}
     episodesstats <- my_envepisodes$episodesstats
     episodeschar <- my_envepisodes$episodeschar   


prates <- (rates_norm | rates_adjust |rates_covid ) / (rates_zlb | rates_inflation)
print(prates)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.pdf", prates)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.png", prates)



# Combine xtable objects
#combined_xtable <- rbind(x1, x2, x3)
episodesstats <-rbind(normstats, adjstats,covidstats, zlbstats,inflationstats)
episodeschar <-rbind(charnorm, charadj,charcovid, charzlb,charinflation)

medianstats<-c(ratesamplestats[,2],normstats[,2], adjstats[,2],covidstats[,2], zlbstats[,2], inflationstats[,2])
iqrstats<-c(ratesamplestats[,3],normstats[,3], adjstats[,3],covidstats[,3], zlbstats[,3], inflationstats[,3])
rangestats<-c(ratesamplestats[,4],normstats[,4], adjstats[,4],covidstats[,4], zlbstats[,4], inflationstats[,4])
volumestats<-c(ratesamplestats[,5],normstats[,5], adjstats[,5],covidstats[,5], zlbstats[,5], inflationstats[,5])

combinedstatsall<-rbind(medianstats,iqrstats,rangestats)

Median Sample   Normalcy Adjust  Covid    Zlb  Inflation
EFFR    156.97  133.79   200.09  150.46  8.08  368.60
TGCR    132.83   83.83   206.30  148.64  4.59  362.14
BGCR    132.85   83.85   206.34  148.64  4.59  362.20
SOFR    134.08   84.78   208.22  161.19  5.41  364.07

# CHAT
# Load the xtable package
library(xtable)
# Load the xtable package
library(xtable)
# Load the xtable package
library(xtable)

#Med_table
categories <- c('Sample', 'Normalcy', 'Adjust', 'Covid', 'Zlb', 'Inflation')
# Create the vector medianstats
medianstats <- list(
  ratesamplestats[,2],
  normstats[,2],
  adjstats[,2],
  covidstats[,2],
  zlbstats[,2],
  inflationstats[,2]
)
num_rows <- length(medianstats[[1]])
median_matrix <- sapply(medianstats, "[", 1:num_rows)
rownames(median_matrix) <- c('EFFR', 'TGCR', 'BGCR', 'SOFR')
colnames(med_table) <- categories
med_table <- xtable(median_matrix, caption = "Median Stats")
print(med_table)


#IqR table
# Create the vector iqrstats
iqrstats <- list(
  ratesamplestats[,3],
  normstats[,3],
  adjstats[,3],
  covidstats[,3],
  zlbstats[,3],
  inflationstats[,3]
)
num_rows <- length(iqrstats[[1]])
iqr_matrix <- sapply(iqrstats, "[", 1:num_rows)
rownames(iqr_matrix) <- c('EFFR', 'TGCR', 'BGCR', 'SOFR')
colnames(iqr_table) <- categories
iqr_table <- xtable(iqr_matrix, caption = "iqr Stats")
print(iqr_table)


#Range table--------------------------------
# Create the vector rangestats
rangestats <- list(
  ratesamplestats[,4],
  normstats[,4],
  adjstats[,4],
  covidstats[,4],
  zlbstats[,4],
  inflationstats[,4]
)

num_rows <- length(rangestats[[1]])
range_matrix <- sapply(rangestats, "[", 1:num_rows)
rownames(range_matrix) <- c('EFFR', 'TGCR', 'BGCR', 'SOFR')
colnames(range_table) <- categories
# Create the xtable
range_table <- xtable(range_matrix, caption = "range Stats")
print(range_table)



# combine 3 tables ---------------------------------------------
# Add a line of text between tables
line_text <- c("\\hline", "Additional Information", "\\hline")

# Stack the tables vertically
stacked_table <- rbind(med_table, iqr_table, range_table)

# Determine positions for adding text
positions <- c(nrow(med_table) + 0.5, nrow(med_table) + nrow(iqr_table) + 1.5, nrow(stacked_table) + 0.5)

# Repeat line_text to match the number of positions
line_text_repeated <- rep(line_text, length(positions))

# Create the add.to.row list
add_text <- list(command = as.character(line_text_repeated), pos = positions)

# Print the stacked table with horizontal lines and additional text
print(stacked_table, add.to.row = add_text)


combinedstats_table <- rbind(med_table, iqr_table, range_table)

# Print the combined table
print(combinedstats_table)
#----------------------------------------------------


# Chat table char 3 THIS IS THE ONE!
# Load required libraries
library(xtable)

# Create the data frame
data <- data.frame(
  EFFR = c(133.789044, 75.863636, 143.094406, 118.094406, 129.376457, 133.326340, 134.546620, 147.023310,
           200.093750, 66.843750, 212.890625, 187.890625, 192.078125, 197.250000, 201.906250, 209.750000,
           150.461538, 71.703297, 168.956044, 143.956044, 145.802198, 149.527473, 151.879121, 157.516484,
           8.085149, 68.968317, 25.000000, 0.000000, 5.069307, 7.130693, 8.671287, 12.401980,
           368.601367, 99.564920, 385.649203, 360.649203, 365.448747, 367.562642, 369.177677, 388.813212),
  TGCR = c(83.829837, 158.525641, NA, NA, 79.883450, 83.438228, 83.656177, 85.503497,
           206.296875, 466.218750, NA, NA, 191.656250, 205.625000, 206.921875, 214.359375,
           148.637363, 401.736264, NA, NA, 142.076923, 148.472527, 148.780220, 153.285714,
           4.586139, 353.603960, NA, NA, 2.079208, 4.520792, 4.645545, 13.291089,
           362.141230, 455.915718, NA, NA, 340.849658, 360.990888, 364.255125, 373.123007),
  BGCR = c(83.835664, 166.420746, NA, NA, 79.966200, 83.452214, 83.682984, 88.441725,
           206.343750, 492.468750, NA, NA, 191.796875, 205.625000, 206.984375, 225.796875,
           148.637363, 423.186813, NA, NA, 142.296703, 148.472527, 148.890110, 158.318681,
           4.588119, 376.318812, NA, NA, 2.051485, 4.526733, 4.673267, 13.910891,
           362.195900, 469.753986, NA, NA, 341.457859, 361.013667, 364.375854, 374.797267),
  SOFR = c(84.784382, 350.220280, NA, NA, 81.437063, 83.547786, 86.848485, 89.968531,
           208.218750, 1151.000000, NA, NA, 196.468750, 206.000000, 216.531250, 237.734375,
           151.186813, 1085.604396, NA, NA, 145.615385, 148.714286, 156.087912, 165.076923,
           5.409901, 943.722772, NA, NA, 1.570297, 3.920792, 6.970297, 16.011881,
           364.066059, 1199.936219, NA, NA, 355.364465, 362.034169, 367.712984, 376.717540)
)

# Assign row names
row_names <- c("Rate", "Volume", "Upper target", "Lower target", "Percentile_01",
               "Percentile_25", "Percentile_75", "Percentile_99")

# Assign periods
periods <- c("Normalcy", "Adjustment", "Covid", "Zero lower bound", "Inflation")

# Create an empty list to store each table
tables <- list()

# Populate the list with tables for each period
for (i in seq_along(periods)) {
  start <- (i - 1) * length(row_names) + 1
  end <- i * length(row_names)
  tbl <- data.frame(data[start:end, ])
  # Add number to "Rate" row name to ensure uniqueness
  rownames(tbl) <- ifelse(row.names(tbl) == "Rate", "Rate", paste("Rate", seq_len(nrow(tbl)), sep = "_"))
  tbl$Episode <- ifelse(seq_along(row_names) == 1, paste("\\hline", periods[i], "\\hline"), "")
  tables[[i]] <- tbl
}

# Combine tables with period labels
combined_table <- do.call(rbind, tables)


# Print the xtable
print(xtable(combined_table), include.rownames = TRUE, hline.after = c(0, 8, 16, 24, 32))



# Chat characteristics table
# Load required libraries
library(xtable)

# Create the data frame
data <- data.frame(
  EFFR = c(133.789044, 75.863636, 143.094406, 118.094406, 129.376457, 133.326340, 134.546620, 147.023310,
           200.093750, 66.843750, 212.890625, 187.890625, 192.078125, 197.250000, 201.906250, 209.750000,
           150.461538, 71.703297, 168.956044, 143.956044, 145.802198, 149.527473, 151.879121, 157.516484,
           8.085149, 68.968317, 25.000000, 0.000000, 5.069307, 7.130693, 8.671287, 12.401980,
           368.601367, 99.564920, 385.649203, 360.649203, 365.448747, 367.562642, 369.177677, 388.813212),
  TGCR = c(83.829837, 158.525641, NA, NA, 79.883450, 83.438228, 83.656177, 85.503497,
           206.296875, 466.218750, NA, NA, 191.656250, 205.625000, 206.921875, 214.359375,
           148.637363, 401.736264, NA, NA, 142.076923, 148.472527, 148.780220, 153.285714,
           4.586139, 353.603960, NA, NA, 2.079208, 4.520792, 4.645545, 13.291089,
           362.141230, 455.915718, NA, NA, 340.849658, 360.990888, 364.255125, 373.123007),
  BGCR = c(83.835664, 166.420746, NA, NA, 79.966200, 83.452214, 83.682984, 88.441725,
           206.343750, 492.468750, NA, NA, 191.796875, 205.625000, 206.984375, 225.796875,
           148.637363, 423.186813, NA, NA, 142.296703, 148.472527, 148.890110, 158.318681,
           4.588119, 376.318812, NA, NA, 2.051485, 4.526733, 4.673267, 13.910891,
           362.195900, 469.753986, NA, NA, 341.457859, 361.013667, 364.375854, 374.797267),
  SOFR = c(84.784382, 350.220280, NA, NA, 81.437063, 83.547786, 86.848485, 89.968531,
           208.218750, 1151.000000, NA, NA, 196.468750, 206.000000, 216.531250, 237.734375,
           151.186813, 1085.604396, NA, NA, 145.615385, 148.714286, 156.087912, 165.076923,
           5.409901, 943.722772, NA, NA, 1.570297, 3.920792, 6.970297, 16.011881,
           364.066059, 1199.936219, NA, NA, 355.364465, 362.034169, 367.712984, 376.717540)
)

# Assign row names
row_names <- c("Rate", "Volume", "Upper target", "Lower target", "Percentile_01",
               "Percentile_25", "Percentile_75", "Percentile_99")

# Assign periods
periods <- c("Normalcy", "Adjustment", "Covid", "Zero lower bound", "Inflation")

# Create an empty list to store each table
tables <- list()

# Populate the list with tables for each period
for (i in seq_along(periods)) {
  start <- (i - 1) * length(row_names) + 1
  end <- i * length(row_names)
  tbl <- data.frame(data[start:end, ])
  rownames(tbl) <- row_names
  tbl$Episode <- ifelse(seq_along(row_names) == 1, paste("\\hline", periods[i], "\\hline"), "")
  tables[[i]] <- tbl
}

# Combine tables with period labels
combined_table <- do.call(rbind, tables)

# Print the xtable
print(xtable(combined_table), include.rownames = TRUE, hline.after = c(0, 8, 16, 24, 32))



# Define variable names for statistics
variable_names <- c("Normalcy", "Adjustment", "Covid", "Zero lower bound", "Inflation")

# Print timestamp
cat("Thu Mar 21 21:23:31 2024\n")

# Print LaTeX table environment
cat("\\begin{table}[ht]\n")
cat("\\centering\n")
cat("\\begin{tabular}{rlrrrr}\n")
cat("  \\hline\n")
cat(" & Category & Median & IQR & RANGE & VOLUME \\\\ \n")
cat("  \\hline\n")

# Print table contents (example)
# Replace this with your actual table content
for (i in 1:nrow(episodesstats)) {
  if (grepl("^EFFR", episodesstats[i, "Category"])) {
    if ((i %% 4) == 1 && i != 1) {
      cat(variable_names[(i - 1) / 4 + 1], "\n")  # Insert variable name every 4 rows above "EFFR"
    }
  }
  cat(episodesstats[i, "Category"], " & ",
      episodesstats[i, "Category"], " & ",
      episodesstats[i, "Median"], " & ",
      episodesstats[i, "IQR"], " & ",
      episodesstats[i, "RANGE"], " & ",
      episodesstats[i, "VOLUME"], " \\\\ \n")
}

# Print end of LaTeX table environment
cat("   \\hline\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")




# Define variable names for stats
variable_names <- c("Normalcy", "Adjustment", "Covid", "Zero lower bound", "Inflation")

# Print timestamp
cat("Thu Mar 21 21:23:31 2024\n")

# Print LaTeX table environment
cat("\\begin{table}[ht]\n")
cat("\\centering\n")
cat("\\begin{tabular}{rlrrrr}\n")
cat("  \\hline\n")
cat(" & Category & Median & IQR & RANGE & VOLUME \\\\ \n")
cat("  \\hline\n")

# Print table contents (example)
# Replace this with your actual table content
for (i in 1:nrow(episodesstats)) {
  if (grepl("^EFFR", episodesstats[i, "Category"])) {
    if ((i %% 4) == 1 && i != 1) {
      cat(variable_names[(i - 1) / 4 + 1], "\n")  # Insert variable name every 4 rows above "EFFR"
    }
  }
  cat(episodesstats[i, "Category"], " & ",
      episodesstats[i, "Category"], " & ",
      episodesstats[i, "Median"], " & ",
      episodesstats[i, "IQR"], " & ",
      episodesstats[i, "RANGE"], " & ",
      episodesstats[i, "VOLUME"], " \\\\ \n")
}

# Print end of LaTeX table environment
cat("   \\hline\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")


# OLD Print the combined xtable
#print(xtable(episodesstats),include.rownames = FALSE))
#print(xtable(episodeschar),include.rownames = FALSE))

my_envepisodes$episodesstats <- episodesstats
my_envepisodes$episodeschar <- episodeschar


saveRDS(my_envepisodes, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envepisodes.RDS")


# Identify distribution, densities  ----------------------------
# recall idea to have Monikas idea of a short policy rate, and investigate distribution of FOMC rate changes and macro announcements
# https://rpubs.com/eraldagjika/715261#:~:text=The%20function%20descdist()%20provides,may%20use%20argument%20discrete%3DTRUE.&text=Trying%20to%20fit%20probability%20distributions%20to%20the%20number%20of%20cyber%20attacs
#hist(cyber.data[,2],col="green",main="Histogram attacs",xlab="number of attacs",ylab="Freq")
breakpoints <- c(10, 20, 30, 40, 50, 60)


# histograms and densities --------------------------
# try plotdist in https://www.rdocumentation.org/packages/fitdistrplus/versions/1.1-11
# make histograms as as side graphs to time series plots
#ggside is insane for making side plots with #ggplot.
#Make marginal distributions, side-box plots, & many other #ggplot2 geoms.
# https://t.co/lsXLC0OHzm


density_effr<-plotdist(rrbp[,1], histo = TRUE, breaks = "default", 
                       demp = TRUE, discrete=TRUE)
print(density_effr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/density_effr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/density_effr.png")

# Try this from url
hist_obj$xlab <- "Effective Fed Funds rate"
besthisteffr<-plotdist(rrbp[,1], breaks=num_bins,histo = TRUE, demp = TRUE)
besthisteffr$xAxisTitle <- "Effective Fed Funds rate"
print(besthisteffr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/besthisteffr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/besthisteffr.png")


besthistsofr<-plotdist(rrbp[,5], breaks=num_bins, histo = TRUE, demp = TRUE)
#besthistsofr$xAxisTitle <- "Secured overnight Fed Funds rate"
print(besthistsofr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/besthistsofr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/besthistsofr.png")



density_sofr<-plotdist(rrbp[,5], histo = TRUE, breaks = "default", 
                       demp = TRUE, discrete=TRUE)
print(density_sofr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/density_sofr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/density_sofr.png")

# Cullen and Frey graph for theoretical distribution suggestions
skewkurt_effr<-descdist(rrbp[,1], discrete = TRUE, boot = NULL, method = "sample",
         graph = TRUE, print = TRUE, obs.col = "green", obs.pch = 10, boot.col = "orange")
print(skewkurt_effr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/skewkurt_effr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/skewkurt_effr.png")



# EFFR
ggplot(data = rrbp, aes(sample = rrbp[,1])) +
  geom_qq(distribution = qnorm, color = "blue") +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  #qqline(PercentileE1, col = "steelblue", lwd = 2) +
  labs(x = "Theoretical Quantiles", y = "EFFR") +
  ggtitle("QQ Plot of SOFR vs Normal Distribution")

# SOFR
ggplot(data = rrbp, aes(sample = rrbp[,5])) +
  geom_qq(distribution = qnorm, color = "blue") +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  #qqline(PercentileE1, col = "steelblue", lwd = 2) +
  labs(x = "Theoretical Quantiles", y = "SOFR") +
  ggtitle("QQ Plot of SOFR vs Normal Distribution")

# ------------------ How to fit a distribution in R https://www.youtube.com/watch?v=srsTC9SXajw
# prior work
par(mfrow=(c(2,1))) # arrange 4 plots 2 in each of 2 rows
num_bins <- 20
distr_effr<-hist(rrbp[,1],breaks=num_bins, col="green",main="Histogram for EFFR",xlab="rates",ylab="Freq")
print(distr_effr)
#C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\Figures2
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/distr_effr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/distr_effr.png")


distr_sofr<-hist(rrbp[,5],breaks=num_bins,col="orange",main="Histogram for SOFR",xlab="rates",ylab="Freq")
print(distr_sofr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/distr_sofr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/distr_sofr.png")

par(mfrow=(c(2,1))) # arrange 4 plots 2 in each of 2 rows
num_bins <- 20
distr_effr<-hist(rrbp[,1],breaks=num_bins, col="green",main="Histogram for EFFR",xlab="rates",ylab="Freq")
print(distr_effr)
distr_sofr<-hist(rrbp[,5],breaks=num_bins,col="orange",main="Histogram for SOFR",xlab="rates",ylab="Freq")
print(distr_sofr)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/hist_effr_sofr.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/hist_effr_sofr.png")

# summary(rrbp[,1])
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0     9.0    91.0   108.3   190.0   433.0 
# > summary(rrbp[,5])
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0     8.0    91.0   108.1   190.0   525.0 

# summary(rrbp[,2])
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0     9.0    81.0   104.8   184.5   432.0 

# summary(rrbp[,3])
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0     8.0    79.0   104.4   184.5   525.0 
# > summary(rrbp[,4])
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0     7.0    80.0   105.5   186.5   525.0 

# a. fitdistr
descdist(data=rrbp[,1],discrete=TRUE)
numbin=20 #breaks=numbin,
#b. fitur
# library(actuar)
# fitur::fit_dist_addin




#spreads-----------------------------------------------------
k=1
ioreffr<-spread$IORR-rrbp[,k]
k=5
iorsofr<-spread$IORR-rrbp[,k]
rrppsofr<-spread$RRPONTSYAWARD-rrbp[,k]

keyspreads <- ggplot(spread, aes(x = sdate)) +
  geom_line(aes(y = iorsofr, color = "IOR-SOFR"), linewidth = 1) + 
  geom_line(aes(y = rrppsofr, color = "Reverse repo-SOFR"), linewidth = 1) + 
  geom_line(aes(y = ioreffr, color = "IOR-EFFR"), linewidth = 1) + 
  labs(x = "Date", y = "basis points (bp)") + 
  scale_color_manual(values = c("IOR-SOFR" = "red", "Reverse repo-SOFR" = "blue","IOR-EFFR"="green")) + 
  theme_minimal()+
  scale_y_continuous(breaks = y_breaks, limits = y_limits)                                                                                                                                                                                           
print(keyspreads)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/spreads.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/spreads.png")

# ------------------------------ Volatility and dispersion measures
# Sample stats and histograms?          
# average median values of sample

p2575E<-quantileE[6]-quantileE[5]  # interquartile
p0199E<-quantileE[7]-quantileE[4]  $ range
p2575S<-quantileS[4]-quantileES[3]
p0199S<-quantileES[5]-quantileES[2]

# summary(cyber.data[,c(2,3)])# descriptive statistics of our dataset
# summary(rrbp)
# EFFR            OBFR            TGCR            BGCR            SOFR      
# Min.   :  1.0   Min.   :  1.0   Min.   :  1.0   Min.   :  1.0   Min.   :  1.0  
# 1st Qu.:  9.0   1st Qu.:  9.0   1st Qu.:  8.0   1st Qu.:  7.0   1st Qu.:  8.0  
# Median : 91.0   Median : 81.0   Median : 79.0   Median : 80.0   Median : 91.0  
# Mean   :108.3   Mean   :104.8   Mean   :104.4   Mean   :105.5   Mean   :108.1  
# 3rd Qu.:190.0   3rd Qu.:184.5   3rd Qu.:184.5   3rd Qu.:186.5   3rd Qu.:190.0  
# Max.   :433.0   Max.   :432.0   Max.   :525.0   Max.   :525.0   Max.   :525.0 



# Convert the list to a data frame
stats_effr <- as.data.frame(stats_metricE)
# Print the data frame using xtable
print(xtable(stats_effr))
# see also mean deviation

# https://libertystreeteconomics.newyorkfed.org/2023/08/the-federal-reserves-two-key-rates-similar-but-not-the-same/
# 
# NYFed
# Gara The deviation of the effective funds rate
# from the target rate (or its absolute value) is widely used to
# gauge average performance of the rate over an entire day
# DK The dispersion index D at day t as the weighted mean absolute deviation of the cross-sectional adjusted rate
# distribution on that day
# Gara
# ALonso dispersion index from target rates
# Targets quintile plots in stirregv

#The daily value of $D_t$ is the deviations between the value weighted daily 
#fed funds rate and the FOMC target, for 2017-2022.
#FF > upper target TU
#Equation 1:
  #$D_t = \overline{\rho}_t - \rho_{max,t}$ if $\rho_{max,t} < \overline{\rho}_t$ 
  #Equation 2:
  #$D_t = \overline{\rho}_t - \rho_{min,t}$ if $\overline{\rho}_t < \rho_{min,t}$ 
  #FF < lower target 
  #Equation 3:
  #$D_t = \overline{\rho}_t - \rho_{min,t}$ if $\overline{\rho}_t <\rho_{min,t}$
  # Equation 4:
  # $D_t=0$ if $\rho_{min,t}<\overline{\rho}_t <\rho_{max,t} $
  # 
  # Create a data frame with the equations
  equations_df <- data.frame(Equation = c(equation1, equation2,equation3, equation4))

# Display the table
# kable(equations_df, format = "latex", escape = FALSE, booktab
#       
#       cat("Equation 1:\n")
#       cat(eq1, "\n")
#       
#       cat("Equation 2:\n")
#       cat(eq2, "\n")
#       
#       cat("Equation 3:\n")
#       cat(eq3, "\n")
#       
#       cat("Equation 4:\n")
#       cat(eq4, "\n")
#       
      
      # Alternative
      # Define the variables
      D_t = 0
      rho_bar_t= 0
      rho_max_t= 0
      rho_min_t= 0
      
      # Calculate D_t based on conditions
      if (rho_max_t < rho_bar_t) {
        D_t <- rho_bar_t - rho_max_t
      } else if (rho_bar_t < rho_min_t) {
        D_t <- rho_bar_t - rho_min_t
      }
      
      # the volatility of the fed funds rate, let ¯ρt denote the value-weighted
      # fed funds rate (average for day t). Let ρmaxt be the upper bound for the FOMC policy target
      # band for day t, and let ρmint be the lower bound of the band. Define the deviation from target
      # on day t, denoted Dt
      
      
      # Initialize 'g' vector
      n=nrow(rrbp)
      g <- numeric(n)  # Replace 'n' with the actual number of rows
      g  = zeros(size(spread,1))
      # Loop through 't' values
      
      for (t in seq_len(n)) {
        if (!is.na(spread$TargetUe[t]) && !is.na(rrbp[t, 1])) {
          if (spread$TargetUe[t] < rrbp[t, 1]) {
            # Upper target
            g[t] <- rrbp[t, 1] - spread$TargetUe[t]
          } else if (!is.na(spread$TargetDe[t]) && rrbp[t, 1] < spread$TargetDe[t]) {
            # Lower target
            g[t] <- rrbp[t, 1] - spread$TargetDe[t]
          } else {
            # Handle other cases (if neither condition is met)
            # You can assign a default value to 'g[t]' or handle it as needed
          }
        } else {
          # Handle cases where 'spread$TargetUe[t]' or 'rrbp[t, 1]' is NA
          # You can assign a default value to 'g[t]' or handle it as needed
        }
      }
      
      k=5
      begn<-c(1,859,923,1014,1519,1)
      endn<-c(858,922,1013,1518,1957,1957)
      #begn<- c(1, 857, 921,  1020, 1514, 1) OLD
      #endn<- c(856, 920, 1029, 1513, 1711, 1711) OLD
      y_breaks=50
      y_limits=500
      
      
      # spread["AGSA"]<-g
      # spread_filtered <- spread %>%
      #   filter(!is.na(rrbp[begn[k]:endn[k], 1]) & !is.na(g[begn[k]:endn[k]]) & !is.na(TargetDe[begn[k]:endn[k]])& !is.na(TargetDe[begn[k]:endn[k]]))
      # #[begn[k]:endn[k]]
      gara <- ggplot(spread_filtered, aes(x = sdate)) +
        geom_line(aes(y = rrbp[begn[k]:endn[k],1], color = "EFFR"), linewidth =1) + 
        #geom_line(aes(y = spread$TargetDe[begn[k]:endn[k]], color = "Lower target"), linewidth = 1) + 
        #geom_line(aes(y = spread$TargetUe[begn[k]:endn[k]], color = "Upper target"), linewidth = 1) + 
        #geom_line(aes(y = mad[begn[k]:endn[k],4], color = "MAD"), linewidth = 1) + 
        #geom_line(aes(y = g[begn[k]:endn[k]], color = "Gara"), linewidth = 1) + 
        labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
        scale_color_manual(values = c("EFFR" = "black", "Lower target rate" = "blue", "Upper target rate" = "green","Gara" = "red")) + 
        scale_y_continuous(breaks = y_breaks, limits = y_limits) + 
        theme_minimal()
      print(gara)
      #  "MAD" = "orange", 
      #C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\Figures2
      ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/gara.pdf")
      ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/gara.png")
      
      
      
      
      file_path<-"C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Data/indices2.csv"
      write.csv(dk_data, file = file_path, row.names = FALSE)
      
      # Duffie Krishnamurthy ------------------------------------
      custom_colors <- c("Duffie Krishnamurthy index" = "black", "Lower target FFR" = "blue", "Upper target FFR" = "green")
      ggdkindex<-ggplot(dk_data, aes(x = sdate)) +
        geom_point(aes(y = dk_data[,7], color = "Duffie Krishnamurthy index"), shape = 16, size = 1) + 
        geom_point(aes(y = TargetDe, color = "Lower target FFR"), shape = 16, size = 1) + 
        geom_point(aes(y = TargetUe, color = "Upper target FFR"), shape = 16, size = 1) +
        # geom_point(aes(y = rrbp[,3], color = "TGCR"), shape = 16, size = 1) + 
        # geom_point(aes(y = rrbp[,4], color = "BGCR"), shape = 16, size = 1) + 
        # geom_point(aes(y = rrbp[,5], color = "SOFR"), shape = 16, size = 1) + 
        labs(x = "Date", y = "Y-axis", color = "Lines") +
        scale_color_manual(values = c("Duffie Krishnamurthy index" = "black", "Lower target FFR" = "blue", "Upper target FFR"= "green" )) + 
        #scale_color_manual(values = c("EFFR" = "black", "OBFR" = "blue", "TGCR" = "green", "BGCR" = "orange", "SOFR" = "red")) + 
        theme_minimal()+
        theme(
          plot.background = element_rect(fill = "white"),  # Set overall plot background to white
          panel.background = element_rect(fill = "white"),  # Set the background for the plot area to white
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          legend.background = element_rect(fill = "white"),  # Set legend background to white
          legend.text = element_text(color = custom_colors),  # Set legend text color to match plot colors
          axis.text = element_text(color = "black")
        )
      print(ggdkindex)
      ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggdkindex.pdf")
      ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/ggdkindex.png")
      
      
      #https://r4ds.had.co.nz/data-visualisation.html
      #https://r4ds.had.co.nz/graphics-for-communication.html
      
      # old DISPERSION PLOTS
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
      dkindex <- numeric(1710)
      meanr> colMeans(rrbp)
      # EFFR  OBFR  TGCR  BGCR  SOFR 
      # FALSE FALSE FALSE FALSE FALSE 
      colsumvold <-rowSums(vold[ , c(1,2,3,4,5)], na.rm=TRUE)
      colsumvold[1:10]
      #[1] 1739 1730 1714 1691 1671 1693 1705 1656 1658 1641
      
      T<-nrow(rrbp)
      # Calculate dk(t)
      for (t in 1:T) {
        for (i in 1:rcol) {
          dk[t, i] <- (1 / colsumvold[t]) * vold[t,i]*abs(rrbp[t, i] - meanr[i])
        }
      }
      
      # Calculate dkindex(t)
      for (t in 1:T) {
        dkindex[t] <- sum(dk[t, 1:rcol])
      }
      
      
      # ----------------------- Histograms and distributions
      
# see fed liberty street quote 
T=nrow(spread)  # Replace 5 with the desired number of rows
dgaraa <- rep(0, times = T)
nrow(dgaraa)

quantilesE["TargetUe-EFFR"]= -quantilesE$TargetUe-quantilesE$EFFR #if <0 EFFR exceed Upper bound
cat("TargetUe-EFFR", bondcoupon[, "EFFR-TargetUe"], "\n")

quantilesE["EFFR-TargetDe"]= quantilesE$EFFR- quantilesE$TargetDe if <0 EFFR less than lower bound
cat("EFFR-TargetDe", bondcoupon[, "EFFR-TargetDe"], "\n")

#bondcoupon["yield"] <- bondcoupon[, "coupon payment"] / bondcoupon[, "pricecoupon"]
$cat("yield", bondcoupon[, "yield"], "\n")

begn<-  520
for (t in 520:T) {
  if (rrbp[t,1] > quantilesE$TargetUe[t]) {
    dgaraa[t] <- rrbp[t, 1] - quantilesE$TargetUe[t] } # greater than TU
  else if (rrbp[t, 1] < quantilesE$TargetDe[t]) {
    dgaraa[t] <- rrbp[t, 1] - quantilesE$TargetDe[t] }  # less than TD
}

# MADM, the median absolute deviation
urrbp= quantilesE$TargetUe-quantilesE$EFFR
drrbp= quantilesE$EFFR- quantilesE$TargetDe
distance=c(urrbp,drrbp)
print(distance[520:T,])
deviation<-c(urrbp,drrbp)
str(deviation)

devgara <- ggplot(quantilesE, aes(x = sdate)) +
  geom_line(aes(y = dgaraa, color = "Deviation"), linewidth = 1) + 
  geom_line(aes(y = quantilesE[,2], color = "Upper target"), linewidth = 1) + 
  geom_line(aes(y = quantilesE[,3], color = "Lower target"), linewidth = 1) + 
  labs(x = "Date", y = "basis points (bp)") + 
  scale_color_manual(values = c("Deviation" = "red", "Upper target" = "blue","Lower target"="green")) + 
  theme_minimal()+
  scale_y_continuous(breaks = y_breaks, limits = y_limits)                                                                                                                                                                                           
print(devgara)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/spreads.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/spreads.png")

fomc <- ggplot(quantilesE, aes(x = sdate)) +
  geom_line(aes(y = quantilesE[,1], color = "EFFR"), linewidth = 1) + 
  geom_line(aes(y = quantilesE[,2], color = "Upper target"), linewidth = 1) + 
  geom_line(aes(y = quantilesE[,3], color = "Lower target"), linewidth = 1) + 
  labs(x = "Date", y = "basis points (bp)") + 
  scale_color_manual(values = c("EFFR" = "red", "Upper target" = "blue","Lower target"="green")) + 
  theme_minimal()+
  scale_y_continuous(breaks = y_breaks, limits = y_limits)                                                                                                                                                                                           
print(fomc)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/fomc.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/fomc.png")


fomc <- ggplot(quantilesE, aes(x = sdate)) +
  geom_line(aes(y = quantilesE[,1], color = "EFFR"), linewidth = 1) + 
  geom_line(aes(y = quantilesE[,2], color = "Upper target"), linewidth = 1) + 
  geom_line(aes(y = quantilesE[,3], color = "Lower target"), linewidth = 1) + 
  labs(x = "Date", y = "basis points (bp)") + 
  scale_color_manual(values = c("EFFR" = "red", "Upper target" = "blue","Lower target"="green")) + 
  theme_minimal()+
  scale_y_continuous(breaks = y_breaks, limits = y_limits)                                                                                                                                                                                           
print(fomc)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/fomc.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/fomc.png")

fomcrange<-data.frame(rrbp$EFFR,dgara,urrbp,drrbp)
targets <- ggplot(fomcrange, aes(x = sdate)) +
  geom_line(aes(y = fomcrange[,1],color = "EFFR"), linewidth = 1) + 
  geom_line(aes(y = urrbp, color = "Upper target"), linewidth = 1) + 
  geom_line(aes(y = drrbp, color = "Lower target"), linewidth = 1) + 
  labs(x = "Date", y = "basis points (bp)") + 
  scale_color_manual(values = c("EFFR" = "red", "Upper target" = "blue","Lower target"="green")) + 
  theme_minimal()+
  scale_y_continuous(breaks = y_breaks, limits = y_limits)                                                                                                                                                                                           
print(targets)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/fomc.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/fomc.png")

grid.arrange(devgara, fomc, targets, ncol = 3)




# Monthly data -----------------------------------
headers=  read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/FeDFunds_monthly.csv',header=F, nrows=1) #,as.is=T)
effrm <- read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/FeDFunds_monthly.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE,skip=4)
colnames(effrm )=headers
class(effrm )
mdate<-as.Date(effrm$DATE,"%m/%d/%Y") # not working  
# observations row 743 4/1/2016	0.37
# observations row 740 1/1/2016	0.34
# observations row 823 12/1/2022	4.1
# https://fred.stlouisfed.org/series/FEDFUNDS
# References
# (1) Federal Reserve Bank of New York. "Federal funds." Fedpoints, August 2007.
# (2) Board of Governors of the Federal Reserve System. "Monetary Policy".
# Suggested Citation:
#   Board of Governors of the Federal Reserve System (US), Federal Funds Effective Rate [FEDFUNDS], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/FEDFUNDS, September 26, 2023.

headers=  read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/SOFR30DAYAVG.csv',header=F, nrows=1) #,as.is=T)
sofrm <- read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/SOFR30DAYAVG.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE,skip=4)
colnames(sofrm )=headers
class(sofrm )
# As an extension of the Secured Overnight Financing Rate (SOFR), the 30-day SOFR Average is the compounded average of the SOFR over a rolling 30-day period.
# For more information on the production of the SOFR Averages and Index—including the calculation methodology, treatment of non-business days, and value dates—please read the additional documentation about the Treasury Repo Reference Rates.
# Suggested Citation:
#   Federal Reserve Bank of New York, 30-Day Average SOFR [SOFR30DAYAVG], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/SOFR30DAYAVG, September 27, 2023.



  
# ------------------------------Shocks needs work
# C:\Users\Owner\Documents\Research\MonetaryPolicy\MonetaryPolicy\Data\Final data files\shocks.csv
# [Link Text](http://www.example.com)
# 
# To display link <http://www.example.com>
#   



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


  
# Multiboxplots for sample ----------------------------------------
my_environmentbox <- new.env()

#March 2 https://stackoverflow.com/questions/61912097/boxplot-in-r-using-prescribed-percentile-data


boxplot_sample <- data.frame(
  Group = structure(1:4, .Label = c("EFFR", "TGCR", "BGCR", "SOFR"), class = "factor"),
  y0 = c(Estats[5], Tstats[3], Bstats[3], Sstats[3]),
  y25 = c(Estats[6], Tstats[4], Bstats[4], Sstats[4]),
  y50 = c(Estats[1], Tstats[1] , Bstats[1] , Sstats[1]) ,
  y75 = c(Estats[7], Tstats[5], Bstats[5], Sstats[5]),
  y100 = c(Estats[8], Tstats[6], Bstats[6], Sstats[6]))

library(ggplot2)
  bsample <- ggplot(boxplot_sample, aes(x = Group,
                                        ymin = y0,
                                        ymax = y100,
                                        lower = y25,
                                        middle = y50,
                                        upper = y75,
                                        fill = Group)) +
    labs(caption = "Sample rates 3/4/2016-12/14/2023", x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
    geom_boxplot(stat = "identity") +
    theme(panel.background = element_rect(fill = "white"),
          plot.background = element_rect(fill = "white"))
  print(bsample)
  #my_environmentbox$sample<-bsample 
  
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bsample.pdf")
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bsample.png")
  
  
  # boxplots episodes---------------------------------------------------
  # Normalcy
  # 
  # y0 = c(min(quantilesE$EFFR), min(quantilesT$TGCR), min(quantilesB$BGCR), min(quantilesS$SOFR)),
  # y25 = c(quantile(quantilesE$Percentile25_EFFR, 0.25), quantile(quantilesT$Percentile25_TGCR, 0.25), quantile(quantilesB$Percentile25_BGCR, 0.25), quantile(quantilesS$Percentile25_SOFR, 0.25)),
  # y50 = c(median(quantilesE$EFFR), median(quantilesT$TGCR), median(quantilesB$BGCR), median(quantilesS$SOFR)),
  # y75 = c(quantile(quantilesE$Percentile75_EFFR, 0.75), quantile(quantilesT$Percentile75_TGCR, 0.75), quantile(quantilesB$Percentile75_BGCR, 0.75), quantile(quantilesS$Percentile75_SOFR, 0.75)),
  # y100 = c(max(quantilesE$EFFR), max(quantilesT$TGCR), max(quantilesB$BGCR), max(quantilesS$SOFR)))

  # Send dataframe data to rmarkdown--------------------------------
  # Create a new environment
 
  
  
  # Save the environment to an RDS file
  #saveRDS(my_environmentbox, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_environmentbox.RDS")
  
  # Render the R Markdown document
  #rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11292023b.Rmd",envir= my_envmp)
  rmarkdown::render("C:/Users/Owner/Documents/Research/OvernightRates/ONrates03072024.Rmd",envir= my_envmp)
  
  # my_env$bondcoupon <- bondcoupon
  my_data<- my_envbox$spread_no_na
  str(my_data)
  # Send dataframe data to rmarkdown--------------------------------
  # Create a new environment
  my_envmp <- new.env()
  
  # Store your data frame in the environment
  #my_envmp$spread_no_na <-spread_no_na
  
  # Save the environment to an RDS file
  saveRDS(my_envmp, file = "C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/my_environmentmp.RDS")
  
  # Render the R Markdown document
  #rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates11292023b.Rmd",envir= my_envmp)
  rmarkdown::render("C:/Users/Owner/Documents/Research/MonetaryPolicy/MPResults/LaTeX/ONrates12112023.Rmd",envir= my_envmp)
  
  # my_env$bondcoupon <- bondcoupon
  my_data<- my_envmp$spread_no_na
  str(my_data)
  
  
boxplot_normalcy <- data.frame(
  Group = structure(1:4, .Label = c("EFFR", "TGCR", "BGCR", "SOFR"), class = "factor"),
  y0 = c(Estatsnorm[5], Tstatsnorm[3], Bstatsnorm[3], Sstatsnorm[3]),
  y25 = c(Estatsnorm[6], Tstatsnorm[4], Bstatsnorm[4], Sstatsnorm[4]),
  y50 = c(Estatsnorm[1], Tstatsnorm[1] , Bstatsnorm[1] , Sstatsnorm[1]) ,
  y75 = c(Estatsnorm[7], Tstatsnorm[5], Bstatsnorm[5], Sstatsnorm[5]),
  y100 = c(Estatsnorm[8], Tstatsnorm[6], Bstatsnorm[6], Sstatsnorm[6]))

bnormalcy <- ggplot(boxplot_normalcy , aes(x=Group,
                                           ymin = y0,
                                           ymax = y100,
                                           lower = y25,
                                           middle = y50,
                                           upper = y75,
                                           fill = Group)) +
  labs(caption = "Normalcy 3/4/2016-7/31/2019", x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
  geom_boxplot(stat = "identity") +
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"))
print(bnormalcy)
  my_environmentbox$norm <-bnormalcy 
 
  
  #str(boxplot_normalcy)
  # 'data.frame':	4 obs. of  6 variables:
  #   $ Group: Factor w/ 4 levels "EFFR","TGCR",..: 1 2 3 4
  # $ y0   : num  4 0 0 0
  # $ y25  : num  9 0 0 0
  # $ y50  : num  116 7 7 9
  # $ y75  : num  233 229 230 230
  # $ y100 : num  533 531 531 539
  
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bnormalcy.pdf")
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bnormalcy.png")
  
  
  # Adjust
  boxplot_adjust<- data.frame(
    Group = structure(1:4, .Label = c("EFFR", "TGCR", "BGCR", "SOFR"), class = "factor"),
    y0 = c(Estatsadj[5], Tstatsadj[3], Bstatsadj[3], Sstatsadj[3]),
    y25 = c(Estatsadj[6], Tstatsadj[4], Bstatsadj[4], Sstatsadj[4]),
    y50 = c(Estatsadj[1], Tstatsadj[1] , Bstatsadj[1] , Sstatsadj[1]) ,
    y75 = c(Estatsadj[7], Tstatsadj[5], Bstatsadj[5], Sstatsadj[5]),
    y100 = c(Estatsadj[8], Tstatsadj[6], Bstatsadj[6], Sstatsadj[6]))
  
  badjust<-ggplot(boxplot_adjust , aes(x=Group,
                                           ymin = y0,
                                           ymax = y100,
                                           lower = y25,
                                           middle = y50,
                                           upper = y75,
                                           fill = Group)) +
    labs(caption = "Mid cycle adjustment 8/1/2019-10/31/2019", x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
    geom_boxplot(stat = "identity") +  
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"))
  
  print(badjust)
  my_environmentbox$adjust <-badjust 
  
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/badjust.pdf")
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/badjust.png")
  
  # Covid
  boxplot_covid <- data.frame(
    Group = structure(1:4, .Label = c("EFFR", "TGCR", "BGCR", "SOFR"), class = "factor"),
    y0 = c(Estatscovid[5], Tstatscovid[3], Bstatscovid[3], Sstatscovid[3]),
    y25 = c(Estatscovid[6], Tstatscovid[4], Bstatscovid[4], Sstatscovid[4]),
    y50 = c(Estatscovid[1], Tstatscovid[1] , Bstatscovid[1] , Sstatscovid[1]) ,
    y75 = c(Estatscovid[7], Tstatscovid[5], Bstatscovid[5], Sstatscovid[5]),
    y100 = c(Estatscovid[8], Tstatscovid[6], Bstatscovid[6], Sstatscovid[6]))
  
  bcovid<-ggplot(boxplot_covid, aes(x=Group,
                                           ymin = y0,
                                           ymax = y100,
                                           lower = y25,
                                           middle = y50,
                                           upper = y75,
                                           fill = Group)) +
    labs(caption = "Covid 11/1/2019-3/16/2020", x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
    geom_boxplot(stat = "identity") +  
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"))
  print(bcovid)
  my_environmentbox$covid <-  bcovid 

  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bcovid.pdf")
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bcovid.png")
  
  # ZLB 
  boxplot_zlb <- data.frame(
    Group = structure(1:4, .Label = c("EFFR", "TGCR", "BGCR", "SOFR"), class = "factor"),
    y0 = c(Estatszlb[5], Tstatszlb[3], Bstatszlb[3], Sstatszlb[3]),
    y25 = c(Estatszlb[6], Tstatszlb[4], Bstatszlb[4], Sstatszlb[4]),
    y50 = c(Estatszlb[1], Tstatszlb[1] , Bstatszlb[1] , Sstatszlb[1]) ,
    y75 = c(Estatszlb[7], Tstatszlb[5], Bstatszlb[5], Sstatszlb[5]),
    y100 = c(Estatszlb[8], Tstatszlb[6], Bstatszlb[6], Sstatszlb[6]))
  
  bzlb<-ggplot(boxplot_zlb , aes(x=Group,
                                           ymin = y0,
                                           ymax = y100,
                                           lower = y25,
                                           middle = y50,
                                           upper = y75,
                                           fill = Group)) +
    labs(caption = "Zero lower bound  3/17/2020-3/16/2022", x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
    geom_boxplot(stat = "identity") +
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"))
  
  print(bzlb)
  my_environmentbox$zlb <-  bzlb
  
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bzlb.pdf")
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bzlb.png")
 
  

  # caption = "Inflation 03/17/2022-12/14/2023",
  # Inflation-------------------------------------------
  boxplot_inflation <- data.frame(
  Group = structure(1:4, .Label = c("EFFR", "TGCR", "BGCR", "SOFR"), class = "factor"),
  y0 = c(Estatsinflation[5], Tstatsinflation[3], Bstatsinflation[3], Sstatsinflation[3]),
  y25 = c(Estatsinflation[6], Tstatsinflation[4], Bstatsinflation[4], Sstatsinflation[4]),
  y50 = c(Estatsinflation[1], Tstatsinflation[1] , Bstatsinflation[1] , Sstatsinflation[1]) ,
  y75 = c(Estatsinflation[7], Tstatsinflation[5], Bstatsinflation[5], Sstatsinflation[5]),
  y100 = c(Estatsinflation[8], Tstatsinflation[6], Bstatsinflation[6], Sstatsinflation[6])
  
  binflation<-ggplot(boxplot_inflation , aes(x=Group,
                                       ymin = y0,
                                       ymax = y100,
                                       lower = y25,
                                       middle = y50,
                                       upper = y75,
                                       fill = Group)) +
    labs(caption = "Inflation 03/17/2022-12/14/2023", x="",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
    geom_boxplot(stat = "identity") +
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"))
  print(binflation)
  my_environmentbox$inflation <-binflation 
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bzlb.pdf")
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/bzlb.png")
  
  saveRDS(my_environmentbox, file = "C:/Users/Owner/Documents/Research/OvernightRates/my_envbox.RDS")
  
  # Combine boxplots
  pboxplots<-(bnormalcy | badjust ) / (bcovid | bzlb) / (binflation | bsample)
  print(pboxplots)
  my_environmentbox$pboxplots<-pboxplots
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/boxplots.pdf")
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/boxplots.png")
  
  
  
  # Alternative Arrange plots in a 2x3 grid (2 rows, 3 columns)
  plot_grid(
    bnormalcy, badjust, bcovid,
    bzlb, binflation, bsample,
    ncol = 3  # Number of columns in the grid
  )
 
  #labels = c("A", "B", "C", "D", "E"),
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.pdf", pboxplots)
  ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/episoderates.png", pboxplots)
  
# another method combine plots 
combined_plot <- ggarrange(be,
                           bs,
                           nrow = 2,
                           ncol = 1) 


#-------------------------------------------------------
# Distributions and histograms
descdist(data=rrbp[,2],discrete=TRUE)
numbin=50 #breaks=numbin,
par(mfrow=(c(3,1))) # arrange 4 plots 2 in each of 2 rows
normal_<-fitdist(rrbp[,2],"norm")
nbin_<-fitdist(rrbp[,2],"nbinom")
pois_<-fitdist(rrbp[,2],"pois")


normE<-plot(normal_)
nbinE<-plot(nbin_)
#plot(pois_)
print(normE)
ggsave("C:/Users/Owner/Documents/Research/OvernightRates/Figures/normE.pdf")
ggsave("C:/Users/Owner/Documents/Research/V/Figures/normE.png")
print(normal_)

# Distributions and histograms
descdist(data=rrbp[,3],discrete=TRUE)
numbin=50 #breaks=numbin,
par(mfrow=(c(3,1))) # arrange 4 plots 2 in each of 2 rows
normal_<-fitdist(rrbp[,3],"norm")
nbin_<-fitdist(rrbp[,3],"nbinom")
#pois_<-fitdist(rrbp[,3],"pois")


normEadj<-plot(normal_)
nbinEadj<-plot(nbin_)
#plot(pois_)
print(normEadj)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEadj.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEadj.png")


# print(nbinE)
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.pdf")
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.png")

print(normal_)
# Fitting of the distribution ' norm ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# mean 108.29106   2.371974
# sd    98.11497   1.677240

print(nbin_)
# Fitting of the distribution ' nbinom ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# size   0.7834525 0.02365515
# mu   108.2425026 2.96577371
#print(pois_)

summary(normal_)
summary(nbin_)
#summary(pois_)

# Distributions and histograms
descdist(data=rrbp[,4],discrete=TRUE)
numbin=20 #breaks=numbin,
par(mfrow=(c(3,1))) # arrange 4 plots 2 in each of 2 rows
normal_<-fitdist(rrbp[,4],"norm")
nbin_<-fitdist(rrbp[,4],"nbinom")
#pois_<-fitdist(rrbp[,4],"pois")


normEcovid<-plot(normal_)
nbinEcovid<-plot(nbin_)
#plot(pois_)
print(normEcovid)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEcovid.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEcovid.png")

# not good
# nbinE<-plot(nbin_)
# print(nbinE)
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.pdf")
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.png")

print(normal_)
# Fitting of the distribution ' norm ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# mean 108.29106   2.371974
# sd    98.11497   1.677240

print(nbin_)
# Fitting of the distribution ' nbinom ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# size   0.7834525 0.02365515
# mu   108.2425026 2.96577371
#print(pois_)

summary(normal_)
summary(nbin_)
#summary(pois_)


# Distributions and histograms
descdist(data=rrbp[,5],discrete=TRUE)
numbin=20 #breaks=numbin,
par(mfrow=(c(3,1))) # arrange 4 plots 2 in each of 2 rows
normal_<-fitdist(rrbp[,5],"norm")
nbin_<-fitdist(rrbp[,5],"nbinom")
#pois_<-fitdist(rrbp[,5],"pois")


normEzlb<-plot(normal_)
nbinEzlb<-plot(nbin_)
#plot(pois_)
print(normEzlb)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEzlb.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEzlb.png")

# not good
# nbinE<-plot(nbin_)
# print(nbinE)
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.pdf")
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.png")

print(normal_)
# Fitting of the distribution ' norm ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# mean 108.29106   2.371974
# sd    98.11497   1.677240

print(nbin_)
# Fitting of the distribution ' nbinom ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# size   0.7834525 0.02365515
# mu   108.2425026 2.96577371
#print(pois_)

summary(normal_)
summary(nbin_)
#summary(pois_)


# Distributions and historams
descdist(data=rrbp[,6],discrete=TRUE)
numbin=20 #breaks=numbin,
par(mfrow=(c(3,1))) # arrange 4 plots 2 in each of 2 rows
normal_<-fitdist(rrbp[,6],"norm")
nbin_<-fitdist(rrbp[,6],"nbinom")
#pois_<-fitdist(rrbp[,6],"pois")
print(normal_)

normEinflation<-plot(normal_)
nbinEinflation<-plot(nbin_)
#plot(pois_)
print(normEinflation)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEinflation.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/normEinflation.png")

# not good
# nbinE<-plot(nbin_)
# print(nbinE)
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.pdf")
# ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/nbinE.png")

print(normal_)
# Fitting of the distribution ' norm ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# mean 108.29106   2.371974
# sd    98.11497   1.677240

print(nbin_)
# Fitting of the distribution ' nbinom ' by maximum likelihood 
# Parameters:
#   estimate Std. Error
# size   0.7834525 0.02365515
# mu   108.2425026 2.96577371
#print(pois_)

summary(normal_)
summary(nbin_)
#summary(pois_)


grid_episodes <- grid.arrange(ggnorm,ggcovd, ggadj, ggzlb, ggpi,ncol = 5)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/episodes.png", grid_epsiodes, width = 12, height = 8, dpi = 300)

ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/dailyrates.png")
grid_arrangement <- grid.arrange(ggnorm,ggadj, ggzlb, ncol = 4)
ggsave("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Figures/Figures2/storyOnrates.png", grid_arrangement, width = 12, height = 8, dpi = 300)

# -------------------------------------- DELETE until line 1892-----------------------------------------
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


# ---------------------------------------
percentile <-ggplot(normE, aes(x = sdate)) +
#geom_line(aes(y = normalcy, color = "EFFR", linetype ="solid", linewidth = 1.5, alpha = 1.25) + 
              #geom_area(aes(ymin = normE[,4], ymax= normE[,5])
              #          ,fill = "Area between 25th and 75th percentile"), alpha = 0.5) +
              geom_line(aes(y = normE[,2]*, color = "25 pct", linetype = "solid", color = "black",linewidth = 1, alpha = 0.8) + 
                          #geom_line(aes(y = normE[,5]*100, color = "75 pct", linetype ="dashed", linewidth = 1, alpha = 0.8) + 
                                      geom_line(aes(y = normE[,4]), color = "green") +
                                      geom_line(aes(y = normE[,5], color = "green") +
                                      geom_ribbon(aes(x = sdate,
                                                      ymin = normE[,7],
                                                      ymax = normE[,8]),
                                                  fill ="grey80")+
                                      labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
                                      #ylim= c(0,450)+
                                      scale_color_manual(values = c("EFFR" = "blue))
  #scale_color_manual(values = c("EFFR" = "blue, "25 pct" = "grey", "75 pct" = "grey" )) + 
                                      #scale_color_manual(values = c("EFFR" = "black","Lower target" = "green","Upper target" = "blue", "25 pct" = "grey", "75 pct" = "grey" )) + 
                                      theme_minimal()# 
                                      
percentile <-ggplot(normE, aes(x = sdate)) +
geom_line(aes(y = normE[,2], color = "EFFR", linetype ="solid", color = "black",linewidth = 1.5, alpha = 1.25) + 
geom_line(aes(y = normE[,4], color = "green",linetype ="solid",linewidth = 1) +
geom_line(aes(y = normE[,5], color = "green",linetype ="solid",linewidth = 1) +
geom_line(aes(y = normE[,7], color = "25 pct", linetype = "solid", color = "magenta",linewidth = 1, alpha = 0.8) + 
geom_line(aes(y = normE[,8], color = "75 pct", linetype = "solid", color = "magenta",linewidth = 1, alpha = 0.8) +
geom_ribbon(aes(x = sdate, ymin = normE[,7], ymax = normE[,8]), fill ="grey80")+
labs(x = "Date", y = "basis points (bp)", color = "Lines") + 
#ylim= c(0,450)+
#scale_color_manual(values = c("EFFR" = "blue))
#scale_color_manual(values = c("EFFR" = "blue, "25 pct" = "grey", "75 pct" = "grey" )) + 
#scale_color_manual(values = c("EFFR" = "black","Lower target" = "green","Upper target" = "blue", "25 pct" = "grey", "75 pct" = "grey" )) + 
theme_minimal()
print(percentile)

# -------------------------------------- DELETE OLS GMM -----------------------------------------


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
# Credit SUISSE DISPERTION
#https://research-doc.credit-suisse.com/docView?language=ENG&format=PDF&source_id=csplusresearchcp&document_id=805810360&serialid=7b0hziYR8YC9WgdgSZceFVZcmKHnCBinVkLwiTRHqKU%3D&cspId=null
# 


#Fama French equations------------------------
# r(t,t+k) =a + b_k r(t-k,t) +e(t+k)
# k=1 r(2,3) = a +b_1 r(1,2)
# k=2 r(3,5) = a +b_1 r(1,3)
# k=5 r(6,11) = a +b_1 r(1,6)
# k=10 r(11,21) = a +b_1 r(1,11)


# 
# print(res0 <- gmm(g0, x, c(mu = 0, sig = 0)))


   
                                      
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
# two_day_avg_returns <- rollapply(rrbp_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
                                      # five_day_avg_returns <- rollapply(rrbp_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
                                      # ten_day_avg_returns <- rollapply(rrbp_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")                                 
\url{https://www.rdocumentation.org/packages/zoo/versions/1.8-12/topics/rollapply}                                     
  rrbp_zoo <- zoo(rrbp)                                    
  rrbp2 <- rollapply(rrbp_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp2) #[1] 1709
  ncol(rrbp2) #[1] 5
  
  rrbp5 <- rollapply(rrbp_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp5) #[1] 1706
  ncol(rrbp5) #[1] 5
  
  
  rrbp10 <- rollapply(rrbp_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp10) #[1] 1701
  ncol(rrbp10) #[1] 5
#ten_day_avg_returns <- rowMeans(matrix(daily_returns, ncol = 5, byrow = TRUE, nrow = 10), ncol = 5)

  
                                      
source("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Code/olsgmmv2.R")
# k=1  k=1 r(2,3) = a +b_1 r(1,2)                                     
lhv<- rrbp[2:1710,1:5]
ones_v <- rep(1, times = T-1)
nrow(ones_v)
rhv1<- rrbp[1:1709,1:5]

# k=2  k=1 r(2,3) = a + a +b_1 r(1,3)                                  
T<-nrow(rrbp2) #[1] 1709
lhv<- rrbp2[2:1709,1:5]
ones_v <- rep(1, times = T-1)
nrow(ones_v)
rhv1<- rrbp2[1:1708,1:5]


# k=5  k=1 r(2,3) = a +b_1 r(1,6) 
# length(rrbp5) #[1] 1706
# rrbp5_df <- as.data.frame(rrbp5)
lhv<- rrbp5[2:1706,1:5]
T<-nrow(lhv) 
ones_v <- rep(1, times = T)
nrow(ones_v)
rhv1<- rrbp5[1:1705,1:5]


# k=10   k=10 r(11,21) = a +b_1 r(1,11)   
# length(rrbp10) #[1] 1701
# rrbp10_df <- as.data.frame(rrbp10)
#T<-nrow(rrbp10) 
lhv<- rrbp10[2:1701,1:5]
T<-nrow(lhv) 
ones_v <- rep(1, times = T)
nrow(ones_v)
rhv1<- rrbp10[1:1700,1:5]



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
  
  
# epochs --------------------
  # normalcy <-rrbp %>% slice(1:856)
  normalcy_zoo <- zoo(normalcy)                                    
  normalcy2 <- rollapply(normalcy_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(normalcy2) #[1] 1709
  ncol(rrbp2) #[1] 5
  
  rrbp5 <- rollapply(rrbp_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp5) #[1] 1706
  ncol(rrbp5) #[1] 5
  
  
  rrbp10 <- rollapply(rrbp_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  nrow(rrbp10) #[1] 1701
  ncol(rrbp10) #[1] 5
  
  
  normalcy_zoo <- zoo(normalcy) 
  adjust_zoo <- zoo( adjust)  
  covid_zoo <- zoo(covid)  
  zlb_zoo <- zoo(zlb)  
  inflation_zoo <- zoo(inflation)  
  
  normalcy2 <- rollapply(normalcy_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(normalcy2) # [1] 855
  ncol(normalcy2) #[1] 5
  lhv<- normalcy2[2:855,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- normalcy[1:854,1:5]
  
  normalcy5 <- rollapply(normalcy_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  nrow(normalcy5) #[1] 852
  ncol(normalcy5) #[1] 5
  lhv<- normalcy10[2:852,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- normalcy[1:851,1:5]
  
  normalcy10 <- rollapply(normalcy_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  nrow(normalcy10) #[1]  847
  ncol(normalcyp10) #[1] 5
  lhv<- normalcy10[2:847,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- normalcy[1:846,1:5]
  
  
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
  
  # adjust <-rrbp %>% slice(857:920)
  adjust2 <- rollapply(adjust_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(adjust2) #[1] 1709
  ncol(adjust2) #[1] 5
  lhv<- adjust2[2:1701,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- adjust2[1:1700,1:5]
  
  adjust5 <-  rollapply(adjust_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(adjust5) #[1] 1706
  ncol(adjust5) #[1] 5
  lhv<- adjust5[2:1701,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- adjust5[1:1700,1:5]
  
  
  adjust10 <-  rollapply(adjust_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(adjust10) #[1] 1701
  ncol(adjust10) #[1] 5
  lhv<- adjust10[2:1701,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- adjust10[1:1700,1:5]
  
  # covid <-rrbp %>% slice(921:1029)
  covid2 <- rollapply(covid_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(covid2) #[1] 108
  ncol(covid2) #[1] 5
  lhv<- covid2[2:108,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- covid2[1:107,1:5]
  
  covid5 <- rollapply(covid_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  nrow(covid5) #[1] 105
  ncol(covid5) #[1] 5
  lhv<- covid5[2:105,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- covid5[1:104,1:5]
  
  covid10 <- rollapply(covid_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  nrow(covid10) #[1] 100
  ncol(covid10) #[1] 5
  lhv<- covid10[2:100,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- covid10[1:99,1:5]
  
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
  
  # zlb <-rrbp %>% slice(1030:1513)
  zlb2 <- rollapply(normalcy_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(zlb2) #[1] 855
  ncol(zlb2) #[1] 5
  lhv<- covid2[2:855,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- zlb2[1:854,1:5]
  
  zlb5 <- rollapply(zlb_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  nrow(zlb5) #[1] 480
  ncol(zlb5) #[1] 5
  lhv<- zlb5[2:480,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- zlb5[1:479,1:5]
  
  zlb10 <- rollapply(zlb_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  nrow(zlb10) #[1] 475
  ncol(zlb10) #[1] 5
  lhv<- zlb10[2:475,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- zlb10[1:474,1:5]
  
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
  
  # inflation <-rrbp %>% slice(1514:1710)
  inflation2 <- rollapply( inflation_zoo, width = 2, FUN = mean, na.rm = TRUE, align = "right")
  nrow(inflation2) #[1] 196
  ncol(inflation2) #[1] 5
  lhv<- inflation2[2:196,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- inflation2[1:195,1:5]
  
  inflation5 <- rollapply( inflation_zoo, width = 5, FUN = mean, na.rm = TRUE, align = "right")
  nrow(inflation5) #[1] 193
  ncol(inflation5) #[1] 5
  lhv<- inflation5[2:193,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- inflation5[1:192,1:5]
  
  inflation10 <- rollapply( inflation_zoo, width = 10, FUN = mean, na.rm = TRUE, align = "right")
  nrow(inflation10) #[1] 188
  ncol(inflation10) #[1] 5
  lhv<- inflation10[2:188,1:5]
  T<-nrow(lhv) 
  ones_v <- rep(1, times = T)
  nrow(ones_v)
  rhv1<- inflation10[1:187,1:5]
  
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
  
  
# --------------------OLS GMM CODE -----------------------  
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
  # --------------------OLS GMM CODE -----------------------
  
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

dailystat$rrbpm <- rrbp- colMeans(rrbp)
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

# ------------------------------ Ribbon plot examples

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

metricE<-select(spread,EFFR,TargetDe,TargetUe,PercentileE25,PercentileE75,
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


