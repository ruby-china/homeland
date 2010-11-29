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

#ifndef css_SynonymsDict_h
#define css_SynonymsDict_h

#include <string>
#include <map>
#include "darts.h"
#include "csr_mmap.h"

namespace css {

	typedef struct _csr_sybarray_trie_tag{
		i4	base;
		u4	check;
		//u4  flag; //used to tell how may features. only low-4bit used now.
		size_t offset; //the base offset.
	}_csr_sybarray_trie;

    /** 
     *  How to find item fast is a real problem here.
     *  @return the string(utf-8,encoded) of the id.
     */
class SynonymsDict {

 public:
	typedef Darts::DoubleArray::result_pair_type result_pair_type;
	typedef struct _tag_result_pair_type {
		i4	value;
		u1	length;
		i4	dict_id;
	}Result;

 public:
	 SynonymsDict():m_file(NULL),array_(NULL){
		 string_pool = NULL;
	 };
	 virtual ~SynonymsDict(){
		 if(m_file){
			 csr_munmap_file(m_file);
		 }
	 }

    virtual int load(const char* filename);

    virtual int import(const char* filename);

    virtual int save(const char* filename);

    virtual const char* exactMatch(const char* key, int len = 0);
	virtual const char* maxMatch(const char* key, int &len);

protected:
	_csr_mmap_t* m_file;
	Darts::DoubleArray m_da;
	std::map<std::string, size_t> rKeys;
	//std::set<std::string, size_t> rKeys;
	std::map<std::string, size_t> lKeys;

	size_t m_string_pool_size;
	_csr_sybarray_trie * array_;
	const char* string_pool;

	typedef i4	array_type_;
	typedef u4	array_u_type_;
	typedef u1	node_u_type_; 
	
	inline void set_result(Result& x, i4 r, u1 l) {
		x.value = r;
		x.length = l;
		x.dict_id = 0;
	}
	inline void set_result(Result& x, i4 r, u1 l,i4 id) {
		x.value = r;
		x.length = l;
		x.dict_id = id;
	}

protected:
	int exactMatchID(const char* key);
};

} /* End of namespace css */
#endif

