#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this scipt, I first create hash of all MACS ids. and combine all sheets. which acts as a directory afterwards.
Created on Mon Jul  2 11:22:49 2018

@author: haroonr
"""

#%% read and format faculty sheet ,,,

import hashlib
import pandas as pd
mac_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/mac_ids/"
sheetname = "processed_faculty_staff_sheet.csv"
sheetname2 = "processed_students_all_sheet.csv"
gt =  pd.read_csv(mac_path+sheetname)
gt.drop(columns=['Unnamed: 0','devicename'],inplace=True)
gt = gt.dropna(subset = ['mac'])
hashed_mac = []
for i in range(0,gt.shape[0]):
  m = hashlib.sha256()
  temp = gt.mac[i].strip().lower()
  #print(i)
  temp = temp.encode('utf-8')
  m.update(temp)
  hashed_mac.append(m.hexdigest())
  
gt['hashed_mac'] = hashed_mac

# read second csv
gt2 =  pd.read_csv(mac_path+sheetname2)
gt2.drop(columns=['Unnamed: 0'],inplace=True)
gt2.columns = ['mac','username']

hashed_mac2 = []
for i in range(0,gt2.shape[0]):
  m = hashlib.sha256()
  temp = gt2.mac[i].strip().lower()
  temp = temp.encode('utf-8')
  m.update(temp)
  hashed_mac2.append(m.hexdigest())
gt2['hashed_mac'] = hashed_mac2
# combine both CSVS to create one unique directory
gt_final = pd.concat([gt,gt2],axis=0)
gt_final.dropna(inplace=True)
users = [i.strip().lower() for i in gt_final.username]
gt_final.username = users
gt_final.to_csv(mac_path + "final_hashed_mac_id.csv",index=False)
# save all names

    
#%%
mac_path = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/"
bldg = "3103.xls"
df = pd.read_excel(mac_path + bldg)    
df.index = pd.to_datetime(df.Time,yearfirst=True)
df.columns = ['xy','Time','Temp','Humi']
df2 = pd.read_csv(mac_path + "year2018_VIDP_station_two_months.csv")    
df2.index = pd.to_datetime(df2['date'])


    
