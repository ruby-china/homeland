#/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import unicodedata
import re
import codecs
import os

def enmu_all_keys(key):
    kl = []
    if len(key)==0:
        return kl
    prefix = ''
    for c in key:
        prefix = prefix + c
        if len(prefix) == 1:
            continue
        kl.append(prefix)
    kl2 = enmu_all_keys(key[1:])
    return kl + kl2
   
def main():
    fh = codecs.open(sys.argv[1],"r", "UTF-8")
    lines = fh.readlines()
    fh.close()
    i = 0
    ht = {}
    for l in lines:
        if i % 2 == 0:
            l = l.strip()
            l = l.split('\t')[0]
            ht[l] = 1
            #print l
        i = i + 1
    
    for k in ht:
        if len(k) == 1:
            continue
        subk = {}
        kl = enmu_all_keys(k)
        for sk in kl:
            #print sk, sk != k ,ht.has_key(sk)
            if sk != k and ht.has_key(sk):
                subk[sk] = 1
        ht[k] = subk
        
    for k in ht:
        if ht[k] != 1 and  ht[k] != {}:
            print k.encode('UTF-8')
            s = ''
            #print k, ht[k]
            for sk in ht[k]:
                s = s + sk + ',';
            print ('-'+s).encode('UTF-8')
    
    
if __name__ == "__main__":
     main()
     #print enmu_all_keys('abc')