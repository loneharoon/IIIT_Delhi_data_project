library(data.table)
library(xts)
library(dplyr)
library(tbl2xts)

def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/"
features <- c("power","energy","current","voltage","frequency","power_factor")
sub_paths <- sapply(features,function(x) return(paste0(def_path,x,"/")))

meter <- "girls_hostel_ups.csv"
meter_features <- paste0(sub_paths,meter)

df_files <- lapply(meter_features,function(x) {
  data <- fread(x)
  tbl_data <- tbl_df(data) %>% mutate(timestamp=fasttime::fastPOSIXct(data$timestamp)-19800)
  return(tbl_data)
}
)

min_data <- lapply(df_files,function(x) resample_tbl_data_minutely(x,1) )
#visualize_dataframe_all_columns(min_data[[3]]["2013"])
lapply(min_data,head)
lapply(min_data,tail)
dummy_year <- create_NA_timeseries_tibble('2013-08-10','2017-07-07 23:59:59','1 mins')
for (i in 1:length(min_data)){
  temp <- full_join(dummy_year,min_data[[i]],by="timestamp")
  dummy_year <- temp
}
temp2 <- select(temp,c('timestamp',features))
f_df <- as.data.frame(temp2)
write.csv(f_df,paste0(def_path,"processed/",meter),row.names = FALSE)
rm(f_df,temp2,min_data,df_files)
