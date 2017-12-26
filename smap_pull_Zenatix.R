library(RSmap)
library(xts)
RSmap("http://energy.iiitd.edu.in:9102/backend")
#Functions:
start <- as.numeric(strptime("10-20-2017", "%m-%d-%Y"))*1000
end <- as.numeric(strptime("10-28-2017", "%m-%d-%Y"))*1000
default_path = "/Volumes/Downloads/"
oat <- list(
  #"6daaff1d-3120-55f6-b11c-afecf75d2870"
  #"78f5e016-7a20-5291-9372-f0894adbfef2"
  #"cbd6c314-3d38-5774-ab58-1640558333d0"
  # "c30d4d9a-48b7-56fa-b714-c36247ee7aa8"
  #"854b1bb5-c78f-5460-bcf9-26ad3a6497d2"
  #"9a8f6c69-d8f4-5862-b1fb-de292ce5ae7a"
  "9f161747-5ada-54e0-8367-9a66f31d4ebb" 
)
data <- RSmap.data_uuid(oat, start, end)
filenames <- "hello.csv"
for(i in 1:length(filenames)){
  dframe=as.data.frame(cbind(data[[i]]$time,data[[i]]$value))
  names(dframe) = c("timestamp","power")
  dframe$timestamp = as.POSIXct(dframe$timestamp/1000,origin="1970-01-01")
  write.csv(dframe,file=paste(default_path,filenames[i],sep=""),row.names=F,quote=F)
}