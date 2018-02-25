# -*- coding: utf-8 -*-
"""

This script is the first script which I run on the ubuntu server to process extracted data. It reads josn logs and saves requried data in csv files.
This can be run in parallelized fashion as well to save time

This contains support code
Created on Sat Feb 17 22:04:53 2018

@author: haroon
"""

import time,csv
import multiprocessing as mp


monthlist = ['data_2016_september.json','data_2016_october.json','data_2016_november.json',
'data_2017_april.json','data_2017_september.json']
#monthlist = ['data_2017_september_last.json']

def  compute_stage_1_parallel(monthname):
    fl = monthname
    #packet_count = 0
    print('Processing file {}'.format(monthname))
    start_time = time.time()
    savepath = "/home/hrashid/occupancy_files/processed_stage_1/" + monthname.split('.')[0]+'.csv'
    writefile = open(savepath,'w')
    csvfilewriter = csv.writer(writefile,delimiter=',')
    csvfilewriter.writerow(['trap_AP','trap_client','session_start','session_end'])
    with open(fl) as infile:
        for line in infile:
            packet = eval(line)
            #packet_count += 1
            #if packet['oid'] == 'ciscoLwappDot11ClientMovedToRunState':
            #temp = {}
            trap_AP  =  packet['cLApName']
            trap_client = packet['cldcClientIPAddress'] 
            session_start = packet['ts']
            temp_val = packet.get('endTs','Empty')
            if temp_val != 'Empty':  
              session_end = temp_val
            else:
              session_end= float('nan')
            csvfilewriter.writerow([trap_AP,trap_client,session_start,session_end])
            #df = df.append(temp,ignore_index=True)
    writefile.close()
    print(" Time taken for processing month {} was {} minutes".format(monthname,(time.time()-start_time)/60))
  
  
#compute_stage_1_parallel('data_2017_march.json')    
processes = [mp.Process(target=compute_stage_1_parallel, args=(x,)) for x in monthlist] 
for p in processes:
    p.start()
