#/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import unicodedata
import re
import codecs
import os

def main():
	fh = codecs.open(sys.argv[1],"r", "UTF-8")
	lines = fh.readlines()
	fh.close()
	uni_char = {}
	for l in lines:
		l = l.strip()
		toks = l.split('\t')
		k = toks[0]
		cnt = int(toks[1])
		if k not in uni_char:
			uni_char[k] = cnt
	fh = codecs.open(sys.argv[2],"r", "UTF-8")
	lines = fh.readlines()
	fh.close()
	for l in lines:
		l = l.strip()
		if l not in uni_char:
			uni_char[l] = 1
		pass
	for k in uni_char:
		cnt = uni_char[k]
		print (k+'\t'+str(cnt)).encode('UTF-8')
		print ('x:'+str(cnt)).encode('UTF-8')
	pass
	
if __name__ == "__main__":
     main()