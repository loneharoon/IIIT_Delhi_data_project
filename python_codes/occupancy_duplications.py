#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
With this script I detect number of duplicate MAC
Created on Mon Jul  9 20:41:12 2018

@author: haroonr
"""

import pandas as pd
path = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/"
mac_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/mac_ids/"
bldg = "mac_idwithcount.csv"
df = pd.read_csv(path + bldg)
gt =  pd.read_csv(mac_path + "final_hashed_mac_id.csv")

#%%

flag = 0
count_2 = [] # unique clients
count_3 = []
for key,value in df.iterrows():
  print(flag)
  flag = flag +1
  clients = list(set(eval(value.clientMacs)))# set removes duplicates
  count_2.append(len(clients)) # unique clients
  users = []
  for cl in clients:
    try:
       users.append(gt[gt.hashed_mac == cl].iat[0,2])
    except:
       users.append(cl)
  count_3.append( len(list(set(users))))     

updated_count = pd.DataFrame({'count_1':list(df['count'].values),'count_2':count_2,'count_3':count_3})
updated_count.to_csv("temporary.csv")