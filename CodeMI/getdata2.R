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


filepath<-"C:/Users/Owner/Documents/Research//MonetaryPolicy/Data/"

print(nydata1_new)

# 3/4/2016 to 2/22/2023 
# Read data into a data frame
nydata<-read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedRefRates_new12172023.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE)
# Create a new column for grouping every 5 rows
#nydata$Group <- rep(1:(nrow(nydata)/5), each = 5)
nydata$Group <- rep(1:(ceiling(nrow(nydata)/5)), each = 5, length.out = nrow(nydata))

# Reshape the data using tidyr
nydata_long <- gather(nydata, Key, Value, -Date, -Reference, -Group)

# Create a new data frame with reshaped data
nydata_new <- spread(nydata_long, Key, Value)

# Remove unnecessary columns
#df_new <- df_new[, c("Date", "Type", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")]

nydata_new <- nydata_new %>%
  arrange(Group, as.Date(Date, format="%m/%d/%Y"))
# nydata_new <- nydata_new %>%
#   +     arrange(Group, as.Date(Date, format="%m/%d/%Y"))

str(nydata_new)
# Print the result
#print(nydata_new)
# Assuming nydata_new is your data frame
write.csv(nydata_new, file = "C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedRefRates2.csv", row.names = FALSE)



# Check if there are missing or zero values in Rate_Count
if (any(is.na(combined_data$Rate_Count)) | any(combined_data$Rate_Count == 0)) {
  # Handle the case where there are missing or zero values
  combined_data$Group <- rep(1:(nrow(combined_data)), each = 1, length.out = nrow(combined_data))
} else {
  # Reassign the Group numbers based on the number of rates in each group
  combined_data$Group <- rep(1:(ceiling(nrow(combined_data) / max(combined_data$Rate_Count))), 
                             each = max(combined_data$Rate_Count), 
                             length.out = nrow(combined_data))
}

# Remove the temporary 'Rate_Count' column
combined_data <- combined_data %>% select(-Rate_Count)

# Reshape the combined data
combined_data_long <- gather(combined_data, Key, Value, -Date, -Reference, -Group)

# Create a new data frame with reshaped data
combined_data_new <- spread(combined_data_long, Key, Value)

# Arrange the data by Group and Date
combined_data_new <- combined_data_new %>%
  arrange(Group, as.Date(Date, format="%m/%d/%Y"))


# ------------------- New data set ----------------------------
# Pivot the data
library(tidyr)

# Assuming your original data frame is named 'nydata'
# Replace 'nydata' with the actual name of your data frame

nyrate <- pivot_wider(nydata, 
                      id_cols = c("Date"),
                      names_from = Reference,
                      values_from = c("Rate", "Percentile01", "Percentile25", "Percentile75", "Percentile99", "TargetDe", "TargetUe", "Volume"))

# Print the structure of the resulting data frame
str(nyrate)



# Save to CSV
write.csv(nyrate, file = "C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedReferenceRates_12172023.csv", row.names = FALSE)




