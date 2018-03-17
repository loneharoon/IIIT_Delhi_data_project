library(ggplot2)
library(xts)
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Submitted/KDD_2017/KDD2018/figures/")
rootdir = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/formatted_iiitd_airport_data.csv"
df = read.csv(rootdir)
#df_xts <- xts(df[,2:NCOL(df)], fasttime::fastPOSIXct(df$X))
df$X = fasttime::fastPOSIXct(df$X)

df_temp <- df[,c(1,2,4)]


colnames(df_temp) <- c('timestamp','Airport','IIIT-Delhi')
temp_melt <- reshape2::melt(df_temp,id.vars=c('timestamp'))
g <- ggplot(temp_melt,aes(timestamp,value,color=variable)) + geom_line(size=0.6)
g <- g + labs(x = 'Timestamp', y = 'Temperature(°C)') + scale_colour_brewer(palette = "Set1")
g <- g + theme(text = element_text(size = 9),axis.text = element_text(color="Black",size=8),legend.position =  c(0.08,0.85),legend.text = element_text(size = 9),legend.title = element_blank(),legend.background = element_rect(fill = alpha('grey',0.2)))  
g <- g + scale_x_datetime(breaks=scales::date_breaks("1 day"),labels = scales::date_format("%d-%b"))
g
ggsave("")


df_humidity <- df[,c(1,3,5)]