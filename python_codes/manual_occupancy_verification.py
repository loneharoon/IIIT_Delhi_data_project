#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this script I get data and compare with the manual occupancy counts which I did in library and 4th floor academdic buildig.  Existing functions defined in other scripts are borrowed(each referenced)
Created on Fri Jul 13 19:46:35 2018
Functions called in this script are defined in get_stage_2_buildingdata.py. This script is in server_scripts(192.168.2.71) folder

@author: haroonr
"""
import pandas as pd
#%% stage 1
json_file  = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/junejuly2018/data_2018_junejuly.json"
compute_stage_1_parallel(json_file) # function defined in  get_stage_1_files.py in server_scripts folder
#%% stage 2
month_name = "data_2018_junejuly.csv"
direc_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/junejuly2018/"
file_path = direc_path + month_name
df = pd.read_csv(file_path) 
name = "LB"
wifidata = df[df.trap_AP.str.startswith(name)]
if wifidata.shape[0] > 0: # do we have data of this building
  print('Processing data of {} buildig\n'.format(name))
  result_df = compute_final_occupancy(wifidata)
  #savepath = "/home/hrashid/occupancy_files/processed_stage_2/"+ name +"/" + month_name
  savepath = direc_path + name +"_" + month_name
  result_df.to_csv(savepath)
#%%
# Now let us extract data of New building 4th floor
name = "NACB4FAP"
wifidata = df[df.trap_AP.str.startswith(name)]
if wifidata.shape[0] > 0: # do we have data of this building
  print('Processing data of {} buildig\n'.format(name))
  result_df = compute_final_occupancy(wifidata)
  #savepath = "/home/hrashid/occupancy_files/processed_stage_2/"+ name +"/" + month_name
  savepath = direc_path + name +"_" + month_name
  result_df.to_csv(savepath)
