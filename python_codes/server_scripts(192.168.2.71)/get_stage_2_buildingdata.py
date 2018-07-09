#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This is the second script which I use to process csv files obtained with script parse_support.py.
It reads csv files, separates data building wise and then runs algorithm to compute occupancy of each building.
Created on Sun Feb 25 08:53:33 2018

@author: haroonr
"""
import pandas as pd
#from datetime import datetime
from collections import defaultdict
#%%

def compute_final_occupancy(BBH):
  ''' this function create final occupancy time series data'''
  BBH.session_start = pd.to_datetime(BBH.session_start) # convert string to datetime
  BBH.session_end = pd.to_datetime(BBH.session_end)
  BBH.session_start = BBH.session_start.apply(lambda x:x.round('T')) # round seconds to minutes , makes calculation easier
  #%%
  # This cell genertes 1's till users session end. Later in another cell I perfrom addition across users at specific time stamp
  BBH = BBH[BBH['session_end'].notnull()]  # removes entries with missing endTs
  sessions = []
  for key,entry in BBH.iterrows():
    print (key)
    seq = pd.Series(1,pd.date_range(start= entry['session_start'],end = entry['session_end'], freq ='T'))
    seq.name =  entry.trap_clientMAC
    sessions.append(seq)
  #% his cell creats a list of groups corresponding to series of different users
  c = [entry.groupby(entry.index.date) for entry in sessions]
  
  #%% This cell creates a dictionary where a key corresponds to a date so each key contains data of single day
  def_dic = defaultdict(list)
  for i in c:
    for k in i.groups:
      def_dic[k].append(i.get_group(k))
  #%% This cell finds number of users connected at some point of time and their MAC ids
  res = []
  for k,item in def_dic.items():
    print (k)
    temp = pd.concat(item,axis = 1)
    temp2 = compute_clients_and_count(temp)
    res.append(temp2)
  occu = pd.concat(res,axis=0).sort_index()
  return occu
  
  #%% Used in submission version I
  # This cell perfoms summation across active users at a timestamp
#  res = []
#  for k,item in def_dic.items():
#    #print(k)
#    temp = pd.concat(item,axis=1).sum(axis=1)
#    res.append(temp)
#  occu = pd.concat(res,axis=0).sort_index()
#  return occu
  #occu.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/occupancy_boyshostel.csv")
#%%
month_name = "data_2017_june.csv"
direc_path = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/"
#direc_path = "/home/hrashid/occupancy_files/processed_stage_1/"

file_path = direc_path + month_name

#df = pd.read_csv(file_path,dtype={'trap_AP':str,'trap_clientIP':str,'trap_clientMAC':str,'trap_type':str,'session_start':datetime.datetime,'session_end':datetime.datetime}) 
df = pd.read_csv(file_path) 
#df_BH = df[df.trap_AP.str.startswith('BH')] # get building specific packets
buildings = ['BH','GH','DB','ACB','LCB','LB','SRB']
for name in buildings:
  wifidata = df[df.trap_AP.str.startswith(name)]
  if wifidata.shape[0] > 0: # do we have data of this building
    print('Processing data of {} buildig\n'.format(name))
    result_df = compute_final_occupancy(wifidata)
    #savepath = "/home/hrashid/occupancy_files/processed_stage_2/"+ name +"/" + month_name
    savepath = "/home/hrashid/occupancy_files/processed_stage_2_new/"+ name +"/" + month_name
    result_df.to_csv(savepath)

def compute_clients_and_count(temp): 
  ''' This function computes occupancy count and the name of clients connected at a specific timestamp'''
  tempdf = pd.DataFrame()
  for timestamp,entry in temp.iterrows():
    mydf = entry[entry.notnull()]
    dic = {}
    dic['timestamp'] = mydf.name
    dic['count']  = mydf.sum()
    dic['clientMacs']  = list(mydf.index)
    tempdf = tempdf.append(dic,ignore_index = True)
  tempdf.index = tempdf.timestamp
  return tempdf.drop('timestamp',axis=1)