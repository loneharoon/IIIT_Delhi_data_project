# -*- coding: utf-8 -*-
"""
This script is the first script which I run on the ubuntu server to process extracted data. It reads josn logs and saves requried data in csv files.
This can be run in parallelized fashion as well to save time
Created on Sat Feb 17 22:04:53 2018

@author: haroon
"""
import pandas as pd
import time
import multiprocessing as mp


monthlist = ['data_2015_december.json','data_2016_january.json','data_2016_february.json',
'data_2016_march.json','data_2016_april.json','data_2016_may.json','data_2016_june.json']

def  compute_stage_1_parallel(monthname):
    paths = "/home/hrashid/occupancy_files/"
    fl = paths + monthname
    #packet_count = 0
    print('Processing file {}'.format(monthname))
    df = pd.DataFrame()
    start_time = time.time()
    with open(fl) as infile:
        for line in infile:
            packet = eval(line)
            #packet_count += 1
            if packet['oid'] == 'ciscoLwappDot11ClientMovedToRunState':
              temp = {}
              #print(packet_count)
             # temp['trap_type'] = packet['oid']
              temp['trap_AP']   =  packet['cLApName']
              temp['trap_client'] = packet['cldcClientIPAddress'] 
              temp['session_start'] = packet['ts']
              temp_val = packet.get('endTs','Empty')
              if temp_val != 'Empty':  
                temp['session_end'] = temp_val
              else:
                temp['session_end'] = float('nan')
              df = df.append(temp,ignore_index=True)
    savedirec = "/home/hrashid/occupancy_files/processed_stage_1/"
    savepath = savedirec + monthname.split('.')[0]
    print(" Time taken for processing month {} was {} minutes".format(monthname,(time.time()-start_time)/60))
    df.to_csv(savepath)
    
processes = [mp.Process(target=compute_stage_1_parallel, args=(x,)) for x in monthlist] 
for p in processes:
    p.start()
