
'''
This is the first script which I run on Joy's VM when mongdb is ON. This script works perfectly untill September 28, 2017. After that there are some extra keys, so I run another script namely second_scipt.py., which takes care of all extra things.

'''

from pymongo import MongoClient
from bson import json_util
import datetime
import pickle
import time, iso8601	
import json
savedir= 'C:\Users\Joy\Documents'
client = MongoClient()
db = client.dec
collection = db.log
timestamp_start = datetime.datetime(2017,6,1,0,0,0)
timestamp_end = datetime.datetime(2017,6,30,23,59,59)
packets =[]
count = 1
start_time = time.time()
with open(savedir+"\data_2017_june.json",'w') as fp:
	for item in collection.find({'ts': {'$gt':timestamp_start,'$lt': timestamp_end}}):
		if item['oid'] == 'ciscoLwappDot11ClientMovedToRunState':
			#packet = json.dumps(item,default=json_util.default)
			try:
				item['ts'] = item['ts'].isoformat()
				item['endTs'] = item['endTs'].isoformat()
			except Exception as e:
				pass
			json.dump(item,fp)
			#json.dumps(item,fp,default=json_util.default)
			fp.write('\n')
			#count+=1
			#print (count)
fp.close()
print ('first script %s minutes taken' % ((time.time()-start_time)//60))
