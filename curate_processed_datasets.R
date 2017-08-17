# IN this script we process each dataset separtely library(data.table)
# steps done: remove energy column, remove rows with entire NA values, round values to 5 decimal places, convert timestamps to unix format.
# IMPORTANT NOTE: In files library, lecture, mess and boys_ups there are some unknnown inconsitency which creates problems so a solution is to identify the dates usually last dates of dataset and remove them before processing further.
rm(list=ls())
library(xts)
library(data.table)


create_version_2_of_dataset <- function() {
  # this function exclusiely creates version 2 of the dataset
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed/"
  meter <- "boys_hostel_ups.csv"
  data <- fread(paste0(def_path,meter))
  # the next step is applied only for the files: library, lecture, mess and boys_ups
  #data <- data[1:(2056966-646),]
  data_xts <- xts(data[,2:ncol(data)],fasttime::fastPOSIXct(data$timestamp)-19800)
  start_date <- as.POSIXct("2013-08-10")
  end_date <- as.POSIXct("2017-07-07 23:59:59")
  xts_sub <- data_xts[paste0(start_date,"/",end_date)]
  xts_sub <- xts_sub[,!colnames(xts_sub)%in%c("energy")] # remove energy column
  na_rows <- apply(xts_sub,1,function(x) all(is.na(x)))
  xts_without_NA_rows <- xts_sub[!na_rows,] 
  dframe <- data.frame(timestamp=index(xts_without_NA_rows),coredata(xts_without_NA_rows))
  dframe$timestamp <- as.numeric(dframe$timestamp)
  save_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  #write.csv(round(dframe,5),paste0(save_path,meter),row.names=FALSE)
  t2 <- 2056966
  t1 <- t2 - 1440 * 1
  data[t1:t2]$timestamp
  head(data[t1:t2]$timestamp,200)
}

aggregate_one_parameter_of_all_buildings <- function() {
  # this function does two things:
  # create all CSV contining only power data of all buildings
  # create csv showing which points are missing and which are there  
  path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  fl <- list.files(path,pattern = "*.csv")
  
  df_files <- lapply(fl,function(x) {
    data <- fread(paste0(path,x),select=c("timestamp","power"))
    #tbl_data <- tbl_df(data) %>% mutate(timestamp = as.POSIXct(data$timestamp,origin = "1970-01-01", tz="Asia/Kolkata"))
    tbl_data <- tbl_df(data) %>% mutate(timestamp = as.POSIXct(data$timestamp,origin = "1970-01-01"))
    return(tbl_data)
  })
  dummy_year <- create_NA_timeseries_tibble('2013-08-10','2017-07-07 23:59:59','1 mins')
  for (i in 1:length(df_files)){
    temp <- full_join(dummy_year,df_files[[i]],by="timestamp")
    dummy_year <- temp
  }
  # remove second column
  temp <- dummy_year %>% select(timestamp,starts_with("power"))
  source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Data_wrangling/wrangle_data.R")
  data_xts <- mytbl_xts(temp)
  build_names <- c("Academic","Boys_main","Boys_backup","Facilities","Girls_main","Girls_backup","Lecture","Library","Mess")
  colnames(data_xts) <- build_names
  #path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  write.csv(data.frame(timestamp=index(data_xts),coredata(data_xts)),paste0(path,"all_buildings_power.csv"),row.names = FALSE)
  
  
  # CREATE CSV WHICH SHOWS WHICH DATA POINTS ARE PRESENT AND WHICH ONE ARE MISSING
  data_present_status <- ifelse(is.na(data_xts),0,1)
  df_status <- data.frame(timestamp=index(data_xts),data_present_status)
  #write.csv(df_status,paste0(path,"data_present_status.csv"),row.names = FALSE)
}

sqeeze_datasets <- function() {
  # this function is used to save datasets within input dates
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  meter <- "library_build_mains.csv"
  data <- fread(paste0(def_path,meter))
  data$timestamp <- as.POSIXct(data$timestamp,origin = "1970-01-01", tz="Asia/Kolkata")
  start_date <- as.POSIXct("2013-08-10")
  end_date <- as.POSIXct("2017-07-07 23:59:59")
  temp <- data[data$timestamp>=start_date,]
  temp$timestamp <- as.numeric(temp$timestamp)
  save_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  #  write.csv(temp,paste0(save_path,meter),row.names=FALSE)
}

show_data_presence_plot<- function(){
  # this function is used to show missing data using default minutely data.
  library(ggplot2)
  library(data.table)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  meter <- "data_present_status.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  temp <- data[data$timestamp <= as.POSIXct("2013-11-10 23:59:59"),]
   temp <- as.data.frame(temp)
   mulfactor <- 1:(NCOL(temp)-1)
   for (i in 2:NCOL(temp)) {
   temp[,i] <- temp[,i] * mulfactor[i-1] }
   data_long <- reshape2::melt(temp,id.vars=c("timestamp"))
   data_long$value <- ifelse(data_long$value==0,NA,data_long$value)
   g <- ggplot(data_long,aes(timestamp,value,fill=variable)) + geom_line()
   g <- g + scale_y_continuous(breaks= c(1:9))
 #  ggsave(filename = "mydemo.pdf",plot = g)
}

summarise_missing_data_plot<- function(){
  # this function is used to plot the plot of paper which shows the days on which quater of the data is missing by gaps
  library(ggplot2)
  library(data.table)
  library(xts)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  meter <- "data_present_status.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  temp <- data[data$timestamp <= as.POSIXct("2017-07-07 23:59:59"),]
  temp_xts <- xts(temp[,-1],temp$timestamp)
  day_data <- split.xts(temp_xts,f="days",k=1)
  sumry_data <- lapply(day_data, function(x) {
  #x <- day_data[[1]]
  sumry <- apply(x,2,sum)
  sumry <- ifelse(sumry <=1440/4, NA, 1)
  return(xts(data.frame(t(sumry)),as.Date(index(x[1]),tz="Asia/Kolkata")))
  #return(sumry)
  })
  sumry_data_xts <-  do.call(rbind,sumry_data)
  temp <- data.frame(timestamp=index(sumry_data_xts),coredata(sumry_data_xts))
  mulfactor <- 1:(NCOL(temp)-1)
  for (i in 2:NCOL(temp)) {
    temp[,i] <- temp[,i] * mulfactor[i-1] }
  data_long <- reshape2::melt(temp,id.vars=c("timestamp"))
 #  data_long$value <- ifelse(data_long$value==0,NA,data_long$value)
 names <- colnames(sumry_data_xts)
  g <- ggplot(data_long,aes(timestamp,value,color=variable)) + geom_line()
  g <- g + theme(axis.text = element_text(color="black"),axis.text.y = element_blank(),axis.ticks.y = element_blank(), legend.title = element_blank(), legend.position = "none" )+ labs(x= " ", y="Meter") + scale_x_date(breaks=scales::date_breaks("6 month"),labels = scales::date_format("%b-%Y"))
  g <- g + annotate("text",x=as.Date("2013-08-30"),y=seq(1.3,9.3,1),label=names)
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  #ggsave(filename="data_missing_plot.pdf",height = 5,width = 10,units = c("in"))
}
   