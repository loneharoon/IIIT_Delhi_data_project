
# IN this script we process each dataset separtely 
# steps done: remove energy column, remove rows with entire NA values, round values to 5 decimal places, convert timestamps to unix format.
# IMPORTANT NOTE: In files library, lecture, mess and boys_ups there are some unknnown inconsitency which creates problems so a solution is to identify the dates usually last dates of dataset and remove them before processing further.
rm(list=ls())
library(xts)
library(data.table)
Sys.setenv(TZ='Asia/Kolkata')


create_version_2_of_dataset <- function() {
  # this function exclusiely creates version 2 of the dataset
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed/after_july7/"
  meter <- "transformer_1.csv"
  data <- fread(paste0(def_path,meter))
  # the next step is applied only for the files: library, lecture, mess and boys_ups,girls_ups
  #data <- data[1:(2056320),]
  data_xts <- xts(data[,2:ncol(data)],fasttime::fastPOSIXct(data$timestamp)-19800)
  
  start_date <- as.POSIXct("2017-07-08")
  #start_date <- as.POSIXct("2017-06-26") # library
  end_date <- as.POSIXct("2017-12-31 23:59:59")
  xts_sub <- data_xts[paste0(start_date,"/",end_date)]
  xts_sub <- xts_sub[,!colnames(xts_sub)%in%c("energy")] # remove energy column
  na_rows <- apply(xts_sub,1,function(x) all(is.na(x)))
  xts_without_NA_rows <- xts_sub[!na_rows,] 
  dframe <- data.frame(timestamp=index(xts_without_NA_rows),coredata(xts_without_NA_rows))
  dframe$timestamp <- as.numeric(dframe$timestamp)
  save_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_2/after_july7/"
  write.csv(round(dframe,5),paste0(save_path,meter),row.names=FALSE)
  
  
  t2 <- 2056966
  t1 <- t2 - 1440 * 1
  data[t1:t2]$timestamp
  head(data[t1:t2]$timestamp,200)
}

aggregate_one_parameter_of_all_buildings <- function() {
  # this function does two things:
  # create a CSV contining only power data of all buildings
  # create csv showing which points are missing and which are there  
  path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_3/"
  fl <- list.files(path,pattern = "*.csv")
  
  df_files <- lapply(fl,function(x) {
    data <- fread(paste0(path,x), select = c("timestamp","power"))
    #tbl_data <- tbl_df(data) %>% mutate(timestamp = as.POSIXct(data$timestamp,origin = "1970-01-01", tz="Asia/Kolkata"))
    tbl_data <- tbl_df(data) %>% mutate(timestamp = as.POSIXct(data$timestamp,origin = "1970-01-01"))
    attr(tbl_data$timestamp, "tzone") <- "Asia/kolkata"
    return(tbl_data)
  })
  lapply(df_files,head)
  lapply(df_files,tail)
  
  dummy_year <- create_NA_timeseries_tibble('2013-08-10','2017-12-31 23:59:00','1 mins')
  # for transformers
  dummy_year <- create_NA_timeseries_tibble('2013-11-26','2017-12-31 23:59:00','1 mins')
  attr(dummy_year$timestamp, "tzone") <- "Asia/kolkata"
  for (i in 1:length(df_files)){
    temp <- full_join(dummy_year,df_files[[i]],by="timestamp")
    dummy_year <- temp
  }
  # remove second column
  temp <- dummy_year %>% select(timestamp,starts_with("power"))
  source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Data_wrangling/wrangle_data.R")
  data_xts <- mytbl_xts(temp)
  build_names <- c("Academic","Boys_main","Boys_backup","Facilities","Girls_main","Girls_backup","Lecture","Library","Mess")
  #for tranformer
  # build_names <- c('transfomer_1','transfomer_2','transfomer_3')
  colnames(data_xts) <- build_names
  savehere <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_3/"
  # write.csv(data.frame(timestamp=index(data_xts),coredata(data_xts)),paste0(savehere,"all_transformer_power.csv"),row.names = FALSE)
  
  
  # CREATE CSV WHICH SHOWS WHICH DATA POINTS ARE PRESENT AND WHICH ONE ARE MISSING
  data_present_status <- ifelse(is.na(data_xts),0,1)
  df_status <- data.frame(timestamp=index(data_xts),data_present_status)
  # write.csv(df_status,paste0(savehere,"data_present_status.csv"),row.names = FALSE)
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

sqeeze_all_builidngs_power_datasets <- function() {
  # this function is used to squeeze power reading of all the buildings, i.e., convert timestamp to unix timeformat and remove rows which contain NA's
  #def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "all_buildings_power.csv"
  data <- fread(paste0(def_path,meter))
  data$timestamp <- as.POSIXct(data$timestamp,origin = "1970-01-01", tz="Asia/Kolkata")
  # start_date <- as.POSIXct("2013-08-10")
  #  end_date <- as.POSIXct("2017-07-07 23:59:59")
  # temp <- data[data$timestamp>=start_date,]
  data_xts <- xts(data[,-1],data$timestamp)
  
  na_rows <- apply(data_xts,1,function(x) all(is.na(x)))
  xts_without_NA_rows <- data_xts[!na_rows,] 
  dframe <- data.frame(timestamp=index(xts_without_NA_rows),coredata(xts_without_NA_rows))
  dframe$timestamp <- as.numeric(dframe$timestamp)
  #save_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  save_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  # write.csv(dframe,paste0(save_path,"all_buildings_power_Unix_timstamp.csv"),row.names=FALSE)
}


show_data_presence_plot<- function(){
  # this function is used to show missing data using default minutely data.
  library(ggplot2)
  library(data.table)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
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
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "data_present_status.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  temp <- data[data$timestamp <= as.POSIXct("2017-07-07 23:59:59"),]
  temp_xts <- xts(temp[,-1],temp$timestamp)
  day_data <- split.xts(temp_xts,f="days",k=1)
  sumry_data <- lapply(day_data, function(x) {
    #x <- day_data[[1]]
    sumry <- apply(x,2,sum)
    sumry <- ifelse(sumry <= 1440/4, NA, 1)
    return(xts(data.frame(t(sumry)), as.Date(index(x[1]), tz = "Asia/Kolkata")))
    #return(sumry)
  })
  sumry_data_xts <-  do.call(rbind,sumry_data)
  # Calculate uptime for each meter
  #apply(sumry_data_xts,2,sum,na.rm=TRUE)/1428 #[1428 is the total no. of days]
  #    Academic    Boys_main  Boys_backup   Facilities   Girls_main Girls_backup      Lecture      Library         Mess   #   0.9880952    0.7261905    0.7331933    0.8928571    0.7002801    0.9985994    0.9880952    0.7240896    0.8725490
  uptime <- apply(sumry_data_xts,2,sum,na.rm=TRUE)
  # Next line has been counted manually, 1428 represents total no. of days, subtracted numbers from 1428 shows that corresponding meter started or stopped early by the mentioned days
  divisor  <- c(1428,1428,1428,1428-97,1428,1428,1428,1428-25,1428-45)
  uptime <-round(as.numeric(uptime/divisor)*100,1)
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
  g <- g + annotate("text",x=as.Date("2017-07-07"),y=seq(1.3,9.3,1),label=uptime)
  g <- g + scale_y_continuous(sec.axis = sec_axis(~./1, name = "Uptime (%)"  ))
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  # ggsave(filename="data_missing_plot_2.pdf",height = 5,width = 10,units = c("in"))
}

summarise_missing_data_plot_WITH_TRANsformer<- function(){
  # this function is used to plot the plot of paper which shows the days on which quater of the data is missing by gaps. This version also shows the transformer data
  library(ggplot2)
  library(data.table)
  library(xts)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "data_present_status.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  temp <- data[data$timestamp <= as.POSIXct("2017-12-31 23:59:59"),]
  temp_xts <- xts(temp[,-1],temp$timestamp)
  #ARRANGE TRANSFORMER DATA##
  transformer_data <-  "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_3/data_present_status.csv"
  df_tran <-  fread(transformer_data)
  df_tran$timestamp <- fasttime::fastPOSIXct(df_tran$timestamp)-19800
  df_tran <- df_tran[df_tran$timestamp <= as.POSIXct("2017-12-31 23:59:59"),]
  df_tran_xts <- xts(df_tran[,-1], fasttime::fastPOSIXct(df_tran$timestamp) - 19800)
  colnames(df_tran_xts) <- c("Transformer_1","Transformer_2","Transformer_3")
  ########
  temp_xts <- cbind(temp_xts,df_tran_xts)
  
  day_data <- split.xts(temp_xts,f="days",k=1)
  sumry_data <- lapply(day_data, function(x) {
    #x <- day_data[[1]]
    sumry <- apply(x,2,sum)
    sumry <- ifelse(sumry <=1440/4, NA, 1)
    return(xts(data.frame(t(sumry)),as.Date(index(x[1]),tz="Asia/Kolkata")))
    #return(sumry)
  })
  sumry_data_xts <-  do.call(rbind,sumry_data)
  # Calculate uptime for each meter
  # apply(sumry_data_xts,2,sum,na.rm=TRUE)/1428 #[1428 is the total no. of days]
  #    Academic    Boys_main  Boys_backup   Facilities   Girls_main Girls_backup      Lecture      Library         Mess   #   0.9880952    0.7261905    0.7331933    0.8928571    0.7002801    0.9985994    0.9880952    0.7240896    0.8725490
  uptime<- apply(sumry_data_xts,2,sum,na.rm=TRUE)
  # Next line has been counted manually, 1428 represents total no. of days, subtracted numbers from 1428 shows that corresponding metter started or stopped eary by the mentioned days
  #divisor  <- c(1428,1428,1428,1428-97,1428,1428,1428,1428-12,1428-45,1428-105,1428-105,1428-105) # first submitted version
  divisor  <- c(1605,1605,1605,1605-97,1605,1605,1605,1605-12,1605-45,1605-105,1605-105,1605-105)
  uptime <-round(as.numeric(uptime/divisor)*100,1)
  temp <- data.frame(timestamp=index(sumry_data_xts),coredata(sumry_data_xts))
  mulfactor <- 1:(NCOL(temp)-1)
  for (i in 2:NCOL(temp)) {
    temp[,i] <- temp[,i] * mulfactor[i-1] }
  data_long <- reshape2::melt(temp,id.vars=c("timestamp"))
  #  data_long$value <- ifelse(data_long$value==0,NA,data_long$value)
  names <- colnames(sumry_data_xts)
  g <- ggplot(data_long,aes(timestamp,value,color=variable)) + geom_line()
  g <- g + theme(axis.text = element_text(color="black"),axis.text.y = element_blank(),axis.ticks.y = element_blank(), legend.title = element_blank(), legend.position = "none" )+ labs(x= " ", y="Meter") + scale_x_date(breaks=scales::date_breaks("6 month"),labels = scales::date_format("%b-%Y"))
  g <- g + annotate("text",x=as.Date("2013-08-10"),y=seq(1.3,12.3,1),label=names,hjust=0)
  g <- g + annotate("text",x=as.Date("2018-01-05"),y=seq(1.3,12.3,1),label=uptime)
  g <- g + scale_y_continuous(sec.axis = sec_axis(~./1, name = "Uptime (%)"  ))
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  # ggsave(filename="data_missing_plot_version_3.pdf",height = 5,width = 10,units = c("in"))
}

plot_facetted_histograms_of_Data_WITH_TRANsformer<- function(){
  # this function is used to plot histograms of different meters in grid manner.
  # THIS ONE ALSO INCLUDES TRANSFORMER DATA
  library(ggplot2)
  library(data.table)
  library(xts)
  # REQUIRED FUNCTION
  remove_outliers <- function(x, na.rm = TRUE, ...) {
    # remove outliers from columns and fill with NAS
    # https://stackoverflow.com/a/4788102/3317829
    qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
    H <- 1.5 * IQR(x, na.rm = na.rm)
    y <- x
    y[x < (qnt[1] - H)] <- NA
    y[x > (qnt[2] + H)] <- NA
    y
  }
  
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "all_buildings_power.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  df_xts <- xts(data[,-1],data$timestamp)
  #ARRANGE TRANSFORMER DATA##
  transformer_data <-  "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_3/all_transformer_power.csv"
  df_tran <-  fread(transformer_data)
  df_tran_xts <- xts(df_tran[,-1], fasttime::fastPOSIXct(df_tran$timestamp) - 19800)
  colnames(df_tran_xts) <- c("Transformer_1","Transformer_2","Transformer_3")
  ########
  df_xts <- cbind(df_xts,df_tran_xts)
  df <- data.frame(timestamp=index(df_xts),coredata(df_xts))
  # handle zero readings in Lecture building
  df$Lecture <- ifelse(df$Lecture==0,NA,df$Lecture)
  # remove timestamp column and apply remove_outliers function
  temp2 <- apply(df[,-1],2,remove_outliers)
  data_long <- reshape2::melt(temp2)
  data_long$value <- data_long$value/1000
  data_long <- data_long[,2:3]
  #data_long$value <- ifelse(data_long$value==0,NA,data_long$value)
  g <- ggplot(data_long,aes(value)) + geom_histogram(binwidth = 1) + facet_wrap(~Var2 ,scales = "free")
  g <- g + labs(x="Power (kW)", y = "Count") + theme(axis.text = element_text(color = "black"))
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  # ggsave(filename="data_histograms_2.pdf",height = 8,width = 12,units = c("in"))
}

plot_facetted_histograms_of_Data<- function(){
  # this function is used to plot histograms of different meters in grid manner.
  library(ggplot2)
  library(data.table)
  library(xts)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "all_buildings_power.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  temp <- data[data$timestamp <= as.POSIXct("2017-07-07 23:59:59"),]
  data_long <- reshape2::melt(temp,id.vars=c("timestamp"))
  #  data_long$value <- ifelse(data_long$value==0,NA,data_long$value)
  names <- colnames(sumry_data_xts)
  data_long$value <- data_long$value/1000
  data_long <- data_long[,2:3]
  g <- ggplot(data_long,aes(value)) + geom_histogram(binwidth = 1) + facet_wrap(~variable,scales = "free")
  g <- g + labs(x="Power (kW)", y= "Count") + theme(axis.text = element_text(color = "black"),axis.text.y=element_blank(),axis.title.y=element_blank(),axis.ticks.y = element_blank())
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  #ggsave(filename="data_histograms.pdf",height = 6,width = 8,units = c("in"))
}


plot_histograms_hour_wise_data<- function(){
  # this function is used to plot hour-wise consumption of different buildings
  library(ggplot2)
  library(data.table)
  library(xts)
  library(dplyr)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  meter <- "all_buildings_power.csv"
  df <- fread(paste0(def_path,meter)) 
  df$timestamp <- fasttime::fastPOSIXct(df$timestamp)-19800
  start_date <- as.POSIXct("2017-01-01")
  end_date <- as.POSIXct("2017-04-30 23:59:59")
  temp <- df[df$timestamp>=start_date & df$timestamp <= end_date,]
  temp$hour <- lubridate::hour(temp$timestamp)
  tbl <- as_data_frame(temp)
  dat <- tbl %>% group_by(hour) %>% summarise_all(funs(mean(.,na.rm=TRUE))) %>% select(-timestamp)
  dat_long <- reshape2::melt(dat,id.vars="hour")
  g <- ggplot(dat_long,aes(hour,value/1000)) + geom_bar(stat="identity") + facet_wrap(~variable,scales = "free")
  g <- g + labs(x="Day hour", y= "Power(kW)") + theme(axis.text = element_text(color = "black"))
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  ggsave(filename="day_hour_usage_plot_2.pdf",height = 5,width = 8,units = c("in"))
}

plot_histograms_hour_wise_data_WITH_TRANSFORMER<- function(){
  # this function is used to plot hour-wise consumption of different buildings and supply transformer
  library(ggplot2)
  library(data.table)
  library(xts)
  library(dplyr)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "all_buildings_power.csv"
  df <- fread(paste0(def_path,meter)) 
  df$timestamp <- fasttime::fastPOSIXct(df$timestamp)-19800
  df_xts <- xts(df[,-1],df$timestamp)
  
  #ARRANGE TRANSFORMER DATA##
  transformer_data <-  "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_3/all_transformer_power.csv"
  df_tran <-  fread(transformer_data)
  df_tran_xts <- xts(df_tran[,-1], fasttime::fastPOSIXct(df_tran$timestamp) - 19800)
  colnames(df_tran_xts) <- c("Transformer_1","Transformer_2","Transformer_3")
  ########
  df_xts <- cbind(df_xts,df_tran_xts)
  start_date <- as.POSIXct("2017-01-01")
  end_date <- as.POSIXct("2017-04-30 23:59:59")
  temp <- df_xts[paste0(start_date,"/",end_date)]
  temp <- data.frame(timestamp=index(temp),coredata(temp))
  #temp <- df[df$timestamp>=start_date & df$timestamp <= end_date,]
  temp$hour <- lubridate::hour(temp$timestamp)
  tbl <- as_data_frame(temp)
  dat <- tbl %>% group_by(hour) %>% summarise_all(funs(mean(.,na.rm=TRUE))) %>% select(-timestamp)
  dat_long <- reshape2::melt(dat,id.vars="hour")
  g <- ggplot(dat_long,aes(hour,value/1000)) + geom_bar(stat="identity") + facet_wrap(~variable,scales = "free")
  g <- g + labs(x="Day hour", y= "Power(kW)") + theme(axis.text = element_text(color = "black"))
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  ggsave(filename="day_hour_usage_plot_2_1.pdf",height = 8,width = 12,units = c("in"))
}


plot_energy_and_temperature_data <- function(){
  # this function is used to plot monthly energy data and the average montly temperture
  library(ggplot2)
  library(data.table)
  library(xts)
  library(dplyr)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "all_buildings_power.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  start_date <- as.POSIXct("2013-08-10")
  end_date <- as.POSIXct("2017-12-31 23:59:59")
  data <- data[data$timestamp>=start_date & data$timestamp <= end_date,]
  data_xts <- xts(data[,-1],fasttime::fastPOSIXct(data$timestamp)-19800)
  power_sum <- apply.monthly(data_xts,apply,2, sum, na.rm=TRUE)
  # energy = power * time
  # energy = sum(power*1/60)*1/1000 [kWH]
  energy_month <- power_sum/60000
  
  # following 2 lines used in firs submission
  #weather_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/weatherdata_PROCESSED/"
  #dirs <- list.files(weather_path,recursive = TRUE,include.dirs = TRUE,pattern = "*FULL.csv")
  
  weather_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/weather/processed/"
  dirs <- list.files(weather_path,recursive = FALSE,include.dirs = FALSE,pattern = "*.csv")
  
  
  weather_files <- lapply(dirs, function(x){
    df <- fread(paste0(weather_path,x))
    df$V1 <- as.POSIXct(df$V1,tz="Asia/kolkata",origin="1970-01-01")
    df_xts <- xts(df[,-1],df$V1)
    #df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp)-19800)
    return(df_xts)
  })
  weather <- do.call(rbind,weather_files)
  weather_month <- apply.monthly(weather,mean)
  
  temp <- data.frame(timestamp = index(energy_month),coredata(energy_month$Academic),coredata(weather_month$temperature))
  
  colnames(temp) <- c("timestamp","Energy","Temperature")
  #https://rpubs.com/MarkusLoew/226759
  p <- ggplot(temp,aes(timestamp,Energy)) + geom_histogram(aes(colour="Energy"),stat="Identity")
  p <- p + geom_line(aes(y=Temperature*700,colour="Temperature"))
  p <- p + scale_y_continuous(sec.axis = sec_axis(~./700, name = "Temperature"*"("~degree*"C)"  ))
  p <- p + scale_colour_manual(values = c("blue", "red")) 
  p <- p + labs(y = "Energy (kWh)", x = "",colour = "Parameter") + scale_x_datetime(breaks=scales::date_breaks("6 month"),labels = scales::date_format("%b-%Y"))
  p <- p + theme(legend.position = c(0.1,0.9),axis.text = element_text(color = "black"))
  p
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  #ggsave(filename="energy_temperature.pdf",height = 3,width = 10,units = c("in"))
}

plot_energy_data_across_years <- function() {
  # this function is used to plot monthly energy data and the average montly temperture
  library(ggplot2)
  library(data.table)
  library(xts)
  library(dplyr)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  meter <- "all_buildings_power.csv"
  data <- fread(paste0(def_path,meter)) 
  data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  start_date <- as.POSIXct("2013-08-10")
  end_date <- as.POSIXct("2017-07-07 23:59:59")
  data <- data[data$timestamp>=start_date & data$timestamp <= end_date,]
  data_xts <- xts(data[,-1],fasttime::fastPOSIXct(data$timestamp)-19800)
  monthly_energy_summation <- function() {
    # this function plots monthly summation energy across years,
    # Input data is taken from prevous code.
    power_sum <- apply.monthly(data_xts,apply,2, sum, na.rm=TRUE)
    # energy = power * time
    # energy = sum(power*1/60)*1/1000 [kWH]
    energy_month <- power_sum/60000
    energy_month$year <- lubridate::year(index(energy_month))
    energy_month$month <- lubridate::month(index(energy_month))
    df_long <- reshape2::melt(fortify(energy_month),id.vars=c("Index","year","month"))
    p <- ggplot(df_long,aes(month,value,color=factor(year))) + geom_line() + facet_wrap(~variable,scales="free")
    p }
  monthly_average_energy <- function() {
    # this function plots monthly day wise average energy across years,
    # Input data is taken from prevous code.
    # next function is customized otherwise it sums NA values if any as zero
    power_daily2 <- apply.daily(data_xts,apply,2, 
                                function(x){
                                  temp <- ifelse(any(is.na(x)),NA,sum(x))
                                  return(temp)
                                })
    # energy = power * time
    # energy = sum(power*1/60)*1/1000 [kWH]
    energy_daily <- power_daily2/60000
    energy_monthly <- apply.monthly(energy_daily,apply,2, mean, na.rm=TRUE)
    
    
    energy_monthly$Year <-  lubridate::year(index(energy_monthly))
    energy_monthly$month <- lubridate::month(index(energy_monthly))
    df_long <- reshape2::melt(fortify(energy_monthly),id.vars=c("Index","Year","month"))
    df_long$Year <-as.factor(df_long$Year)
    p <- ggplot(df_long,aes(month,value,color=Year)) + geom_line() + geom_point(aes(shape=Year))+ facet_wrap(~variable,scales="free")
    p  <- p + scale_x_continuous(breaks=seq(1,12,1))
    p <-  p + labs(y = "Energy (kWh)", x = "Month of year")
    p <-  p + theme(legend.position = "top",axis.text = element_text(color = "black"))
    p
    setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
    #ggsave(filename=".pdf",height = 3,width = 10,units = c("in"))
    power_daily["2015-03-01/2015-03-28"]
    energy_daily["2014-05-01/2014-05-31"] 
  }
}

plot_campus_energy_and_temperature <- function(){
  # this scipt is used to plot total consumption of the campus and the average temperature. It takes data from all the three transformers and plots the data.
  library(data.table)
  library(xts)
  library(ggplot2)
  Sys.setenv(TZ='Asia/Kolkata')
  path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_3/all_transformer_power.csv"
  df <- fread(path,header = TRUE)
  df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp)-19800) # subtracting5:30 according to IST
  power_daily <- apply.daily(df_xts,apply,2, 
                             function(x){
                               #temp <- ifelse(any(is.na(x)),NA,sum(x))
                               temp <- sum(x,na.rm = TRUE)
                               return(temp)
                             })
  # energy = power * time
  # energy = sum(power*1/60)*1/1000 [kWH]
  energy_daily <- power_daily/60000
  temp <- apply(energy_daily,1,sum,na.rm=TRUE) 
  energy_monthly <- apply.monthly(temp, mean, na.rm=TRUE)
  energy_xts <- xts(as.numeric(energy_monthly),as.Date(row.names(energy_monthly) )) 
  plot(energy_xts)
  #weather data
  
  
  weather_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/weather/processed/"
  dirs <- list.files(weather_path,recursive = FALSE,include.dirs = FALSE,pattern = "*.csv")
  
  weather_files <- lapply(dirs, function(x){
    df <- fread(paste0(weather_path,x))
    df$V1 <- as.POSIXct(df$V1,tz="Asia/kolkata",origin="1970-01-01")
    df_xts <- xts(df[,-1],df$V1)
    #df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp)-19800)
    return(df_xts)
  })
  
  weather<- do.call(rbind,weather_files)
  weather_month <- apply.monthly(weather,mean,na.rm=TRUE)
  index(weather_month) <- as.Date(index(weather_month))
  index(weather_month) <- as.Date(index(weather_month))
  weather_month <- weather_month["2013-11-25/"]
  temp2 <- data.frame(timestamp=index(energy_xts),coredata(energy_xts),coredata(weather_month$temperature))
  colnames(temp2) <- c("timestamp","Energy","Temperature")
  # temp2$timestamp <- temp2$timestamp - 15 # shifting timestamp of mid of month
  #https://rpubs.com/MarkusLoew/226759
  temp3 <- temp2
  temp3$timestamp <- as.yearmon(temp3$timestamp)
  # temp3$category <- rep(c('cat1','cat2'),c(22,23))
  #temp3$category <- as.factor(temp3$category)
  
  p <- ggplot() 
  p <- p + geom_histogram(data=temp3,aes(timestamp,Energy,colour="black"),stat="Identity",bindwidth=10)
  p <- p + geom_line(data=temp3,aes(timestamp,y=Temperature*200,linetype="red"),colour="red",size=0.8)
  p <- p + scale_x_yearmon(format ="%b-%Y",n=10)
  p <- p + scale_y_continuous(sec.axis = sec_axis(~./200, name = "Temperature"*"("~degree*"C)"  ))
  p <- p + scale_linetype_manual( labels="Temperature", values = "solid") 
  p <- p + labs(y = "Energy (kWh)", x = "") 
  p <- p + scale_colour_manual(name = "", labels = "Energy", values = 'black')
  p <- p + guides(colour = guide_legend(override.aes = list(colour = "black", size = 1), order = 1), linetype = guide_legend(title = NULL, override.aes = list(linetype = "solid", colour = "red", size = 1),order = 2)) 
  p <- p + theme(legend.key = element_rect(fill = "white", colour = NA),legend.spacing = unit(0, "lines"),legend.position = c(0.1,0.85), legend.background = element_rect(fill = alpha('grey',0.1)),
                 axis.title.y.right = element_text(colour = "red"),axis.text.y.right = element_text(colour = "red"),axis.text.x = element_text(color = "black"),axis.text.y.left  = element_text(color = "black"))
  p
  # ggsave(filename="campus_total_energy_and_temperature_3.pdf",height = 3,width = 8,units = c("in"))
}

show_transformer_data_present_status <- function(){
  # this function is used to write a CSV which shows on what timings we have logged meter data and the timings when data got missed
  library(data.table)
  library(xts)
  library(ggplot2)
  path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_2/all_transformer_power.csv"
  df <- fread(path,header = TRUE)
  df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp)-19800) # subtracting5:30 according to IST
  data_present_status <- ifelse(is.na(df_xts),0,1)
  df_status <- data.frame(timestamp=index(df_xts),data_present_status)
  savepath <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_2/"
  # write.csv(df_status,paste0(savepath,"data_present_status_transformer.csv"),row.names = FALSE)
}

plot_line_graph_hour_wise_data<- function(){
  # this function is used to plot hour-wise consumption of different buildings and supply transformer
  library(ggplot2)
  library(data.table)
  library(xts)
  library(dplyr)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  meter <- "all_buildings_power.csv"
  df <- fread(paste0(def_path,meter)) 
  df$timestamp <- fasttime::fastPOSIXct(df$timestamp)-19800
  df_xts <- xts(df[,-1],df$timestamp)
  
  #ARRANGE TRANSFORMER DATA##
  transformer_data <-  "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_2/all_transformer_power.csv"
  df_tran <-  fread(transformer_data)
  df_tran_xts <- xts(df_tran[,-1], fasttime::fastPOSIXct(df_tran$timestamp) - 19800)
  colnames(df_tran_xts) <- c("Transformer_1","Transformer_2","Transformer_3")
  ########
  df_xts_comb <- cbind(df_xts,df_tran_xts)
  # get January data
  start_date <- as.POSIXct("2017-01-01")
  end_date <- as.POSIXct("2017-01-30 23:59:59")
  temp <- df_xts_comb[paste0(start_date,"/",end_date)]
  data_month_1 <- create_data_summary(temp,month="January")
  # get June data
  start_date <- as.POSIXct("2016-08-01")
  end_date <- as.POSIXct("2016-08-30 23:59:59")
  temp <- df_xts_comb[paste0(start_date,"/",end_date)]
  data_month_6 <- create_data_summary(temp,month="August")
  
  comb_data<- rbind(data_month_1,data_month_6)
  
  dat_long <- reshape2::melt(comb_data,id.vars=c("hour","Month"))
  dat_long$Month <- as.factor(dat_long$Month)
  
  g <- ggplot(dat_long,aes(hour,value/1000)) + geom_line(aes(group=Month,colour=Month,linetype=Month),size=0.8) + facet_wrap(~variable,scales = "free")
  g <- g + labs(x="Day hour", y= "Power(kW)") + theme(axis.text = element_text(color = "black"),legend.position = "top")
  g
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  # 
  # ggsave(filename="day_hour_usage_plot_2_3.pdf",height = 8,width = 11,units = c("in"))
}

create_version_3_of_dataset <- function() {
  # this function combines data of two releases, pre july 2017 and after july 2017
  root_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
  branch_path <- paste0(root_path,'after_july7/')
  #meter <- "transformer_3.csv"
  meters <-  c( 
    "boys_hostel_mains.csv",
    "girls_hostel_mains.csv",
    "acad_build_mains.csv",
    "lecture_build_mains.csv",
    "library_build_mains.csv",
    "mess_build_mains.csv",
    "facilities_build_mains.csv",
    "boys_hostel_ups.csv",
    "girls_hostel_ups.csv"
    #  "transformer_1.csv",
    #  "transformer_2.csv",
    # "transformer_3.csv",
  )
  for (i in 1:length(meters)){ 
    meter <- meters[i]
    prejuly2017_data <- fread(paste0(root_path,meter))
    postjuly2017_data <- fread(paste0(branch_path,meter))
    concat_df <- rbind(prejuly2017_data,postjuly2017_data)
    save_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
    write.csv(concat_df,paste0(save_path,meter),row.names=FALSE)
  }  
}

plot_power_occupancy_data <- function(){
  #  I use this function to plot power and occupancy of two buildings.
  #  Remember at the time of plotting, the occupancy dataset was 5:30 hours lagging (seems in UTC) so I forced timestamps to correct value.
  library(ggplot2)
  library(data.table)
  library(xts)
  library(dplyr)
  Sys.setenv(TZ='Asia/Kolkata')
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Submitted/IIIT_dataset/figures/")
  
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "acad_build_mains.csv"
  data <- fread(paste0(def_path,meter))
  data$timestamp <- as.POSIXct(data$timestamp,tz="Asia/Kolkata",origin = "1970-01-01")
  #data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  start_date <- as.POSIXct("2017-04-01")
  end_date <- as.POSIXct("2017-04-05 23:59:59")
  data_sub <- data[data$timestamp >= start_date & data$timestamp <= end_date,]
  data_sub_xts <- xts(data_sub$power,data_sub$timestamp)
  data_sampled <- resample_data_minutely(data_sub_xts,30)
  plot(data_sampled)
  #ggplot(data,aes(timestamp,power))+ geom_line()
  
  occupancy_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/final_processed_data/ACB.csv"
  
  occu_df <- fread(occupancy_path)
  occu_df$timestamp <- as.POSIXct(occu_df$timestamp,tz="Asia/Kolkata",origin = "1970-01-01")
  occu_df$timestamp <- occu_df$timestamp + 19800 # adding 5:30 hours
  occu_sub <- occu_df[occu_df$timestamp >= start_date & occu_df$timestamp <= end_date,]
  occu_xts <- xts(occu_sub$occupancy_count, occu_sub$timestamp) 
  occu_sampled <- resample_occupancy_minutely(occu_xts,30)
  plot(occu_sampled)
  
  temp <- cbind(data_sampled,occu_sampled)
  temp_df <- fortify(temp)
  colnames(temp_df) <- c("timestamp","power","occupancy")
  p <- ggplot(temp_df,aes(timestamp,power/1000)) + geom_line(aes(colour="Power"))
  p <- p + geom_line(aes(y=occupancy/10,colour="Occupancy"))
  p <- p + scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Occupancy count"))
  p <- p + scale_colour_manual(values = c("blue", "red")) 
  p <- p + labs(y = "Power (kW)", x = "",colour = "") + scale_x_datetime(breaks=scales::date_breaks("1 day"),labels = scales::date_format("%d-%b"))
  p <- p + theme(legend.position = c(0.2,0.9),axis.text.x = element_text(color = "black"))
  p <- p + theme(axis.text.y.right=element_text(colour = "blue"),axis.title.y.right=element_text(colour = "blue"),axis.title.y.left = element_text(colour = "red"),axis.text.y.left = element_text(color = "red"))
  p
  #ggsave("occu_power_acb_1.pdf",height = 2,width = 6,units = c("in"))
  
  
  
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
  meter <- "girls_hostel_mains.csv"
  data <- fread(paste0(def_path,meter))
  data$timestamp <- as.POSIXct(data$timestamp,tz="Asia/Kolkata",origin = "1970-01-01")
  #data$timestamp <- fasttime::fastPOSIXct(data$timestamp)-19800
  start_date <- as.POSIXct("2017-04-01")
  end_date <- as.POSIXct("2017-04-05 23:59:59")
  data_sub <- data[data$timestamp >= start_date & data$timestamp <= end_date,]
  data_sub_xts <- xts(data_sub$power,data_sub$timestamp)
  data_sampled <- resample_data_minutely(data_sub_xts,30)
  plot(data_sampled)
  #ggplot(data,aes(timestamp,power))+ geom_line()
  
  occupancy_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/final_processed_data/GH.csv"
  
  occu_df <- fread(occupancy_path)
  occu_df$timestamp <- as.POSIXct(occu_df$timestamp,tz="Asia/Kolkata",origin = "1970-01-01")
  occu_df$timestamp <- occu_df$timestamp + 19800 # adding 5:30 hours
  occu_sub <- occu_df[occu_df$timestamp >= start_date & occu_df$timestamp <= end_date,]
  occu_xts <- xts(occu_sub$occupancy_count, occu_sub$timestamp) 
  occu_sampled <- resample_occupancy_minutely(occu_xts,30)
  plot(occu_sampled)
  
  temp <- cbind(data_sampled,occu_sampled)
  temp_df <- fortify(temp)
  colnames(temp_df) <- c("timestamp","power","occupancy")
  p <- ggplot(temp_df,aes(timestamp,power/1000)) + geom_line(aes(colour="Power"))
  p <- p + geom_line(aes(y=occupancy/10,colour="Occupancy"))
  p <- p + scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Occupancy count"))
  p <- p + scale_colour_manual(values = c("blue", "red")) 
  p <- p + labs(y = "Power (kW)", x = "",colour = "") + scale_x_datetime(breaks=scales::date_breaks("1 day"),labels = scales::date_format("%d-%b"))
  p <- p + theme(legend.position = c(0.2,0.9),axis.text.x = element_text(color = "black"))
  p <- p + theme(axis.text.y.right=element_text(colour = "blue"),axis.title.y.right=element_text(colour = "blue"),axis.title.y.left = element_text(colour = "red"),axis.text.y.left = element_text(color = "red"))
  p
  #ggsave("occu_power_girls_main_1.pdf",height = 2,width = 6,units = c("in"))
}