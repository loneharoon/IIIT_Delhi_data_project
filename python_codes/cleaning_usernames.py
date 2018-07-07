#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script extracts extracts names corresponding to usernames of csv sheets received from Mr Bhawani. Here I try to create dictionary of usernames --> full names
Created on Fri Jul  6 11:29:21 2018

@author: haroonr
"""
import pandas as pd
#%% This cell entirely formats CSV sheets received from Bhawani for mapping
direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/username_emailid/"
fls = ['btech2015.csv','btech2016.csv','btech2017.csv','mtech2015.csv','mtech2016.csv','mtech2017.csv']


df1 = pd.read_csv(direc + fls[0])
df2 = pd.read_csv(direc + fls[1])
df3 = pd.read_csv(direc + fls[2])
df4 = pd.read_csv(direc + fls[3])
df5 = pd.read_csv(direc + fls[4])
df6 = pd.read_csv(direc + fls[5])

df_comb = pd.concat([df1,df2,df3,df4,df5,df6],axis=0)
df_comb['name'] =  df_comb['First Name'] + " " +df_comb['Last Name']
df_comb.drop(columns = ['First Name','Last Name'],inplace=True)
df_comb['username'] =  [id.split('@')[0] for id in df_comb['Email Address']]
df_comb.drop(columns=['Email Address'],inplace= True)
df_comb.to_csv(direc+'formatted_useranmes.csv')
#%%