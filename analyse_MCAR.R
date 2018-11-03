# in this I do the MCAR test on the testsets as asked in the second review 
#
rm(list=ls())
library(xts)
library(data.table)
library(mvnmle)
library(BaylorEdPsych)
Sys.setenv(TZ='Asia/Kolkata')
# data_present_status_all_meters shows 1 for days when majority of data was logged and NA for days when more than 25% of data was missing
df3 = fread("/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/data_present_status_all_meters.csv")
df3_xts = xts(df3[,3:14],fasttime::fastPOSIXct(df3$Index)-19800)
# over several experiments, I found that using [1, NA] values only fails LittelMCAR function so I replace 1 values in the given matrix with random values as
tt = apply(df3_xts,2,function(temp){
  for (j in c(1:length(temp))){
    if (!is.na(temp[j])) {
      temp[j] = runif(1,1,100)
    }
  }
  return(temp)
})
# now do test
res = LittleMCAR(tt)
res$p.value
# saving data, if in case we need to work on this data in python.
# Intention was to use https://github.com/RianneSchouten/pymice library  so as to compute p value for each corresponding columns. But doing that results in NaN value for some pairs.
save_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
write.csv(tt,paste0(save_path,"data_status_ones_replaced.csv"))
#If in case, we use above python library, then we can plot obtained results in corellogram style as
library(ggcorrplot)
save_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
# "mcar_matrix.csv" was obtained in python with above library.
df = read.csv(paste0(save_path,"mcar_matrix.csv"))
df2 = df[2:13]
ggcorrplot(df2, legend.title = "P value",sig.level = 0,lab = TRUE,type="upper")


