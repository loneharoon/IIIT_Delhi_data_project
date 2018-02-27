#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 22 21:22:23 2018
I use this script to download data from weather underground API

@author: haroonr
"""

key="aca4914ccfcb186d"
#%%%
#%%
from wunder import weather
from time imort sleep
#%%
from pprint import pprint
import arrow
from WunderWeather import weather
api_key = key
location = 'MA/Bos'
extractor = weather.Extract(api_key)
date = arrow.get("20170601","YYYYMMDD")
response = extractor.date(location,date.format('YYYYMMDD'))
pprint(response.data)
#%%
import csv
import datetime
from datetime import date
import os
import requests # this library makes html requests much simpler
from time import sleep
key="" # put your key here3
api_key = key
station_id ='VIDP' # VIDP is international airport while as VIDD is safdarjung airport
start_date = datetime.date(2018,2,15)
end_date = datetime.date(2018,2,25)
savefilename="//////////"
download_weather_data(station_id,start_date,end_date,savefilename)

#%%
def download_weather_data(station_id,start_date,end_date,savefilename):
  
  with open(savefilename, 'wb') as outfile:
    writer = csv.writer(outfile)
    # defines all weather acronyms
    #https://serbian.wunderground.com/weather/api/d/docs?d=resources/phrase-glossary
    headers = ['date','temperature','humidity','wind speed','wind direction'] # edit these as required
    writer.writerow(headers)
    datex = start_date
    while datex <= end_date:
      date_string = datex.strftime('%Y%m%d')
      url = ("http://api.wunderground.com/api/{}/history_{}/q/{}.json".format(api_key,date_string,station_id))
      data = requests.get(url).json()
      for history in data['history']['observations']:
        row = []
        row.append(str(history['date']['pretty']))
        row.append(str(history['tempm']))	
        row.append(str(history['hum']))
        row.append(str(history['wspdm']))
        row.append(str(history['wdird']))
        writer.writerow(row)
      sleep(30) # in seconds, limit is 10 calls per minute
      datex += datetime.timedelta(days=1) 				 
#%%
station_id = "VIDD"
start_date = datetime.date(2018,2,20)
date_string = start_date.strftime('%Y%m%d')
url = ("http://api.wunderground.com/api/{}/history_{}/q/{}.json".format(api_key,date_string,station_id))
data = requests.get(url).json()
#%%

