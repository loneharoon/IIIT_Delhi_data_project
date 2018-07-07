#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this scipt, I first create hash of all MACS ids and then I check for duplicates clients in SNMP logs
Created on Mon Jul  2 11:22:49 2018

@author: haroonr
"""
#%%
import hashlib
m = hashlib.sha256()
#msg = '12:34:56:78:09:10'
msg = 'AB:bc:cd:df:aa:bc'
msg = msg.encode('utf-8')
m.update(msg)
m.hexdigest()
#%% read and format faculty sheet

import hashlib
mac_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/mac_ids/"
sheetname = "processed_faculty_staff_sheet.csv"

gt =  pd.read_csv(mac_path+sheetname)
gt = gt.dropna(subset = ['mac'])
hashed_mac = []
for i in range(0,gt.shape[0]):
  m = hashlib.sha256()
  temp = gt.mac[i]
  print(i)
  temp = temp.encode('utf-8')
  m.update(temp)
  hashed_mac.append(m.hexdigest())
  
gt['hashed_mac'] = hashed_mac
gt.index = gt.hashed_mac



#%%
mac_path = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/"
bldg = "mac_idwithcount.csv"
df = pd.read_csv(mac_path + bldg)
#%%
from itertools import groupby
flag = 0
for key,value in df.iterrows():
  if flag == 30:
    exit()
  print(flag)
  flag = flag +1
  clients = eval(value.clientMacs)
  count = value.count 
  my_users = []
  new_count = []
  for cl in clients:
    try:
      user = gt[cl].username
      my_users.append(user)
      print( [len(list(gp)) for key,gp in groupby(my_users)])
    except:
      print (cl + 'not found')
  #Enew_count = len(my_users)      
    # users.append())
    
    
    
    
  #'4c33d70e0afce09a9dbded6a6f55802bb01328ca77982cb3af9f837b28e54c0e'