'in this script I plot the boxplots showing duplicacy count of buidling occupancy'
library(ggplot2)
library(data.table)
library(xts)
#girls_hostel_mains.csv, boys_hostel_mains.csv,acad_build_mains,fac_build_mains,lecture_build_mains,
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/IIIT_Delhi_data_project/reports/figures/")
read_data_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/july2018_occupancy_duplication/R_data/"



df1 = fread(paste0(read_data_path,'BH_semester.csv'),header = TRUE)
df_new1 = data.table(reshape2::melt(df1))
df_new1 = cbind(df_new1, "bldg"="Boys Dormitory")

df2 = fread(paste0(read_data_path,'GH_semester.csv'),header = TRUE)
df_new2 = data.table(reshape2::melt(df2))
df_new2 = cbind(df_new2, "bldg"="Girls Dormitory")

df3 = fread(paste0(read_data_path,'ACB_semester.csv'),header = TRUE)
df_new3 = data.table(reshape2::melt(df3))
df_new3 = cbind(df_new3, "bldg"="Academic Building")


df4 = fread(paste0(read_data_path,'DB_semester.csv'),header = TRUE)
df_new4 = data.table(reshape2::melt(df4))
df_new4 = cbind(df_new4, "bldg"="Dining Building")

df5 = fread(paste0(read_data_path,'LCB_semester.csv'),header = TRUE)
df_new5 = data.table(reshape2::melt(df5))
df_new5 = cbind(df_new5, "bldg"="Lecture Building")

df6 = fread(paste0(read_data_path,'LB_semester.csv'),header = TRUE)
df_new6 = data.table(reshape2::melt(df6))
df_new6 = cbind(df_new6, "bldg"="Library Building")

df7 = fread(paste0(read_data_path,'SRB_semester.csv'),header = TRUE)
df_new7 = data.table(reshape2::melt(df7))
df_new7 = cbind(df_new7, "bldg"="Facilities Building")


df = rbind(df_new1, df_new2, df_new3,df_new4, df_new5, df_new6,df_new7)

h <- ggplot(df,aes(variable, value)) + facet_wrap(~bldg,ncol=4,scales = "free_y") + geom_boxplot(outlier.size = 0.000001,size=0.1,outlier.color = 'red',fill="white",colour= "#3366FF",outlier.shape = 1)
#h  <- h + scale_x_continuous(breaks=seq(0,23,2))
h <-  h + labs(x = "Day Hour", y = "Duplicacy Count")
h <-  h + theme(text = element_text(size=6) ,axis.text = element_text(color = "black")) + scale_x_discrete(breaks= seq(0,23,2))
h

spath <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Submitted/IIIT_dataset/figures/"
ggsave(paste0(spath,"duplicacy_count_figure.pdf"),width=6,height = 2.5, units = "in")

# Now cosidering only Summer or vacation months
# 
df1 = fread(paste0(read_data_path,'BH_summer.csv'),header = TRUE)
df_new1 = data.table(reshape2::melt(df1))
df_new1 = cbind(df_new1, "bldg"="Boys Dormitory")

df2 = fread(paste0(read_data_path,'GH_summer.csv'),header = TRUE)
df_new2 = data.table(reshape2::melt(df2))
df_new2 = cbind(df_new2, "bldg"="Girls Dormitory")

df3 = fread(paste0(read_data_path,'ACB_summer.csv'),header = TRUE)
df_new3 = data.table(reshape2::melt(df3))
df_new3 = cbind(df_new3, "bldg"="Academic Building")


df4 = fread(paste0(read_data_path,'DB_summer.csv'),header = TRUE)
df_new4 = data.table(reshape2::melt(df4))
df_new4 = cbind(df_new4, "bldg"="Dining Building")

df5 = fread(paste0(read_data_path,'LCB_summer.csv'),header = TRUE)
df_new5 = data.table(reshape2::melt(df5))
df_new5 = cbind(df_new5, "bldg"="Lecture Building")

df6 = fread(paste0(read_data_path,'LB_summer.csv'),header = TRUE)
df_new6 = data.table(reshape2::melt(df6))
df_new6 = cbind(df_new6, "bldg"="Library Building")

df7 = fread(paste0(read_data_path,'SRB_summer.csv'),header = TRUE)
df_new7 = data.table(reshape2::melt(df7))
df_new7 = cbind(df_new7, "bldg"="Facilities Building")


df_sumr = rbind(df_new1, df_new2, df_new3,df_new4, df_new5, df_new6,df_new7)
h <- ggplot(df_sumr,aes(variable, value)) + facet_wrap(~bldg,ncol=4,scales = "free_y") + geom_boxplot(outlier.size = 0.1,size=0.3)
#h  <- h + scale_x_continuous(breaks=seq(0,23,2))
h <-  h + labs(x = "Day Hour", y = "Duplicacy Count")
h <-  h + theme(text = element_text(size=6) ,axis.text = element_text(color = "black")) + scale_x_discrete(breaks= seq(0,23,2))
h
spath <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Submitted/IIIT_dataset/figures/"
ggsave(paste0(spath,"duplicacy_count_figure_summer.pdf"),width=6,height = 2.5, units = "in")

