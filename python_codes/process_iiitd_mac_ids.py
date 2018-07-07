#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this script I clean all mac adress sheets shared by Mr Bhawani
Created on Thu Jun 28 17:11:54 2018

@author: haroonr
"""
import pandas as pd
#%%
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/mac_ids/"

workbook_name = "Faculty-Staff-PhD.xlsx"

sheet0 = pd.read_excel(path+workbook_name,sheet_name=0)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols0 = sheet0[keep_names]

sheet1 = pd.read_excel(path+workbook_name,sheet_name=1)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols1 = sheet1[keep_names]

sheet2 = pd.read_excel(path+workbook_name,sheet_name=2)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols2 = sheet2[keep_names]

sheet3 = pd.read_excel(path+workbook_name,sheet_name=3)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols3 = sheet3[keep_names]

#sheet4 = pd.read_excel(path+workbook_name,sheet_name=4)
#keep_names = ['User Name','Device Name', 'MAC']
#sheet_sel_cols4 = sheet4[keep_names]

sheet5 = pd.read_excel(path+workbook_name,sheet_name=5)
keep_names = ['User Name','Device Name', 'MAC']
sheet_sel_cols5 = sheet5[keep_names]

# sheet 4 seems faulty
df = pd.concat([sheet_sel_cols0,sheet_sel_cols1,sheet_sel_cols2,sheet_sel_cols3,sheet_sel_cols5],axis=0)
df.columns = ['username','devicename','mac']
# fix letter case
df = df.dropna(subset = ['mac'])

usernames = list(df.username)
usernames_small = [str(s).lower() for s in usernames]
df.username = usernames_small
#df_gp = df.groupby('username')

#%%
addresses = list(df.mac)
new_addresses = []
for i in addresses:
  
  try:
    address = str(i.lower().strip())
  except: # case when i is not in required format
    address = str(i)
  if len(address) < 12 or len(address) > 17:
    address = float('nan')
    #addresses.append(address)
  elif not (':' in str(address)):
      address = ':'.join(address[i:i+2] for i in range(0,12,2))
      #addresses.append(address)
  new_addresses.append(address)
df.mac = new_addresses   
df.to_csv(path+"processed_faculty_staff_sheet.csv")
#%% studnents mobile sheet Students Mobile.numbers

path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/mac_ids/"
import pandas as pd
workbook_name = "StudentsLaptop_numbers_converted.xlsx"
sheet0 = pd.read_excel(path+workbook_name,sheet_name=0)
sel0 = sheet0[['User Name','MAC']]
sel0.columns = ['Username','MAC']

sheet1 = pd.read_excel(path+workbook_name,sheet_name=1)
sel1 =  sheet1.iloc[:,[1,3]]
sel1.columns = ['Username','MAC']
sheet2 = pd.read_excel(path+workbook_name,sheet_name=2)
sel2 =  sheet2.iloc[:,[1,3]]
sel2.columns = ['Username','MAC']

sheet3 = pd.read_excel(path+workbook_name,sheet_name=3)
sel3 =  sheet3.iloc[:,[1,3]]
sel3.columns = ['Username','MAC']

sheet4 = pd.read_excel(path+workbook_name,sheet_name=4)
sel4 =  sheet4.iloc[:,[1,3]]
sel4.columns = ['Username','MAC']

sheet6 = pd.read_excel(path+workbook_name,sheet_name=6)
sel6 =  sheet6.iloc[:,[1,3]]
sel6.columns = ['Username','MAC']

# special treatment for remaining two pages
sheet5 = pd.read_excel(path+workbook_name,sheet_name=5)
sel5 =  sheet5.iloc[:,[1,3]]
sel5.columns = ['Username','MAC']

sheet7 = pd.read_excel(path+workbook_name,sheet_name=7)
sel7 =  sheet7.iloc[:,[1,3]]
sel7.columns = ['Username','MAC']
# load dicionary for usernames first
direc = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/IIIT_occupancy/username_emailid/"
mydictionary = pd.read_csv(direc+"formatted_useranmes.csv")
mydictionary.drop(['Unnamed: 0'],axis=1,inplace = True)

def strip_me(frame):
  # this removes leading and trailing whitespaces of all columns of dataframe
  my_dic = {}
  for col_name in frame.columns:
    my_dic[col_name] = [val.strip() for val in mydictionary[col_name].values]
  return pd.DataFrame(my_dic)


mydictionary = strip_me(mydictionary) # define below

  
#% format sheet 7
full_names = []
for i in range(0,sel7.shape[0]):
  username = sel7.Username[i].strip()
  print (username)
  try:
    full_names.append(mydictionary[mydictionary.username == username].iat[0,0])
  except:
    full_names.append(float('nan'))
sel7['fullname'] =  full_names
sel7.drop(columns=['Username'],inplace = True)
sel7.columns = ['MAC','Username']
#% format sheet 5
full_names = []
for i in range(0,sel5.shape[0]):
  
  username = sel5.Username[i]
  #print (username)
  try:
    full_names.append(mydictionary[mydictionary.username == username.strip()].iat[0,0])
  except:
    full_names.append(float('nan'))
sel5['fullname'] =  full_names
sel5.drop(columns = ['Username'],inplace = True)
sel5.columns = ['MAC','Username']
#% combine all  students sheets into one
all_macs  = pd.concat([sel0,sel1,sel2,sel3,sel4,sel5,sel6,sel7],axis = 0)
#%% Read third sheet:  related to mobile phones

workbook_name = "StudentsMobile_numbers_converted.xlsx"
pag0 = pd.read_excel(path+workbook_name,sheet_name=1)
selec0 = pag0.iloc[:,[1,2]]
selec0.columns = ['Username','MAC']

pag1 = pd.read_excel(path+workbook_name,sheet_name=2)
selec1 =  pag1.iloc[:,[1,2]]
selec1.columns = ['Username','MAC']
selec1.dropna(inplace= True)
selec1 = selec1.reindex(range(0,selec1.shape[0]))
# format sheet 1
#% format 
full_names = [ ]
for i in range(0,selec1.shape[0]):
  username = selec1.Username[i]
  try:
    full_names.append(mydictionary[mydictionary.username == username.strip()].iat[0,0])
  except:
    full_names.append(float('nan'))
selec1['fullname'] =  full_names
selec1.drop(columns = ['Username'],inplace = True)
selec1.columns = ['MAC','Username']
#%
all_macs_mobile = pd.concat([selec0,selec1],axis=0)
all_macs_mobile.dropna(inplace = True)
#%% concate all students connections
students_macs = pd.concat([all_macs,all_macs_mobile])
students_macs.to_csv(path +"processed_students_all_sheet.csv")
