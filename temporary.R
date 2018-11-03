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