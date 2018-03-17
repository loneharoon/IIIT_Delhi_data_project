#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this, script I clean weather data of IIITD and VIDP weather station for the variance analysis.
Aim is to keep data between 1 - 15 March 2018 of both, align the data and make it ready for ggplot plotting
Plots weather variables of IIIT Delhi, elitech data logger

Created on Sat Feb  3 11:10:50 2018
@author: haroonr
"""
import pandas as pd
import datetime
#%% In this cell, I process IIIT  weather data
iiitd_weather = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/iiitd_weather_till16march2018.csv"
df_d = pd.read_csv(iiitd_weather,index_col='Time')
df_d.index = pd.to_datetime(df_d.index)
df_d.drop(labels=['Number'],inplace=True,axis=1)
dfsub =  df_d['2018-03-01':'2018-03-15']
dfsub['Humidity%RH'].plot()
dfsub.index = dfsub.index - datetime.timedelta(seconds = 93) # corrects timestamp by sub 93 seconds to 

#%%%  since VIDP, Delhi airport data was downloaded in serveral chunk, so I will process that in this cell
#STAGE 1 OF WU DATA PROCESSING : IT SIMPLY COMBINES TWO FILES: IMPOSSIBLE TO RUN AGAIN BECAUSE SMALL INPUT FILES WILL BE REMOVED
wu1 = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/vidp_data.csv"
wu2 = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/vidp_4_16march2018.csv"
df1 = pd.read_csv(wu1,index_col='date')
df1.index= pd.to_datetime(df1.index)
df2 = pd.read_csv(wu2,index_col='date')
df2.index= pd.to_datetime(df2.index)
df1_sub = df1[ :'2018-03-03']
df2_sub = df2['2018-03-04':]
df_wu = pd.concat([df1_sub,df2_sub],axis=0)
df_wu = df_wu['2018-03-01':'2018-03-15']
df_wu['humidity'].plot()
df_wu.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/formatted_vidp_data.csv")
#%% STAGE 2: read stage 1 procESSED file (related to VIDP data), remove duplicate entries from file and store again final file
wuf = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/formatted_vidp_data.csv"
dff = pd.read_csv(wuf,index_col='date')
dff.index = pd.to_datetime(dff.index)
# remove duplicate entires
dff['timestamp'] = dff.index.values
res = dff[~dff.duplicated('timestamp')]
res.drop(['timestamp'],axis=1,inplace=True)
#%%  IN this cell, we combine VIDP and iiitd weather data
#Keep only those timestamps in IIITD data which are in vidp data
rr = dfsub[((dfsub.index.minute == 0) | (dfsub.index.minute == 30))]
cat = pd.concat([res[['temperature','humidity']],rr[['temperature','humidity']]],axis=1)
cat.columns = ['Airport_temperature','Airport_Humidity','IIITD_temperature','IIITD_Humidity']
cat.interpolate(inplace = True)
cat.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/formatted_iiitd_airport_data.csv")
#%%
