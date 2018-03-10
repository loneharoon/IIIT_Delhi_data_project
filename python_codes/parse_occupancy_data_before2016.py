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
from collections import OrderedDict
#%%
def compute_connection_sequence_of_single_client(ob):
  connection = pd.Series() # dummy initialization
  df_connect = ob[ob.trap==1].timestamp.tolist()
  df_disconnect = ob[((ob.trap==2) | (ob.trap== 3))].timestamp.tolist()
  disconnect = pd.Series(1,df_disconnect)
  #%
  sessions = []
  for i in range((len(df_connect)-1)):
    connect1 = df_connect[i]
    connect2 = df_connect[i+1]
    disconnect_pool= disconnect[((disconnect.index > connect1) & (disconnect.index < connect2))].index
    if len(disconnect_pool):
        seq = pd.Series(1,pd.date_range(start= connect1,end = disconnect_pool[-1], freq ='T'))
        seq.index = seq.index.round('T')
        sessions.append(seq)
    else:
      count = i+1 # this keeps track of connect traps, for loop can't be used to have control 
      candidate_size = 2 # since we have 2 connect traps till now, this shows how many connect traps are there before we find a disconnect trap 
      try: 
        while True: # lets find set of connect traps until we find some disconnect traps
          count = count + 1
          connect_next = df_connect[count]
          disconnect_pool= disconnect[((disconnect.index > connect1) & (disconnect.index < connect_next))].index
          if len(disconnect_pool):
            seq = pd.Series(1,  pd.date_range(start = connect1,  end = disconnect_pool[-1], freq ='T'))
            seq.index = seq.index.round('T')
            sessions.append(seq)
            break
          candidate_size += 1
          if candidate_size ==10: # lets limit number of connect traps to 10, if we don't find then we give up and ffind pair for the next one
            break
      except:
        pass
        #print("something went wrong when value of i was {}".format(i))
  try:
    connection = pd.concat(sessions,axis=0)
    connection = connection[~connection.index.duplicated()] # remove duplicates
  except:
    pass
    #print("No connection sequenence was found for the input client")
  return connection

#%%
#df_sub.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/subset_2014.csv")
#fl = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/occupancy_dump_before2016.csv"
#fl = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/subset_2014.csv"
fl= "/home/hrashid/occupancy_files/occupancy_dump_before2016.csv"
save_dir = "/home/hrashid/occupancy_files/digvijay_dump_results/"
#%%
df = pd.read_csv(fl)
df.drop(['Unnamed: 0'],axis=1,inplace=True)
df.columns = ["device_id",'client_id','timestamp','acces_point','trap']
buildings = ['BH','GH','DB','ACB','LCB','LB','SRB']

for build in buildings:
  print('processing {} data'.format(build))
  bh_df = df[df.acces_point.str.startswith(build)]
  bh_df.timestamp = pd.to_datetime(bh_df.timestamp)
  bh_df.sort_values(by='timestamp',inplace=True)
  bh_df.index = bh_df.timestamp # important for some next operation
  bh_group = bh_df.groupby([bh_df.index.year, bh_df.index.month]) # contains day wise data
  
  day_result = OrderedDict()
  for day,traps_seq in bh_group:
    print(day)
    gp_obj = traps_seq.groupby(traps_seq.client_id)
    connections = []
    for client, readings in gp_obj:
      temp = compute_connection_sequence_of_single_client(readings)
      connections.append(temp)
    day_result[day] = pd.concat(connections,axis=1)
  result_months = []
  for i in day_result.keys():
    result_months.append(day_result[i].sum(axis=1))
  result_building = pd.concat(result_months,axis=0)
  result_building.to_csv(save_dir + build + ".csv")
  
 #%% Module to rectify data at day boundaries
build_sub = result_building.resample('10 T',label='right',closed='right').max()
start_minutes = "23:30:00"
end_minutes = "00:30:00"
boundary_values = build_sub.between_time(start_minutes,end_minutes,include_start=True,include_end=True)
# forward timestamp by 30 minutes temporarily; required for grouping
temp_index = (boundary_values.index +  pd.Timedelta(30, unit='M')).floor('d')
boundary_values_gps = boundary_values.groupby(temp_index) 
newseries = []
for ind, obs in boundary_values_gps:
  #case when data is already missing
  if (np.isnan(obs[0]) or (np.isnan(obs[-1]))):
    pass
  else: # when we want to rectify data
    obs[1:-1] = float('nan')
    obs.interpolate(method='linear',inplace=True)
  newseries.append(obs)
res = pd.concat(newseries)
build_sub[res.index] = res.values
build_sub.plot()  
