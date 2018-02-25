'''
Please read header of printcollections.py to understand this script. Also see wiki notes on the github repo.
'''

from pymongo import MongoClient
from datetime import date
import datetime, time, csv,json
savedir= 'C:\Users\Joy\Documents'
client = MongoClient()
db = client.dec
collection = db.log
timestamp_start = datetime.datetime(2017,12,1,0,0,0)
timestamp_end = datetime.datetime(2017,12,31,23,59,59)
packets =[]
count = 0
start_time = time.time()
with open(savedir+"\data_2017_december.json",'w') as fp:
	for item in collection.find({'ts': {'$gt':timestamp_start,'$lt': timestamp_end}}):
		if item['oid'] == 'ciscoLwappDot11ClientMovedToRunState':
			#packet = json.dumps(item,default=json_util.default)
			try:
				item['ts'] = item['ts'].isoformat()
				item['endTs'] = item['endTs'].isoformat()
			except Exception as e:
				pass
			temp1 = item.get('lastLocENDTs','Empty')
			temp2 = item.get('lastLocSTs','Empty')
			if temp1 != 'Empty':
				item['lastLocENDTs'] = item['lastLocENDTs'].isoformat()
				item['lastLocSTs'] = item['lastLocSTs'].isoformat()
			#print(item)
			#print('\n')
			json.dump(item,fp)
			#json.dumps(item,fp,default=json_util.default)
			fp.write('\n')
			#count+=1
			#print (count)
fp.close()
print ('second script %s minutes taken' % ((time.time()-start_time)//60))