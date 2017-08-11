library(data.table)
library(xts)
library(fasttime)
#library(ggvis)
def_path_proc <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed/"
meter <- "acad_build_mains.csv"
df <- fread(paste0(def_path_proc,meter))
df_xts <- xts(df[,2:NCOL(df)], fastPOSIXct(df$timestamp)-19800)

startdate <- fastPOSIXct(paste0("2013-09-01",' ',"00:00:00"))-19800
enddate <- fastPOSIXct(paste0("2013-09-31",' ',"23:59:59"))-19800
df_sub <- df_xts[paste0(startdate,"/",enddate)]

visualize_dataframe_all_columns(df_sub[,'power'])
visualize_dataframe_all_columns(df_sub[,'energy'])
visualize_dataframe_all_columns(df_sub[,'current'])
visualize_dataframe_all_columns(df_sub[,'voltage'])
visualize_dataframe_all_columns(df_sub[,'power_factor'])
visualize_dataframe_all_columns(df_sub[,'frequency'])
