#  I have datasets curated at different levels. Therfore do debug data at certain level I run this script to understand things


# INDIVIDUAL PARAMETER CHECK OF RAW DOWNLOADED FILE FROM sMAP
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/power/"
met <- "girls_hostel_ups.csv"
dfh <- fread(paste0(path,met)) 
dfh$timestamp <- fasttime::fastPOSIXct(dfh$timestamp)-19800
start_day <- as.POSIXct("2017-01-01")
end_day <- as.POSIXct("2017-01-03 23:59:59")
temph <- dfh[dfh$timestamp>=start_day & dfh$timestamp <= end_day,]

dfh_xts <- xts(temph[,2],temph$timestamp )
visualize_dataframe_all_columns(dfh_xts["2017-01-01/2017-01-30"])
rm(dfh,temph,dfh_xts)

# CHECK FILES IN PROCESSED FOLDER: FILES CONTAINING ALL PARAMETERS OF A METER
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed/"
met <- "girls_hostel_ups.csv"
dfh <- fread(paste0(path,met)) 
dfh$timestamp <- fasttime::fastPOSIXct(dfh$timestamp)-19800
start_day <- as.POSIXct("2017-01-01")
end_day <- as.POSIXct("2017-01-03 23:59:59")
temph <- dfh[dfh$timestamp>=start_day & dfh$timestamp <= end_day,]
dfh_xts <- xts(temph[,2],temph$timestamp )
visualize_dataframe_all_columns(dfh_xts["2017-01-01/2017-01-30"])
rm(dfh,temph,dfh_xts)

# CHECK FILES IN PROCESSED_phase_2 FOLDER: FILES CONTAINING ALL PARAMETERS OF A METER
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
met <- "girls_hostel_ups.csv"
dfh <- fread(paste0(path,met)) 
dfh$timestamp <- as.POSIXct(dfh$timestamp,origin="1970-01-01")
#dfh$timestamp <- fasttime::fastPOSIXct(dfh$timestamp)-19800
start_day <- as.POSIXct("2017-01-01")
end_day <- as.POSIXct("2017-01-03 23:59:59")
temph <- dfh[dfh$timestamp>=start_day & dfh$timestamp <= end_day,]

dfh_xts <- xts(temph[,2],temph$timestamp)
visualize_dataframe_all_columns(dfh_xts["2017-01-01/2017-01-30"])
rm(dfh,temph,dfh_xts)

