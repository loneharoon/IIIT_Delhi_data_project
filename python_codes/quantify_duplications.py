#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul 11 15:18:03 2018

@author: haroonr
"""
import pandas as pd
path = "/Volumes/HAROONS/"
bldg = "BH/data_2017_august.csv"
df = pd.read_csv(path + bldg)
df.index = pd.to_datetime(df.timestamp)
df.drop(columns = ['Unnamed: 0','timestamp'],axis = 1,inplace=True)
df_sub =  df.resample('10 T',label='right',closed='right').max()
df_sub['difference'] = df_sub.count_1 - df_sub.count_3
df_sub['hour'] = df_sub.index.hour

df_groups = df_sub.groupby(['hour'])
dic = {}
for i in range(0,24):
  dic[i] = list(df_groups.get_group(i).difference)
df_res = pd.DataFrame.from_dict(dic,orient="index").T
df_res.boxplot()