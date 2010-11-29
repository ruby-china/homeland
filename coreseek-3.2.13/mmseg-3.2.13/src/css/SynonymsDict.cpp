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

#include <algorithm>
#include <fstream>
#include <iostream>
#include <map>

#include "UnigramCorpusReader.h"
#include "SynonymsDict.h"

namespace css {

const char head_mgc[] = "SYMD";

typedef struct _csr_crfdict_fileheader_tag{
	char mg[4];
	short version;
	short reserve;
	int	  darts_size;
	int   pool_size;
}_csr_synonymsdict_fileheader;

int SynonymsDict::load(const char* filename)
{
	m_file = csr_mmap_file(filename,0);
	if(!m_file)
		return -1; //can not load dict.
	csr_offset_t tm_size = csr_mmap_size(m_file);
	u1* ptr = (u1*)csr_mmap_map(m_file);
	u1* ptr_end = ptr + tm_size;
	_csr_synonymsdict_fileheader* head_ = (_csr_synonymsdict_fileheader*)ptr;
	if(strncmp(head_->mg,head_mgc,4) == 0) {
		if(head_->version == 1) {
			ptr += sizeof(_csr_synonymsdict_fileheader);
			if(ptr >= ptr_end) return -4; //file broken.
			array_ = (_csr_sybarray_trie*)ptr;
			ptr += sizeof(_csr_sybarray_trie)* head_->darts_size;
			if(ptr >= ptr_end) return -4; //file broken.
			string_pool = (char*)ptr;
			ptr += sizeof(char)*head_->pool_size;
			if(ptr > ptr_end) return -4; //file broken.
		}else{
			return -2; //unsupported version.
		}
	}else
		return -3; //bad format
    
	return 0;
}

std::string trimmed ( std::string const& str ///< the original string
					  , char const* sepSet ///< C string with characters to be dropped
 )
{
	std::string::size_type const first = str.find_first_not_of(sepSet);
	return ( first==std::string::npos )
		? std::string()
		: str.substr(first, str.find_last_not_of(sepSet)-first+1);
}

int SynonymsDict::import(const char* filename)
{
	std::istream *is;
	//std::map<std::string, size_t> rKeys;
	//std::map<std::string, size_t> lKeys;
	is = new std::ifstream(filename);
	
	if (! *is) 
		return -1;
	std::string line;
	std::string lKey,rKey;
	size_t offset = 1;
	char txtHead[3] = {239,187,191};
	//load 
	while (std::getline(*is, line)) {
		//for each line.
		if(line.size()<4)
			continue;
		if(line[0]=='/' && line[1]=='/')
			continue;
		int pos = line.find("=>");
		if(pos == -1)
			continue; //=>not found.
		size_t lKey_offset = 0;
		if(memcmp(line.c_str(),txtHead,sizeof(char)*3) == 0)
			lKey = trimmed(line.substr(3,pos-3)," \t" );
		else
			lKey = trimmed(line.substr(0,pos)," \t" );
        rKey = trimmed(line.substr(pos+2)," \t" );
		if(lKey.size() == 0 || rKey.size() == 0)
			continue;
		//all key loaded.
		//check rKey
		std::map<std::string ,size_t>::iterator it = rKeys.find(rKey);

		if(it == rKeys.end()) {
			lKey_offset = offset;
			rKeys.insert(std::map<std::string, size_t>::value_type(rKey, offset));
			offset += rKey.size() + 1; //0 term
		}else{
			lKey_offset = it->second;
			
		}
		//check lKey
		it = lKeys.find(lKey);
		if(it == lKeys.end()) {
			lKeys.insert(std::map<std::string, size_t>::value_type(lKey, lKey_offset));
		}else{
			//dup left Keys! skip.
		}
	} //end while
	//done
	m_string_pool_size = offset;

	delete is;

	return 0;
}

bool Cmp(const char *p1, const char * p2)
{
	u4 i = 0;
	while(1) {
		u1 pu1 = p1[i];
		u1 pu2 = p2[i];
		if(pu1 == pu2) {
			if(pu1 == 0)
				break;
			i++;
		}else{
			return pu1 < pu2;
		}
	}
	return true;
}

int SynonymsDict::save(const char* filename)
{
	_csr_synonymsdict_fileheader head;
	//re-sort lKeys
	std::vector <Darts::DoubleArray::key_type *> keys;
	for( std::map<std::string,size_t>::iterator it = lKeys.begin();
		it != lKeys.end(); it++) {
			//const std::string & str = it->first;
			//char* ptr = &(str.data())[0];
			char* ptr = (char*)(&((*it).first)[0]);
			keys.push_back(ptr);
	}
	std::sort(keys.begin(), keys.end(), Cmp);
	m_da.clear();
	int nRet = m_da.build(keys.size(), &keys[0], 0, 0 ) ;
	//build _csr_3dynarray_trie 	
	size_t size_ = m_da.size();//the count of unit_t
	array_ = new _csr_sybarray_trie[m_da.size()];
	memcpy(&head,head_mgc,sizeof(head_mgc));
	head.darts_size = m_da.size();
	head.version = 1;
	head.reserve = 0;
	head.pool_size = m_string_pool_size;

	const int* iArray = reinterpret_cast<const int*>(m_da.array());
	for(size_t i=0;i<size_;i++){
		array_[i].base = static_cast<const i4>(iArray[i*2]);
		array_[i].check = static_cast<const u4>(iArray[i*2+1]);
		array_[i].offset = 0;
	}
	//fill offset
	for( std::map<std::string,size_t>::iterator it = lKeys.begin();
		it != lKeys.end(); it++) {
			int id = exactMatchID(it->first.c_str());
			if(id > 0)
				array_[id].offset = it->second;
			else{
				printf("ERROR: mismatch\n");
			}
	}
	//do real save
	{
		//write header
		std::FILE *fp  = std::fopen(filename, "wb");
		std::fwrite(&head,sizeof(_csr_synonymsdict_fileheader),1,fp);
		std::fwrite(array_,sizeof(_csr_sybarray_trie),head.darts_size,fp);
		//write string-pool
		char* buf = new char[head.pool_size];
		memset(buf,0,head.pool_size);
		char null_char = 0;
		
		for( std::map<std::string,size_t>::iterator it = rKeys.begin();
			it != rKeys.end(); it++) {
				const std::string & str = it->first;
				size_t offset = it->second;
				memcpy(&buf[offset],str.c_str(),str.size());
				//std::fwrite(str.c_str(),sizeof(char),str.size(),fp);
				//std::fwrite(&null_char,sizeof(char),1,fp);
		}
		std::fwrite(buf,sizeof(char),head.pool_size,fp);
		std::fclose(fp);
		delete[] buf;
	}
	//clear
	delete[] array_;
    return 0;
}

int SynonymsDict::exactMatchID(const char* key)
{
	size_t len = strlen(key);
	size_t node_pos = 0;
	Result result;
	set_result(result, -1, 0);

	//_csr_sybarray_trie* array_ = d_->array_;
	register array_type_  b = array_[node_pos].base;
	register array_u_type_ p;
	u1 buf[3];
	u1 buf_size = 0;
	for (register size_t i = 0; i < len; ++i) {
		p = b +(node_u_type_)(key[i]) + 1;
		if (static_cast<array_u_type_>(b) == array_[p].check)
			b = array_[p].base;
		else
			return -1;
	}

	p = b;
	array_type_ n = array_[p].base;
	if (static_cast<array_u_type_>(b) == array_[p].check && n < 0)
		set_result(result, -n-1, (u1)len, p);
	if(result.dict_id)
		return result.dict_id;
	return -1;
};

const char* SynonymsDict::maxMatch(const char* key, int &len)
{
	if(!array_)
		return NULL;

	if (!len) len = strlen(key);
	
	Result result;
	set_result(result, -1, 0);

	register array_type_  b   = array_[0].base; //node_pos = 0;
	register size_t     num = 0;
	register array_type_  n;
	register array_u_type_ p;

	for (register size_t i = 0; i < len; ++i) {
		p = b;  // + 0;
		n = array_[p].base;
		if ((array_u_type_) b == array_[p].check && n < 0) {
			// result[num] = -n-1;
			//found a sub word
			//if (num < result_len) set_result(result[num], -n-1, i , p);
			set_result(result, -n-1, i , p);
			++num;
		}

		p = b +(node_u_type_)(key[i]) + 1;
		if ((array_u_type_) b == array_[p].check)
			b = array_[p].base;
		else{
			//found a mismatch
			//return num;
			goto DO_RESULT;
		}
	}

	p = b;
	n = array_[p].base;
	//total-string match.
	if ((array_u_type_)b == array_[p].check && n < 0) {
		//if (num < result_len) set_result(result[num], -n-1, len, p);
		set_result(result, -n-1, len , p);
		++num;
	}

DO_RESULT:
	if(num && result.dict_id){
		len = result.length;
		size_t offset = array_[result.dict_id].offset;
		return &string_pool[offset];
	}
	return NULL;
}

const char* SynonymsDict::exactMatch(const char* key, int aLen )
{
	size_t len = aLen?aLen:strlen(key);
	size_t node_pos = 0;
	Result result;
	set_result(result, -1, 0);

	//_csr_sybarray_trie* array_ = d_->array_;
	register array_type_  b = array_[node_pos].base;
	register array_u_type_ p;
	u1 buf[3];
	u1 buf_size = 0;
	for (register size_t i = 0; i < len; ++i) {
		p = b +(node_u_type_)(key[i]) + 1;
		if (static_cast<array_u_type_>(b) == array_[p].check)
			b = array_[p].base;
		else
			return NULL; //not found
	}

	p = b;
	array_type_ n = array_[p].base;
	if (static_cast<array_u_type_>(b) == array_[p].check && n < 0)
		set_result(result, -n-1, (u1)len, p);
	if(result.dict_id){
		size_t offset = array_[result.dict_id].offset;
		return &string_pool[offset];
		//return result.dict_id;
	}

	return NULL;
}


} /* End of namespace css */

