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


# 02/17/2023 TGCR 4.52 4.45 4.51 4.55 4.56 450
# 02/17/2023 BGCR 4.52 4.45 4.51 4.55 4.58 461
# 02/17/2023 SOFR 4.55 4.47 4.53 4.58 4.64 1209"

filepath<-"C:/Users/Owner/Documents/Research//MonetaryPolicy/Data/"
headers=  read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/dailyovernightrates090923v2.csv',header=F, nrows=1) #,as.is=T)
spread <- read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/dailyovernightrates090923v2.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE) #,skip=4)

nydata<-read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedRefRates_new.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE)
# Read data into a data frame
df <- read.table(text = data, col.names = c("Date", "Type", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8"))

# Create a new column for grouping every 5 rows
df$Group <- rep(1:(nrow(df)/5), each = 5)

# Reshape the data using tidyr
library(tidyr)
df_long <- gather(df, Key, Value, -Date, -Type, -Group)

# Create a new data frame with reshaped data
df_new <- spread(df_long, Key, Value)

# Remove unnecessary columns
df_new <- df_new[, c("Date", "Type", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")]

# Print the result
print(df_new)
# ---------------------

# 3/1/2016 to  3/30/2018
nydata1<-read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedRefRatesa_new.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE)
nydata1$Group <- rep(1:(ceiling(nrow(nydata1) / 2)), each = 2, length.out = nrow(nydata1))

# Reshape the data using tidyr
nydata1_long <- gather(nydata1, Key, Value, -Date, -Reference, -Group)

# Create a new data frame with reshaped data
nydata1_new <- spread(nydata1_long, Key, Value)

# Arrange the data by Group and Date
nydata1_new <- nydata1_new %>%
  arrange(Group, as.Date(Date, format="%m/%d/%Y"))
str(nydata1)
# Save to CSV
write.csv(nydata1_new, file = "nydata1_sorted.csv", row.names = FALSE)

print(nydata1_new)

# 4/4/2018 to 2/22/2023 
# Read data into a data frame
nydata<-read.csv('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedRefRatesb_new.csv',header=TRUE, sep=",",dec=".",stringsAsFactors=FALSE)
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


# combine both nydat1 and nydata
library(dplyr)
library(tidyr)

# Assuming nydata1 and nydata are your two data frames

# Add a new column 'Rate_Count' to nydata1 to indicate the number of rates in each group
nydata1 <- nydata1 %>%
  group_by(Group) %>%
  mutate(Rate_Count = n())

# Combine the two datasets
combined_data <- bind_rows(nydata1, nydata)

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
rates_datab <- pivot_wider(nydata, id_cols = c("Date", "Ref"),
                             names_from = "Ref",
      
                                               values_from = c("Percentile01", "Percentile25", "Percentile50", "Percentile75", "Percentile99", "Volume", "TargetDe", "TargetUe"))

rates_datab <- pivot_wider(nydata, id_cols = c("Date", "Reference"),
                             names_from = "Reference",
                             values_from = c("Rate",Percentile01", "Percentile25", "Percentile75", "Percentile99","TargetDe", "TargetUe","Volume"))
rates_datab <- spread(nydata, key = Reference, value = c("Percentile01", "Percentile25", "Percentile75", "Percentile99", "TargetDe", "TargetUe", "Volume"))

# Display the spread data
print(spread_data)


# Display the reshaped data
print(reshaped_data)


# -------------------- New 12/17/2023 ----------------------------
names(combined_data_new)

# Extract columns for each reference rate using matches
effr_data <- combined_data_new %>% select(Group, Date, Reference, matches("EFFR"))
obfr_data <- combined_data_new %>% select(Group, Date, Reference, matches("OBFR"))
tgcr_data <- combined_data_new %>% select(Group, Date, Reference, matches("TGCR"))
bgcr_data <- combined_data_new %>% select(Group, Date, Reference, matches("BGCR"))
sofr_data <- combined_data_new %>% select(Group, Date, Reference, matches("SOFR"))

# Extract columns for each reference rate
effr_data <- combined_data_new %>% select(Group, Date, Reference, EFFR)
obfr_data <- combined_data_new %>% select(Group, Date, Reference, OBFR)
tgcr_data <- combined_data_new %>% select(Group, Date, Reference, TGCR)
bgcr_data <- combined_data_new %>% select(Group, Date, Reference, BGCR)
sofr_data <- combined_data_new %>% select(Group, Date, Reference, SOFR)

# Extract columns for each reference rate
effr_data <- combined_data_new %>% select(Group, Date, Reference, Rate = Percentile50)
obfr_data <- combined_data_new %>% select(Group, Date, Reference, Rate = Percentile25)
tgcr_data <- combined_data_new %>% select(Group, Date, Reference, Rate = Percentile75)
bgcr_data <- combined_data_new %>% select(Group, Date, Reference, Rate = Rate)
sofr_data <- combined_data_new %>% select(Group, Date, Reference, Rate = Percentile99)
#-----------
library(dplyr)
library(tidyr)


rate_data <- combined_data_new %>%
  gather(key = "Rate_Type", value = "Rate", -Group, -Date, -Reference) %>%
  filter(Rate_Type %in% c("TargetDe", "TargetUe", "Percentile01", "Percentile25", "Percentile75", "Percentile99", "Volume")) %>%
  unite(Rate_Column, Reference, Rate_Type, sep = "_") %>%
  spread(key = Rate_Column, value = Rate)

# If you want to filter specific rates (e.g., EFFR, OBFR, TGCR, BGCR, SOFR), you can do the following:
effr_data <- rate_data %>% filter(Rate_Type == "Percentile50" & Reference == "EFFR")
obfr_data <- rate_data %>% filter(Rate_Type == "Percentile25" & Reference == "OBFR")
tgcr_data <- rate_data %>% filter(Rate_Type == "Percentile75" & Reference == "TGCR")
bgcr_data <- rate_data %>% filter(Rate_Type == "Rate" & Reference == "BGCR")
sofr_data <- rate_data %>% filter(Rate_Type == "Percentile99" & Reference == "SOFR")


# Merge data frames for each reference rate based on the common variables
merged_data <- merge(effr_data, obfr_data, by = c("Group", "Date", "Reference"))
merged_data <- merge(merged_data, tgcr_data, by = c("Group", "Date", "Reference"))
merged_data <- merge(merged_data, bgcr_data, by = c("Group", "Date", "Reference"))
merged_data <- merge(merged_data, sofr_data, by = c("Group", "Date", "Reference"))

# Optionally, arrange the merged data by Group and Date
merged_data <- merged_data %>% arrange(Group, as.Date(Date, format="%m/%d/%Y"))

# Save the merged data frame to a CSV file
write.csv(merged_data, file = "C:/path/to/merged_data.csv", row.names = FALSE)


# Save to CSV
write.csv(combined_data_new, file = "C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/Final data files/NYFedReferenceRates12162023", row.names = FALSE)




