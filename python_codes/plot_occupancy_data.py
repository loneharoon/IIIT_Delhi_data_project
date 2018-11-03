#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
The first block of the script plot occupancy data of one week for all buildings  on campus
# second block compute correlation between occupancy and power consumption
Created on Sat Jul 14 09:05:23 2018

@author: haroonr
"""
import pandas as pd
import datetime
import matplotlib.pyplot as plt

occupancy_data_direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/IIITD_occupancy_dataset/"
blds = ['ACB.csv','BH.csv','GH.csv','DB.csv','LB.csv','LCB.csv','SRB.csv']
store = []
for i in blds:
  df_o = pd.read_csv(occupancy_data_direc + i,index_col = 'timestamp')
  df_o.index = pd.to_datetime(df_o.index,unit = 's')
  df_o.index =  df_o.index + datetime.timedelta(minutes = 60*5 + 30) 
  df_s = pd.Series(data = df_o.occupancy_count,index = df_o.index)
  #df_s['2017-04-04':].plot()
  store.append(df_s['2017-09-3':'2017-09-9'])
  #%
names = ['Academic Building','Boys Dormitory','Girls Dormitory','Dining Building','Library Building','Lecture Building','Facilities Building']
df_res = pd.concat(store, axis=1)
df_res.columns = names
#df_res = df_res.resample('30 T',label='right',closed='right').mean()
ax = df_res.plot(subplots=True,figsize = (6,4),)
ax[6].set_xlabel('Days of a month')
ax[3].set_ylabel('Occupancy count')
plt.savefig('/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Submitted/IIIT_dataset/figures/occupancy_week.pdf')
#%% compute correlation between occupancy and power rconsumption
#occupancy_data_direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/IIITD_occupancy_dataset/"
occupancy_data_direc = "/Volumes/DATA_DSK/Datasets_Macbook/IIIT_occupancy/IIITD_occupancy_dataset/"
blds = ['ACB.csv','BH.csv','GH.csv','DB.csv','LB.csv','LCB.csv','SRB.csv']
store = []
for i in blds:
  df_o = pd.read_csv(occupancy_data_direc + i,index_col = 'timestamp')
  df_o.index = pd.to_datetime(df_o.index,unit = 's')
  df_o.index =  df_o.index + datetime.timedelta(minutes = 60*5 + 30) 
  df_s = pd.Series(data = df_o.occupancy_count,index = df_o.index)
  #store.append(df_s['2017-06-11':'2017-06-13'])
  dt1 = '2017-06-10'
  dt2 = '2017-06-16'
  store.append(df_s[dt1:dt2])
names = ['Academic Building','Boys Dormitory','Girls Dormitory','Dining Building','Library Building','Lecture Building','Facilities Building']
df_res = pd.concat(store, axis=1)
df_res.columns = names
df_res = df_res.resample('30 T',label='right',closed='right').mean()

#energy_data_direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/processed_phase_3/"
energy_data_direc = "/Volumes/DATA_DSK/Datasets_Macbook/IIIT_dataset/processed_phase_3/"
bil = "all_buildings_power.csv"
df_e = pd.read_csv(energy_data_direc+bil,index_col = 'timestamp')
df_e.index = pd.to_datetime(df_e.index,unit = 's')
df_e.index =  df_e.index + datetime.timedelta(minutes = 60*5 + 30) # adding 5:30 hours as India
df_e = df_e.resample('30 T',label='right',closed='right').mean() 
df_e['Boys Dormitory'] = df_e['Boys_backup'] + df_e['Boys_main']
df_e['Girls Dormitory'] = df_e['Girls_backup'] + df_e['Girls_main']
df_e.drop(columns=['Boys_main', 'Boys_backup','Girls_main','Girls_backup'],inplace=True,axis=1)
df_e.columns = ['Academic Building','Facilities Building','Lecture Building','Library Building','Dining Building','Boys Dormitory','Girls Dormitory']
#df_e_sub = df_e['2017-06-11':'2017-06-13']
df_e_sub = df_e[dt1:dt2]
for name in names:
  power = df_e_sub[name]
  occu =  df_res[name]
  frame = pd.concat([power,occu],axis=1)
  print(frame.corr().iloc[0,1])
  #%%