#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script will parse IIITD occupancy dumps
Created on Thu Dec 21 22:10:15 2017

@author: haroonr
"""
##
#%% 
import numpy as np
import pandas as pd
from datetime import datetime
from collections import defaultdict

fl = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/data_subset.json"

#%% 
#In this cell, I read a part of big json file , save the packets foor the analysis
count = 0
lis = []
with open(fl) as infile:
    for line in infile:
        #print(line)
        lis.append(eval(line))
        count = count + 1
        if count == 500:
          break
import json
with open("/Volumes/MacintoshHD2/Users/haroonr/Downloads/fivehundred.json",'w') as fp:
  json.dump(lis,fp,indent = 2)
#outfile = open("/Volumes/MacintoshHD2/Users/haroonr/Downloads/twentypackets.json",'w')
#for item in lis:
#  outfile.write("%s\n" % item)
#%% Find all unique traps type in a file
# trap type is stored in 'oid' field
# takes 10 minutes to read complete file
count = 0
traps = []
with open(fl) as infile:
    for line in infile:
        #print(line)
        traps.append(eval(line)['oid'])
        count = count + 1
        #if count == 20:
         # break
unique_traps = np.unique(traps)   
print(unique_traps)
['bsnDot11StationAssociate' 'bsnDot11StationAssociateFail'
 'bsnDot11StationDeauthenticate' 'bsnDot11StationDisassociate'
 'ciscoLwappDot11ClientAssocDataStatsTrap'
 'ciscoLwappDot11ClientCoverageHolePreAlarm'
 'ciscoLwappDot11ClientDisassocDataStatsTrap'
 'ciscoLwappDot11ClientMovedToRunState' 'ciscoLwappDot11ClientSessionTrap'
 'ciscoLwappSiIdrDevice']

#%% Create dataframe of required information
# Caputure only required packet. It contains whole information required
packet_count = 0
df = pd.DataFrame()
with open(fl) as infile:
    for line in infile:
        packet = eval(line)
        packet_count += 1
        if packet['oid'] == 'ciscoLwappDot11ClientMovedToRunState':
          temp = {}
          print(packet_count)
         # temp['trap_type'] = packet['oid']
          temp['trap_AP']   =  packet['cLApName']
          temp['trap_client'] = packet['cldcClientIPAddress'] 
          temp['session_start'] =  pd.to_datetime(packet['ts']['$date'])
          temp_val = packet.get('endTs','Empty')
          if temp_val != 'Empty':  
            temp['session_end'] = pd.to_datetime(temp_val['$date'])
          else:
            temp['session_end'] = float('nan')
          df = df.append(temp,ignore_index=True)
#  we dropped collecting these packets becasue they wer missing for most of the sessions
#        elif packet['oid'] == 'bsnDot11StationDeauthenticate' :
#          temp = {}
#          temp['trap_type'] = packet['oid']
#          temp['trap_time'] =  pd.to_datetime(packet['ts']['$date'])
#          temp['trap_AP']   = packet['bsnAPName']
#          temp['trap_client'] = packet['bsnUserIpAddress']
#          df = df.append(temp,ignore_index=True)
#          print(packet_count)
        #if packet_count == 100:
         # break
filepath = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/July2017_5days_second_attempt.csv"
df.to_csv(filepath)
#%% Now Use dataframe obtained in previous steps to get occupancy stats
# Mostly I read it from drive, because initial steps take time to compute things
# this cell reads and formats columns for further processing
df = pd.read_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/July2017_5days_second_attempt.csv",dtype={'trap_AP':str,'trap_client':str,'trap_type':str,'session_start':datetime,'session_end':datetime}) 

df_BH = df[df.trap_AP.str.startswith('BH')] # get building specific packets
df_BH.session_start = pd.to_datetime(df_BH.session_start) # convert string to datetime
df_BH.session_end = pd.to_datetime(df_BH.session_end)
df_BH.session_start = df_BH.session_start.apply(lambda x:x.round('T')) # round seconds to minutes , makes calculation easier
#%%
# This cell genertes 1's till users session end. Later in another cell I perfrom addition across users at specific time stamp
df_BH = df_BH[df_BH['session_end'].notnull()]  # removes entries with missing endTs
sessions = []
for key,entry in df_BH.iterrows():
  seq = pd.Series(1,pd.date_range(start= entry['session_start'],end = entry['session_end'], freq ='T'))
  sessions.append(seq)
#%%This cell creats a list of groups corresponding to series of different users
c = [entry.groupby(entry.index.date) for entry in sessions]

#%% This cell creates a dictionary where a key corresponds to a date so each key contains data of single day
def_dic = defaultdict(list)
for i in c:
  for k in i.groups:
    def_dic[k].append(i.get_group(k))
#%%
# This cell perfoms summation across active users at a timestamp
res = []
for k,item in def_dic.items():
  print(k)
  temp = pd.concat(item,axis=1).sum(axis=1)
  res.append(temp)
occu = pd.concat(res,axis=0).sort_index()
occu.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/occupancy_boyshostel.csv")
#%%
df =pd.read_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/occupancy_boyshostel.csv",index_col=0)
df.index = pd.to_datetime(df.index)