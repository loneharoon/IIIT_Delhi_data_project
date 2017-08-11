
library(rjson)
jsonfile <- "/Volumes/MacintoshHD2/Users/haroonr/Downloads/dummy.json"
json_data <- fromJSON(file=jsonfile)
df <- as.data.frame(json_data)


setwd("/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/fifteen_minutes/")

df_sample <- resample_data_minutely(df_xts,15) #downsample

df_sample_onemin <- resample_data_minutely(df_xts,1) #downsample
df_sample_5min <- resample_data_minutely(df_xts,5) #downsample
dat <- tidy(df_sample)

df_xts <- cbind(df_xts,1000)
df_xts <- cbind(df_xts,1)
df_xts <- cbind(df_xts,50)


onemin <- resample_data_minutely(df_xts_2,1)
fivemin <- resample_data_minutely(df_xts_2,5)
fifteenmin <- resample_data_minutely(df_xts_2,15)

dat2 <- fortify(df_xts)
dat2$Index <- as.numeric(dat2$Index)
dat2$df_xts <- round(dat2$df_xts,2)
write.csv(fortify(fivemin),"5_feature_fiveminute.csv",row.names = FALSE)
write.csv(fortify(fifteenmin),"5_feature_fifteenminute.csv",row.names = FALSE)

df_xts <- cbind(df_xts,780)
df_xts$power <- 100
newp <- resample_data_minutely(df_xts,30)

resample_mulitcolumn_data_minutely <- function(xts_datap,xminutes) {
  #This function resamples input xts data to xminutes rate
  ds_data <- period.apply(xts_datap,INDEX = endpoints(index(xts_datap)-3600*0.5, on = "minutes", k = xminutes ), FUN= mean) # subtracting half hour to align IST hours
  align_data <- align.time(ds_data,xminutes*60) # aligning to x seconds
  rm(ds_data)
  return(align_data)
}
