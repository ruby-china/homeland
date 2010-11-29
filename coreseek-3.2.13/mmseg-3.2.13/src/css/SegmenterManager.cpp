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

#include "Segmenter.h"
#include "SegmenterManager.h"
extern "C"{
#include "iniparser/iniparser.h"
}
namespace css {


const char g_ngram_unigram_dict_name[] = "uni.lib";
const char g_kword_unigram_dict_name[] = "kw.lib";
const char g_wordweight_unigram_dict_name[] = "weight.lib";
const char g_synonyms_dict_name[] = "synonyms.dat";
const char g_thesaurus_dict_name[] = "thesaurus.lib";
const char g_config_name[] = "mmseg.ini";
/** 
 *  Return a newly created segmenter
 */

Segmenter *SegmenterManager::getSegmenter( bool bFromPool)
{
	Segmenter* seg = NULL;
	if(m_method == SEG_METHOD_NGRAM){
		if(bFromPool)
			seg = seg_freelist_.alloc();
		else
			seg = new Segmenter();
		//init seg
		seg->m_unidict = &m_uni;
		seg->m_symdict = &m_sym;
		if(m_kw.isLoad())
			seg->m_kwdict = &m_kw;
		if(m_weight.isLoad())
			seg->m_weightdict =  &m_weight;
		if(m_thesaurus.isLoad())
			seg->m_thesaurus = &m_thesaurus;
		seg->m_config = &m_config;
	}		
	return seg;
}

void SegmenterManager::loadconfig(const char* confile)
{
	if(confile == NULL)
		return;
	dictionary	*	ini;
	char		*	s;
	int sl = 0;
	//m_config
	ini = iniparser_load(confile);
	if (ini==NULL) {
		return; // not exist or not a valid ini file
	}
	/*
	u1 merge_number_and_ascii;
	u1 seperate_number_ascii;
	u1 compress_space;
	u1 number_and_ascii_joint[512];
	*/
	m_config.merge_number_and_ascii = 
		iniparser_getboolean(ini, "mmseg:merge_number_and_ascii", 0);
	m_config.seperate_number_ascii = 
		iniparser_getboolean(ini, "mmseg:seperate_number_ascii", 0);
	m_config.compress_space = 
		iniparser_getboolean(ini, "mmseg:compress_space", 0);
	s = 
		iniparser_getstring(ini, "mmseg:number_and_ascii_joint", NULL);
	if(s){
		sl = strlen(s);
		if(sl>511){
			memcpy(m_config.number_and_ascii_joint,s,sl);
			m_config.number_and_ascii_joint[511] = 0;
		}else{
			memcpy(m_config.number_and_ascii_joint,s,sl);
			m_config.number_and_ascii_joint[sl] = 0;
		}
	}
}

int SegmenterManager::init(const char* path, u1 method)
{
	if( method != SEG_METHOD_NGRAM)
		return -4; //unsupport segmethod.
	
	if( m_inited )
		return 0; //only can be init once.
	
	char buf[1024];
	memset(buf,0,sizeof(buf));
	if(!path)
		memcpy(buf,".",1);
	else
		memcpy(buf,path,strlen(path));
	int nLen = (int)strlen(path);
	//check is end.
#ifdef WIN32
	if(buf[nLen-1] != '\\'){
		buf[nLen] = '\\';
		nLen++;
	}
#else
	if(buf[nLen-1] != '/'){
		buf[nLen] = '/';
		nLen++;
	}
#endif
	m_method = method;
	int nRet = 0;

	if(method == SEG_METHOD_NGRAM) {
		seg_freelist_.set_size(64);
		memcpy(&buf[nLen],g_ngram_unigram_dict_name,strlen(g_ngram_unigram_dict_name));
		nRet = m_uni.load(buf);

		if(nRet!=0){
			printf("Unigram dictionary load Error\n");
			return nRet;
		}
		//no needs to care kwformat
		memcpy(&buf[nLen],g_kword_unigram_dict_name,strlen(g_kword_unigram_dict_name));
		buf[nLen+strlen(g_kword_unigram_dict_name)] = 0;
		nRet = m_kw.load(buf);
		if(nRet!=0 && nRet!=-1 ){
			//m_kw not exist or format error.
			printf("Keyword dictionary load Error\n");
			return nRet;
		}

		//try to load weight dict
		memcpy(&buf[nLen],g_wordweight_unigram_dict_name,strlen(g_wordweight_unigram_dict_name));
		buf[nLen+strlen(g_wordweight_unigram_dict_name)] = 0;
		nRet = m_weight.load(buf);
		if(nRet!=0 && nRet!=-1 ){
			//m_kw not exist or format error.
			printf("Keyword dictionary load Error\n");
			return nRet;
		}
		
		memcpy(&buf[nLen],g_synonyms_dict_name,strlen(g_synonyms_dict_name));
		buf[nLen+strlen(g_synonyms_dict_name)] = 0;
		//load g_synonyms_dict_name, we do not care the load in right or not
		nRet = m_sym.load(buf);
		if(nRet!=0 && nRet != -1){
			printf("Synonyms dictionary format Error\n");
		}

		memcpy(&buf[nLen],g_thesaurus_dict_name,strlen(g_thesaurus_dict_name));
		buf[nLen+strlen(g_thesaurus_dict_name)] = 0;
		//load g_synonyms_dict_name, we do not care the load in right or not
		nRet = m_thesaurus.load(buf);
		if(nRet!=0 && nRet != -1){
			printf("Thesaurus dictionary format Error\n");
		}

		//read config
		memcpy(&buf[nLen],g_config_name,strlen(g_config_name));
		buf[nLen+strlen(g_config_name)] = 0;
		loadconfig(buf);

		nRet = 0;
		m_inited = 1;
		return nRet;
	}
	return -1;
}

void SegmenterManager::clear()
{
    seg_freelist_.free();
}
SegmenterManager::SegmenterManager()
		:m_inited(0)
{
	m_method = SEG_METHOD_NGRAM;
}
SegmenterManager::~SegmenterManager()
{
	clear();
}
} /* End of namespace css */

