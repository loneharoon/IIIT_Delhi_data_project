#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script will parse IIITD occupancy dumps
Created on Thu Dec 21 22:10:15 2017

@author: haroonr
"""
##
#%%


#%%
fl = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/data_subset.json"
count = 0
lis = []
with open(fl) as infile:
    for line in infile:
        print(line)
        lis.append(eval(line))
        count = count + 1
        if count == 10:
          break

#%%
