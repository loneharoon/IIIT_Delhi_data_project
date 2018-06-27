#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Mar 18 19:44:32 2018

@author: haroonr
"""

import pandas as pd
import datetime

#%% Read energy data correctly
energy_data_direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/lecture_build_mains.csv"
df_e = pd.read_csv(energy_data_direc,index_col = 'timestamp')
df_e.index = pd.to_datetime(df_e.index,unit = 's')
df_e.index =  df_e.index + datetime.timedelta(minutes = 60*5 + 30) # adding 5:30 hours as India timezone offset
df_e['power']['2017-04-04'].plot()





#%% Read occupancy data correctly
occupancy_data_direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/final_processed_data/LCB.csv"
df_o = pd.read_csv(occupancy_data_direc,index_col = 'timestamp')
df_o.index = pd.to_datetime(df_o.index,unit = 's')
df_o.index =  df_o.index + datetime.timedelta(minutes = 60*5 + 30) 
df_s = pd.Series(data = df_o.occupancy_count,index = df_o.index)
df_s['2017-04-04'].plot()
