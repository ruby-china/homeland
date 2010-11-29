# -*- coding: utf-8 -*- 
#
# $Id: test2.py 489 2006-11-22 22:00:40Z shodan $
#

from sphinxapi import *
import sys

docs = ['this is my test text to be highlighted','this is another test text to be highlighted']
words = 'test text'
index = 'test1'

port = 3312

opts = {'before_match':'<b>', 'after_match':'</b>', 'chunk_separator':' ... ', 'limit':400, 'around':15}

cl = SphinxClient()
cl.SetServer ( "localhost", port )
res = cl.BuildExcerpts(docs, index, words, opts)

if not res:
	print 'ERROR:', cl.GetLastError()
else:
	n = 0
	for entry in res:
		n += 1
		print 'n=%d, res=%s' % (n, entry)

#
# $Id: test2.py 489 2006-11-22 22:00:40Z shodan $
#
