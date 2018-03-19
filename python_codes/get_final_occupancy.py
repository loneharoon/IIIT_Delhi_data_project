#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CTM: Joy' downloaded data is in UTC timestamp, so always add 5:30 hours before plotting results
This is the  final script to compute occupancy building wise. It basically concatenates different month results building wise
First two cells deal explicitly with Joy's data and in the last cell I merge data from Joy's and Digvijay's system

Created on Sun Feb 25 22:51:21 201

@author: haroonr
"""
import pandas as pd
import os 
import datetime
#%%
months = ["data_2015_december.csv","data_2016_january.csv","data_2016_february.csv","data_2016_march.csv","data_2016_april.csv","data_2016_may.csv","data_2016_june.csv","data_2016_july.csv","data_2016_august.csv","data_2016_september.csv","data_2016_october.csv","data_2016_november.csv","data_2016_december.csv","data_2017_january.csv","data_2017_february.csv","data_2017_march.csv","data_2017_april.csv","data_2017_may.csv","data_2017_june.csv","data_2017_july.csv","data_2017_august.csv","data_2017_september.csv","data_2017_september_last.csv","data_2017_october.csv","data_2017_november.csv","data_2017_december.csv"]

direc_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/processed_stage_2"
save_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/final_stage"
buildings = ['BH','GH','DB','ACB','LCB','LB','SRB']
for build in buildings:
  df_months = []
  for month in months:
    dpath = os.path.join(direc_path, build,month)
    df = pd.read_csv(dpath)
    df.columns= ["timestamp","occupancy_count"]
    df.timestamp = pd.to_datetime(df.timestamp)
    df_months.append(pd.Series(data=df.occupancy_count.values,index=df.timestamp.values))
  res = pd.concat(df_months,axis=0) 
  saveloc = os.path.join(save_path,build+".csv")
  res.to_csv(saveloc)
#%% In this cell, I create 10 minute version of Joy's data
readir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/processed_stage_3_Joys/"
building = "GH.csv"
df = pd.read_csv(readir + building)
ds = pd.Series(data = df.iloc[:,1].values, index = df.iloc[:,0].values)
ds.index = pd.to_datetime(ds.index) 
ds_sub = ds.resample('10 T',label='right',closed='right').max()
savedirectory = readir + "processed_stage_10minutely/"
ds_sub.to_csv(savedirectory+building)
#%% In this cell, I combine data from joy's and Digvijays system into one final file
# I combine then remove Nans and finally convert timestamp to UNIX format and save file
readir_joy = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/processed_stage_3_Joys/processed_stage_10minutely/"
readir_digvijay = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/digvijay_dump_results/processed_stage_10minutely/" 
building = "SRB.csv"
df_dy = pd.read_csv(readir_digvijay + building)
df_joy = pd.read_csv(readir_joy + building)
ds_dy = pd.Series(data = df_dy.iloc[:,1].values, index = df_dy.iloc[:,0].values)
ds_dy.index = pd.to_datetime(ds_dy.index) 
ds_joy = pd.Series(data = df_joy.iloc[:,1].values, index = df_joy.iloc[:,0].values)
ds_joy.index = pd.to_datetime(ds_joy.index) 
#ds_dy_sub = ds_dy[:'2015-11-30']
#ds_joy_sub = ds_joy['2015-12-1':'2017-11-3']
ds_joy.index = ds_joy.index + datetime.timedelta(minutes = 60*5 + 30)
ds_dy_sub = ds_dy[:'2015-12-1 01:00:00']
ds_joy_sub = ds_joy['2015-12-1 01:10:00':'2017-11-3']
ds_final  = pd.concat([ds_dy_sub,ds_joy_sub]) 
#%
ds_final['2017-02-01':'2017-03-21'] = float('nan')  # seems garbage values are stuck
ds_result = ds_final.dropna()
ds_result.index = ds_result.index.tz_localize('Asia/Kolkata')
unix_index = [ind.timestamp() for ind in ds_result.index]
ds_result.index = unix_index
df =  pd.DataFrame({'timestamp':ds_result.index.values,'occupancy_count':ds_result.values},columns=['timestamp','occupancy_count'])
save_directory = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/final_processed_data/"
df.to_csv(save_directory+building,index=False)
#%%
