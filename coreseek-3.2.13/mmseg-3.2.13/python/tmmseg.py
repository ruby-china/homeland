# -*- coding: utf-8 -*-

import cmmseg
cmmseg.init('F:\\deps\\mmseg\\src\\win32')
rs = cmmseg.segment((u'中文分词').encode('utf-8'))
for i in rs:
    print i.decode('utf-8')