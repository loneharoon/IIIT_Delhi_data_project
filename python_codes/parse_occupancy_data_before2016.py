#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this script, I parse data collected from Digvijay;s system.
The extracted dump is stored on the ubuntu server too. I might delete data file from my system after processing since it size is 4.5GB
Created on Mon Feb 26 21:30:07 2018

@author: haroonr
"""
import numpy as np
import pandas as pd
from datetime import datetime
from collections import defaultdict

#fl = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/occupancy_dump_before2016.csv"

#df_sub = df.iloc[:3240704]
#df_sub.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/subset_2014.csv")
fl = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/subset_2014.csv"
#%%
df = pd.read_csv(fl)
df.drop(['Unnamed: 0'],axis=1,inplace=True)

df.columns = ["device_id",'client_id','timestamp','acces_point','trap']
df.timestamp = pd.to_datetime(df.timestamp)
bh_df = df[df.acces_point.str.startswith('BH')]
