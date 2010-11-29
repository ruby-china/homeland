# -*- coding:utf-8 -*-
# coreseek3.2 python source演示操作mssql数据库
# author: HonestQiao
# date: 2010-06-01 10:05

from os import path
import os
import sys
import pymssql
import datetime

class MainSource(object):
    def __init__(self, conf):
        self.conf =  conf
        self.idx = 0
        self.data = []
        self.conn = None
        self.cur = None

    def GetScheme(self):  #获取结构，docid、文本、整数
        return [
            ('threadid' , {'docid':True, } ),
            ('title', { 'type':'text'} ),
            ('context', { 'type':'text'} ),
            ('date', {'type':'integer'} ),
        ]

    def GetFieldOrder(self): #字段的优先顺序
        return ('title', 'context')
        
    def Connected(self):   #如果是数据库，则在此处做数据库连接
        if self.conn==None:       
            self.conn = pymssql.connect(host='127.0.0.1', user='root', password='123456', database='bbs', as_dict=True)
            self.cur = self.conn.cursor()
            sql = 'SELECT threadid,title,content,date FROM ss_bbs_topic'
            self.cur.execute(sql)
            self.data = [ row for row in self.cur]
        pass

    def NextDocument(self):   #取得每一个文档记录的调用
        if self.idx < len(self.data):
            item = self.data[self.idx]
            self.docid = self.threadid = item['threadid'] #'docid':True
            self.title = item['title'].encode('utf-8')
            self.context = item['context'].encode('utf-8')
            self.date = item['date']
            self.idx += 1
            return True
        else:
            return False

if __name__ == "__main__":    #直接访问演示部分
    conf = {}
    source = MainSource(conf)
    source.Connected()

    while source.NextDocument():
        print "id=%d, subject=%s" % (source.docid, source.title)
    pass
#eof
