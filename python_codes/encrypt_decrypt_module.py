#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
In this scipt, I try to recover the Mac address from the AES encrypted ones
Created on Mon Jul  2 11:22:49 2018

@author: haroonr
"""
#%%
import hashlib
m = hashlib.sha256()
#msg = '12:34:56:78:09:10'
msg = '12:34:56:78:09:10'
msg = msg.encode('utf-8')
m.update(msg)
m.hexdigest()