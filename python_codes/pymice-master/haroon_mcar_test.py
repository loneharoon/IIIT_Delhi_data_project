#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 26 17:25:45 2018

@author: haroonr
"""
import pandas as pd

data_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/data_status_ones_replaced.csv"
df = pd.read_csv(data_path)
df.timestamp = pd.to_datetime(df.timestamp)
df.index = df.timestamp
df.drop('timestamp',axis=1,inplace = True)
#df.drop('Unnamed: 0',axis=1,inplace = True)
#%%
df_sub = df
class_data_mcar3 = McarTests(data=df_sub)
val,status = class_data_mcar3.mcar_t_tests()
#%% saving matrix for R plotting system
save_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
val.to_csv(save_path+"mcar_matrix.csv")
