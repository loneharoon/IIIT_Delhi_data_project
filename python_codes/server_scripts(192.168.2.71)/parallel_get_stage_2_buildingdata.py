#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

This is the parallelized version of script get_stage_2_buildingdata.py
Created on Sun Feb 25 08:53:33 2018

@author: haroonr

"""
month_name = "data_2017_december.csv"
import pandas as pd
from datetime import datetime
from collections import defaultdict
import multiprocessing as mp
#%% function called by second cell
def compute_final_occupancy(BBH,savepath):
  ''' this function create final occupancy time series data'''
  BBH.session_start = pd.to_datetime(BBH.session_start) # convert string to datetime
  BBH.session_end = pd.to_datetime(BBH.session_end)
  BBH.session_start = BBH.session_start.apply(lambda x:x.round('T')) # round seconds to minutes , makes calculation easier
  #%
  # This cell genertes 1's till users session end. Later in another cell I perfrom addition across users at specific time stamp
  BBH = BBH[BBH['session_end'].notnull()]  # removes entries with missing endTs
  sessions = []
  for key,entry in BBH.iterrows():
    seq = pd.Series(1,pd.date_range(start= entry['session_start'],end = entry['session_end'], freq ='T'))
    sessions.append(seq)
  #% his cell creats a list of groups corresponding to series of different users
  c = [entry.groupby(entry.index.date) for entry in sessions]
  
  #% This cell creates a dictionary where a key corresponds to a date so each key contains data of single day
  def_dic = defaultdict(list)
  for i in c:
    for k in i.groups:
      def_dic[k].append(i.get_group(k))
  #%
  # This cell perfoms summation across active users at a timestamp
  res = []
  for k,item in def_dic.items():
    #print(k)
    temp = pd.concat(item,axis=1).sum(axis=1)
    res.append(temp)
  occu = pd.concat(res,axis=0).sort_index()
  occu.to_csv(savepath)
#%%


direc_path = "/home/hrashid/occupancy_files/processed_stage_1/"
file_path = direc_path + month_name
df = pd.read_csv(file_path,dtype={'trap_AP':str,'trap_client':str,'trap_type':str,'session_start':datetime,'session_end':datetime}) 

buildings = ['BH','GH','DB','ACB','LCB','LB','SRB']
for name in buildings:
  wifidata = df[df.trap_AP.str.startswith(name)]
  if wifidata.shape[0] > 0: # do we have data of this building
    savepath = "/home/hrashid/occupancy_files/processed_stage_2/"+ name +"/" + month_name
    print('Processing data of {} buildig of month {}\n'.format(name,month_name))
    p  = mp.Process(target=compute_final_occupancy,args=(wifidata,savepath,))
    p.start()

