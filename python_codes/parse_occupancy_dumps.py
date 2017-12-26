#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script will parse IIITD occupancy dumps
Created on Thu Dec 21 22:10:15 2017

@author: haroonr
"""
##
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
        if count == 20:
          break

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
