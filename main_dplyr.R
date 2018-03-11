# use this script to process the data downloaded from meters for the first time.
# It combines all features of a builing in one frame and resamples data at one minute frequency
library(data.table)
library(xts)
library(dplyr)
library(tbl2xts) # converts tibble to xts format
Sys.setenv(TZ='Asia/Kolkata')

def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/"
features <- c("power","energy","current","voltage","frequency","power_factor")
# supply tranformers have only 4 features
#features <- c("power","current","voltage","power_factor")
sub_paths <- sapply(features,function(x) return(paste0(def_path,x,"/after_july7/")))

meter <- "library_build_mains.csv"
meter_features <- paste0(sub_paths,meter)

df_files <- lapply(meter_features,function(x) {
  data <- fread(x)
  #tbl_data <- tbl_df(data) %>% mutate(timestamp=fasttime::fastPOSIXct(data$timestamp)-3600)
  tbl_data <- tbl_df(data) %>% mutate(timestamp=fasttime::fastPOSIXct(data$timestamp)-19800)
  attr(tbl_data$timestamp, "tzone") <- "Asia/kolkata"
  return(tbl_data)
}
)

min_data <- lapply(df_files,function(x) resample_tbl_data_minutely(x,1) )
#visualize_dataframe_all_columns(min_data[[3]]["2013"])
lapply(min_data,head)
lapply(min_data,tail)
dummy_year <- create_NA_timeseries_tibble('2017-06-26 00:00:00','2017-12-31 23:59:00','1 mins')
attr(dummy_year$timestamp, "tzone") <- "Asia/kolkata"

for (i in 1:length(min_data)){
  temp <- full_join(dummy_year,min_data[[i]],by="timestamp")
  dummy_year <- temp
}
colnames(temp) <- c('timestamp','dummy','power','energy','current','voltage','frequency','power_factor')
# for transformer columns
#colnames(temp) <- c('timestamp','dummy','power','current','voltage','power_factor')
temp2 <- select(temp,c('timestamp',features))
f_df <- as.data.frame(temp2)
write.csv(f_df,paste0(def_path,"processed/after_july7/",meter),row.names = FALSE)
rm(f_df,temp2,min_data,df_files)

filenames= c( 
  "boys_hostel_mains.csv",
  "girls_hostel_mains.csv",
  "acad_build_mains.csv",
  "lecture_build_mains.csv",
  "library_build_mains.csv",
  "mess_build_mains.csv",
  "facilities_build_mains.csv",
  "boys_hostel_ups.csv",
  "girls_hostel_ups.csv",
  "transformer_1.csv",
  "transformer_2.csv",
  "transformer_3.csv"
)