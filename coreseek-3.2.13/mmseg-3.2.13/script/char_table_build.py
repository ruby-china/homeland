#/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import unicodedata
import re
import codecs
import os

# tag set 
#tag-set:
#m: number
#e: non CJK char, e.g. English pinyin
#[unuse] t: time.    年号 干支等（此处识别出后，仅加入 oov ，不参与实际分词）
#c: CJK char.
#s: Symbol e.g. @
#w: Sentence seperator.
#x: unknown char.
# Use to generate c-style
def ANSI_build(name): 
	tag = {}
	for c in range(0x20,0x7F):
		tag[c] = 's'
	#number
	num = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') 
	for c in num:
		#print ord(c)
		#print chr(ord(c))
		tag[ord(c)] = 'm'
	#eng
	for c in range(ord('a'),ord('z')):
		tag[c] = 'e'
	for c in range(ord('A'),ord('Z')):
		tag[c] = 'e'
	for c in range(0xC0,0xFF):
		tag[c] = 'e'
	
	#seperate
	wset = ('!','"','\'',',','.',':',';','?')
	for c in wset:
		tag[ord(c)] = 'w'
	#do output page
	codepage = ['']*256
	for c in tag:
		codepage[c] = tag[c]
	code = 'char '+name+'[]= {'
	for i in range(0,256):
		if i%8 == 0:
			code = code + '\n\t'
		if codepage[i]:
			code = code + '\'' + codepage[i] +'\''
		else:
			code = code + '\'\\0\'' 
		if i != 256:
			code = code + ', '
	code = code + '\n\t};'
	print code
	#print codepage
	pass
	
#generate CJK area.
def ChineseBuild(name):
	only = (35, 118, 129, 104, 151, 141, 84, 150, 87, 116, 89)
	tag = {}
	# number
	num1 = (u'零',u'〇',u'一',u'二',u'三',u'四',u'五',u'六',u'七',u'八',u'九',u'十',u'壹',u'贰',u'叁',u'肆',u'伍',u'陆',u'柒',u'捌',u'玖',u'拾',u'个',u'百',u'千',u'万',u'亿',u'兆',u'仟',u'佰')
	num2 = (u'１', u'２', u'３', u'４', u'５', u'６', u'７', u'８', u'９', u'０')
	num = num1 + num2
	for c in num:
		iCode = ord(c)
		if iCode/256 == 0:
			continue
		if iCode/256 in only:
			print iCode, 
			print c
		tag[iCode] = 'm'
	#syb
	syb1 = (u'～', u'！', u'＠', u'＃', u'#', u'￥', u'％', u'…', u'＆', u'×', u'（', u'）', u'—', u'＋', u'｛', u'｝', u'｜', u'：', u'“', u'”', u'《', u'》', u'？', u'·', u'·', u'－', u'＝', u'【', u'】', u'＼', u'；', u'‘', u'’', u'，', u'。', u'、', u'¨', u'〔', u'〕', u'〈', u'〉', u'「', u'」', u'『', u'』', u'．', u'〖', u'〗', u'【', u'】', u'（', u'）', u'［', u'］', u'｛', u'｝', u'。', u'，', u'：', u'≈', u'≡', u'≠', u'＝', u'≤', u'≥', u'＜', u'＞', u'≮', u'≯', u'∷', u'±', u'＋', u'－', u'×', u'÷', u'／', u'∫', u'∮', u'∝', u'∞', u'∧', u'∨', u'∑', u'∏', u'∪', u'∩', u'∈', u'∵', u'∴', u'⊥', u'∥', u'∠', u'⌒', u'⊙', u'≌', u'∽', u'　', u'√')
	for c in syb1:
		iCode = ord(c)
		if iCode/256 == 0:
			continue
		if iCode/256 in only:
			print c
		tag[iCode] = 's'
	#eng
	for c in range(ord(u'ａ'),ord(u'ｚ')):
		tag[c] = 'e'
	for c in range(ord(u'Ａ'),ord(u'Ｚ')):
		tag[c] = 'e'
	#sep	
	wset = (u'、', u'，', u'，', u'\'', u'‘', u'’', u'‘', u'’', u'！', u'！', u'？', u'？', u'。', u'。', u'？', u'？', u'.', u'“', u'”', u'“', u'”', u'：', u':', u'＂',u'＇',u'｀',u'〃')
	
	for c in wset:
		iCode = ord(c)
		if iCode/256 == 0:
			continue
		if iCode/256 in only:
			print c
		tag[iCode] = 'w'
	#process
	st = {}
	oc = 0x30
	codepage = ['\\0']*256
	if oc == 0xFF:
		for c in range(0xFF01, 0xFF66):
			codepage[c-0xFF00] = 's'
	if oc == 0x30:
		for c in range(0x3001, 0x3040):
			codepage[c-0x3001] = 's'
			
	for c in tag:
		iCode = (c)
		k = iCode/256
		if k == oc:
			print iCode%256, c
			codepage[iCode%256] = tag[c] 
			
	code = 'char '+name+'[]= {'
	for i in range(0, 256):
		if i%8 == 0:
			code = code + '\n\t'
		if codepage[i]:
			code = code + '\'' + codepage[i] +'\''
		if i != 256:
			code = code + ', '
	code = code + '\n\t};'
	print code
	
	# output all chinese, by tag.
	code = '{'
	for c in tag:
		k = c/256
		if k == 0xFF or k == 0x30:
			continue
		if tag[c] == 'm':
			code = code + str(hex(c))+', '
	print code
	# output all chinese, by tag.
	# NOTE 0x22xx, 0x23xx is number symbol, ignore this block.
	code = '{'
	for c in tag:
		k = c/256
		if k == 0xFF or k == 0x30:
			continue
		if tag[c] == 's':
			code = code + str(hex(c))+', '
	print code
	# sep
	code = '{'
	for c in tag:
		k = c/256
		if k == 0xFF or k == 0x30:
			continue
		if tag[c] == 'w':
			code = code + str(hex(c))+', '
	print code
	#eng
	code = '{'
	for c in tag:
		k = c/256
		if k == 0xFF or k == 0x30:
			continue
		if tag[c] == 'e':
			code = code + str(hex(c))+', '
	print code
	pass
def main():
	ANSI_build("ansipage")
	ChineseBuild("sym1")
	pass

if __name__ == "__main__":
     main()