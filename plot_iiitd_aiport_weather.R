# created: 17 March 2018
# in this I plot IIITD and VIDP weather data REQUIRED for variance analysis in the paper [NATURE]
# 
library(ggplot2)
library(xts)
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Submitted/IIIT_dataset/figures/")
rootdir = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/formatted_iiitd_airport_data.csv"
df = read.csv(rootdir)
#df_xts <- xts(df[,2:NCOL(df)], fasttime::fastPOSIXct(df$X))
df$X = fasttime::fastPOSIXct(df$X)

df_temp <- df[,c(1,2,4)]
colnames(df_temp) <- c('timestamp','Airport','IIIT-Delhi')
temp_melt <- reshape2::melt(df_temp,id.vars=c('timestamp'))
g <- ggplot(temp_melt,aes(timestamp,value,color=variable)) + geom_line(size=0.6)
g <- g + labs(x = 'Timestamp', y = 'Temperature(°C)') + scale_colour_brewer(palette = "Set1")
g <- g + theme(text = element_text(size = 9),axis.text = element_text(color="Black",size=8),legend.position =  c(0.9,0.13),legend.text = element_text(size = 9),legend.title = element_blank(),legend.background = element_rect(fill = alpha('grey',0.1)))  
g <- g + scale_x_datetime(breaks=scales::date_breaks("2 day"),labels = scales::date_format("%d-%b"))
g
#ggsave("temperature_airport_iiitd.pdf",height = 2,width = 6,units = c("in"))


df_humidity <- df[,c(1,3,5)]
colnames(df_humidity) <- c('timestamp','Airport','IIIT-Delhi')
humid_melt <- reshape2::melt(df_humidity,id.vars=c('timestamp'))
g <- ggplot(humid_melt,aes(timestamp,value,color=variable)) + geom_line(size=0.6)
g <- g + labs(x = 'Timestamp', y = 'Humidity (%RH)') + scale_colour_brewer(palette = "Set1")
g <- g + theme(text = element_text(size = 9),axis.text = element_text(color="Black",size=8),legend.position =  c(0.9,0.83),legend.text = element_text(size = 9),legend.title = element_blank(),legend.background = element_rect(fill = alpha('grey',0.1)))  
g <- g + scale_x_datetime(breaks=scales::date_breaks("2 day"),labels = scales::date_format("%d-%b"))
g
#ggsave("humidity_airport_iiitd.pdf",height = 2,width = 6,units = c("in"))

