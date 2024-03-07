# Loading
#library("dplyr")
library(tidyverse)
library(dslabs)
library(lubridate)
headers=  read.csv('C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Data/dailyovernightratesbriefv2.csv',header=F, nrows=1,as.is=T)
spread <- read.csv('C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Data/dailyovernightratesbriefv2.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE,skip=4)
colnames(spread)=headers

class(spread)
spread %>% replace(is.na(.),0)
str(spread)
#spread[1] "data.frame"
#rm(spread)
 #,rowIndex = 4:1715, colIndex = 1:52)
#skip=4
#R Data Import/Export manual.
# Check that the data were read correctly, and inspect the table:
nrow(spread) # [1] 1710
ncol(spread) # [1] 37
head(spread)
tail(spread)
summary(spread)
length(spred) #   1244          47
class(spread$Time)
spread$Time <-mdy(spread$Time)
spread$date <= as.Date(spread$Time)
sdate <- as.Date(date, format, tryFormats = c("%m-%d-%Y", "%m/%d/%Y"), optional = FALSE)
#sdate = datenum(raws(:,1),'mm/dd/yyyy');
#sdate1 = datenum(txts(:,1),'mm/dd/yyyy');
#rrbp[,1:5]<-spread[,2:8:34]*100;
rrbp<-  select(spread,EFFR,OBFR,TGCR,BGCR,SOFR)
rrbp<-rrbp*100;
vold<-select(spread, volumeEFFR,volumeOBFR,volumeTGCR,volumeBGCR,volumeSOFR);
ior<-mutate(spread,IORR*100);
#sofr<-spread[1:1711,43]*100;
rrpreward<-mutate(spread,RRPONTSYAWARD*100);
target<- select(spread,TargetD,TargetU);
target(isnan(target))=0; # ind <- is.na(z)
targetbp<-target*100;
vdsum=sum(vold(1:1711,1:5),2); #wrates1(:,2:2:10),2);                %
begintarget = 789-447+1;
quantileeffr=select(spread,Percentile1,Percentile25,Percentile75,Percentile99)
#5:8)*100; 
quantileobfr=spread(1:1711,13:16); # NaN until 4/19/2019
quantiletgcr=spread(1:1711,21:24);
quantilebgcr=spread(1:1711,28:32);
quantilesofr=spread(1:1711,37:40)
#
#
# Dates
# ## S3 method for class 'character'
# as.Date(x, format, tryFormats = c("%Y-%m-%d", "%Y/%m/%d"),
#        optional = FALSE, ...)
## S3 method for class 'numeric'
# as.Date(x, origin, ...)
class(spread$Time)
#[1] "character"  3/4/2016 0:00
#print(spread$Time)
#[1] "3/7/2016 0:00"   "3/8/2016 0:00"   "3/9/2016 0:00" 
mydate<-as.POSIXct(spread$Time,format="%m/%d/%Y %H:%M")
sdate<-as.Date(mydate)
sdatet<-t(sdate)


# plot daily sample rates
#nf =  1  Select sample
#1 03/04/2016 - 12/29/2022 NYFed rates series start date  4
# p<-ggplot(data=rrbp)sdate
# p +  Layer2 + layer 2
spread %>% ggplot() + geom_point(aes(sdate, rrbp, size=2))+ geom_text(aes(x=Time, y=rrbp,label=abb))
#rlang::last_trace()sd
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

# plot  year ny=1
#2017  213   463  {'1/3/2017'} - '12/29/2017'}
#2018  464   712  {'1/2/2018'} - {'12/31/2018'} 
#2019  713   963  {'1/2/2019'} - {'12/31/2019'}    
#2020  964  1214  {'1/2/2020'} - {'12/31/2020'}    
#2021 1215  1465  {'1/4/2021'} - {'12/31/2021'}  
#2022 1466  1714  {'1/3/2022'} - {'12/29/2022'} 


# plot daily epoch volumes
# use filter or slice to define eopchs
#
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
# ggsave("stations.pdf",p)


