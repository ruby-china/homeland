/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* ***** BEGIN LICENSE BLOCK *****
* Version: GPL 2.0
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License. You should have
* received a copy of the GPL license along with this program; if you
* did not, you can find it at http://www.gnu.org/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is Coreseek.com code.
*
* Copyright (C) 2007-2008. All Rights Reserved.
*
* Author:
*	Li monan <li.monan@gmail.com>
*
* ***** END LICENSE BLOCK ***** */

#include <fstream>
#include <string>
#include <iostream>
#include <cstdio>
#include <algorithm>
#include <map>
#include  <stdlib.h>

#ifdef WIN32
#include "bsd_getopt_win.h"
#else
#include "bsd_getopt.h"
#endif

#include "UnigramCorpusReader.h"
#include "UnigramDict.h"
#include "SynonymsDict.h"
#include "ThesaurusDict.h"
#include "SegmenterManager.h"
#include "Segmenter.h"
#include "csr_utils.h"

using namespace std;
using namespace css;

#define SEGMENT_OUTPUT 1

void usage(const char* argv_0) {
	printf("Coreseek COS(tm) MM Segment 1.0\n");
	printf("Copyright By Coreseek.com All Right Reserved.\n");
	printf("Usage: %s <option> <file>\n",argv_0);
	printf("-u <unidict>           Unigram Dictionary\n");
	printf("-r           Combine with -u, used a plain text build Unigram Dictionary, default Off\n");
	printf("-b <Synonyms>           Synonyms Dictionary\n");
	printf("-t <thesaurus>          Thesaurus Dictionary\n");
	printf("-h            print this help and exit\n");
	return;
}
int segment(const char* file,Segmenter* seg);
/*
Use this program 
Usage:
1)
./ngram [-d dict_path] [file] [outfile] 
Do segment. Will print segment result to stdout
-d the path with contains unidict & bidict
file: the file to be segment, must encoded in UTF-8 format. [*nix only] if file=='-', read data from stdin
2)
./ngram -u file [outfile]
Build unigram dictionary from corpus file. 
file: the unigram corpus. Use \t the separate each item.
eg.
item	3
n:2	a:1
if outfile not assigned , file.uni will be used as output
3)
./ngram -u unidict -b file [outfile]
Build bigram 
if outfile not assigned , file.bi will be used as output
*/

int main(int argc, char **argv) {
	int c;
	const char* corpus_file = NULL;
	const char* uni_corpus_file = NULL;
	const char* thesaurus_file = NULL;
	const char* out_file = NULL;
	const char* dict_path = NULL;
	const char* target_file = NULL;
	char out_buf[512];
	
	if(argc < 2){
		usage(argv[0]);
		exit(0);
	}
	u1 bPlainText = 0;
	u1 bUcs2 = 0;
	while ((c = getopt(argc, argv, "t:b:u:d:o:rU")) != -1) {
		switch (c) {
		case 'o':
			target_file = optarg;
			break;
		case 'u':
			uni_corpus_file = optarg;
			break;
		case 'b':
			corpus_file = optarg;
			break;
		case 'd':
			dict_path = optarg;
			break;
		case 't':
			thesaurus_file = optarg;
			break;
		case 'r':
			bPlainText = 1;
			break;
		case 'U':
			bUcs2 = 1;
			break;
		case 'h':
			usage(argv[0]);
			exit(0);
		default:
			fprintf(stderr, "Illegal argument \"%c\"\n", c);
			return 1;
		}
	}

	if(optind < argc) {
		out_file = argv[optind];
	}

	if(thesaurus_file) {
		ThesaurusDict tdict;
		tdict.import(thesaurus_file, target_file);
		//ThesaurusDict ldict;
		//ldict.load("thesaurus.lib");
		return 0;
	}

	if(corpus_file){
		//build Synonyms dictionary
		SynonymsDict dict;
		dict.import(corpus_file);
		if(target_file)
		   dict.save(target_file);
		else
		   dict.save("synonyms.dat");
		//debug use
		//dict.load("synonyms.dat");
		//printf("%s\n", dict.exactMatch("c#"));
		return 0;
	}

	if(!corpus_file && !dict_path) {
		//build unigram 
		if(!out_file) {
			//build the output filename
			size_t len = strlen(uni_corpus_file);
			memcpy(out_buf,uni_corpus_file,len);
			memcpy(&out_buf[len],".uni\0",5);
			out_file = out_buf;
		}
		
		if(target_file) {
			out_file = target_file;
		}
		
		UnigramCorpusReader ur;
		ur.open(uni_corpus_file,bPlainText?"plain":NULL);
		if(!bUcs2){
			UnigramDict ud;
			int ret = ud.import(ur);
			ud.save(out_file);		
			//check
			int i = 0;
			for(i=0;i<ur.count();i++)
			{
				UnigramRecord* rec = ur.getAt(i);
				
				if(ud.exactMatch(rec->key.c_str()) == rec->count){
					continue;
				}else{
					printf("error!!!");
				}
			}//end for
		}else{
			printf("UCS2 used as inner encoding, is unsupported\n");
		}
		return 0;
	}else
	if(!dict_path){ //not segment mode.
		//build bigram
		if(!out_file) {
			//build the output filename
			size_t len = strlen(corpus_file);
			memcpy(out_buf,corpus_file,len);
			memcpy(&out_buf[len],".bi\0",4);
			out_file = out_buf;
		}
		printf("Bigram build unsupported.\n");
	}//end if(!corpus_file)
	//Segment mode
	{
		SegmenterManager* mgr = new SegmenterManager();
		int nRet = 0;
		if(dict_path)
			nRet = mgr->init(dict_path);
		else{
			usage(argv[0]);
			exit(0);
		}
		if(nRet == 0){
			//init ok, do segment.
			Segmenter* seg = mgr->getSegmenter();
			segment(out_file,seg);
		}
		delete mgr;
	}
	
	return 0;
}

int segment(const char* file,Segmenter* seg)
{
	std::istream *is;

	is = new std::ifstream(file, ios::in | ios::binary);
	if (! *is) 
		return -1;

	std::string line;
	int n = 0;
	
	unsigned long srch,str;
	str = currentTimeMillis();
	//load data.
	int length;
	is->seekg (0, ios::end);
	length = is->tellg();
	is->seekg (0, ios::beg);
	char* buffer = new char [length+1];
	is->read (buffer,length);
	buffer[length] = 0;
	//begin seg
	seg->setBuffer((u1*)buffer,length);
	u2 len = 0, symlen = 0;
	u2 kwlen = 0, kwsymlen = 0;
	//check 1st token.
	char txtHead[3] = {239,187,191};
	char* tok = (char*)seg->peekToken(len, symlen);
	seg->popToken(len);
	if(seg->isSentenceEnd()){
		do {
			char* kwtok = (char*)seg->peekToken(kwlen , kwsymlen,1);
			if(kwsymlen)
				printf("[kw]%*.*s/x ",kwsymlen,kwsymlen,kwtok);
		}while(kwsymlen);
	}

	if(len == 3 && memcmp(tok,txtHead,sizeof(char)*3) == 0){
		//check is 0xFEFF
		//do nothing
	}else{
		printf("%*.*s/x ",symlen,symlen,tok);
	}
	while(1){
		len = 0;
		char* tok = (char*)seg->peekToken(len,symlen);
		if(!tok || !*tok || !len)
			break;
		seg->popToken(len);
		if(seg->isSentenceEnd()){
			do {
				char* kwtok = (char*)seg->peekToken(kwlen , kwsymlen,1);
				if(kwsymlen)
					printf("[kw]%*.*s/x ",kwsymlen,kwsymlen,kwtok);
			}while(kwsymlen);
		}

		if(*tok == '\r')
			continue;
		if(*tok == '\n'){
			printf("\n");
			continue;
		}

		//printf("[%d]%*.*s/x ",len,len,len,tok);
		printf("%*.*s/x ",symlen,symlen,tok);
		//check thesaurus
		{
			const char* thesaurus_ptr = seg->thesaurus(tok, symlen);
			while(thesaurus_ptr && *thesaurus_ptr) {
				len = strlen(thesaurus_ptr);
				printf("%*.*s/s ",len,len,thesaurus_ptr);
				thesaurus_ptr += len + 1; //move next
			}
		}
		//printf("%s",tok);
	}
	srch = currentTimeMillis() - str;
	printf("\n\nWord Splite took: %d ms.\n", srch);
	//found out the result
	delete is;
	
	return 0;
}
