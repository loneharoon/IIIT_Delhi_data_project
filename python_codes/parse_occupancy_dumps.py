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

fl = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/data_subset.json"
#%%

 num_lines = sum(1 for line in open(fl)) # get total number of lines or records in a file 11962709
#%%

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
#%% Find all packets of a single day and then store them building wise

count = 0
traps = []
with open(fl) as infile:
    for line in infile:
        #print(line)
        traps.append(eval(line)['oid'])
        count = count + 1
        if count == 1571:
          break
unique_traps = np.unique(traps)   
print(unique_traps)
#%% Create dataframe of required information
#took 2 hours to get data of 5 days, read till line number 1206104
# second time parsed till line 1339137 in 30 minutes
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
#%% Use df to get occupancy stats
df = pd.read_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/July2017_5days_second_attempt.csv",dtype={'trap_AP':str,'trap_client':str,'trap_type':str,'session_start':datetime,'session_end':datetime}) 

df_BH = df[df.trap_AP.str.startswith('BH')]
df_BH.session_start = pd.to_datetime(df_BH.session_start)
df_BH.session_end = pd.to_datetime(df_BH.session_end)
df_BH.session_start = df_BH.session_start.apply(lambda x:x.round('T'))
#%%
time_seq  = pd.date_range('2017-07-01',periods = 120, freq ='T')

client_count  = []
for tm in time_seq:
  count = 0
  for key,entry in df_BH.iterrows():
    if tm >= entry['session_start'] and tm <= entry['session_end']:
      count = count + 1
      print(count)
    if tm < entry['session_start'] or tm > entry['session_end']:
      break
  client_count.append(count)
  dfc = pd.DataFrame(client_count,index=time_seq)
  
  