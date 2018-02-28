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
bh_df.sort_values(by='timestamp',inplace=True)
p1 = bh
p1.index = p1.timestamp
p1.groupby(p1.index.date)



gp_obj = bh_df.groupby(bh_df.client_id)
#%%
#ob = gp_obj.get_group(4665)
connections = []
for key,ob in gp_obj:
  print (key)
  temp = compute_connection_sequence_of_single_client(ob)
  connections.append(temp)
#%%
#for key,ob in gp_obj.items():
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
        print("something went wrong when value of i was {}".format(i))
  try:
    connection = pd.concat(sessions,axis=0)
    connection = connection[~connection.index.duplicated()] # remove duplicates
  except:
    print("No connection sequenence was found for the input client")
  return connection
      
#%%  temps
dts1= pd.to_datetime("2014-02-20 14:00:00")
dts2= pd.to_datetime("2014-02-20 21:17:00")
temp = ob[((ob.timestamp>dts1) & (ob.timestamp<dts2))]