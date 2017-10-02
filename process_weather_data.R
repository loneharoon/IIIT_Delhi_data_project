

# this scrips mostly changes POSIXct form to numeric one

library(data.table)
def_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_weather/"
fls <- list.files(def_path)

for(i in 1:length(fls)) {
df <- fread(paste0(def_path,fls[i])) 
df$timestamp <- fasttime::fastPOSIXct(df$timestamp) - 19800
df$timestamp <- as.numeric(df$timestamp)
write.csv(df,paste0(def_path,fls[i]),row.names = FALSE)
}