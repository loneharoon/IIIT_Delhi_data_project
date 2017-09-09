# IN this script we process each dataset separtely 
# steps done: remove energy column, remove rows with entire NA values, round values to 5 decimal places, convert timestamps to unix format.
# IMPORTANT NOTE: In files library, lecture, mess and boys_ups there are some unknnown inconsitency which creates problems so a solution is to identify the dates usually last dates of dataset and remove them before processing further.
rm(list=ls())
library(xts)
library(data.table)


create_version_2_of_dataset <- function() {
  # this function exclusiely creates version 2 of the dataset
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed/"
  meter <- "girls_hostel_ups.csv"
  data <- fread(paste0(def_path,meter))
  # the next step is applied only for the files: library, lecture, mess and boys_ups,girls_ups
  data <- data[1:(2056320),]
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
  # write.csv(round(dframe,5),paste0(save_path,meter),row.names=FALSE)
  t2 <- 2056966
  t1 <- t2 - 1440 * 1
  data[t1:t2]$timestamp
  head(data[t1:t2]$timestamp,200)
}

aggregate_one_parameter_of_all_buildings <- function() {
  # this function does two things:
  # create a CSV contining only power data of all buildings
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
  # Calculate uptime for each meter
  #apply(sumry_data_xts,2,sum,na.rm=TRUE)/1428 #[1428 is the total no. of days]
  #    Academic    Boys_main  Boys_backup   Facilities   Girls_main Girls_backup      Lecture      Library         Mess   #   0.9880952    0.7261905    0.7331933    0.8928571    0.7002801    0.9985994    0.9880952    0.7240896    0.8725490
  uptime<- apply(sumry_data_xts,2,sum,na.rm=TRUE)
  # Next line has been counted manually, 1428 represents total no. of days, subtracted numbers from 1428 shows that corresponding metter started or stopped eary by the mentioned days
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
   
plot_facetted_histograms_of_Data<- function(){
  # this function is used to plot histograms of different meters in grid manner.
  library(ggplot2)
  library(data.table)
  library(xts)
  def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_2/"
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

plot_energy_and_temperature_data <- function(){
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
  power_sum <- apply.monthly(data_xts,apply,2, sum, na.rm=TRUE)
  # energy = power * time
  # energy = sum(power*1/60)*1/1000 [kWH]
  energy_month <- power_sum/60000

  
  weather_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/weatherdata_PROCESSED/"
  dirs <- list.files(weather_path,recursive = TRUE,include.dirs = TRUE,pattern = "*FULL.csv")
  weather_files <- lapply(dirs, function(x){
    df <- fread(paste0(weather_path,x))
    df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp)-19800)
    return(df_xts)
  })
  weather<- do.call(rbind,weather_files)
  weather_month <- apply.monthly(weather,mean)
  
  temp <- data.frame(timestamp=index(energy_month),coredata(energy_month$Academic),coredata(weather_month$TemperatureC))
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

compute_campus_energy <- function(){
  # this scipt is used to plot total consumption of the campus and the average temperature. It takes data from all the three transformers and plots the data.
  library(data.table)
  library(xts)
  library(ggplot2)
  path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/supply/processed_phase_2/all_transformer_power.csv"
  df <- fread(path,header = TRUE)
  df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp)-19800) # subtracting5:30 according to IST
  power_daily <- apply.daily(df_xts,apply,2, 
                             function(x){
                               temp <- ifelse(any(is.na(x)),NA,sum(x))
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
  weather_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/weatherdata_PROCESSED/"
  dirs <- list.files(weather_path,recursive = TRUE,include.dirs = TRUE,pattern = "*FULL.csv")
  weather_files <- lapply(dirs, function(x){
    df <- fread(paste0(weather_path,x))
    df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp)-19800)
    return(df_xts)
  })
  weather<- do.call(rbind,weather_files)
  weather_month <- apply.monthly(weather,mean)
  index(weather_month) <- as.Date(index(weather_month))
  index(weather_month) <- as.Date(index(weather_month))
  weather_month <- weather_month["2013-11-25/"]
  temp2 <- data.frame(timestamp=index(energy_xts),coredata(energy_xts),coredata(weather_month$TemperatureC))
  colnames(temp2) <- c("timestamp","Energy","Temperature")
  # temp2$timestamp <- temp2$timestamp - 15 # shifting timestamp of mid of month
  #https://rpubs.com/MarkusLoew/226759
  temp3 <- temp2
  temp3$timestamp <- as.yearmon(temp3$timestamp)
  #  p <- ggplot(temp2,aes(timestamp,Energy)) + geom_histogram(aes(colour="Energy"),stat="Identity")
  #  p <- p + geom_line(aes(y=Temperature*200,colour="Temperature"))
  #  p <- p + scale_y_continuous(sec.axis = sec_axis(~./200, name = "Temperature"*"("~degree*"C)"  ))
  #  p <- p + scale_colour_manual(values = c("blue", "red")) 
  #   p <- p + labs(y = "Energy (kWh)", x = "",colour = "Parameter") + scale_x_date(breaks=scales::date_breaks("2 month"),labels = scales::date_format("%b-%Y",tz="UTC"))
  # # p <- p + labs(y = "Energy (kWh)", x = "",colour = "Parameter") + scale_x_date(breaks=seq(as.POSIXct("2013-11-30"),as.POSIXct("2017-06-30"),"1 mon"),labels = scales::date_format("%b-%Y",tz="Asia/Kolkata"))
  #   p <- p + theme(legend.position = c(0.1,0.9),axis.text = element_text(color = "black"),axis.text.x = element_text(angle = 90, hjust = 1))
  #  p
  p <- ggplot(temp3,aes(timestamp,Energy)) + geom_histogram(aes(colour="Energy"),stat="Identity",bindwidth=10)
  p <- p + geom_line(aes(y=Temperature*200,colour="Temperature"))
  p <- p + scale_y_continuous(sec.axis = sec_axis(~./200, name = "Temperature"*"("~degree*"C)"  ))
  p <- p + scale_colour_manual(values = c("black", "red")) 
  p <- p + labs(y = "Energy (kWh)", x = "",colour = "Parameter") 
  p <- p + scale_x_yearmon(format ="%b-%Y",n=30)
  p <- p + theme(legend.position = c(0.1,0.9),axis.text = element_text(color = "black"),axis.text.x = element_text(angle = 90, hjust = 1))
  p
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/IIIT_dataset/figures/")
  #ggsave(filename="campus_total_energy_and_temperature.pdf",height = 4,width = 10,units = c("in"))
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


