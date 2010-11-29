#/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import unicodedata
import re
import codecs
import os

def getNum(leftK):
	idxleftK = 0
	if leftK.find('U+') == -1:
		idxleftK = ord(leftK)
	else:
		leftK = leftK.replace('U+','0x')
		idxleftK = eval(leftK)
	return idxleftK

def dump(i, table):
	#print table
	print '//'+hex(i/256-1),hex(i)
	#print 'const static u2 table_'+hex(i/256-1)+'[] = {'
	print 'const static u2 table_'+str(i/256-1)+'[] = {'
	line = ''
	for j in range(0,256):
		#print hex(j) +'->'+hex(table[j]),
		if j and j % 16 == 0:
			print line;
			line = ''
		line = line + hex(table[j])+','
	print line[:-1]
	print '};'
	#dump convert table
	print '/*'
	for j in range(0,256):
		#print i-255+j, table[j]
		if i-256+j and table[j]:
			print (unichr(i-256+j)+'>'+unichr(table[j])).encode('UTF-8'),
	print '*/'
	pass
	
def main():
	fh = codecs.open(sys.argv[1],"r", "UTF-8")
	lines = fh.readlines()
	fh.close()
	trans_table = [0]*65536;
	for line in lines:
		if line[0] == '#':
			continue
		parse = line.strip().split(',')
		for p in parse:
			keyIdx = p.find('->')
			#print p,
			if keyIdx != -1 and p.find('..') == -1:
				#not range
				#print p,
				idxleftK = 0
				idxrightK = 0
				leftK = p[:keyIdx]
				if leftK.find('U+') == -1:
					idxleftK = ord(leftK)
				else:
					leftK = leftK.replace('U+','0x')
					idxleftK = eval(leftK)
				rightK = p[keyIdx+2:]
				if rightK.find('U+') == -1:
					idxrightK = ord(rightK)
				else:
					rightK = rightK.replace('U+','0x')
					idxrightK = eval(rightK)
				if idxleftK > 65536 or idxrightK > 65536:
					continue
				if idxleftK and idxrightK:
					#print leftK,rightK,'\t',
					#print idxleftK,idxrightK,
					#print (unichr(idxleftK) +'->'+ unichr(idxrightK)+'\t').encode('UTF-8')
					trans_table[idxleftK] = idxrightK
				#Russian char made things harder.
				bSkipOverride = 0;
				if bSkipOverride and trans_table[idxleftK] and trans_table[idxleftK] != idxrightK:
					print leftK, rightK, "inconst conver",idxleftK,idxrightK,trans_table[idxleftK]
					print (unichr(idxleftK) + ',' + unichr(idxrightK) + ',' + unichr(trans_table[idxleftK])).encode('UTF-8')
					pass
					
				trans_table[idxleftK] = idxrightK
				pass
			if keyIdx != -1 and p.find('..') > 0:
				leftK = p[:keyIdx]
				rightK = p[keyIdx+2:]
				lbegin = leftK.find('..')
				strbegin = leftK[:lbegin].strip()
				strend = leftK[lbegin+2:].strip()
				#print getNum(strbegin),getNum(strend)
				from_range = range(getNum(strbegin),getNum(strend)+1)
				leftK = rightK
				lbegin = leftK.find('..')
				strbegin = leftK[:lbegin].strip()
				strend = leftK[lbegin+2:].strip()
				to_range = range(getNum(strbegin),getNum(strend)+1)
				
				for i in range(0,len(from_range)):
					if trans_table[from_range[i]] and trans_table[from_range[i]] != to_range[i]:
						print "inconst conver",from_range[i],to_range[i],trans_table[idxleftK]
					#print from_range[i],to_range[i]
					trans_table[from_range[i]] = to_range[i]
				#print getNum(strbegin),getNum(strend)
				#print p,
				pass
	#  人工 强制指定的符号转换
	trans_table[ord(u'／')] = ord('/')
	trans_table[ord(u'￥')] = ord('$')
	trans_table[ord(u'＃')] = ord('#')
	trans_table[ord(u'％')] = ord('%')
	trans_table[ord(u'！')] = ord('!')
	trans_table[ord(u'＊')] = ord('*')
	trans_table[ord(u'（')] = ord('(')
	trans_table[ord(u'）')] = ord(')')
	trans_table[ord(u'－')] = ord('-')
	trans_table[ord(u'＋')] = ord('+')
	trans_table[ord(u'＝')] = ord('=')
	trans_table[ord(u'｛')] = ord('{')
	trans_table[ord(u'｝')] = ord('}')
	trans_table[ord(u'［')] = ord('[')
	trans_table[ord(u'］')] = ord(']')
	trans_table[ord(u'、')] = ord(',')
	trans_table[ord(u'｜')] = ord('|')
	trans_table[ord(u'；')] = ord(';')
	trans_table[ord(u'：')] = ord(':')
	trans_table[ord(u'‘')] = ord('\'')
	trans_table[ord(u'“')] = ord('"')
	trans_table[ord(u'《')] = ord('<')
	trans_table[ord(u'》')] = ord('>')
	trans_table[ord(u'〉')] = ord('<')
	trans_table[ord(u'〈')] = ord('>')
	trans_table[ord(u'？')] = ord('?')
	trans_table[ord(u'～')] =ord('~')
	trans_table[ord(u'｀')] =ord('`')
	
	#dump the trans-table
	#page size = 256
	#print trans_table
	trans_page = [0]*256
	idx_page = [0]*256
	i = 0
	for i in range(0,65536):
		if i%256 == 0:
			bOutput = 0
			for j in range(0,256):
				if trans_page[j]:
					bOutput = 1
					break
			if bOutput:
				#print trans_page
				idx_page[i/256-1] = 1;
				dump(i,trans_page)
			trans_page = [0]*256
		if trans_table[i]:
			trans_page[i%256] = trans_table[i]
	
	bOutput = 0
	for j in range(0,256):
		if trans_page[j]:
			bOutput = 1
			break
	if bOutput:
		#print trans_page
		idx_page[i/256] = 1;
		dump(i+1,trans_page)
	print 'const static u2 table_index[] = {' 
	for j in range(0,256):
		if idx_page[j]:
			print 'table_'+str(j),
		else:
			print 'NULL',
		if j != 255:
			print ',',
	print '};'
if __name__ == "__main__":
     main()