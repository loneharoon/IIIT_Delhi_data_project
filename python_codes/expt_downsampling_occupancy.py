#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
showing downsampling data does not reduce accuracy data considerably
Created on Fri Oct 26 12:13:17 2018
@author: haroonr
"""
import pandas as pd
import datetime
import matplotlib.pyplot as plt
#%%
dpath = "/Volumes/DATA_DSK/Datasets_Macbook/IIIT_occupancy/processed_stage_3_Joys/"
blds = ['ACB.csv','BH.csv','GH.csv','DB.csv','LB.csv','LCB.csv','SRB.csv']

df_o = pd.read_csv(dpath + blds[0],index_col = 0)
df_o.index = pd.to_datetime(df_o.index)
dt1 = '2017-04-10'
dt2 = '2017-04-16'
df_s = df_o[dt1:dt2]
  
s1 = df_s.between_time('8:00:00', '8:10:00')  
s2 = df_s.between_time('10:00:00','10:10:00')  
s3 = df_s.between_time('12:00:00','12:10:00')  
s4 = df_s.between_time('14:00:00','14:10:00')  
s5 = df_s.between_time('16:00:00','16:10:00')  
s6 = df_s.between_time('18:00:00','18:10:00')  
gp_o1 = s1.groupby(s1.index.day)
gp_o2 = s2.groupby(s2.index.day)
gp_o3 = s3.groupby(s3.index.day)
gp_o4 = s4.groupby(s4.index.day)
gp_o5 = s5.groupby(s5.index.day)
gp_o6 = s6.groupby(s6.index.day)

for k,v in gp_o1:
  l = v
  print( int(l[~l.index.duplicated(keep='last')].std()))
 
for k,v in gp_o2:
  l = v
  print( int(l[~l.index.duplicated(keep='last')].std()))

for k,v in gp_o3:
  l = v
  print( int(l[~l.index.duplicated(keep='last')].std()))

for k,v in gp_o4:
  l = v
  print( int(l[~l.index.duplicated(keep='last')].std()))

for k,v in gp_o5:
  l = v
  print( int(l[~l.index.duplicated(keep='last')].std()))  
  
for k,v in gp_o6:
  l = v
  print( int(l[~l.index.duplicated(keep='last')].std()))
  
gs = []
gps = [gp_o1,gp_o2,gp_o3,gp_o4,gp_o5,gp_o6]
for i in gps:
  ls = []
  for k,v in i:
    l = v
    ls.append(int(l[~l.index.duplicated(keep='last')].std()))
  gs.append(ls)  
