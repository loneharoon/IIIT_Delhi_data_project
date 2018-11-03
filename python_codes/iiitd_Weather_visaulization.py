#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this, script I clean weather data of IIITD and VIDP weather station for the variance analysis.
Aim is to keep data between 1 - 15 March 2018 of both, align the data and make it ready for ggplot plotting
Plots weather variables of IIIT Delhi, elitech data logger
::July 2018 update::
Please read last cells becuase I update code in july 2018 for resubmission  


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
res.drop(['timestamp'],axis = 1,inplace = True)
#%%  IN this cell, we combine VIDP and iiitd weather data
#Keep only those timestamps in IIITD data which are in vidp data
rr = dfsub[((dfsub.index.minute == 0) | (dfsub.index.minute == 30))]
cat = pd.concat([res[['temperature','humidity']],rr[['temperature','humidity']]],axis=1)
cat.columns = ['Airport_temperature','Airport_Humidity','IIITD_temperature','IIITD_Humidity']
cat.interpolate(inplace = True)
cat.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/formatted_iiitd_airport_data.csv")
#%%
#% FOLLOWING CODE WAS WRITTEN IN JULY 2018, Most of this is redundant of above one
wu1 = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp_data/year2018_VIDP_station_march_april.csv"
wu2 = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp_data/year2018_VIDP_station_two_months.csv"
wu3 = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp_data/fifth_april.csv"
wu4 = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp_data/twelth_april.csv"

df1 = pd.read_csv(wu1,index_col='date')
df1.index= pd.to_datetime(df1.index)
df2 = pd.read_csv(wu2,index_col='date')
df2.index= pd.to_datetime(df2.index)

df3 = pd.read_csv(wu3,index_col='date')
df3.index= pd.to_datetime(df3.index)

df4 = pd.read_csv(wu4,index_col='date')
df4.index= pd.to_datetime(df4.index)

df_wu = pd.concat([df1,df2,df3,df4],axis=0)
df_wu = df_wu.sort_index()
df_wu.index = df_wu.index + datetime.timedelta(minutes = 60*5 + 30) 
df_wu.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp_data/"+ "mytemp.csv")
# read again 
wuf = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp_data/"+ "mytemp.csv"
dff = pd.read_csv(wuf,index_col='date')
dff.index = pd.to_datetime(dff.index)
# remove duplicate entires
dff['timestamp'] = dff.index.values
res = dff[~dff.duplicated('timestamp')]
res.drop(['timestamp'],axis = 1,inplace = True)

#%% this is iiitd data, reading iiitd data
mac_path = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp_data/"
bldg = "3103.xls"
df = pd.read_excel(mac_path + bldg)    
df.index = pd.to_datetime(df.Time,yearfirst=True)
df.columns = ['xy','Time','Temp','Humi']
df.drop(columns=['xy','Time'], axis=1, inplace=True)
dfsub =  df['2018-03-01':'2018-06-28']
dfsub.index = dfsub.index - datetime.timedelta(seconds = 93) # corrects timestamp by sub 93 seconds to 

#%% combingng both
rr = dfsub[((dfsub.index.minute == 0) | (dfsub.index.minute == 30))]
cat = pd.concat([res[['temperature','humidity']],rr[['Temp','Humi']]],axis=1)
cat.columns = ['Airport_temperature','Airport_Humidity','IIITD_temperature','IIITD_Humidity']
cat.interpolate(inplace = True)
cat_sub = cat['2018-03-01':]
# writing data3
cat_sub.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/weather_comparison")
#%% compute correlation between temperature of two site and the humdity one
#
direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_dataset/weather_comparison/formatted_iiitd_airport_data_four_months.csv"
df = pd.read_csv(direc,index_col = "Unnamed: 0")
df.index = pd.to_datetime(df.index)
df[['Airport_temperature','IIITD_temperature']].plot()
df[['Airport_temperature','IIITD_temperature']].corr() # got 0.96
df[['Airport_Humidity','IIITD_Humidity']].corr() # got 0.90
#%% testing stage
df_new = df
df_new['temp_diff'] =  df['Airport_temperature'] - df['IIITD_temperature']
df_new['humid_diff'] = df['Airport_Humidity'] - df['IIITD_Humidity']
keep = ['temp_diff','humid_diff']
df_new[keep].boxplot()
#%%
day_gp = df_new.between_time('8:0','18:0')
night_gp = df_new[(df_new.index.hour < 8) | (df_new.index.hour > 18)]
day_gp[keep].boxplot()
night_gp[keep].boxplot()
