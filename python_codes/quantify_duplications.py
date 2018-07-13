#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
in this script, I plot the duplicate mac connections as boxplots 
Created on Wed Jul 11 15:18:03 2018

@author: haroonr
"""
import pandas as pd
import matplotlib.pyplot as plt
import datetime
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/july2018_occupancy_duplication/"
months_break = ["data_2017_june.csv","data_2017_july.csv"]
months_semester = ['data_2017_august.csv',"data_2017_september.csv"]
months_all = ["data_2017_june.csv","data_2017_july.csv",'data_2017_august.csv',"data_2017_september.csv"]
savepath = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/july2018_occupancy_duplication/plots/"

#%%
bldg = 'SRB'
compute_hourwise_count(path, bldg, months_all, savepath,filename = "all.pdf" )
compute_hourwise_count(path, bldg, months_break, savepath,filename = "summer.pdf" )
compute_hourwise_count(path, bldg, months_semester, savepath,filename = "semester.pdf" )


#%%



def compute_hourwise_count(path, bldg, months, savepath,filename):
  month_data = []
  for i in range(0,len(months)):
    df = pd.read_csv(path + bldg + "/" + months[i])
    df.index = pd.to_datetime(df.timestamp)
    df.index = df.index + datetime.timedelta(minutes = 60*5 + 30) # joy's system has 5:30 hours lag
    df.drop(columns = ['Unnamed: 0','timestamp'],axis = 1,inplace=True)
    df_sub =  df.resample('10 T',label='right',closed='right').max()
    df_sub['difference'] = df_sub.count_1 - df_sub.count_3
    df_sub['hour'] = df_sub.index.hour
    month_data.append(df_sub)
  all_data = pd.concat(month_data,axis=0)
  df_groups = all_data.groupby(['hour'])
  dic = {}
  for i in range(0,24):
    dic[i] = list(df_groups.get_group(i).difference) # difference is column name
  df_res = pd.DataFrame.from_dict(dic,orient="index").T
  pl = df_res.boxplot()
  pl.set_ylabel('Count')
  pl.set_xlabel('Day Hour')
  plt.savefig(savepath + bldg + "_" + filename)
  plt.close()
  #return df_res




#%% plotting data single month wise
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