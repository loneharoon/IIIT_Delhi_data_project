
# THIS FILE IS USED TO PROCESS THE DATASETS DOWNLOADED DIRECTLY FROM SMAP INTERFACE
library(data.table)
library(xts)
library(stringr)
path <- "/Volumes/MacintoshHD2/Users/haroonr/Downloads/"
file <- "mess_build_mains_volt.csv"
# set feature to be working with
data_type <- "voltage"
filepath <- paste0(path,file)
df2 <- fread(filepath,skip = 54) # first 54 lines are metadata
colnames(df2) <- c("timestamp",data_type)
df2$timestamp <- fasttime::fastPOSIXct(df2$timestamp)-1980
# KEEP EYE ON THE FEATURE TO BE USING
df2$voltage <- as.numeric(str_replace_all(df2$voltage, "[\r]" , ""))
savedir <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/"
# CHANGE FOLDER AND FILE NAME ACCORDINGLY
filename <- "voltage/mess_build_mains.csv"
savename <- paste0(savedir,filename)
print(savename)
write.csv(df2,savename,row.names = FALSE)
