# There are some minor changes in this script as compared to pull_SMap_data.R.
# This has feature
rm(list=ls())
library(RSmap)
library(xts)
RSmap("http://energy.iiitd.edu.in:9102/backend")
#Functions:
#1. pulldata: used to pull data from IIITD smart meters, received data is formatted and specific values are stored as a csv file
#    CAUTION: daterange, csv filename, if more than one stream then look at code
pulldata<-function(){
  
  start <- as.numeric(strptime("07-01-2013", "%m-%d-%Y"))*1000
  end <- as.numeric(strptime("07-10-2017", "%m-%d-%Y"))*1000
  data_column <- "voltage"
  default_path = paste0("/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/",data_column,"/")
  print(default_path)
  #fifteen_min_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/fifteen_minutes/"
  oat <- "ec0ee091-a63d-5a87-94c0-4da6bf631bfa"
  data <- RSmap.data_uuid(oat, start, end)
  
  filename = "mess_build_mains.csv"
  
  dframe=as.data.frame(cbind(data[[1]]$time,data[[1]]$value))
  names(dframe) = c("timestamp",data_column)
  dframe$timestamp = as.POSIXct(dframe$timestamp/1000,origin="1970-01-01")
  write.csv(dframe,file=paste(default_path,filename,sep=""),row.names=F,quote=F)
 rm(data,dframe)

  
  
filenames= c( 
  "boys_hostel_mains.csv",
  "girls_hostel_mains.csv",
  "acad_build_mains.csv",
  "lecture_build_mains.csv",
  "library_build_mains.csv",
  "mess_build_mains.csv",
  "facilities_build_mains.csv",
  "boys_hostel_ups.csv",
  "girls_hostel_ups.csv"
)
}