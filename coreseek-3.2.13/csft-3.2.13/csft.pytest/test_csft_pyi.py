import sys
sys.path.append("G:\\Coreseek\\sphinx-0.9.9\\bin\\Release\\")
print sys.path

import pycsft


print sys.argv[1]
conf = pycsft.load(sys.argv[1])

print conf.SourceNames(), conf.IndexNames()

for n in conf.SourceNames():
    print conf.GetSource(n)
    
idx = conf.GetIndex("test1")
print idx.tokenizer("hello world")