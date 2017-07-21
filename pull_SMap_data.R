#rm(list=ls())
library(RSmap)
library(xts)
RSmap("http://energy.iiitd.edu.in:9102/backend")
#Functions:
#1. pulldata: used to pull data from IIITD smart meters, received data is formatted and specific values are stored as a csv file
#    CAUTION: daterange, csv filename, if more than one stream then look at code
pulldata<-function(){
  
  start <- as.numeric(strptime("07-01-2013", "%m-%d-%Y"))*1000
  end <- as.numeric(strptime("07-19-2017", "%m-%d-%Y"))*1000
  default_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/default/"
  fifteen_min_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/fifteen_minutes/"
  oat <- list(
    #"6daaff1d-3120-55f6-b11c-afecf75d2870"
    #"78f5e016-7a20-5291-9372-f0894adbfef2"
   #"cbd6c314-3d38-5774-ab58-1640558333d0"
   # "c30d4d9a-48b7-56fa-b714-c36247ee7aa8"
   #"854b1bb5-c78f-5460-bcf9-26ad3a6497d2"
   #"9a8f6c69-d8f4-5862-b1fb-de292ce5ae7a"
   "022dfbe9-c9f2-5acb-b973-e3873444855e"
  )
  data <- RSmap.data_uuid(oat, start, end)
  filenames= c( 
    "boys_hostel_mains.csv",
    "girls_hostel_mains.csv",
    "acad_build_mains.csv",
    "lecture_build_mains.csv",
    "library_build_mains.csv",
    "mess_build_mains.csv",
    "facilities_build_mains.csv"
  )
  for(i in 1:length(filenames)){
    dframe=as.data.frame(cbind(data[[i]]$time,data[[i]]$value))
    names(dframe) = c("timestamp","power")
    dframe$timestamp = as.POSIXct(dframe$timestamp/1000,origin="1970-01-01")
    write.csv(dframe,file=paste(default_path,filenames[i],sep=""),row.names=F,quote=F)
    #save files as hourly calcultions
    #x <- xts(dframe$power,dframe$timestamp)
    #h1 <- period.apply(x, endpoints(index(x)-3600*0.5, "minutes",k=15), mean)
    #h1 <- data.frame(timestamp=trunc(index(h1),'mins'), power=coredata(h1)) 
    #write.csv(h1,file=paste(hourly_path,filenames[i],sep=""),row.names=F,quote=F)
  }
  
}

filenames = "facilities_build_mains.csv"
