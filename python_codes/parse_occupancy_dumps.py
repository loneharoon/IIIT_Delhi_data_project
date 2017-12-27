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


#%%

 num_lines = sum(1 for line in open(fl)) # get total number of lines or records in a file 11962709
#%%
fl = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/data_subset.json"
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

x = lis[5]['ts']['$date']
xfor = datetime.strptime(lis[5]['ts']['$date'],'%Y-%m-%dT%H:%M:%S.000Z')
xfor.strftime('%Y-%m-%d %H:%M:%S')

pd.to_datetime(lis[5]['ts']['$date'])


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
#%% Create dataframe of required information
packet_count = 0
df = pd.DataFrame()
with open(fl) as infile:
    for line in infile:
        packet = eval(line)
        packet_count += packet_count
        if packet['oid'] == 'ciscoLwappDot11ClientMovedToRunState':
          temp = {}
          temp['trap_type'] = packet['oid']
          temp['trap_time'] =  pd.to_datetime(packet['ts']['$date'])
          temp['trap_AP']   =  packet['cLApName']
          temp['trap_client'] = packet['cldcClientIPAddress'] 
          df = df.append(temp,ignore_index=True)
        elif packet['oid'] == 'bsnDot11StationDeauthenticate' :
          temp['trap_type'] = packet['oid']
          temp['trap_time'] =  pd.to_datetime(packet['ts']['$date'])
          temp['trap_AP']   = packet['bsnAPName']
          temp['trap_client'] = packet['bsnUserIpAddress']
          df = df.append(temp,ignore_index=True)
        if packet_count == 100:
          break
 
print(unique_traps)


