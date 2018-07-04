#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 28 17:11:54 2018

@author: haroonr
"""
#from openpyxl import Workbook
#from openpyxl import load_workbook
#%%
#path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/mac_ids/"

#wb = load_workbook(filename = path+sheet)
# get sheet names
#wb_sheets = wb.sheetnames
#print (wb_sheets)
# get sheet
#sheet_data = wb['Faculty28-31']
#%%
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/mac_ids/"
import pandas as pd
workbook_name = "Faculty-Staff-PhD.xlsx"

sheet0 = pd.read_excel(path+workbook_name,sheet_name=0)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols0 = sheet0[keep_names]

sheet1 = pd.read_excel(path+workbook_name,sheet_name=1)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols1 = sheet1[keep_names]

sheet2 = pd.read_excel(path+workbook_name,sheet_name=2)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols2 = sheet2[keep_names]

sheet3 = pd.read_excel(path+workbook_name,sheet_name=3)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols3 = sheet3[keep_names]

#sheet4 = pd.read_excel(path+workbook_name,sheet_name=4)
#keep_names = ['User Name','Device Name', 'MAC']
#sheet_sel_cols4 = sheet4[keep_names]

sheet5 = pd.read_excel(path+workbook_name,sheet_name=5)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols5 = sheet5[keep_names]

# sheet 4 seems faulty
df = pd.concat([sheet_sel_cols0,sheet_sel_cols1,sheet_sel_cols2,sheet_sel_cols3,sheet_sel_cols5],axis=0)
df.columns = ['username','devicename','mac']
# fix letter case
df = df.dropna(subset = ['mac'])
#usernames = list(df.username)
#usernames_small = [s.lower() for s in usernames]
#df.username = usernames_small

#df_gp = df.groupby('username')
#%%

#%%



#%%
addresses = list(df.mac)
new_addresses = []
for i in addresses:
  
  try:
    address = str(i.lower().strip())
  except: # case when i is not in required format
    address = str(i)
  if len(address) < 12 or len(address) > 17:
    address = float('nan')
    #addresses.append(address)
  elif not (':' in str(address)):
      address = ':'.join(address[i:i+2] for i in range(0,12,2))
      #addresses.append(address)
  else:
    addresses.append(address)
  new_addresses.append(address)
    
#%%


import re
if re.match("[0-9a-f]{2}([-:]?)[0-9a-f]{2}(\\1[0-9a-f]{2}){4}$", x.lower()):
  
  ' 4ccc6a3c3de9',
  '3c970ee4b361 ',