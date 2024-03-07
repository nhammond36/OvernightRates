library("dplyr")
library(tidyverse)
library(rugarch)
library(xts)
library(rmgarch)
library("plyr")
library(ggplot2)
library(reshape2)
library(tseries)
library(PerformanceAnalytics)
library(FinTS)
library(urca)

# READ DATA -------------------
ofrep<-read.csv("C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/OFRrepo01262024.csv",header=TRUE, skip = 3, sep=",",dec=".",stringsAsFactors=FALSE)
str(ofrep)
sdate<-as.Date(ofrep$date,format="%m/%d/%Y")
print(colnames(ofrep))
ofrep$sdate=sdate
str(ofrep)

ofrep_no_na<-ofrep
ofrep_no_na$REPO.DVP_AR_LE30.P <- as.numeric(ofrep_no_na$REPO.DVP_AR_LE30.P)
ofrep_no_na[is.na(ofrep_no_na)] <- 0
#ofrep_no_na<- ofrep_no_na[, -which(names(df) == "date")]
str(ofrep_no_na)

columns_to_exclude<- c("date","sdate")
ofrep_no_na <- ofrep_no_na %>%
  #mutate(across(.cols = -columns_to_exclude, function(x) as.numeric(x * 100), .names = "new_{.col}"))
  #mutate(across(.cols = -columns_to_exclude, ~ . * 100))

  #mutate(across(.cols = -columns_to_exclude, ~ . * 100))

  #mutate(across(.cols = -columns_to_exclude, ~ as.numeric(. * 100)))

mx=max(ofrep_no_na[,2:4])
mn=min(ofrep_no_na[,2:4])
# Plot rates
meltrates <- meltrates %>%
  mutate(value = as.numeric(value))

rates <- ggplot(meltrates, aes(x = sdate, y = value, colour = variable, group = variable)) + 
  geom_point(shape = 16, size = 1) +
  labs(x = "Date", y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
  scale_y_continuous(breaks = seq(mn, mx, by = 0.1), limits = c(mn, mx)) + 
  theme_minimal() +
  guides(shape = guide_legend(title = "Rate"))
print(rates)




# meltrates<- melt(ofrep_no_na,id="sdate")
# rates <- ggplot(meltrates,aes(x=sdate,y=value,colour=variable,group=variable)) + 
#   geom_point(shape=16,size=1) +
#   labs(x="Date",  y = "Basis Points (bp)", color = "Rate", shape = "Rate") +  
#   scale_y_continuous(breaks = seq(mn, mx, by = 0.05), limits = c(mn, mx)) + 
#   theme_minimal() + guides(shape = guide_legend(title = "Rate"))
# print(rates)
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/ofrrates.pdf")
ggsave("C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/Figures2/ofrrates.png")
