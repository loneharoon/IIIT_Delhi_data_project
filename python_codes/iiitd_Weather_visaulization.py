#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Plots weather variables of IIIT Delhi, elitech data logger
Created on Sat Feb  3 11:10:50 2018

@author: haroonr
"""
import pandas as pd
#import matplotlib.pyplot as plt
#%%
iiitd_weather = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/1.csv"
df = pd.read_csv(iiitd_weather,index_col='Time')
df.index = pd.to_datetime(df.index)
df.drop(labels=['Number'],inplace=True,axis=1)
#%%s
#dfsub =  df["2018-01-30":"2018-02-02"]
dfsub =  df["2018-02-21":]

dfsub['Temperature°C'].plot(subplots=True)


#%%%
wu = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/tempweather.csv"
df2 = pd.read_csv(wu,index_cold='date')
df2.index= pd.to_datetime(df2.index)
df_sub = df2['2018-2-21':]
df_sub['temperature'].plot()