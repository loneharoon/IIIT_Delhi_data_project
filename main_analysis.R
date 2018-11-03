# seems I have used this script for initial analysis, and does not form a part of final processed datasets
library(data.table)
library(xts)
#girls_hostel_mains.csv, boys_hostel_mains.csv,acad_build_mains,fac_build_mains,lecture_build_mains,
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/IIIT_Delhi_data_project/reports/figures/")
direc  = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/power/"

file = "mess_build_mains.csv"
df = fread(paste0(direc,file))
df_xts <- xts(df$power,fasttime::fastPOSIXct(df$timestamp)-19800) # subtracting5:30 according to IST
df_sample <- resample_data_minutely(df_xts,15) #downsample
df_year <- split.xts(df_sample,f="years",k=1) # yearwise break
# fill missing readings with NA
df_year_full <- lapply(df_year,function(x) fill_missing_readings_with_NA(x,"15 mins"))
#set all years to a defualt year
same_year <- lapply(df_year_full, function(y) {
     change_year(y)
})
dummy_year <- create_year_data_NA('2016','15 mins') #create dummy year NA data
updated_same_year <- c(list(dummy_year),same_year)
year_data <- do.call(cbind,updated_same_year)
year_data <- year_data[,2:NCOL(year_data)]# dropping dummy column
colnames(year_data) <- paste0('Y',unique(lubridate::year(df_sample)))

#visualize_dataframe_all_columns(year_data['2016-02']/1000)

#visualize_month_data_facet_form(year_data['2016-5']/1000,'Y2017')

visualize_dataframe_all_columns_facet_form(year_data,ncol=3)

q <- visualize_dataframe_all_columns_facet_form(year_data,ncol=3)
ggsave("mess_build.pdf",q,width=15,height = 20,units= c("cm"))

years <- c('Y2013','Y2014','Y2015','Y2016','Y2017')
for ( i in 1:length(years)) {
p <- visualize_dataframe_one_column_facet_form(year_data[,years[i]],ncol=3)
ggsave(paste0("mess_build_",years[i],".pdf"),p,width=15,height = 20,units= c("cm"))
#ggsave("acad_build_year2013.pdf",p,width=15,height = 20,units= c("cm"))
}

def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/"
features <- c("power","energy","current","voltage","frequency","power_factor")
sub_paths <- sapply(features,function(x) return(paste0(def_path,x,"/")))

meter <- "acad_build_mains.csv"
meter_features <- paste0(sub_paths,meter)
df_files <- lapply(meter_features,function(x) {
  data <- fread(x)
  df_xts <- xts(data[,2],fasttime::fastPOSIXct(data$timestamp)-19800)
  return(df_xts)
  }
  )
sapply(df_files,dim) # checks # of rows or dimensions
min_data <- lapply(df_files,function(x) resample_data_minutely(x,1) )
visualize_dataframe_all_columns(min_data[[3]]["2013"])

dummy_year <- create_NA_timeseries_data('2013-08-03','2017-07-18 23:59:59','1 mins') #create dummy year NA data
updated_same_year <- c(list(dummy_year),min_data)
year_data <- do.call(cbind,updated_same_year)
year_data <- year_data[,2:NCOL(year_data)]# dropping dummy column

