
# this script is used to create first instance of the institute calender

savedir <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/iiitd_calender_schedule/"
 start = as.Date("2013-08-01")
 end = as.Date("2013-12-31") 
 timeseq <- seq(start,end,by="1 day")
 df <- data.frame(Date=timeseq)
 df$working_day <- ifelse(lubridate::wday(timeseq) %in% c(1,7),0,1)
 df$activity <- ifelse(lubridate::month(timeseq) %in% c(1:4,8:11),'H','L')
 fname <- "iiitd_calender_year_2013_.csv"
 write.csv(df,paste0(savedir,fname),row.names = FALSE)
 