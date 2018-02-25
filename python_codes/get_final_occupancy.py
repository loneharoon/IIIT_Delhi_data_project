#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This is the  fianl script to compute occupancy building wise. It basically concatenates differeent month results building  wise
Created on Sun Feb 25 22:51:21 2018

@author: haroonr
"""
import pandas as pd
import os 
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
  #%%